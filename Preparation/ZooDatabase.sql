CREATE DATABASE ZooModel

USE ZooModel;

CREATE TABLE Zoo(
	id INT PRIMARY KEY IDENTITY(1,1),
	administrator VARCHAR(30),
	name VARCHAR(40),
);

CREATE TABLE Animal(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	dob DATE,
	zoo_id INT REFERENCES Zoo(id)
);

CREATE TABLE Food(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(25)
);

CREATE TABLE DailyQuota(
	id INT PRIMARY KEY IDENTITY(1,1),
	animal_id INT REFERENCES Animal(id),
	food_id INT REFERENCES Food(id),
	quantity INT
);

CREATE TABLE Visitor(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(40),
	age TINYINT
);

CREATE TABLE Visit(
	id INT PRIMARY KEY IDENTITY(1,1),
	zoo_id INT REFERENCES Zoo(id),
	visitor_id INT REFERENCES Visitor(id),
	day DATE,
	paid_price SMALLINT
);

SELECT * FROM Zoo;
INSERT INTO Zoo VALUES('admin1','zoo1'), ('admin2','zoo2');

SELECT * FROM Animal;
INSERT INTO Animal VALUES ('tiger','2017-03-10',1),
							('elephant','2014-10-10',2),
							('monkey','2018-11-11',1);

SELECT * FROM Food;
INSERT INTO Food VALUES ('banana'),('meat'),('water');

SELECT * FROM DailyQuota;
INSERT INTO DailyQuota VALUES (1,2,5), (2,3,10), (3,1,2);

SELECT * FROM Visitor;
INSERT INTO Visitor VALUES ('v1', 19), ('v2',20), ('v3',30), ('v4', 25);

SELECT * FROM Visit;
INSERT INTO Visit VALUES (1, 1, '2020-10-10', 20),
							(1, 2, '2020-09-09', 25),
							(2, 3, '2020-10-16', 20);
--2) Stored procedure that receives an animal and deletes all the data
-- about the food quotas for the animal

GO
CREATE OR ALTER PROCEDURE usp_deleteFood(@animal_id INT)
AS
	IF EXISTS (SELECT *
				FROM DailyQuota d
				WHERE d.animal_id = @animal_id )
		BEGIN
			DELETE
			FROM DailyQuota
			WHERE animal_id = @animal_id 
		END
	ELSE
		BEGIN
			PRINT 'No such entry!'
			RETURN
		END
GO

EXEC usp_deleteFood 1;


--3) View that shows the ids of the zoos with the smallest nr of visitors

GO
CREATE OR ALTER VIEW view_smallestCountVisitors
AS
	SELECT t1.zoo_id
	FROM (SELECT v.zoo_id, COUNT(v.zoo_id) MYCOUNT
			FROM Visit v
			GROUP BY v.zoo_id) t1
	WHERE t1.MYCOUNT IN (
		SELECT MIN(t2.MYCOUNT)
		FROM (SELECT v.zoo_id, COUNT(v.zoo_id) MYCOUNT
				FROM Visit v
				GROUP BY v.zoo_id) t2
		);
GO

SELECT * FROM view_smallestCountVisitors;

--3) Function that lists the ids of he visitors who went to the zoos
-- that have at least N animals

GO
CREATE FUNCTION ufn_visitorsN (@N INT)
RETURNS TABLE
AS
RETURN 
	SELECT v.visitor_id
	FROM Visit v
	WHERE v.zoo_id IN (
		SELECT a.zoo_id
		FROM Animal a
		GROUP BY a.zoo_id
		HAVING COUNT(*) >= @N
		)
		
GO

SELECT * FROM ufn_visitorsN(1);
SELECT * FROM ufn_visitorsN(2);