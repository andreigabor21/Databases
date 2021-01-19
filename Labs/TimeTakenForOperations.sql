CREATE DATABASE Tests;
USE Tests;

--a table with a single-column primary key and no foreign keys;
CREATE TABLE Students(
	sid INT NOT NULL,
	CONSTRAINT PK_Student PRIMARY KEY(sid)
	);

--a table with a single-column primary key and at least one foreign key;
CREATE TABLE Grade(
	id INT NOT NULL,
	CONSTRAINT PK_Grade PRIMARY KEY(id),
	stud_id INT,
	FOREIGN KEY(stud_id) REFERENCES Students(sid)
	);

--a table with a multicolumn primary key
CREATE TABLE Transactions(
	studID INT NOT NULL,
	gradeID INT NOT NULL,
	CONSTRAINT PK_Transactions PRIMARY KEY (studID, gradeID)
	);

CREATE TABLE Aux(
	id INT NOT NULL,
	CONSTRAINT PK_Aux PRIMARY KEY (id)
	);

INSERT INTO Aux VALUES (1),(2),(3);

--a view with a SELECT statement operating on one table;
GO
CREATE OR ALTER VIEW ViewStudents
AS
	SELECT *
	FROM Students
GO

--a view with a SELECT statement operating on at least 2 tables;
GO
CREATE OR ALTER VIEW ViewGrade
AS
	SELECT G.id
	FROM GRADE G 
	INNER JOIN Transactions T ON G.id = T.gradeID
GO

--a view with a SELECT statement that has a GROUP BY clause and operates on at least 2 tables.
GO
CREATE OR ALTER VIEW ViewTransactions
AS
	SELECT T.gradeID
	FROM Transactions T
	INNER JOIN Aux A on T.gradeID = A.id 
	GROUP BY T.gradeID
GO

--insert data in Tables, Views and Tests tables
--Tables – holds data about tables that might take part in a test;
INSERT INTO Tables VALUES
	('Students'), ('Grade'), ('Transactions');
SELECT * FROM Tables;

--Views – holds data about a set of views from the database, used to assess the performance of certain SQL queries;
INSERT INTO Views VALUES
	('ViewStudents'), ('ViewGrade'), ('ViewTransactions');
SELECT * FROM Views;

--Tests – holds data about different test configurations;
INSERT INTO Tests VALUES
	('selectView'), ('insertStudent'), ('deleteStudent'), ('insertGrade'), ('deleteGrade'), ('insertTransaction'), ('deleteTransaction');
SELECT * FROM Tests;

--TestViews – link table between Tests and Views (which views take part in which tests);
INSERT INTO TestViews VALUES
	(1,1), (1,2), (1,3);
SELECT * FROM TestViews;

--TestTables – link table between Tests and Tables (which tables take part in which tests);
INSERT INTO TestTables VALUES
	(2,1,1000,1), (4,2,1000,2), (6,3,1000,3);
SELECT * FROM TestTables;
DELETE FROM TestTables

DELETE FROM TestRunViews;
DELETE FROM TestRuns;
DELETE FROM TestRunTables;

INSERT INTO Students VALUES (1);

--Procedure to insert data in Student table
GO
CREATE OR ALTER PROC insertStudent
AS
	DECLARE @current INT = 1
	DECLARE @rows INT
	SELECT @rows = NoOfRows FROM TestTables WHERE TestID = 2
	PRINT(@rows)

	WHILE @current <= @rows
	BEGIN	
		INSERT INTO Students VALUES (@current + 1)
		SET @current = @current + 1
	END
GO

--Procedure to delete data in Student table
GO 
CREATE OR ALTER PROC deleteStudents
AS
	DELETE FROM Students WHERE sid > 1;
GO

--Procedure to insert data in Grade table
GO
CREATE OR ALTER PROC insertGrade
AS
	DECLARE @current INT = 1
	DECLARE @rows INT
	SELECT @rows = NoOfRows FROM TestTables WHERE TestID = 4
	PRINT(@rows)

	WHILE @current <= @rows
	BEGIN
		INSERT INTO Grade VALUES (@current, 1)
		SET @current = @current + 1
	END
GO

--Procedure to delete data from Student table
GO
CREATE OR ALTER PROC deleteGrade
AS
	DELETE FROM Grade;
GO

--Procedure to insert data in Transactions table
GO
CREATE OR ALTER PROC insertTransactions
AS
	DECLARE @current INT = 1
	DECLARE @rows INT
	SELECT @rows = NoOfRows from TestTables WHERE TestID = 6
	PRINT(@rows)

	WHILE @current <= @rows
	BEGIN
		INSERT INTO Transactions VALUES (@current, @current)
		SET @current = @current + 1
	END
