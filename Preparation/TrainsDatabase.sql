CREATE DATABASE TrainsModel;

USE TrainsModel;

DROP TABLE Trains;
DROP TABLE TrainTypes;
DROP TABLE Stations;
DROP TABLE Routes;

--1)
CREATE TABLE Trains(
	trainId INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	trainTypeId INT REFERENCES TrainTypes(trainTypeId)
);

CREATE TABLE TrainTypes(
	trainTypeId INT PRIMARY KEY IDENTITY(1,1),
	description VARCHAR(50)
);

CREATE TABLE Stations(
	stationId INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30) UNIQUE
);

CREATE TABLE Routes(
	routeId INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30) UNIQUE,
	trainId INT REFERENCES Trains(trainId)
);

CREATE TABLE RoutesStations(
	routeId INT REFERENCES Routes(routeId),
	stationId INT REFERENCES Stations(stationId),
	arrival TIME,
	departure TIME,
	PRIMARY KEY(routeId, stationId)
);

SELECT * FROM Trains;

--2)
GO
CREATE OR ALTER PROCEDURE uspInsertStation 
@route VARCHAR(30), @station VARCHAR(30), @arrival TIME, @departure TIME
AS
	DECLARE @routeId INT = (SELECT r.routeId
							FROM Routes r
							WHERE r.name = @route)
	DECLARE @stationId INT = (SELECT s.stationId
							FROM Stations s
							WHERE s.name = @station)
	IF @routeId IS NULL OR @stationId IS NULL
	BEGIN
		RAISERROR('No such Route or Station', 16, 1)
	END

	IF NOT EXISTS(SELECT * 
					FROM RoutesStations rs
					WHERE rs.routeId = @routeId AND rs.stationId = @stationId) 
		INSERT INTO RoutesStations VALUES(@routeId, @stationId, @arrival, @departure)
	ELSE
		UPDATE RoutesStations
		SET arrival = @arrival, departure = @departure
		WHERE stationId = @stationId
GO

INSERT INTO Stations VALUES('asd'), ('qwer'), ('cluj');
SELECT * FROM Stations;

INSERT INTO TrainTypes VALUES('electric');
INSERT INTO Trains VALUES ('tren 1', 1);
INSERT INTO Trains VALUES ('tren 2', 1);
INSERT INTO Routes VALUES ('Cluj-Brasov', 1);
INSERT INTO Routes VALUES ('Timisoara-Bucuresti', 2);

SELECT * FROM Routes;

EXEC uspInsertStation @route = 'Cluj-Brasov', @station = 'asd', @arrival = '10:15', @departure = '12:08'

EXEC uspInsertStation @route = 'Cluj-Brasov', @station = 'asd', @arrival = '10:17', @departure = '12:08'

EXEC uspInsertStation @route = 'Timisoara-Bucuresti', @station = 'qwer', @arrival = '10:17', @departure = '12:08'

EXEC uspInsertStation @route = 'Cluj-Brasov', @station = 'qwer', @arrival = '10:20', @departure = '12:35'


SELECT * FROM RoutesStations;

--3)
GO
CREATE OR ALTER VIEW StationsView AS
SELECT r.name 
FROM Routes r 
WHERE r.routeId NOT IN (SELECT r1.routeId
						FROM Routes r1
						EXCEPT 
						SELECT rs.routeId
						FROM RoutesStations rs)
GO

SELECT * FROM StationsView;

--4)

GO
CREATE OR ALTER FUNCTION ufnStationsCount (@count INT)
RETURNS TABLE
AS
RETURN 
(
	SELECT s.name
	FROM Stations s
	WHERE s.stationId IN (SELECT rs.stationId
						  FROM RoutesStations rs
						  GROUP BY RS.stationId
						  HAVING COUNT(*) > @count)
)
GO

SELECT * FROM ufnStationsCount(1)