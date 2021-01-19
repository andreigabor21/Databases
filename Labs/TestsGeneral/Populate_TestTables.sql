
USE HospitalTest

GO

INSERT INTO Tables(Name) VALUES
	('Department'),
	('Doctor'),
	('Nurse'),
	('Room')

INSERT INTO Tests(Name) VALUES
	('Test_1000'),
	('Test_5000'),
	('Test_10000')


INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES
	((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Department'),  1000, 1),

	((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Doctor'),  1000, 2),

	((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Nurse'),  1000, 3),

	 ((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Room'),  1000, 2),


	((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Department'),  5000, 1),

	((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Doctor'),  5000, 2),

	((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Nurse'),  5000, 3),

	 ((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Room'),  1000, 2),


	((SELECT TestID FROM Tests WHERE Name = 'Test_10000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Department'),  10000, 1),

	((SELECT TestID FROM Tests WHERE Name = 'Test_10000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Doctor'),  10000, 2),

	((SELECT TestID FROM Tests WHERE Name = 'Test_10000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Nurse'),  10000, 3),

	 ((SELECT TestID FROM Tests WHERE Name = 'Test_10000'),
	 (SELECT TableID FROM Tables WHERE Name = 'Room'),  1000, 2)


INSERT INTO Views(Name) VALUES
	('DeptView'),
	('DeptDocView'),
	('SupervisorNurseView')

INSERT INTO TestViews(TestID, ViewID) VALUES
	((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT ViewID FROM Views WHERE Name = 'DeptView')),

	((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT ViewID FROM Views WHERE Name = 'DeptDocView')),

	((SELECT TestID FROM Tests WHERE Name = 'Test_1000'),
	 (SELECT ViewID FROM Views WHERE Name = 'SupervisorNurseView')),


	((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT ViewID FROM Views WHERE Name = 'DeptView')),

	((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT ViewID FROM Views WHERE Name = 'DeptDocView')),

	((SELECT TestID FROM Tests WHERE Name = 'Test_5000'),
	 (SELECT ViewID FROM Views WHERE Name = 'SupervisorNurseView'))
    

SELECT * FROM TestTables