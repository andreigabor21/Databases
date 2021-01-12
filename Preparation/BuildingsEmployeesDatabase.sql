

CREATE TABLE Cities
(
	CID INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR(50),
	year VARCHAR(4),
	nrOfPeople INT
)


CREATE TABLE Buildings
(
	BID INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR(50),
	weight INT,
	height INT,
	duration INT,
	CID INT REFERENCES Cities(CID)
	AID INT REFERENCES Arhitects(AID)
)


CREATE TABLE Arhitects
(
	AID INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR(50),
	surname VARCHAR(50),
	dateOfBirth DATE,
	numberOfDesigned INT
)

CREATE TABLE Employees
(
	EID INT PRIMARY KEY IDENTITY(1, 1),
	name VARCHAR(50),
	experience INT,
	numberOfHours INT
)

CREATE TABLE BuildingsEmployees
(
	EID INT REFERENCES Employees(EID),
	BID INT REFERENCES Buildings(BID),
	dateOfFinalization DATE,
	amountPerMonth INT,
	PRIMARY KEY(EID, BID)
)

INSERT INTO Cities(name, year, nrOfPeople) VALUES
('Paris', '1900', 2000),
('Rome', '100', 3000),
('London', '1500', 10000)

INSERT INTO Employees(name, experience, numberOfHours) VALUES
('Name 1', 10, 100),
('Name 2', 20, 200),
('Name 3', 30, 300),
('Name 4', 40, 400)

INSERT INTO Arhitects(name, surname, dateOfBirth, numberOfDesigned) VALUES
('Name 1', 'Surname 1', '1990-10-01', 4),
('Name 2', 'Surname 2', '1991-10-01', 20),
('Name 3', 'Surname 3', '1992-10-01', 30),
('Name 4', 'Surname 4', '1993-10-01', 40)

INSERT INTO Buildings(name, weight, height, duration, CID, AID) VALUES
('Tour Eiffel', 100, 100, 200, 1, 1),
('Notre Dame', 100, 100, 200, 1, 2),
('Jardin au Luxemburg', 100, 100, 200, 1, 2),
('Colosseum', 100, 100, 200, 2, 2),
('St Peters Church', 100, 100, 200, 2, 2),
('Big Ben', 100, 100, 200, 3, 2),
('London Eye', 100, 100, 200, 3, 2)

INSERT INTO BuildingsEmployees(EID, BID, dateOfFinalization, amountPerMonth) VALUES
(1,1, '2018-01-03', 500),
(2,1, '2018-01-03', 500),
(1,2, '2018-01-03', 500),
(3,2, '2018-01-03', 500)



--2
ALTER PROC insertOrUpdateBuildingEmployee
	@BID INT,
	@EID INT,
	@dateOfFinalization DATE,
	@amountPerMonth INT
AS
BEGIN
	IF EXISTS (SELECT * FROM BuildingsEmployees WHERE BID = @BID AND EID = @EID)
		UPDATE BuildingsEmployees
		SET dateOfFinalization = @dateOfFinalization, amountPerMonth = @amountPerMonth
		WHERE BID = @BID AND EID = @EID
	ELSE
		INSERT BuildingsEmployees(EID, BID, dateOfFinalization, amountPerMonth) VALUES
		(@EID, @BID, @dateOfFinalization, @amountPerMonth)
END

EXEC insertOrUpdateBuildingEmployee 1, 1, '2050-01-03', 1000
EXEC insertOrUpdateBuildingEmployee 1, 3, '2099-01-03',555

SELECT * FROM BuildingsEmployees

-----------------
ALTER VIEW arhitectsWithMoreThan5
AS
	SELECT * FROM Arhitects
	WHERE Arhitects.numberOfDesigned >= 5

GO

SELECT * FROM arhitectsWithMoreThan5

------------------------------

ALTER FUNCTION lazyEmployees()
RETURNS TABLE
AS
	RETURN SELECT E.name as EName FROM Employees E
		WHERE E.EID NOT IN(SELECT DISTINCT EID FROM BuildingsEmployees)

GO

SELECT * FROM lazyEmployees()