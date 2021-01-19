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

-- a. 2 queries with the union operation; use UNION [ALL] and OR;

-- All the email from clients and Publishing houses
SELECT Email 
FROM Client
UNION 
SELECT Email
From PublishingHouse;

-- All the phone numbers that end in '3' or '5' from clients and Publishing houses
SELECT DISTINCT PhoneNumber
FROM PublishingHouse
WHERE PhoneNumber LIKE '%3' OR PhoneNumber LIKE '%5'
UNION 
SELECT DISTINCT PhoneNumber 
From Client
WHERE PhoneNumber LIKE '%3' OR PhoneNumber LIKE '%5';


-- b. 2 queries with the intersection operation; use INTERSECT and IN;
 
-- Registration dates(and client ID) when the client also loaned a book
SELECT C.CId, C.RegistrationDate 
FROM Client C
INTERSECT 
SELECT L.CId, L.LoanDate 
FROM Loans L;

-- Checks if the Emails 'office@polirom.ro', 'info@litera.ro' from publishers are also listed on clients
-- Another way to check if these publishers are 'clients' for the library
SELECT Email
FROM PublishingHouse
WHERE Email IN ( 'office@polirom.ro', 'info@litera.ro', 'contact@humanitas.ro')
INTERSECT 
SELECT Email 
FROM Client;

-- c. 2 queries with the difference operation; use EXCEPT and NOT IN;

-- Get the ISBN, Author and Title of the books which have votes of 4 or 5 stars

SELECT B.ISBN, B.Author, B.Title, 10 * V.NumberOfStars AS PersonalScore
FROM Books B, Votes V
WHERE B.ISBN = V.ISBN
EXCEPT 
SELECT B2.ISBN, B2.Author, B2.Title, 10 * V2.NumberOfStars AS PersonalScore
FROM Books B2, Votes V2
WHERE B2.ISBN = V2.ISBN AND V2.NumberOfStars NOT IN (4, 5);

-- Get the data of the clients who loaned a book only in the previous years

SELECT DISTINCT C.FirstName, C.SecondName, C.SSN, C.CAddress, C.PhoneNumber, C.Email
FROM Client C, Loans L
WHERE C.CId = L.CId
EXCEPT
SELECT DISTINCT C2.FirstName, C2.SecondName, C2.SSN, C2.CAddress, C2.PhoneNumber, C2.Email
FROM Client C2, Loans L2
WHERE C2.CId = L2.CId AND YEAR(L2.LoanDate) >= 2020;

-- d. 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator); 
-- one query will join at least 3 tables, while another one will join at least two many-to-many relationships;

-- Categories and Languages of books based on publishers
-- (Ce categorii si in ce limba au fost scrise carti de la care editura)

SELECT C.CategoryName, L.LName, P.PName
FROM Books B
INNER JOIN Category C ON B.CategoryID = C.CategoryID
INNER JOIN Languages L ON B.LId = L.LId
INNER JOIN PublishingHouse P ON B.PHId = P.PHId
ORDER BY C.CategoryName

-- Get the maximum debt for each category of clients which did not restituted their book
-- order decreasing by debt

SELECT MAX(D.SumToPay) AS MaxPayment, CG.CGName
FROM Books B
LEFT JOIN (SELECT * 
	  FROM Loans L
	  WHERE L.RestitutionDate IS NULL) t
ON B.ISBN = t.ISBN
LEFT JOIN Client C ON t.CId = c.CId
LEFT JOIN Debtors D ON D.CId = C.CId
JOIN ClientsGroups CG ON CG.CGId = D.CGId
GROUP BY CG.CGName
ORDER BY MaxPayment DESC;

-- Get the title, author and category of the books
-- show also the categories which do not belong to any book in the library

SELECT B.Title, B.Author, C.CategoryName
FROM Books B
RIGHT JOIN Category C ON B.CategoryID = C.CategoryID;

-- Show the ISBN and the description of the books which have been lend before 2020 and those who have never been lend
-- order by the loan date increasing

SELECT B.ISBN, B.BDescription, L.LoanDate 
FROM Books B
FULL JOIN Loans L ON L.ISBN = B.ISBN
WHERE YEAR(L.LoanDate) < 2020 OR L.LoanDate IS NULL
ORDER BY L.LoanDate;

-- e. 2 queries with the IN operator and a subquery in the WHERE clause; 
-- in at least one case, the subquery should include a subquery in its own WHERE clause;

-- get all the loans that have been made by clients from Satu Mare
SELECT * 
FROM Loans L
WHERE L.CId IN(SELECT C.CId
               FROM Client C
               WHERE C.CAddress LIKE '%Satu Mare%');

-- get all the distinct names of the clients from the 'best' group

SELECT DISTINCT FirstName, SecondName
FROM Client C
WHERE C.CGId IN (SELECT CG.CGId
                 FROM ClientsGroups CG
				 WHERE CG.CGName = 'best');

-- f. 2 queries with the EXISTS operator and a subquery in the WHERE clause;

-- Get the clients that belong to a group that has debts

