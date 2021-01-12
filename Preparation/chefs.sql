CREATE DATABASE TortShony;

USE TortShony;

CREATE TABLE Cakes(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	shape VARCHAR(30),
	weight INT,
	price INT,
	typeId INT REFERENCES CakeTypes(id)
);

CREATE TABLE CakeTypes(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	description VARCHAR(100),
);

CREATE TABLE Specialisatios(
	id INT PRIMARY KEY IDENTITY(1,1),
	chef_id INT REFERENCES Chefs(id),
	cake_id INT REFERENCES Cakes(id),
);

CREATE TABLE Chefs(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	gender CHAR(1),
	dob DATE
);

CREATE TABLE Orders(
	id INT PRIMARY KEY IDENTITY(1,1),
	date DATE
);

CREATE TABLE OrderCakes(
	id INT PRIMARY KEY IDENTITY(1,1),
	order_id INT REFERENCES Orders(id),
	cake_id INT REFERENCES Cakes(id),
	pieces INT
);

GO
CREATE OR ALTER PROCEDURE uspOrderCake
@order_id INT, @cake_name VARCHAR(30), @P INT
AS
	DECLARE @cake_id INT = (SELECT c.id
						FROM Cakes c
						WHERE c.name=@cake_name)
	IF EXISTS (SELECT *
			   FROM OrderCakes o
			   WHERE o.order_id=@order_id AND o.cake_id=@cake_id)
	BEGIN
		UPDATE OrderCakes
		SET pieces=@P
		WHERE order_id=@order_id AND cake_id=@cake_id
	END
	ELSE
		INSERT INTO OrderCakes
		VALUES (@order_id, @cake_id, @P)
GO

GO
CREATE OR ALTER FUNCTION ufnGetChefs()
RETURNS TABLE
AS
RETURN
SELECT c.name
FROM Chefs c
WHERE NOT EXISTS (
	SELECT c2.id
	FROM Chefs c2
	EXCEPT
	SELECT s.chef_id
	FROM Specialisatios s
	WHERE s.chef_id=c.id)
GO


