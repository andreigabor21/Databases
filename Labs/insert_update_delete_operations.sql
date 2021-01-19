SELECT * FROM CoverType;
SELECT * FROM Category;
SELECT * FROM Languages;
SELECT * FROM PublishingHouse;
SELECT * FROM Books;
SELECT * FROM Votes;
SELECT * FROM ClientsGroups;
SELECT * FROM Client;
SELECT * FROM Loans;
SELECT * FROM Debtors;


--insert data – for at least 4 tables; at least one statement should violate referential integrity constraints;
INSERT INTO Client
VALUES(6, 'Mark', 'Maier', '5000534897104', 'Cluj Principala Nr.1003', '0754671286', 'mark_maier@gmail.com', '03-04-2017', 2);

INSERT INTO Client  --THIS VIOLATES CONSTRAINT LEN(PhoneNumber)=10  => ERROR
VALUES(7, 'Cristi', 'Tosa', '5000534890002', 'Cluj Aleea Padin Nr.3', '075467895', 'cristi@gmail.com', '03-04-2017', 4);

INSERT INTO Client
VALUES(7, 'Cosmin', 'Gabor', '5000839265019', 'Cluj Str.Principala Nr.918', '0264371114', 'info@litera.ro', '10-12-2017', 5);


INSERT INTO Books
VALUES(9786069801079, 2, 2, 1, 6, 'ALAIN DE BOTTON', 2019, 1, 'O educatie emotionala', 'O persoana inteligenta emotional stie ca iubirea este o calitate, nu un sentiment');

INSERT INTO Votes
VALUES(9786069801079, 5, '10-20-2020');

INSERT INTO Loans
VALUES(6, 9786069801079, '2020-10-02', '2020-10-15', 1, '2020-10-17'); 

INSERT INTO Loans
VALUES(7, 9786069801079, '2019-05-05', '2019-05-27', 0, NULL); 

INSERT INTO Loans
VALUES(7, 9789734731961, '2017-10-12', '2017-10-19', 0, '2017-10-30'); 

INSERT INTO Loans
VALUES(3, 9789734731961, '2019-08-10', '2019-09-20', 0, NULL);

INSERT INTO Debtors
VALUES(6, 3, 5);

--update data – for at least 3 tables;  {AND, OR, NOT},  {<,<=,=,>,>=,<> }, IS [NOT] NULL, IN, BETWEEN, LIKE.

UPDATE Debtors
SET SumToPay = SumToPay + 1   
WHERE CId = 4 OR CGId = 3;

UPDATE Category
SET Points = 6
WHERE CategoryName LIKE 'Psy%';

UPDATE PublishingHouse
SET Website = NULL
WHERE PName NOT IN ('Polirom', 'RAO', 'Humanitas', 'Curtea Veche');

UPDATE Debtors
SET SumToPay = 65
WHERE CId = 3

--delete data – for at least 2 tables.
DELETE FROM Votes
WHERE NumberOfStars > 4;  --added them back

DELETE FROM Books 
WHERE ISBN=9789734681815;   -- ADDED them back(because of cascade)
/*INSERT INTO Books
VALUES(9789734681815, 4, 1, 1, 2, 'IOAN T. MORAR', 2020, 1, 'Fake news in Epoca de Aur', 'Fie ca si-a propus, fie ca nu, Ioan T. Morar ne ofera o savuroasa contra-istorie.');
INSERT INTO Votes
VALUES(9789734681815, 4, '06-09-2020');
INSERT INTO Votes
VALUES(9789734681815, 5, '10-08-2020');*/




