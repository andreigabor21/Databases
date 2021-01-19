USE HospitalTest

-- a single-column primary key and no foreign keys

CREATE TABLE Department
(DeptID INT PRIMARY KEY,
DeptName VARCHAR(50),
Capacity INT)


-- a single-column primary key and at least one foreign key

CREATE TABLE Doctor
(DocID INT PRIMARY KEY,
FName VARCHAR(50),
LName VARCHAR(50),
CNP CHAR(14) UNIQUE,
Specialty VARCHAR(50),
DeptID INT,
FOREIGN KEY (DeptID) REFERENCES Department(DeptID) ON DELETE CASCADE,
Score TINYINT)


-- a multicolumn primary key

CREATE TABLE Nurse
(NurseID INT,
FName VARCHAR(50),
LName VARCHAR(50),
CNP CHAR(14) UNIQUE,
Specialty VARCHAR(50),
DeptID INT FOREIGN KEY REFERENCES Department(DeptID) ON DELETE CASCADE,
SupervisorID INT FOREIGN KEY REFERENCES Doctor(DocID),
PRIMARY KEY(NurseID, DeptID))


CREATE TABLE Room
(DeptID INT,
FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
RoomNumber INT PRIMARY KEY,
RoomFloor TINYINT,
RoomType VARCHAR(50))