GO

--Procedure to delete data from Transactions table
GO
CREATE OR ALTER PROC deleteTransactions
AS
	DELETE FROM Transactions;
GO

--------
SELECT * FROM Views;

SELECT * FROM TestRuns;
SELECT * FROM TestRunViews;

--TestRuns – contains data about different test runs
--TestRunViews – contains performance data for every view in the test.
GO
CREATE OR ALTER PROC TestRunViewsProc
AS
	DECLARE @start1 DATETIME;
	DECLARE @start2 DATETIME;
	DECLARE @start3 DATETIME;
	DECLARE @end1 DATETIME;
	DECLARE @end2 DATETIME;
	DECLARE @end3 DATETIME;

	SET @start1 = GETDATE();
	PRINT('executing SELECT * FROM ViewStudents')
	EXEC ('SELECT * FROM ViewStudents');
	SET @end1 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_view', @start1, @end1)
	INSERT INTO TestRunViews VALUES (@@IDENTITY,1, @start1, @end1)
	
	SET @start2 = GETDATE();
	PRINT('executing SELECT * FROM ViewGrade')
	EXEC ('SELECT * FROM ViewGrade');
	SET @end2 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_view2', @start2, @end2)
	INSERT INTO TestRunViews VALUES (@@IDENTITY,2, @start2, @end2)

	SET @start3 = GETDATE();
	PRINT('executing SELECT * FROM ViewTransactions')
	EXEC ('SELECT * FROM ViewStudents');
	SET @end3 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_view3', @start3, @end3)
	INSERT INTO TestRunViews VALUES (@@IDENTITY,3, @start3, @end3)
GO


SELECT * FROM TestRunTables;

--TestRunTables – contains performance data for INSERT operations for every table in the test;
GO
CREATE OR ALTER PROC TestRunTablesProc
AS
	DECLARE @start1 DATETIME;
	DECLARE @start2 DATETIME;
	DECLARE @start3 DATETIME;
	DECLARE @start4 DATETIME;
	DECLARE @start5 DATETIME;
	DECLARE @start6 DATETIME;
	DECLARE @end1 DATETIME;
	DECLARE @end2 DATETIME;
	DECLARE @end3 DATETIME;
	DECLARE @end4 DATETIME;
	DECLARE @end5 DATETIME;
	DECLARE @end6 DATETIME;

	SET @start1 = GETDATE();
	PRINT('Inserting data into Students')
	EXEC insertStudent;
	SET @end1 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_insert_student', @start1, @end1);
	INSERT INTO TestRunTables VALUES (@@IDENTITY,1, @start1, @end1);

	SET @start2 = GETDATE();
	PRINT('Deleting data from Students')
	EXEC deleteStudents;
	SET @end2 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_delete_students', @start2, @end2);
	--INSERT INTO TestRunTables VALUES (@@IDENTITY,1, @start1, @end1);
	
	SET @start3 = GETDATE();
	PRINT('Inserting data into Grades')
	EXEC insertGrade;
	SET @end3 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_insert_grades', @start3, @end3);
	INSERT INTO TestRunTables VALUES (@@IDENTITY,2, @start3, @end3);

	SET @start4 = GETDATE();
	PRINT('Deleting data from Grades')
	EXEC deleteGrade;
	SET @end4 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_delete_grades', @start4, @end4);
	--INSERT INTO TestRunTables VALUES (@@IDENTITY,2, @start3, @end3);

	SET @start5 = GETDATE();
	PRINT('Inserting data into Transactions')
	EXEC insertTransactions;
	SET @end5 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_insert_transactions', @start5, @end5);
	INSERT INTO TestRunTables VALUES (@@IDENTITY,3, @start5, @end5);

	SET @start6 = GETDATE();
	PRINT('Deleting data from Transactions')
	EXEC deleteTransactions;
	SET @end6 = GETDATE();
	INSERT INTO TestRuns VALUES ('test_delete_transactions', @start6, @end6);
	--INSERT INTO TestRunTables VALUES (@@IDENTITY,2, @start3, @end3);
GO


EXEC TestRunTablesProc;
EXEC TestRunViewsProc;

SELECT * FROM TestRuns --with all
SELECT * FROM TestRunTables --only with insertions
SELECT * FROM TestRunViews

DELETE FROM TestRuns 
DELETE FROM TestRunViews
DELETE FROM TestRunTables

SELECT * FROM Students;
SELECT * FROM Grade;
SELECT * FROM Transactions;
