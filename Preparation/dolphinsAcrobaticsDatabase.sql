CREATE DATABASE wealthCenter
GO

IF OBJECT_ID('Shows', 'U') IS NOT NULL
	DROP TABLE Shows

IF OBJECT_ID('FoodTypes', 'U') IS NOT NULL
	DROP TABLE FoodTypes

IF OBJECT_ID('Dolphins', 'U') IS NOT NULL
	DROP TABLE Dolphins

IF OBJECT_ID('Acrobatics', 'U') IS NOT NULL
	DROP TABLE Acrobatics

IF OBJECT_ID('AcrobaticsDolphins', 'U') IS NOT NULL
	DROP TABLE AcrobaticsDolphins

CREATE TABLE Shows(
	ID SMALLINT PRIMARY KEY IDENTITY(1, 1),
	[Name] VARCHAR(30) UNIQUE, 
	Duration TIME
	)

CREATE TABLE FoodTypes(
	ID SMALLINT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(30),
	Quantity SMALLINT
	)

CREATE TABLE Dolphins(
	ID SMALLINT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) UNIQUE,
	Age TINYINT,
	SpecialPower VARCHAR(100),
	Show SMALLINT FOREIGN KEY REFERENCES Shows(ID),
	FoodType SMALLINT FOREIGN KEY REFERENCES FoodTypes(ID)
	)

CREATE TABLE Acrobatics(
	ID SMALLINT PRIMARY KEY IDENTITY(1, 1),
	[Name] VARCHAR(30) UNIQUE,
	Difficulty VARCHAR(8)
	)

CREATE TABLE AcrobaticsDolphins(
	Dolphin SMALLINT FOREIGN KEY REFERENCES Dolphins(ID),
	Acrobatic SMALLINT FOREIGN KEY REFERENCES Acrobatics(ID),
	[Time] TIME,
	Price MONEY,
	CONSTRAINT pk_AcrobaticsDolphins PRIMARY KEY(Dolphin, Acrobatic)
	)

INSERT INTO Shows VALUES('Circus', '2:30')
INSERT INTO Shows VALUES('Bazinus', '1:45')
INSERT INTO FoodTypes VALUES('Cereals', 30)
INSERT INTO FoodTypes VALUES('Proteins', 200)

INSERT INTO Dolphins VALUES('Bestus', 20, 'SuperDolphin', 1, 1)
INSERT INTO Dolphins VALUES('Dunno', 13, 'Invisible', 2, 1)

INSERT INTO Acrobatics VALUES('Impressionable', 'hard')
INSERT INTO Acrobatics VALUES('Not so Impressionable', 'easy')

INSERT INTO AcrobaticsDolphins VALUES (1, 1, '5:00', 2000)
INSERT INTO AcrobaticsDolphins VALUES (2, 2, '3:00', 800)

SELECT * FROM AcrobaticsDolphins

DROP PROC IF EXISTS addAcrobaticToDolphin
GO

CREATE PROCEDURE addAcrobaticToDolphin
@Dolphin SMALLINT,
@Acrobatic SMALLINT,
@Time TIME,
@Price MONEY
AS
	IF NOT EXISTS ( SELECT * FROM Dolphins WHERE ID = @Dolphin )
		RAISERROR('Inexistent dolphin', 16, 1)
	ELSE IF NOT EXISTS ( SELECT * FROM Acrobatics WHERE ID = @Acrobatic )
		RAISERROR('Inexistent acrobatic', 16, 1)
	ELSE IF EXISTS ( SELECT * FROM AcrobaticsDolphins WHERE Dolphin = @Dolphin AND Acrobatic = @Acrobatic )
		RAISERROR('The acrobatic already exists for the dolphin', 16, 1)
	ELSE INSERT INTO AcrobaticsDolphins(Dolphin, Acrobatic, [Time], Price)
		VALUES (@Dolphin, @Acrobatic, @Time, @Price)
GO

addAcrobaticToDolphin 3, 1, '2:30', 3000
SELECT * FROM AcrobaticsDolphins

GO

DROP VIEW IF EXISTS AcrobaticsForShow
GO

CREATE VIEW AcrobaticsForShow
AS
	SELECT S.ID as Show, A.ID as Acrobatic
	FROM Dolphins D
	INNER JOIN AcrobaticsDolphins AD ON AD.Dolphin = D.ID
	INNER JOIN Acrobatics A ON A.ID = AD.Acrobatic
	INNER JOIN Shows S ON S.ID = D.Show
	GROUP BY S.ID, A.ID
GO

SELECT * FROM AcrobaticsForShow
GO

CREATE FUNCTION AcrobaticsWithMaxDolphins()
RETURNS TABLE
RETURN
SELECT *
FROM Acrobatics AA
WHERE AA.ID IN(
				SELECT t1.Acrobatic as Acrobatic
				FROM 
					(
					SELECT AD.Acrobatic, COUNT(AD.Acrobatic) as Dolphins
					FROM AcrobaticsDolphins AD
					INNER JOIN Acrobatics A ON AD.Acrobatic = A.ID
					INNER JOIN Dolphins D ON D.ID = AD.Dolphin
					GROUP BY AD.Acrobatic
					) t1
				GROUP BY t1.Acrobatic, t1.Dolphins
				HAVING Dolphins IN (
									SELECT TOP 1 MAX(Dolphins)
									FROM 
										(
										SELECT AD.Acrobatic, COUNT(AD.Acrobatic) as Dolphins
										FROM AcrobaticsDolphins AD
										INNER JOIN Acrobatics A ON AD.Acrobatic = A.ID
										INNER JOIN Dolphins D ON D.ID = AD.Dolphin
										GROUP BY AD.Acrobatic
										) t1
									GROUP BY t1.Acrobatic
									)
				)
GO