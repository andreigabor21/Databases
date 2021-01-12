CREATE DATABASE DronesModel;

USE DronesModel;

CREATE TABLE Manufacturers(
	ManufacturerId INT PRIMARY KEY,
	MName VARCHAR(30)
);

CREATE TABLE Models(
	ModelId INT PRIMARY KEY,
	MName VARCHAR(30),
	MBaterry INT,
	MSpeed INT,
	ManufacterId INT REFERENCES Manufacturers(ManufacturerId)
);

CREATE TABLE Drones(
	DroneId INT PRIMARY KEY,
	DSerialNumber VARCHAR(60) UNIQUE,
	ModelId INT REFERENCES Models(ModelId)
);

CREATE TABLE Customers(
	CustomerId INT PRIMARY KEY,
	CName VARCHAR(30),
	CScore INT
);

CREATE TABLE PizzaShops(
	PizzaShopId INT PRIMARY KEY,
	PName VARCHAR(30),
	PAddress VARCHAR(30)
);

CREATE TABLE Deliveries(
	DeliveryId INT PRIMARY KEY IDENTITY(1,1),
	PizzaShopId INT REFERENCES PizzaShops(PizzaShopId),
	CustomerId INT REFERENCES Customers(CustomerId),
	DroneId INT REFERENCES Drones(DroneId),
	DDateTime DATETIME
);

--b)

GO
CREATE OR ALTER PROCEDURE uspAddDelivery
(@CustomerName VARCHAR(30), @PizzaShopName VARCHAR(30), @DSerialNumber VARCHAR(60), @DDateTime DATETIME)
AS
	DECLARE @CID INT, @PID INT, @DID INT

	IF NOT EXISTS(SELECT * FROM Customers c WHERE c.CName=@CustomerName)
	BEGIN
		RAISERROR('Invalid customer name',16,1)
		RETURN
	END
	
	IF NOT EXISTS(SELECT * FROM PizzaShops p WHERE p.PName=@PizzaShopName)
	BEGIN
		RAISERROR('Invalid pizza shop name',16,1)
		RETURN
	END
	IF NOT EXISTS(SELECT * FROM Drones d WHERE d.DSerialNumber=@DSerialNumber)
	BEGIN
		RAISERROR('Invalid serial number name',16,1)
		RETURN
	END

	SELECT @CID = (SELECT CustomerId FROM Customers WHERE CName=@CustomerName)
	SELECT @PID = (SELECT PizzaShopId FROM PizzaShops WHERE PName=@PizzaShopName)
	SELECT @CID = (SELECT DroneId FROM Drones WHERE DSerialNumber=@DSerialNumber)

	INSERT INTO Deliveries
	VALUES (@PID,@CID,@DID,@DDateTime)
GO

SELECT * FROM Deliveries

SELECT * FROM Manufacturers;
INSERT INTO Manufacturers VALUES (1,'man1'),(2,'man2'),(3,'man3')

SELECT * FROM Models;
INSERT INTO Models VALUES (1,'model1',4,6,1),(2,'model2',5,9,2),(3,'model3',2,1,3)

SELECT * FROM Drones;
INSERT INTO Drones VALUES (1,'1234',1),(2,'742942',1),(3,'inve',2),(4,'ooeq',2),(5,'mnbu',3)

SELECT * FROM Customers;
INSERT INTO Customers VALUES (1,'c1',5),(2,'c2',9)

SELECT * FROM PizzaShops;
INSERT INTO PizzaShops VALUES (1,'p1','addr1'),(2,'p2','addr2')


EXEC uspAddDelivery 'c1','p1','1234','1-1-2020'

EXEC uspAddDelivery 'c1','p2','inve','1-2-2020'

SELECT * FROM Deliveries;

GO
CREATE OR ALTER VIEW viewFavoriteManufacturer
AS
	SELECT man.MName
    FROM Drones d
    INNER JOIN Models M
        ON D.ModelId = m.ModelId
    INNER JOIN Manufacturers man
        ON man.ManufacturerId = m.ManufacterId
    GROUP BY man.MName
	HAVING COUNT(*)= (
		SELECT MAX(counts) as max_val
		FROM(
			SELECT COUNT(*) as counts
			FROM Drones d
			INNER JOIN Models M
				ON D.ModelId = m.ModelId
			INNER JOIN Manufacturers man
				ON man.ManufacturerId = m.ManufacterId
			GROUP BY man.ManufacturerId
		) t
	)
GO


GO
CREATE OR ALTER FUNCTION ufnCustomersDeliveries(@D INT)
RETURNS TABLE
AS
RETURN 
SELECT c.CName
FROM Customers c
WHERE c.CustomerId IN(SELECT d.CustomerId
					  FROM Deliveries d
					  GROUP BY d.CustomerId
					  HAVING COUNT(*)>=@D)
GO

SELECT * FROM ufnCustomersDeliveries(1);