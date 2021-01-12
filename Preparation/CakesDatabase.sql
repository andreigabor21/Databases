CREATE DATABASE CakeModel;
USE CakeModel;

CREATE TABLE Chef(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(40),
	gender CHAR(1),
	dob DATE
);

CREATE TABLE Specializations(
	chef_id INT REFERENCES Chef(id),
	cake_id INT REFERENCES Cake(id),
	PRIMARY KEY (chef_id, cake_id)
)

CREATE TABLE Cake(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	shape VARCHAR(30),
	weight INT,
	price INT,
	type_id INT REFERENCES CakeType(id)
);

CREATE TABLE CakeType(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(20),
	description VARCHAR(50)
);

CREATE TABLE Orders(
	id INT PRIMARY KEY IDENTITY(1,1),
	order_date DATE
)

CREATE TABLE CakesOnOrder(
	id INT PRIMARY KEY IDENTITY(1,1),
	order_id INT REFERENCES Orders(id),
	cake_id INT REFERENCES Cake(id),
	quantity INT
)

SELECT * FROM Chef;
INSERT INTO Chef VALUES ('Andrei', 'M', '1990-05-06'),('Lavinia','F','1996-08-20'),('Scarlatescu','M','1978-10-10');

SELECT * FROM CakeType;
INSERT INTO CakeType VALUES ('chocolate','good'),('with vanilla','medium'),('cherry','the best');

SELECT * FROM Cake;
INSERT INTO Cake VALUES ('qwer','square',2,100,1),('asdf','triangle',3,200,2),('dfgh','square',4,87,1);

SELECT * FROM Specializations;
INSERT INTO Specializations VALUES (1,1),(1,2),(2,2),(3,3);

SELECT * FROM Orders;
INSERT INTO Orders VALUES ('2020-12-22'), ('2020-12-18'), ('2020-11-21');

SELECT * FROM CakesOnOrder;
INSERT INTO CakesOnOrder VALUES(1,1,2), (2,2,3), (3,3,8);

--2) sp that receives an order ID, a cake name and a positive number P
-- repr the number of ordered pieces, and adds the cake to the order.
-- if the cake is already on the order, the number of ordered pieces
-- is set to P

GO
CREATE OR ALTER PROCEDURE usp_orderCakes
(@order_id INT, @cake_name VARCHAR(30), @P INT)
AS
	DECLARE @ord INT = (SELECT o.id
				FROM Orders o
				WHERE o.id = @order_id);
	IF @ord IS NULL
	BEGIN
		print 'No such order id!'
		RETURN
	END

	DECLARE @cake_id INT = (SELECT c.id
							FROM Cake c
							WHERE c.name = @cake_name);
	IF @cake_id IS NULL
	BEGIN
		print 'No such cake!'
		RETURN
	END

	IF EXISTS (SELECT * FROM CakesOnOrder co 
				WHERE co.cake_id = @cake_id AND co.order_id = @order_id)
		BEGIN
			UPDATE CakesOnOrder
			SET CakesOnOrder.quantity = @P
			WHERE cake_id = @cake_id AND order_id = @order_id
		END
	ELSE
		BEGIN
			INSERT INTO CakesOnOrder
			VALUES (@order_id, @cake_id, @P)
		END
GO

--error
EXEC usp_orderCakes 10,'qw',0;
EXEC usp_orderCakes 1,'poi',2;
--executed
EXEC usp_orderCakes 1,'qwer',10;
EXEC usp_orderCakes 2, 'dfgh', 5;

INSERT INTO Specializations VALUES(1,3);

--3) Function that list the names of the chefs who are specialized in the
-- preparation of all cakes

GO
CREATE OR ALTER FUNCTION ufn_chefsAllCakes()
RETURNS TABLE
AS
	RETURN 
	
	SELECT ch.name, ch.dob, ch.gender
	FROM Chef ch
	WHERE ch.id IN (
		SELECT s.chef_id
		FROM Specializations s
		INNER JOIN Chef c
			ON s.chef_id = c.id
		GROUP BY s.chef_id
		HAVING COUNT(*) = (SELECT COUNT(*)
							FROM Cake) )   

	/*
	SELECT ch.name
	FROM Chef ch
	INNER JOIN
		(SELECT s.chef_id
		FROM Specializations s
		GROUP BY s.chef_id
		HAVING COUNT(*) = (SELECT COUNT(*) FROM Cake)
		) AS SpecializedChefs
	ON ch.id = SpecializedChefs.chef_id  */

GO

SELECT * FROM ufn_chefsAllCakes();