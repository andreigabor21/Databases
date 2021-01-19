USE HospitalTest
GO

CREATE OR ALTER FUNCTION getOrder (@ListOfTables VARCHAR(1000))
RETURNS VARCHAR(MAX)
BEGIN
	DECLARE @RightOrder VARCHAR(MAX) = ''
	DECLARE @OrderTable TABLE (TableName VARCHAR(50), NoOfFKs INT)

	DECLARE @ForeignKeyTable TABLE (TableName VARCHAR(50), ReferencedTable VARCHAR(50))
	INSERT INTO @ForeignKeyTable
		SELECT T.value, FK.FOREIGN_KEY_TABLE
		FROM STRING_SPLIT(@ListOfTables, ',') AS T
		LEFT JOIN (SELECT KCU.TABLE_NAME, KCU1.TABLE_NAME AS FOREIGN_KEY_TABLE
					FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
					INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
					on KCU.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
					INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU1
					on KCU1.CONSTRAINT_NAME = RC.UNIQUE_CONSTRAINT_NAME) AS FK
		ON T.value = FK.TABLE_NAME

	DECLARE @Cursor CURSOR
	SET @Cursor = CURSOR FOR 
		SELECT * 
		FROM @ForeignKeyTable

	DECLARE @CurrentTable VARCHAR(50), @ReferencedTable VARCHAR(50)

	OPEN @Cursor
	FETCH @Cursor 
	INTO @CurrentTable, @ReferencedTable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @ReferencedTable IS NOT NULL
		BEGIN
			IF @ReferencedTable NOT IN (SELECT *
										FROM STRING_SPLIT(@ListOfTables, ','))
			BEGIN
				CLOSE @Cursor
				DEALLOCATE @Cursor
				RETURN @RightOrder
			END
			IF @CurrentTable NOT IN (SELECT TableName FROM @OrderTable)
			BEGIN
				INSERT INTO @OrderTable VALUES
				(@CurrentTable, (SELECT COUNT(*) 
								 FROM @ForeignKeyTable
								 WHERE TableName = @CurrentTable))
			END
		END
		ELSE
		BEGIN
			INSERT INTO @OrderTable VALUES
				(@CurrentTable, 0)
		END

		FETCH @Cursor
		INTO @CurrentTable, @ReferencedTable
	END
	CLOSE @Cursor
	DEALLOCATE @Cursor

	DECLARE @OrderCursor CURSOR
	SET @OrderCursor = CURSOR FOR
		SELECT TableName
		FROM @OrderTable
		ORDER BY NoOfFKs
	
	OPEN @OrderCursor
	FETCH @OrderCursor
	INTO @CurrentTable
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @RightOrder = @RightOrder + @CurrentTable
		FETCH @OrderCursor
		INTO @CurrentTable

		IF @@FETCH_STATUS = 0
		BEGIN
			SET @RightOrder = @RightOrder + ','
		END
	END
	CLOSE @OrderCursor
	DEALLOCATE @OrderCursor

	RETURN @RightOrder
END
GO

-- checking if the table names given as parameters are valid

CREATE OR ALTER FUNCTION checkTables (@ListOfTables VARCHAR(500), @TestID INT)
RETURNS VARCHAR(MAX)
BEGIN
	DECLARE @Valid VARCHAR(MAX) = ''
	DECLARE @TableName VARCHAR(50)

	DECLARE @Cursor CURSOR
	SET @Cursor = CURSOR FOR 
		SELECT *
		FROM STRING_SPLIT(@ListOfTables, ',')

	OPEN @Cursor
	FETCH NEXT FROM @Cursor INTO @TableName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @TableName NOT IN (SELECT name
							  FROM sys.objects
							  WHERE type = 'U')
		BEGIN 
			RETURN @Valid
		END
		FETCH NEXT FROM @Cursor 
		INTO @TableName
	END
	CLOSE @Cursor
	DEALLOCATE @Cursor

	SET @Valid = [dbo].getOrder(@ListOfTables)

	RETURN @Valid
