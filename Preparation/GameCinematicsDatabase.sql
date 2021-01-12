CREATE DATABASE GameCinematicsModel;

USE GameCinematicsModel;

CREATE TABLE Heroes(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(20),
	description VARCHAR(40),
	importance INT --from 1 to 10
);

CREATE TABLE Cinematics(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	game_id INT REFERENCES Games(id)
);

CREATE TABLE EntryMoments(
	cinematic_id INT REFERENCES Cinematics(id),
	hero_id INT REFERENCES Heroes(id),
	PRIMARY KEY (cinematic_id, hero_id),
	moment TIME
);

CREATE TABLE Games(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	release_date DATE,
	company_id INT REFERENCES Companies(id)
);

CREATE TABLE Companies(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	description VARCHAR(50),
	website VARCHAR(30)
);

SELECT * FROM Heroes;
INSERT INTO Heroes VALUES ('hero1','the best',6),('hero2','weak',8);

SELECT * FROM Cinematics;
INSERT INTO Cinematics VALUES ('cinematic1',1),('cinematic2',2);

SELECT * FROM Games;
INSERT INTO Games VALUES ('game1','2020-01-02',1),('game2','2019-05-05',2);

SELECT * FROM Companies;
INSERT INTO Companies VALUES ('company1','asdfgh','comp.com'),('company2','qwerty','company.ro');

--2) Create a store procedure that receives a hero, a cinematic, and an entry moment and adds the new cinematic to
-- the hero. If the cinematic already exists, the entry moment is updated.

GO
CREATE OR ALTER PROCEDURE uspAddHeroCinematic
(@hero_id INT, @cinematic_id INT, @entry_mom TIME)
AS
IF NOT EXISTS (SELECT *
				FROM Heroes h
				WHERE h.id = @hero_id)
BEGIN
	PRINT 'No such hero id'
	RETURN
END
IF NOT EXISTS (SELECT *
				FROM Cinematics c
				WHERE c.id = @cinematic_id)
BEGIN
	PRINT 'No such cinematic id'
	RETURN
END
IF NOT EXISTS (SELECT *
				FROM EntryMoments e
				WHERE e.hero_id=@hero_id AND e.cinematic_id=@cinematic_id)
BEGIN	
	INSERT INTO EntryMoments 
	VALUES (@cinematic_id, @hero_id, @entry_mom)
END
ELSE
BEGIN
	UPDATE EntryMoments
	SET moment=@entry_mom
	WHERE hero_id=@hero_id AND cinematic_id=@cinematic_id
END
GO

EXEC uspAddHeroCinematic 1,1,'10:10:15';
EXEC uspAddHeroCinematic 2,1,'10:39:40';
EXEC uspAddHeroCinematic 1,2,'10:50:40';


SELECT * FROM EntryMoments;

--3) Create a view that shows the name and the importance of all heroes that appear in all cinematics.

GO
CREATE OR ALTER VIEW viewHeroes
AS
SELECT h.name, h.importance
FROM Heroes h
INNER JOIN EntryMoments em
	ON em.hero_id=h.id
GROUP BY h.name, h.importance
HAVING COUNT(*) = (SELECT COUNT(*)
				   FROM Cinematics) 
GO

SELECT * FROM viewHeroes;

--4) Create a function that lists the name of the company, the name of the game and the title of the cinematic for all 
--games that have the release date greater than or equal to '2000-12-02' and less than or equal to '2016-01-01'. 

GO
CREATE OR ALTER FUNCTION ufGetGames()
RETURNS TABLE
AS
RETURN
SELECT c.name AS CompaniesName, g.name AS GameName, cin.name AS CinematicName
FROM Companies c
INNER JOIN Games g
	ON G.company_id=c.id
INNER JOIN Cinematics cin
	ON cin.game_id=g.id
WHERE g.release_date >= '2000-12-02' AND g.release_date <= '2021-01-01'
GO

SELECT * FROM ufGetGames();