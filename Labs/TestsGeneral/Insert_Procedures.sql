--insert procedures

--CREATE OR ALTER PROCEDURE Insert_Into_Department 
--@NoOfRows INT
--AS
--	DECLARE @CurrentRow INT = 0

--	DECLARE @DeptID INT = 1000
--	DECLARE @DeptName VARCHAR(100) = 'deptName'
--	DECLARE @CurrentName VARCHAR(100)
--	DECLARE @DeptCapacity INT = 100

--	WHILE @CurrentRow < @NoOfRows
--	BEGIN
--		SET @DeptID = @DeptID + 1
--		SET @CurrentName = @DeptName + CAST(@DeptID AS VARCHAR)

--		INSERT INTO Department(DeptID, DeptName, Capacity) VALUES
--		(@DeptID, @DeptName, @DeptCapacity)
		
--		SET @CurrentRow = @CurrentRow + 1
--	END
--GO

--CREATE OR ALTER PROCEDURE Insert_Into_Doctor 
--@NoOfRows INT
--AS
--	DECLARE @CurrentRow INT = 0

--	DECLARE @DocID INT = 1000
--	DECLARE @DeptID INT = (SELECT TOP 1 DeptID
--						   FROM Department)
--	DECLARE @FName VARCHAR(100) = 'FName'
--	DECLARE @LName VARCHAR(100) = 'LName'
--	DECLARE @CNP BIGINT = 10000000000000
--	DECLARE @Specialty VARCHAR(100) = 'Specialty'
--	DECLARE @Score TINYINT = 10

--	WHILE @CurrentRow < @NoOfRows
--	BEGIN
--		SET @DocID = @DocID + 1

--		INSERT INTO Doctor(DocID, FName, LName, CNP, Specialty, DeptID, Score) VALUES
--		(@DocID, @FName + CAST(@DocID AS VARCHAR), @LName + CAST(@DocID AS VARCHAR), CAST((@CNP + @DocID) AS VARCHAR), 
--		 @Specialty + CAST(@DocID AS VARCHAR), @DeptID, @Score)
		
--		SET @CurrentRow = @CurrentRow + 1
--	END

--GO

--CREATE OR ALTER PROCEDURE Insert_Into_Nurse 
--@NoOfRows INT
--AS
--	DECLARE @CurrentRow INT = 0

--	DECLARE @NurseID INT = 1000
--	DECLARE @DeptID INT = (SELECT TOP 1 DeptID
--						   FROM Department)
--	DECLARE @SupervisorID INT = (SELECT TOP 1 DocID
--						         FROM Doctor)

--	DECLARE @FName VARCHAR(100) = 'FName'
--	DECLARE @LName VARCHAR(100) = 'LName'
--	DECLARE @CNP BIGINT = 10000000000000
--	DECLARE @Specialty VARCHAR(100) = 'Specialty'

--	WHILE @CurrentRow < @NoOfRows
--	BEGIN
--		SET @NurseID = @NurseID + 1

--		INSERT INTO Nurse(NurseID, FName, LName, CNP, Specialty, DeptID, SupervisorID) VALUES
--		(@NurseID, @FName + CAST(@NurseID AS VARCHAR), @LName + CAST(@NurseID AS VARCHAR), CAST((@CNP + @NurseID) AS VARCHAR), 
--		 @Specialty + CAST(@NurseID AS VARCHAR), @DeptID, @SupervisorID)
		
--		SET @CurrentRow = @CurrentRow + 1
--	END
--GO





