CREATE DATABASE MedicineModel;

USE MedicineModel;

CREATE TABLE Medicine(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	expiration DATE
);

INSERT INTO Medicine VALUES ('m1','2020-04-04'),('m2','2020-10-10'),('m3','2020-12-29');

CREATE TABLE Pharmacy(
	id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(30),
	address VARCHAR(30)
);

INSERT INTO Pharmacy VALUES ('p1','addr1'),('p2','addr2'),('p3','addr3');

CREATE TABLE Stock(
	lastbuy TIME,
	med_id INT REFERENCES Medicine(id),
	pharm_id INT REFERENCES Pharmacy(id),
	PRIMARY KEY (med_id, pharm_id)
);

INSERT INTO Stock VALUES ('12:15',1,1),('10:24',1,2),('06:30',1,3),('12:15:59',3,3);
SELECT * FROM Stock;

CREATE TABLE Office(
	id INT PRIMARY KEY IDENTITY(1,1),
	office_name VARCHAR(30) UNIQUE,
	office_address VARCHAR(30)
);

INSERT INTO Office VALUES ('o1','oaddr1'),('o2','oaddr2');

CREATE TABLE Prescription(
	refno INT PRIMARY KEY,
	issued_by INT FOREIGN KEY REFERENCES Office(id)
);

INSERT INTO Prescription VALUES (1,1),(2,1),(3,2);

CREATE TABLE PrescriptionLog(
	ref INT REFERENCES Prescription(refno),
	med INT REFERENCES Medicine(id),
	PRIMARY KEY (ref,med)
);

INSERT INTO PrescriptionLog VALUES (1,1),(1,3),(2,3),(3,3);

SELECT * FROM Stock;
SELECT * FROM Prescription;
SELECT * FROM PrescriptionLog;

GO
CREATE OR ALTER PROCEDURE usp_deletePrescriptions(@office_name VARCHAR(30))
AS
	DECLARE @office_id INT
	SET @office_id = (SELECT o.id
					  FROM Office o
					  WHERE o.office_name = @office_name)
	IF @office_id IS NULL
	BEGIN
		PRINT 'No office with this name'
		RETURN
	END

	DELETE FROM PrescriptionLog
	WHERE ref IN (SELECT p.refno
				  FROM Prescription p
				  WHERE p.issued_by = @office_id)
GO

EXEC usp_deletePrescriptions '';
EXEC usp_deletePrescriptions 'o1';

SELECT * FROM Medicine;
SELECT * FROM Pharmacy;
SELECT * FROM Stock;

--medicines that appear in all pharmacies
GO
CREATE OR ALTER VIEW viewShowMedicines
AS
	SELECT m.name
	FROM Medicine m
	WHERE NOT EXISTS ( 
		SELECT p.id
		FROM Pharmacy p
		EXCEPT 
		SELECT s.pharm_id
		FROM Stock s
		WHERE s.med_id = m.id)
GO

SELECT * FROM viewShowMedicines;

GO
CREATE OR ALTER FUNCTION uf_returnNames(@d DATE, @p INT)
RETURNS TABLE
AS
	RETURN
	SELECT m.name
	FROM Medicine m
	WHERE m.expiration > @d AND m.id IN
			(
			SELECT s.med_id
			FROM Stock s
			GROUP BY s.med_id
			HAVING COUNT(*) >= @p)
GO

SELECT * FROM uf_returnNames('2000-01-01',2);