END
GO


-- deleting from all the tables given as parameters

CREATE OR ALTER PROCEDURE RunDelete
@TestedTables VARCHAR(500)
AS
	DECLARE @Cursor CURSOR
	SET @Cursor = CURSOR FOR
		SELECT *
		FROM STRING_SPLIT(@TestedTables, ',')

	DECLARE @CurrentTable VARCHAR(50)

	OPEN @Cursor
	FETCH NEXT FROM @Cursor 
	INTO @CurrentTable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Delete_From_Table @CurrentTable

		FETCH NEXT FROM @Cursor INTO @CurrentTable
	END

	CLOSE @Cursor
	DEALLOCATE @Cursor
GO

-- inserting in all the tables given as parameters a number of rows equal to the one associated with the 
--(testID, tableID)

CREATE OR ALTER PROCEDURE RunInsert
@TestedTables VARCHAR(500),
@TestID INT,
@CurrentTestRunID INT
AS
	DECLARE @Cursor CURSOR
	SET @Cursor = CURSOR FOR
		SELECT *
		FROM STRING_SPLIT(@TestedTables, ',')

	DECLARE @CurrentTable VARCHAR(50)
	DECLARE @StartTime DATETIME
	DECLARE @EndTime DATETIME
	DECLARE @ExecAction NVARCHAR(100)
	DECLARE @NoOfRows INT


	OPEN @Cursor
	FETCH NEXT FROM @Cursor INTO @CurrentTable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @NoOfRows = NoOfRows
		FROM TestTables
		WHERE TestID = @TestID AND TableID = (SELECT TableID 
											  FROM Tables 
											  WHERE Name = @CurrentTable)

		SET @ExecAction = 'EXEC Insert_Into_Table ' + @CurrentTable + ', ' + CAST(@NoOfRows AS VARCHAR)
		
		SET @StartTime = GETDATE()
		EXEC sp_executesql @ExecAction
		SET @EndTime = GETDATE()

		INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt) VALUES
		(@CurrentTestRunID, (SELECT TableID FROM Tables WHERE Name = @CurrentTable), @StartTime, @EndTime)

		FETCH NEXT FROM @Cursor INTO @CurrentTable
	END

	CLOSE @Cursor
	DEALLOCATE @Cursor
GO


-- checking if all the views given as parameters are valid
CREATE OR ALTER FUNCTION checkViews (@ListOfViews VARCHAR(500))
RETURNS INT
BEGIN
	DECLARE @Valid INT = 1
	DECLARE @ViewName VARCHAR(50)

	DECLARE @Cursor CURSOR
	SET @Cursor = CURSOR FOR 
		SELECT *
		FROM STRING_SPLIT(@ListOfViews, ',')

	OPEN @Cursor
	FETCH NEXT FROM @Cursor INTO @ViewName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @ViewName NOT IN (SELECT name
							  FROM sys.objects
							  WHERE type = 'V')
		BEGIN 
			SET @Valid = 0
			BREAK
		END
		
		FETCH NEXT FROM @Cursor INTO @ViewName
	END

	CLOSE @Cursor
	DEALLOCATE @Cursor

	RETURN @Valid
END
GO

-- evaluating all views given as parameters
CREATE OR ALTER PROCEDURE RunViews
@TestedViews VARCHAR(500),
@CurrentTestRunID INT
AS
	DECLARE @Cursor CURSOR
	SET @Cursor = CURSOR FOR
		SELECT *
		FROM STRING_SPLIT(@TestedViews, ',')

	DECLARE @CurrentView VARCHAR(50)
	DECLARE @StartTime DATETIME
	DECLARE @EndTime DATETIME

	OPEN @Cursor
	FETCH NEXT FROM @Cursor INTO @CurrentView

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @StartTime = GETDATE()
		
		EXEC Select_View @CurrentView
		SET @EndTime = GETDATE()

		INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt) VALUES
		(@CurrentTestRunID, (SELECT ViewID FROM Views WHERE Name = @CurrentView), @StartTime, @EndTime)

		FETCH NEXT FROM @Cursor INTO @CurrentView
	END

	CLOSE @Cursor
	DEALLOCATE @Cursor
