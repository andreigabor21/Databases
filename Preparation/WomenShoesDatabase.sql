CREATE DATABASE WomenShoesModel;

USE WomenShoesModel;

CREATE TABLE PresentationShop(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	city VARCHAR(20)
);

CREATE TABLE Women(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	max_amount INT
);

CREATE TABLE Shoes(
	id INT PRIMARY KEY IDENTITY(1,1),
	price INT,
	model_id INT REFERENCES ShoeModel(id)
);

CREATE TABLE ShoeModel(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	season VARCHAR(15)
);

CREATE TABLE Stocks(
	id INT PRIMARY KEY IDENTITY(1,1),
	shop_id INT REFERENCES PresentationShop(id),
	shoe_id INT REFERENCES Shoes(id),
	count_available INT
);

CREATE TABLE Transactions(
	tid INT PRIMARY KEY IDENTITY(1,1),
	women_id INT REFERENCES Women(id),
	shoe_id INT REFERENCES Shoes(id),
	shoes_count INT,
	amount_spent INT
);

INSERT INTO ShoeModel VALUES ('high','autumn'), ('low','summer'); 
INSERT INTO Shoes VALUES (150, 1), (200,2);

INSERT INTO PresentationShop VALUES('asdf','cluj'),('qwer','bucuresti');


--2) Stored procedure that receives a shoe, a presentation shop and
-- the number of shoes and adds the shoe to the presentation shop

GO
CREATE OR ALTER PROCEDURE usp_addToShop
(@shoe_id INT, @ps_id INT, @count INT)
AS
	INSERT INTO Stocks
	VALUES (@ps_id, @shoe_id, @count)
GO

EXEC usp_addToShop 1,1,5;
EXEC usp_addToShop 2,2,10;
EXEC usp_addToShop 1,2,6;

SELECT * FROM Stocks;

--3) View that shows the women that bought at least 2 shoes
-- from a given shoe model

INSERT INTO Women VALUES ('Andreea',500), ('Lavinia',600);

INSERT INTO Transactions VALUES(1,1,3,300);
INSERT INTO Transactions VALUES(2,2,1,100);
INSERT INTO Transactions VALUES(2,1,1,120);

SELECT * FROM Women;
SELECT * FROM Transactions;

GO
CREATE OR ALTER VIEW atLeastTwoShoes
AS
	SELECT W.name
	FROM Women W
	WHERE W.id IN (SELECT T.women_id
					FROM Transactions T
					INNER JOIN Shoes S 
						ON T.shoe_id = S.id
					WHERE S.model_id = 1
					GROUP BY T.women_id
					HAVING SUM(T.shoes_count) >= 2)
GO

SELECT * FROM atLeastTwoShoes;

--4) Function that list the shoes that can be found in at least T
-- presentation shops

GO
CREATE OR ALTER FUNCTION ufn_TShops(@T INT)
RETURNS TABLE
AS
	RETURN
	SELECT *
	FROM Shoes Sh
	WHERE Sh.id IN(
		SELECT St.shoe_id
		FROM Stocks St
		GROUP BY St.shoe_id
		HAVING COUNT(*) >= @T)
GO

SELECT * FROM ufn_TShops(1);

SELECT * FROM ufn_TShops(2);