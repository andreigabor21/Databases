USE HospitalTest
GO

-- a view with a SELECT statement operating on one table >> Get all the departments which have an ID less than 2000.

CREATE OR ALTER VIEW DeptView
AS
	SELECT *
	FROM Department
	WHERE DeptID < 2000
GO

-- a view with a SELECT statement operating on at least 2 tables >> Get all the doctors assigned to a department having
--a capacity greater than 100.

CREATE OR ALTER VIEW DeptDocView
AS
	SELECT D.DeptID, D.DeptName, DOC.DocID, DOC.FName, DOC.LName, DOC.Specialty
	FROM Department D INNER JOIN Doctor DOC ON D.DeptID = DOC.DeptID
	WHERE D.Capacity >= 100
GO

-- a view with a SELECT statement that has a GROUP BY clause and operates on at least 2 tables >> Get ID, name, specialty,
--department ID and the number of supervised nurses for all the doctors that supervise at least a nurse.

CREATE OR ALTER VIEW SupervisorNurseView
AS
	SELECT S.*, D.FName, D.LName, D.Specialty, D.DeptID
	FROM (SELECT SupervisorID, COUNT(*) AS NoOfNurses
		  FROM Nurse N 
	      GROUP BY N.SupervisorID) AS S
		  INNER JOIN Doctor D ON S.SupervisorID = D.DocID
GO


CREATE OR ALTER PROCEDURE Select_View 
@ViewName VARCHAR(100)
AS
	--IF @ViewName NOT IN (SELECT name
	--					 FROM sys.objects
	--					 WHERE type = 'V')
	--BEGIN
	--	PRINT 'Invalid View Name!'
	--	RETURN
	--END

	DECLARE @selectAction NVARCHAR(200)
	SET @selectAction = 'SELECT * FROM ' + @ViewName 

	EXECUTE sp_executesql @selectAction
GO