GO


CREATE OR ALTER FUNCTION reverseOrder (@String VARCHAR(MAX))
RETURNS VARCHAR(MAX)
BEGIN
	DECLARE @Result VARCHAR(MAX) = ''
	DECLARE @Lenght INT 

	WHILE LEN(@String) > 0
	BEGIN
		IF CHARINDEX(',', @String) > 0
		BEGIN
			SET @Result = SUBSTRING(@String, 0, CHARINDEX(',', @String)) + ',' + @Result
			SET @String = SUBSTRING(@String, CHARINDEX(',', @String) + 1, LEN(@String))
		END
		ELSE
		BEGIN
			SET @Result = @String + ',' + @Result
			SET @String = ''
		END
	END
	RETURN @Result
END
GO


--main procedure

CREATE OR ALTER PROCEDURE RunTest
@TestedTables VARCHAR(500),
@TestName VARCHAR(50),
@TestedViews VARCHAR(500)
AS
	-- parameters validation
	DECLARE @TestID INT = (SELECT TestID
						   FROM Tests
						   WHERE Name = @TestName)

	DECLARE @RightOrder VARCHAR(MAX) = [dbo].checkTables(@TestedTables, @TestID)
	IF @RightOrder = ''
	BEGIN
		PRINT 'Invalid tables!'
		RETURN
	END

	SET @TestedTables = @RightOrder

	IF @TestName NOT IN (SELECT Name
					     FROM Tests)
	BEGIN
		PRINT 'Invalid test name!'
		RETURN
	END

	DECLARE @Valid INT
	SET @Valid = [dbo].checkViews(@TestedViews)
	IF @Valid = 0
	BEGIN
		PRINT 'Invalid view name!'
		RETURN
	END

	DECLARE @StartTotalTime DATETIME = GETDATE()
	INSERT INTO TestRuns(Description, StartAt, EndAt) VALUES
		(@TestName +' on: ' + @TestedTables + ' and on: ' + @TestedViews, @StartTotalTime, GETDATE())

	DECLARE @CurrentTestRunID INT = @@IDENTITY

	-- tests execution
		-- test delete

	DECLARE @DeleteOrder VARCHAR(500) = [dbo].reverseOrder(@TestedTables)
	EXEC RunDelete @DeleteOrder
	
		-- test insert
	EXEC RunInsert @TestedTables, @TestID, @CurrentTestRunID

		-- test views
	
	EXEC RunViews @TestedViews, @CurrentTestRunID

	DECLARE @EndTotalTime DATETIME = GETDATE()
	UPDATE TestRuns 
	SET EndAt = @EndTotalTime
	WHERE TestRunID = @CurrentTestRunID

	SELECT *, DATEDIFF(millisecond, StartAt, EndAt) AS 'Total Time (millisec)'
	FROM TestRuns

	SELECT *, DATEDIFF(millisecond, StartAt, EndAt) AS 'Total Time (millisec)'
	FROM TestRunViews

	SELECT *, DATEDIFF(millisecond, StartAt, EndAt) AS 'Total Time (millisec)'
	FROM TestRunTables
GO

USE HospitalTest

EXEC RunTest 'Doctor,Department,Nurse,Room', 'Test_1000', 'DeptView,SupervisorNurseView,DeptDocView'

SELECT *, DATEDIFF(millisecond, StartAt, EndAt) AS 'Total Time (millisec)'
FROM TestRuns

SELECT *, DATEDIFF(millisecond, StartAt, EndAt) AS 'Total Time (millisec)'
FROM TestRunViews

SELECT *, DATEDIFF(millisecond, StartAt, EndAt) AS 'Total Time (millisec)'
FROM TestRunTables

DELETE FROM TestRuns
DELETE FROM TestRunViews
DELETE FROM TestRunTables



GO
