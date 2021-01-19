CREATE DATABASE EXAM;

USE EXAM;

CREATE TABLE Users(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(40),
	pen_name VARCHAR(40) UNIQUE,
	birthYear INT
);

CREATE TABLE ExternalAwards(
	id INT PRIMARY KEY IDENTITY(1,1),
	user_id INT REFERENCES Users(id),
	place INT,
	CHECK (place >= 1 AND place <= 3),
	year INT,
	contest_name VARCHAR(40)
);

CREATE TABLE InternalCompetitions(
	id INT PRIMARY KEY IDENTITY(1,1),
	year INT,
	week_number INT,
	topic VARCHAR(40)
);

CREATE TABLE Poems(
	id INT PRIMARY KEY IDENTITY(1,1),
	title VARCHAR(40),
	text VARCHAR(200)
);

CREATE TABLE Competition_Poems(  --A poem is submitted by a user to a competition
	id INT PRIMARY KEY IDENTITY(1,1),
	user_id INT REFERENCES Users(id),
	poem_id INT REFERENCES Poems(id),
	competition_id INT REFERENCES InternalCompetitions(id)
);

CREATE TABLE Votes( --a user U awards a number N of points to a poem P
	id INT PRIMARY KEY IDENTITY(1,1),
	user_id INT REFERENCES Users(id) UNIQUE,
	poem_id INT REFERENCES Poems(id),
	points INT,
	CHECK (points >= 1 AND points <= 5),
);

--insertions in all tables
SELECT * FROM Users;
INSERT INTO Users VALUES ('Andrei','asdf',2000),('Filip','qwer',1999),('Maria','lkjhbu',2001)

SELECT * FROM ExternalAwards;
INSERT INTO ExternalAwards VALUES (1,1,2015,'Contest1'),(2,2,2017,'Contest2'),(3,3,2015,'Contest1')

SELECT * FROM InternalCompetitions;
INSERT INTO InternalCompetitions VALUES (2015,3,'Poetry1'),(2017,2,'Poetry2');

SELECT * FROM Poems;
INSERT INTO Poems VALUES ('poem1','text1'),('poem2','text2'),('poem3','text3')

SELECT * FROM Competition_Poems
INSERT INTO Competition_Poems VALUES (1,1,1),(2,2,2)

SELECT * FROM Votes
INSERT INTO Votes VALUES (3,1,2),(2,3,1)

--b) Implement a stored procedure that receives a pen name P as parameter, and deletes all external awards earned by the user with pen name P.

GO
CREATE OR ALTER PROCEDURE uspDeleteByPenName(@P VARCHAR(40))
AS
	DECLARE @user_id INT = (SELECT u.id  --get the id of the user with that pen number
				            FROM Users u
				            WHERE u.pen_name = @P)
	IF @user_id IS NULL
	BEGIN   --error if id does not exist
		RAISERROR('No such user',16,1)
		RETURN
	END

	DELETE   --delete entities from the corresponding table
	FROM ExternalAwards
	WHERE user_id=@user_id

GO

EXEC uspDeleteByPenName 10; --will raise an error

--c) Create a view that shows the pen names of users who submitted poems to all internal competitions in 2020 and have won at least one external award.

GO
CREATE OR ALTER VIEW viewPenNames
AS

SELECT Users.pen_name  --display the pen names
FROM Users 
	WHERE Users.id IN (
	SELECT u.id 
	FROM Users u
	INNER JOIN Competition_Poems cp
		ON cp.user_id = u.id
	INNER JOIN ExternalAwards ea --has at least one external award
		on ea.user_id = u.id
	INNER JOIN InternalCompetitions ic
		on cp.competition_id = ic.id
	WHERE ic.year = 2020  --internal competitions in 2020
	GROUP BY cp.competition_id, u.id  --we group mainly by competitions
	HAVING COUNT(cp.competition_id) = (SELECT COUNT(*)
									   FROM InternalCompetitions)  --their count should be equal to the number of internal competitions from InternalCompetitions
									                               -- in order to satisfy the constraint "submitted poems to all internal competitions"
	)

GO

SELECT * FROM viewPenNames;

--d)Implement a function that lists the competitions (year and week number) with less than P poems, where P is the function's parameter.

GO
CREATE OR ALTER FUNCTION ufnCompetitionsLess(@P INT)
RETURNS TABLE
AS
RETURN

SELECT ic.year, ic.week_number --display year and week number
FROM InternalCompetitions ic
WHERE ic.id IN(
	SELECT cp.competition_id  --select the competitions
	FROM Competition_Poems cp
	GROUP BY cp.competition_id  
	HAVING COUNT(cp.poem_id) < @P  --with less than P poems
)
GO

SELECT * FROM ufnCompetitionsLess(2);