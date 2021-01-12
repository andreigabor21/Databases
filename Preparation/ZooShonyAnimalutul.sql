CREATE DATABASE ZooShonyAnimalutul;

USE ZooShonyAnimalutul;

CREATE TABLE Zoos(
	zooId INT PRIMARY KEY IDENTITY(1,1),
	administrator VARCHAR(30),
	zooName VARCHAR(40)
);

CREATE TABLE Animals(
	animalId INT PRIMARY KEY IDENTITY(1,1),
	animalName VARCHAR(30),
	dob DATE,
	zooId INT REFERENCES Zoos(zooId)
);

CREATE TABLE Food(
	foodId INT PRIMARY KEY IDENTITY(1,1),
	foodName VARCHAR(30)
);

CREATE TABLE Quota(
	quotaId INT PRIMARY KEY IDENTITY(1,1),
	animalId INT REFERENCES Animals(animalId),
	foodId INT REFERENCES Food(foodId),
	quota INT
);

CREATE TABLE Visitors(
	visitorId INT PRIMARY KEY IDENTITY(1,1),
	visitorName VARCHAR(40),
	visitorAge INT
);

CREATE TABLE Visits(
	visitId INT PRIMARY KEY IDENTITY(1,1),
	visitorId INT REFERENCES Visitors(visitorId),
	zooId INT REFERENCES Zoos(zooId),
	visitDay INT CHECK (visitDay >=1 AND visitDay <= 7),
	visitPrice INT
);

--2)

GO
CREATE OR ALTER PROCEDURE uspDeleteFromQuota(@animalId INT)
AS
IF NOT EXISTS(SELECT *
			  FROM Animals a
 			  WHERE a.animalId = @animalId)
BEGIN
	RAISERROR('No such animalutz',16,1)
	RETURN
END

DELETE 
FROM Quota
WHERE animalId=@animalId
GO

--3)

GO
CREATE OR ALTER VIEW viewSmallest
AS
	SELECT Visits.zooId
	FROM Visits
	GROUP BY zooId
	HAVING COUNT(*) IN (
		SELECT MIN(t.counts)
		FROM (
			SELECT COUNT(*) AS counts
			FROM Visits
			GROUP BY zooId) t )
GO

--4)

CREATE OR ALTER FUNCTION ufnVisitorAll(@N INT)
RETURNS TABLE
AS
RETURN 

SELECT *
FROM Visits v
WHERE
zooId IN (
	SELECT zooId
	FROM Animals
	GROUP BY zooId
	HAVING COUNT(*) >= 1)--@N )




