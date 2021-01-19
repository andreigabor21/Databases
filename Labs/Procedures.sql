USE BookLibrary;

SELECT * FROM Debtors;

--a. modify the type of a column;
GO
CREATE OR ALTER PROCEDURE usp_make1 AS
BEGIN
	ALTER TABLE Debtors
	ALTER COLUMN SumToPay FLOAT
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake1 AS
BEGIN
	ALTER TABLE Debtors
	ALTER COLUMN SumToPay INT
END
GO

--b. add / remove a column;
GO
CREATE OR ALTER PROCEDURE usp_make2 AS
BEGIN
	ALTER TABLE PublishingHouse
	ADD FoundingDate DATE
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake2 AS
BEGIN
	ALTER TABLE PublishingHouse
	DROP COLUMN FoundingDate
END
GO

--c. add / remove a DEFAULT constraint;
GO
CREATE OR ALTER PROCEDURE usp_make3 AS
BEGIN
	ALTER TABLE Client
	ADD constraint DEF_ClientAddress DEFAULT 'No location' FOR CAddress
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake3 AS
BEGIN
	ALTER TABLE Client
	DROP CONSTRAINT DEF_ClientAddress 
END
GO

--d. add / remove a primary key;
GO
CREATE OR ALTER PROCEDURE usp_make4 AS
BEGIN
	CREATE TABLE TestTablePK(
		ID INT NOT NULL
		);
	ALTER TABLE TestTablePK
	ADD CONSTRAINT PK_ID PRIMARY KEY(ID)
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake4 AS
BEGIN
	ALTER TABLE TestTablePK
	DROP CONSTRAINT PK_ID
	DROP TABLE IF EXISTS TestTablePK
END
GO

--e. add / remove a candidate key;
GO
CREATE OR ALTER PROCEDURE usp_make5 AS
BEGIN
	ALTER TABLE Client
	ADD CONSTRAINT CK_SSN UNIQUE(SSN)
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake5 AS
BEGIN
	ALTER TABLE Client
	DROP CONSTRAINT CK_SSN
END
GO

--f. add / remove a foreign key;
GO
CREATE OR ALTER PROCEDURE usp_make6 AS
BEGIN
	ALTER TABLE Books
	DROP CONSTRAINT IF EXISTS FK_Books_LId
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake6 AS
BEGIN
	ALTER TABLE Books
	ADD CONSTRAINT FK_Books_LId FOREIGN KEY (LId) REFERENCES Languages(LId)
END
GO

--g. create / drop a table;
GO
CREATE OR ALTER PROCEDURE usp_make7 AS
BEGIN
	CREATE TABLE School(
		SId INT NOT NULL,
		Name VARCHAR(30),
		Address VARCHAR(40)
	);
END
GO

GO
CREATE OR ALTER PROCEDURE usp_remake7 AS
BEGIN
	DROP TABLE IF EXISTS School
END
GO

--tests
EXEC usp_make1;
EXEC usp_remake1;
EXEC usp_make2;
EXEC usp_remake2;
EXEC usp_make3;
EXEC usp_remake3;
EXEC usp_make4;
EXEC usp_remake4;
EXEC usp_make5;
EXEC usp_remake5;
EXEC usp_make6;
EXEC usp_remake6;
EXEC usp_make7;
EXEC usp_remake7;

--create database version table

CREATE TABLE DatabaseVersion (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	crt_version INT
	);

--current version is 0
INSERT INTO DatabaseVersion VALUES (0);
SELECT * FROM DatabaseVersion;

UPDATE DatabaseVersion 
SET crt_version=0;

GO
CREATE OR ALTER PROCEDURE goToVersion
	@version INT AS
BEGIN
	DECLARE @crtVersion INT
	SET @crtVersion = (SELECT DV.crt_version
	                   FROM DatabaseVersion DV)
	
	DECLARE @procedure VARCHAR(50)

	IF @version<0 OR @version>7 --check for wrong input
		BEGIN
			PRINT 'Version must be in [0,7]'
			RETURN
		END
	ELSE
		BEGIN
			IF @version>@crtVersion
			BEGIN
				WHILE @version>@crtVersion
				BEGIN
					SET @crtVersion = @crtVersion+1
					SET @procedure = 'usp_make' + CAST(@crtVersion AS VARCHAR(5))
					print('I have run' + @procedure)
					EXEC @procedure
					UPDATE DatabaseVersion SET crt_version=@version;
				END
			END
			ELSE
			BEGIN
				WHILE @version<@crtVersion
				BEGIN
					IF @crtVersion != 0
					BEGIN	
						SET @procedure = 'usp_remake' + CAST(@crtVersion AS VARCHAR(5))
						print('I have run' + @procedure)
						EXEC @procedure
					END
					SET @crtVersion = @crtVersion-1
					UPDATE DatabaseVersion SET crt_version=@version;
				END
			END
			--UPDATE DatabaseVersion SET crt_version=@version;
			RETURN 
		END
END;


EXEC goToVersion 0;

SELECT * FROM DatabaseVersion;