CREATE OR ALTER PROCEDURE getNextValue @TableName VARCHAR(50), @ColumnName VARCHAR(100), @ColumnType VARCHAR(50), 
									   @MaxLength INT, @InsertAction VARCHAR(MAX), @RowNumber INT,
									   @FinalInsertAction VARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @FKTableName VARCHAR(50)
	DECLARE @FKColumnName VARCHAR(100)

	SELECT @FKTableName = KCU1.TABLE_NAME, @FKColumnName = KCU1.COLUMN_NAME
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
		on KCU.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU1
		on KCU1.CONSTRAINT_NAME = RC.UNIQUE_CONSTRAINT_NAME
	WHERE KCU.TABLE_NAME = @TableName AND KCU.COLUMN_NAME = @ColumnName

	-- if the column has a foreign key constraint, we select the first value of the column from the referenced table
	IF @FKTableName IS NOT NULL AND @FKColumnName IS NOT NULL
	BEGIN
		DECLARE @ResultTable TABLE (Result VARCHAR(100))

		DECLARE @GetFKAction NVARCHAR(MAX) = 'DECLARE @FKValue VARCHAR(100)
											  SELECT TOP 1 @FKValue = CAST(' + @FKColumnName + ' AS VARCHAR) FROM ' + @FKTableName
											  + ' SELECT @FKValue'
		INSERT INTO @ResultTable
		EXECUTE sp_executesql @GetFKAction

		DECLARE @FKValueFinal VARCHAR(100)
		SELECT @FKValueFinal = Result FROM @ResultTable
		SET @InsertAction = @InsertAction + ' ' + @FKValueFinal
	END
	-- otherwise we have to insert a value (distinct every time, for ensuring the possible uniqueness constraints), coresponding to the given type:
	ELSE
	BEGIN
		DECLARE @ValueToInsert VARCHAR(MAX)

		IF @ColumnType IN ('int', 'float', 'bigint', 'decimal', 'numeric', 'real')
		BEGIN
			SET @ValueToInsert = CAST(@RowNumber AS VARCHAR)
			SET @InsertAction = @InsertAction + ' ' + @ValueToInsert
		END

		ELSE IF @ColumnType = 'tinyint'
		BEGIN
			SET @ValueToInsert = CAST(@RowNumber % 250 AS VARCHAR)
			SET @InsertAction = @InsertAction + ' ' + @ValueToInsert
		END

		ELSE IF @ColumnType IN ('varchar', 'text', 'nvarchar', 'ntext', 'varbinary')
		BEGIN
			IF len(CAST (@RowNumber AS VARCHAR)) < @MaxLength 
			BEGIN
				SET @ValueToInsert = CAST(@RowNumber AS VARCHAR)
			END
			ELSE
			BEGIN
				SET @ValueToInsert = CAST(@RowNumber % @MaxLength AS VARCHAR)
			END
			SET @InsertAction = @InsertAction + ' ''' + @ValueToInsert + ''' '
		END

		ELSE IF @ColumnType = 'char'
		BEGIN
			IF len(CAST (@RowNumber AS VARCHAR)) < @MaxLength 
			BEGIN
				DECLARE @NumberValue BIGINT = POWER(CAST(10 AS BIGINT), @MaxLength - 1) + CAST(@RowNumber AS BIGINT)
				SET @InsertAction = @InsertAction + ' ''' + CAST(@NumberValue AS VARCHAR) + ''' '
			END
			ELSE
			BEGIN
				SET @ValueToInsert = CAST(@RowNumber % @MaxLength AS VARCHAR)
				SET @InsertAction = @InsertAction + ' ''' + @ValueToInsert + ''' '
			END
		END

		ELSE IF @ColumnType IN ('datetime', 'date', 'datetime2')
		BEGIN
			SET @InsertAction = @InsertAction + ' GETTIME() '
		END

	END
	SET @FinalInsertAction = @InsertAction
END
GO

CREATE OR ALTER PROCEDURE Insert_Into_Table @TableName VARCHAR(50), @NoOfRows INT
AS
	DECLARE @ColumnName VARCHAR(100), @ColumnType  VARCHAR(50), @MaxLength INT
	DECLARE @CurrentRow INT = 1
	DECLARE @FinalInsertAction VARCHAR(MAX) = 'INSERT INTO ' + @TableName + ' VALUES ('

	DECLARE @Cursor CURSOR 
	SET @Cursor = CURSOR FOR	
		SELECT COL.name, T.name, COL.max_length
		FROM sys.objects AS OBJ
		INNER JOIN sys.columns AS COL ON COL.object_id = OBJ.object_id 
		INNER JOIN sys.types AS T ON COL.user_type_id = T.user_type_id
		WHERE OBJ.type = 'U' and OBJ.object_id = OBJECT_ID(@TableName)

	WHILE @CurrentRow <= @NoOfRows
	BEGIN
		OPEN @Cursor
		FETCH @Cursor
		INTO @ColumnName, @ColumnType, @MaxLength

		SET @FinalInsertAction = 'INSERT INTO ' + @TableName + ' VALUES ('
		DECLARE @InsertActionInput VARCHAR(MAX) = @FinalInsertAction
		DECLARE @TempInsertAction VARCHAR(MAX)

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC getNextValue @Tablename, @ColumnName, @ColumnType, @MaxLength, @InsertActionInput, @CurrentRow,
				@TempInsertAction OUTPUT

			SET @InsertActionInput = @TempInsertAction
			FETCH @Cursor
			INTO @ColumnName, @ColumnType, @MaxLength
			IF @@FETCH_STATUS=0
			BEGIN
				SET @InsertActionInput =  @InsertActionInput + ','
			END
			SET @FinalInsertAction = @InsertActionInput
		END
		SET @FinalInsertAction = @FinalInsertAction + ')'
		CLOSE @Cursor

		BEGIN TRY
			EXEC(@FinalInsertAction)
			SET @CurrentRow = @CurrentRow + 1
		END TRY
		BEGIN CATCH  
			PRINT ERROR_MESSAGE() 
		END CATCH
		
	END
	DEALLOCATE @Cursor
GO



GO
EXEC Insert_Into_Table 'Doctor', 10

SELECT * FROM Doctor

INSERT INTO Department VALUES
(123, 'name', 100)
