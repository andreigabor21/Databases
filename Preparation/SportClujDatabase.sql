CREATE DATABASE SportClubModel;

USE SportClubModel;

DROP TABLE IF EXISTS GAME_X_Player
DROP TABLE IF EXISTS GAME
DROP TABLE IF EXISTS Player
DROP TABLE IF EXISTS SportClub
DROP TABLE IF EXISTS SportCompetition


CREATE TABLE SportCompetition(
	sportCompetitionId INT PRIMARY KEY IDENTITY(1,1),
	sportCompetitionName VARCHAR(100)
)

CREATE TABLE SportClub(
	sportClubId INT PRIMARY KEY IDENTITY(1,1),
	sportClubName VARCHAR(100)
)

CREATE TABLE Player(
	playerId INT PRIMARY KEY IDENTITY(1,1),
	playerName VARCHAR(100),
	ranking VARCHAR(100),
	sportClubId INT,
	CONSTRAINT FK_PlayerId
		FOREIGN KEY(sportClubId) REFERENCES SportClub(sportClubId),
)

CREATE TABLE Game(
	gameId INT PRIMARY KEY IDENTITY(1,1),
	gameName VARCHAR(100),
	sportCompetitionId INT,
	CONSTRAINT FK_SportCompetition
		FOREIGN KEY(sportCompetitionId) REFERENCES SportCompetition(sportCompetitionId)
)

CREATE TABLE Game_X_Player(
	gameId Int,
	playerId INT,
	entryTime VARCHAR(100),
	CONSTRAINT PRK PRIMARY KEY(gameId,playerId),
	CONSTRAINT FK_GameId
		FOREIGN KEY(gameId) REFERENCES Game(gameId),
	CONSTRAINT FK_PlayerId2
		FOREIGN KEY(playerId) REFERENCES Player(playerId)
)


INSERT INTO SportCompetition(sportCompetitionName)
	VALUES ('a'),
	 ('a'),
	  ('a'),
	   ('a'),
	    ('a'),
		 ('a'),
		  ('a'),
		   ('a'),
		    ('a'),
			 ('a'),
			  ('a')


INSERT INTO SportClub(sportClubName)
	VALUES ('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b'),
	('b')


INSERT INTO Player(playerName,sportClubId, ranking)
VALUES ('a',1,1), ('b',2,2), ('c',3,3), ('d',4,4), ('e',5,5), ('f',6,6), ('g',7,7)

INSERT INTO GAME(gameName, sportCompetitionId)
	VALUES ('a',1),('b',1), ('c',2), ('d',3), ('e',2),('f',1)   
	 
INSERT INTO Game_X_Player(playerId, gameId, entryTime)
	VALUES (1,1,'1:1'),(1,2,'1:1'),(2,1,'1:1'),(2,2,'1:1'),(3,3,'1:1'),(1,3,'1:1'), (5,2,'2:2')
GO

CREATE VIEW getPlayers
AS
	SELECT p.playerName
	FROM Player p
	WHERE p.playerId IN 
		(SELECT gxp.playerId
		FROM Game_X_Player gxp)

GO
SELECT * FROM getPlayers
GO
CREATE OR ALTER PROC addPLayer
@gameName VARCHAR(100),
@playerName VARCHAR(100),
@entryTime VARCHAR(100)
AS
BEGIN
	--INSERT INTO Player(playerName)
	--VALUES (@playerName)
	--INSERT INTO Game(gameName)
	--VALUES (@gameName)
	--DECLARE @gameId INT
	--DECLARE @playerId INT
	--SELECT @gameId = g.gameId FROM Game g WHERE g.gameName = @gameName AND g.gameId = (SELECT MAX(gameId) FROM Game);
	--SELECT @playerId = p.playerid FROM Player p WHERE p.playerName = p.playerName AND p.playerId = (SELECT MAX(playerId) FROM Player);
	--INSERT INTO Game_X_Player(gameId,playerId,entryTime)
	--VALUES (@gameId,@playerName, @entryTime)
	DECLARE @gameId INT
	DECLARE @playerId INT
	SELECT @gameId = g.gameId FROM Game g WHERE g.gameName = @gameName
	SELECT @playerId = p.playerid FROM Player p WHERE p.playerName = @playerName
	INSERT INTO Game_X_Player(gameId,playerId,entryTime)
	VALUES (@gameId,@playerId, @entryTime)
END
GO
EXEC addPLayer 'a', 'g', '2:2'

GO
CREATE OR ALTER FUNCTION getOut100 (@n INT)
RETURNS TABLE
RETURN
	SELECT p2.playerName
	FROM (
	SELECT p.playerId, count(p.playerId) as c, p0.ranking, p0.playerName
					FROM Game_X_Player p
					INNER JOIN Player p0 ON p0.playerId = p.playerId
					GROUP BY p.playerId,p0.ranking,p0.playerName
					Having count (p.playerId) > @n
	) p2
	WHERE p2.playerId NOT IN
			(SELECT TOP 1 p.playerId
			FROM (SELECT p.playerId, count(p.playerId) as c, p0.ranking
					FROM Game_X_Player p
					INNER JOIN Player p0 ON p0.playerId = p.playerId
					GROUP BY p.playerId,p0.ranking
					Having count (p.playerId) > @n) P
			ORDER BY p.ranking DESC)
	

go
SELECT * from getOut100(0)
GO