SELECT *
FROM Client C
WHERE EXISTS(SELECT *
			 FROM ClientsGroups CG
			 INNER JOIN Debtors D ON D.CGId = CG.CGId
			 WHERE C.CGId = CG.CGId);

-- Get the name and 'SuperPoints' of each category that has books published in 2020
-- we define SuperPoints(x)=10*x+5

SELECT C.CategoryName, 10 * C.Points + 5 AS SuperPoints
FROM Category C
WHERE EXISTS(SELECT *
			 FROM Books B
			 WHERE C.CategoryID = B.CategoryID AND B.YearOfPublication = 2020)

-- g. 2 queries with a subquery in the FROM clause;

-- Get top 3 total number of characters(length of title + length of description)
-- FROM Books which have a count > 1 and have been published after 2015

SELECT TOP 3 LEN(t.BDescription) + LEN(t.Title) AS TotalLength
FROM(SELECT *
     FROM Books B
	 WHERE B.BCount > 1 AND B.YearOfPublication > 2015
)t
ORDER BY TotalLength DESC;

-- Get the Name, Address and Email of the Publishing Houses which have a website
SELECT t.PName, t.PAddress, t.Email
FROM(SELECT *
     FROM PublishingHouse P
	 WHERE P.Website IS NOT NULL) t

-- h. 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 
-- 2 of the latter will also have a subquery in the HAVING clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;

-- How many books have been lend by every group

SELECT CG.CGName, COUNT(*) AS BorrowedBooks
FROM ClientsGroups CG
INNER JOIN Client C ON C.CGId = CG.CGId
INNER JOIN Loans L ON L.CId = C.CId
GROUP BY CG.CGName
HAVING COUNT(*) > 0

-- Print the name of the clients who borrowed the most books

SELECT C.FirstName, C.SecondName
FROM Client C
INNER JOIN Loans L ON C.CId = L.CId
INNER JOIN Books B ON B.ISBN = L.ISBN
GROUP BY C.FirstName, C.SecondName
HAVING COUNT(*) = (SELECT MAX(t.CNT) AS MAXIM
                   FROM(
                   SELECT COUNT(*) AS CNT  
				   FROM Client C
				   INNER JOIN Loans L ON L.CId = C.CId
		           INNER JOIN Books B ON B.ISBN = L.ISBN
		           GROUP BY  C.FirstName) t
				   );

-- The number of books which have number of stars(and the votes are after 2018)
SELECT V.NumberOfStars, COUNT(*) AS CountOfBooks
FROM Books B
INNER JOIN Votes V ON V.ISBN = B.ISBN
GROUP BY V.NumberOfStars
HAVING V.NumberOfStars IN (SELECT V2.NumberOfStars
                           FROM Votes V2
						   WHERE YEAR(V2.DateOfVote) > 2018)

-- Get the average number of books in each language
SELECT AVG(t.BooksPerLanguage)
FROM (
SELECT B.LId, COUNT(*) AS BooksPerLanguage
FROM BOOKS B
GROUP BY B.LId) t;

-- i. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator);
-- rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.

-- Get the books that were published after some Psychology book
SELECT *
FROM BOOKS B
WHERE B.YearOfPublication > ANY(SELECT B2.YearOfPublication
                                FROM Books B2
								INNER JOIN Category C ON C.CategoryID = B2.CategoryID
								WHERE C.CategoryName = 'Psychology')

SELECT *
FROM BOOKS B
WHERE B.YearOfPublication > (SELECT MIN(B2.YearOfPublication)
                                FROM Books B2
								INNER JOIN Category C ON C.CategoryID = B2.CategoryID
								WHERE C.CategoryName = 'Psychology')

-- All publishing houses that have at least one romanian book

SELECT *
FROM PublishingHouse P
WHERE P.PHId = ANY(SELECT B.PHId
                   FROM Books B
				   INNER JOIN Languages L ON L.LId = B.LId
				   WHERE L.LName = 'Romanian')

SELECT *
FROM PublishingHouse P
WHERE P.PHId IN (SELECT B.PHId
                   FROM Books B
				   INNER JOIN Languages L ON L.LId = B.LId
				   WHERE L.LName = 'Romanian')

-- Clients which have registered after all clients with a '.ro' domain in the email

SELECT * 
FROM Client C
WHERE C.RegistrationDate > ALL(SELECT C2.RegistrationDate
                               FROM Client C2
							   WHERE C2.Email LIKE '%.ro')


SELECT * 
FROM Client C
WHERE C.RegistrationDate > (SELECT MAX(C2.RegistrationDate)
                               FROM Client C2
							   WHERE C2.Email LIKE '%.ro')

-- Find all the titles of books which were not loaned

SELECT DISTINCT TOP 25 PERCENT B.Title
FROM Books B
WHERE B.ISBN <> ALL(SELECT L.ISBN
                    FROM Loans L);

SELECT DISTINCT TOP 25 PERCENT B.Title
FROM Books B
WHERE B.ISBN NOT IN (SELECT L.ISBN
                    FROM Loans L);