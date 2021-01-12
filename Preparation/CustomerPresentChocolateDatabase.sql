DROP TABLE IF EXISTS Contain
DROP TABLE IF EXISTS Chocolate
DROP TABLE IF EXISTS Present
DROP TABLE IF EXISTS Customer
DROP TABLE IF EXISTS PType



CREATE TABLE Customer(
	cuid INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR(30),
	dob DATE
)

CREATE TABLE PType(
	ptid INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR(30)
)

CREATE TABLE Present(
	pid INT PRIMARY KEY IDENTITY(1, 1),
	color VARCHAR(30),
	w FLOAT,
	ptid INT REFERENCES PType(ptid),
	cuid INT REFERENCES Customer(cuid)
)

CREATE TABLE Chocolate(
	cid INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR (30),
	price INT
)

CREATE TABLE Contain(
	cid INT REFERENCES Chocolate(cid),
	ptid INT REFERENCES PType(ptid),
	quantity INT,
	PRIMARY KEY (cid, ptid)
)

INSERT INTO Customer VALUES ('Ion', '2015-02-01'),
('Vasile', '2011-02-01'),
('Pavel', '2015-03-02'),
('Andrei', '2012-02-01')

INSERT INTO PType VALUES ('P1'), ('P2'), ('P3')

INSERT INTO Chocolate (name, price) VALUES ('mars', 3), ('sneakers', 1), ('twix', 2)

INSERT INTO Present (color, w, cuid, ptid) VALUES ('blue',20, 3, 1),
('blue', 10, 3, 1),
('blue',11, 2, 2),
('orange',3, 1, 1),
('black', 42, 3, 3)

INSERT INTO Contain VALUES (1, 1, 2), (1, 2, 1), (1, 3, 3), (2, 1, 2), (3, 1, 2)

SELECT * FROM Customer
SELECT * FROM Chocolate
SELECT * FROM Contain
SELECT * FROM Present
SELECT * FROM PType

GO

CREATE OR ALTER PROC addChoco @ChocoId INT, @PresentId INT, @Quantity INT
AS
	DECLARE @cid INT = (SELECT cid FROM Chocolate WHERE cid = @ChocoId),
			@ptid INT = (SELECT ptid FROM PType WHERE ptid = @PresentId)

	IF @cid IS NULL OR @ptid IS NULL
		RAISERROR ('Chocolate/Present Type don''t exist', 16, 1)
	ELSE IF EXISTS (SELECT * FROM Contain WHERE ptid = @ptid AND cid = @cid)
		RAISERROR ('Chocolate already in the present', 16, 1)
	ELSE 
		INSERT INTO Contain VALUES (@cid, @ptid, @Quantity)
GO

addChoco 2, 2, 3 -- change first 2 with 1 to see the exception

SELECT * FROM Contain

GO

CREATE OR ALTER VIEW customersWith3Presents AS
SELECT C.name 
FROM Customer C
WHERE EXISTS (SELECT * FROM Present P
			  WHERE P.cuid = C.cuid
			  GROUP BY P.cuid
			  HAVING COUNT(*) = 3)
GO

SELECT * FROM customersWith3Presents
GO
CREATE OR ALTER FUNCTION getPresentsWithAllChoco ()
RETURNS TABLE
RETURN
	SELECT P.pid, P.color
	FROM Present P
	WHERE P.ptid IN (SELECT C.ptid 
					FROM Contain C
				    GROUP BY C.ptid
				    HAVING COUNT(*) = (SELECT COUNT(cid) FROM Chocolate)
				  )

GO

SELECT * FROM getPresentsWithAllChoco()