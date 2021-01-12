USE BankModel;

--1)
CREATE TABLE ATM(
	id INT PRIMARY KEY IDENTITY(1,1),
	address VARCHAR(40)
);

CREATE TABLE Customer(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(40),
	dob DATE,
	--bank accounts
)

CREATE TABLE BankAccount(
	account_id INT PRIMARY KEY IDENTITY(1,1),
	IBAN VARCHAR(20),
	balance INT,
	holder_id INT REFERENCES Customer(id),
	--cards associated
);

CREATE TABLE Cards(
	card_id INT PRIMARY KEY IDENTITY(1,1),
	number VARCHAR(25),
	CVV CHAR(3),
	bankAccount_id INT REFERENCES BankAccount(account_id)
);

CREATE TABLE Transactions(
	transaction_id INT PRIMARY KEY IDENTITY(1,1),
	ATM_id INT REFERENCES ATM(id),
	card_number INT REFERENCES Cards(card_id),
	sum_money INT,
	transaction_time DATETIME
)

INSERT INTO ATM VALUES ('Cluj, Str.Republicii'), ('Huedin');
INSERT INTO Customer VALUES ('Andrei', '2000-05-21'), ('Cristi', '2001-03-29');
INSERT INTO BankAccount VALUES('1234567',200,2), ('5678910',150,3);
INSERT INTO Cards VALUES('123456789','789',2), ('98765432','432',3);
INSERT INTO Transactions VALUES(1,1,30,'2020-09-20 14:25');
INSERT INTO Transactions VALUES(1,2,40,'2020-10-25 14:25');
INSERT INTO Transactions VALUES(2,1,50,'2020-11-24 14:25');


SELECT * FROM Customer;

SELECT * FROM BankAccount;

SELECT * FROM Cards;

SELECT * FROM ATM;

SELECT * FROM Transactions;

INSERT INTO Transactions VALUES(2,2,30,'2020-10-10 14:14');
INSERT INTO Transactions VALUES(1,1,45,'2020-10-10 14:14');

--2)
--sp receives a card and deletes all the transactions related
--to that card

GO
CREATE OR ALTER PROCEDURE usp_deleteTransactions
@card_number VARCHAR(25)
AS
	DECLARE @card_id INT = (SELECT c.card_id
							FROM Cards c
							WHERE c.number = @card_number)
	IF @card_id is NULL 
		RAISERROR('No such card number', 16, 1);
	ELSE
	BEGIN
		DELETE FROM Transactions 
		WHERE card_number = @card_id
	END
GO

EXEC usp_deleteTransactions @card_number = '123456789';

--3)
--View that shows the card numbers which were used in
--transactions at all ATMs

SELECT * FROM Transactions;

SELECT * FROM Cards;

SELECT *
FROM ATM;

GO
CREATE OR ALTER VIEW cardNumbersView AS
SELECT C.number
FROM Cards C
WHERE C.card_id IN(
	SELECT T.card_number
	FROM Cards C
	INNER JOIN Transactions T 
		ON T.card_number = C.card_id
	GROUP BY T.card_number
	HAVING COUNT(T.ATM_id) = (SELECT COUNT(*) FROM ATM)
)
GO

SELECT * FROM cardNumbersView;

--4)
--functions that lists the cards(number and CVV) that have a total transactions
--sum greater than 2000 lei

GO
CREATE OR ALTER FUNCTION ufn_CardsTotal (@sum INT)
RETURNS TABLE
AS
RETURN
(
	SELECT C.number, C.CVV
	FROM Transactions T INNER JOIN Cards C ON C.card_id = T.card_number
	GROUP BY C.number, C.CVV
	HAVING SUM(sum_money) > @sum
)
GO

SELECT * FROM ufn_CardsTotal(44);