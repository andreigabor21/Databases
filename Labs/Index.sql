CREATE DATABASE Lab5;
USE Lab5;

CREATE TABLE Ta (
	aid INTEGER PRIMARY KEY IDENTITY(1, 1),
	a2 INTEGER UNIQUE,
	a3 VARCHAR(20)
)

CREATE TABLE Tb (
	bid INTEGER PRIMARY KEY IDENTITY(1, 1),
	b2 INTEGER
)

CREATE TABLE Tc (
	cid INTEGER PRIMARY KEY IDENTITY(1, 1),
	aid INTEGER FOREIGN KEY REFERENCES Ta(aid),
	bid INTEGER FOREIGN KEY REFERENCES Tb(bid),
	c1 VARCHAR(30)
)

INSERT INTO Ta VALUES (1, 'AB'), (2, 'CDE'), (5, 'ASD'), (10, 'QWER'), (20, 'RTY');

INSERT INTO Tb VALUES (1), (2) , (3), (7), (20), (-6);

INSERT INTO Tc VALUES (2, 3, 'string6'), (5, 2, 'string7');

SELECT * FROM Tc;

--a. Write queries on Ta such that their execution plans contain the following operators:
--clustered index scan;

SELECT *
FROM Ta;

--clustered index seek;

SELECT *
FROM Ta
WHERE aid BETWEEN 2 AND 10;

--nonclustered index scan + key lookup;

SELECT *
FROM Ta
ORDER BY a2;

--nonclustered index seek;

SELECT a2
FROM Ta
WHERE a2 > 5;


--b. Write a query on table Tb with a WHERE clause of the form WHERE b2 = value and analyze its execution plan. 
--Create a nonclustered index that can speed up the query. Examine the execution plan again.

SELECT *
FROM Tb;

SELECT *
FROM Tb
WHERE b2 = 3;

CREATE NONCLUSTERED INDEX bIndex
ON Tb(b2);

DROP INDEX bIndex ON Tb;

--without nonclustered index -> estimated subtree cost: 0.0032886
--with nonclustered index -> estimated subtree cost: 0.0032831 (index seek)

--c. Create a view that joins at least 2 tables. Check whether existing indexes are helpful; 
--if not, reassess existing indexes / examine the cardinality of the tables.

GO
CREATE OR ALTER VIEW TView AS
	SELECT a3
	FROM Ta 
	INNER JOIN Tb ON Ta.a2 = Tb.b2   --Index seek on nonclustered b2 + index scan on clustered a2
	INNER JOIN Tc ON Ta.aid = Tc.aid;
GO
--7 operations wihout index and 5 with it
SELECT * FROM TView;