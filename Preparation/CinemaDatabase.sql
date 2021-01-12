CREATE DATABASE CinemaModel;

USE CinemaModel;

CREATE TABLE Actors(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	ranking INT
);

CREATE TABLE Movies(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	release_date DATE,
	company_id INT REFERENCES Companies(id),
	director_id INT REFERENCES StageDirectors(id)
);

CREATE TABLE Companies(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30)
);

CREATE TABLE CinemaProductions(
	id INT PRIMARY KEY IDENTITY(1,1),
	title VARCHAR(30),
	movie_id INT REFERENCES Movies(id),
);

CREATE TABLE StageDirectors(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	awards_count INT
);

CREATE TABLE EntryMoments(
	id INT PRIMARY KEY IDENTITY(1,1),
	prod_id INT REFERENCES CinemaProductions(id),
	actor_id INT REFERENCES Actors(id),
	moment INT
);

INSERT INTO Actors VALUES ('Andrei', 10), ('Shony', 9), ('Vlad',8);

INSERT INTO Companies VALUES ('Guby s'), ('Ff'), ('Aaa');

INSERT INTO StageDirectors VALUES ('Stephen', 15), ('Mathew', 87);

INSERT INTO Movies VALUES ('mov1', '2020-10-10', 1, 1);
INSERT INTO Movies VALUES ('mov2', '2020-11-11', 2, 2);
INSERT INTO Movies VALUES ('mov3', '2020-12-12', 3, 1);


INSERT INTO CinemaProductions VALUES('A night', 1);
INSERT INTO CinemaProductions VALUES('Once upon a time', 2);

SELECT * FROM Companies;
SELECT * FROM StageDirectors;
SELECT * FROM Movies;
--2) Stored proc that receives an actor, an entry moment and a cinema
-- prod and adds the new actor to the cinema prod

GO
CREATE OR ALTER PROCEDURE usp_addActor
(@actor_id INT, @moment INT, @production_id INT)
AS
	IF @actor_id NOT IN (SELECT A.id
						 FROM Actors A)
	BEGIN
		RAISERROR('No such actor!', 16,1);
		RETURN;
	END
	IF @production_id NOT IN (SELECT P.id
							  FROM CinemaProductions P)
	BEGIN
		RAISERROR('No such production!', 16,1);
		RETURN;
	END
	INSERT INTO EntryMoments 
		VALUES (@production_id, @actor_id, @moment)
GO

EXEC usp_addActor 1, 3, 1;
EXEC usp_addActor 1, 4, 2;
EXEC usp_addActor 2, 6, 1;

SELECT * FROM EntryMoments;

--3) A view that shows the nae of the actors that appear in all cinema
-- productions

SELECT * FROM CinemaProductions;

GO
CREATE OR ALTER VIEW viewActorsAll
AS
SELECT A.name, A.ranking
FROM Actors A
WHERE A.id IN (
	SELECT E.actor_id
	FROM EntryMoments E
	INNER JOIN Actors A 
		ON E.actor_id = A.id
	GROUP BY E.actor_id
	HAVING COUNT(*) = (SELECT COUNT(*)
						FROM CinemaProductions)
)
GO
 --------------- de intrebat

SELECT * FROM viewActorsAll;

--4) Function that returns all movies that have the rel date after
-- 2018-01-01 and have at least p productions

SELECT * FROM Movies;

SELECT * FROM CinemaProductions;

INSERT INTO CinemaProductions VALUES('qwerty', 1);

GO
CREATE OR ALTER FUNCTION usn_moviesFilter
(@p INT)
RETURNS TABLE
AS
RETURN
SELECT m.name
FROM Movies m
WHERE m.release_date > '2018-01-01' AND m.id IN (
												SELECT cp.movie_id
												FROM CinemaProductions cp
												GROUP BY cp.movie_id
												HAVING COUNT(*) >= @p)
GO

SELECT * FROM usn_moviesFilter(2);