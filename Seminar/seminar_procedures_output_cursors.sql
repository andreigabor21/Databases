SELECT * 
FROM Books;

CREATE OR ALTER PROCEDURE USP_listAllBooks(@title VARCHAR(20), @count INT)
AS
--BEGIN
SELECT * FROM Books AS B
WHERE B.Title = @title and B.BCount = @count;
--END
GO

EXEC USP_listAllBooks @title = 'Faraonul', @count = 1;


SELECT *
FROM sys.sql_modules
WHERE object_id IN
(SELECT object_id
FROM sys.objects
WHERE TYPE = 'P')



SELECT * FROM Client;

CREATE OR ALTER PROCEDURE USP_CountEvenCIdPersons @Count INT OUTPUT
AS
BEGIN
	SET @Count = (SELECT COUNT(*) FROM Client C
	WHERE C.CId IS NULL)
	IF @Count = 0
		RAISERROR('No people with the specified criteria', 5, 1)
		--RAISERROR(Message,Severity,State)
		--Severity - 0 to 25
		--State - 0 to 255
END
GO

DECLARE @ResultCount INT
SET @ResultCount = 0
EXEC USP_CountEvenCIdPersons @Count = @ResultCount OUTPUT

PRINT(@ResultCount)


--
CREATE TABLE QuickTest
(ID INT PRIMARY KEY IDENTITY(1,1),
C2 INT)

SET IDENTITY_INSERT QuickTest ON

INSERT QuickTest(ID,C2) VALUES(1,10)
SELECT @@ERROR

SELECT * FROM QuickTest;

UPDATE QuickTest
SET C2 = 7869
SELECT @@ROWCOUNT

SELECT @@VERSION;

--OUTPUT 

CREATE TABLE Employees
(ID INT PRIMARY KEY,
LastName VARCHAR(50))

CREATE TABLE LogEmployeeChanges
(EID INT,
OldLastName VARCHAR(50),
NewLastName VARCHAR(50),
DateOfChange DATE)

INSERT INTO Employees VALUES(1,'Popescu'), (2,'Ionescu')
SELECT * FROM Employees
SELECT * FROM LogEmployeeChanges

UPDATE Employees
SET LastName = 'Andreescu'
OUTPUT inserted.ID, deleted.LastName, inserted.LastName, GETDATE()
INTO LogEmployeeChanges
WHERE ID = 1
--inserted/delete (pseudo tables)

--
SELECT *
FROM Client;

DECLARE @CId INT, @Fname VARCHAR(20)

DECLARE CursorPersons CURSOR FOR
SELECT C.CId, C.FirstName
FROM Client C
OPEN CursorPersons
FETCH NEXT 
FROM CursorPersons INTO @CId, @Fname
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT CAST(@CId AS VARCHAR(5)) + @Fname
	FETCH NEXT
	FROM CursorPersons INTO @CId, @Fname
END
CLOSE CursorPersons
DEALLOCATE CursorPersons

--

DECLARE @ID VARCHAR(30) = '2', @SqlSt VARCHAR(200)
SET @SqlSt = 'SELECT * FROM Client WHERE CId = ' + @ID
--PRINT @SqlSt
EXEC(@SqlSt)

/*
sp_executesql [ @stmt = ] statement  
[   
  { , [ @params = ] N'@parameter_name data_type [ OUT | OUTPUT ][ ,...n ]' }   
     { , [ @param1 = ] 'value1' [ ,...n ] }  
]  */

EXECUTE sp_executesql   
          N'SELECT * FROM Client
          WHERE CId = @ID AND FirstName = @Name',  
          N'@ID TINYINT, @Name VARCHAR(20)',  
          @ID = 1, @Name = 'Andrei';  