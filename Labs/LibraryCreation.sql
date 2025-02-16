CREATE DATABASE BookLibrary;

USE BookLibrary;

CREATE TABLE Client
(
	CId INT PRIMARY KEY NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	SecondName VARCHAR(20) NOT NULL,
	SSN VARCHAR(14) NOT NULL,
	CAddress VARCHAR(50),
	PhoneNumber VARCHAR(12),
	Email VARCHAR(20),
	RegistrationDate date,
	CGId INT FOREIGN KEY REFERENCES ClientsGroups(CGId)
)

CREATE TABLE ClientsGroups
(
	CGId INT PRIMARY KEY IDENTITY(1, 1),
	CGName VARCHAR(30) NOT NULL,
	hasDebt BIT DEFAULT 0
)

CREATE TABLE Debtors
(
	CId INT FOREIGN KEY REFERENCES Client(CId),
	CGId INT FOREIGN KEY REFERENCES ClientsGroups(CGId),
	PRIMARY KEY (CId, CGId),
	SumToPay INT 
)

CREATE TABLE PublishingHouse
(
	PHId INT PRIMARY KEY NOT NULL,
	PName VARCHAR(20) NOT NULL,
	PAddress VARCHAR(50),
	Email VARCHAR(25),
	PhoneNumber VARCHAR(12),
	Website VARCHAR(20)
)

CREATE TABLE Category
(
	CategoryID INT PRIMARY KEY IDENTITY(1, 1),
	CategoryName VARCHAR(15),
	Points INT NOT NULL
)

CREATE TABLE CoverType
(
	CVId INT PRIMARY KEY IDENTITY(1, 1),
	Fabric VARCHAR(15)
)

CREATE TABLE Languages
(
	LId INT PRIMARY KEY IDENTITY(1, 1),
	LName VARCHAR(20)
)

CREATE TABLE Loans
(
	CId INT FOREIGN KEY REFERENCES Client(CId),
	ISBN BIGINT FOREIGN KEY REFERENCES Books(ISBN),
	PRIMARY KEY (CId, ISBN),
	LoanDate DATE NOT NULL,
	DueDate DATE NOT NULL,
	IsReturned BIT,
	RestitutionDate DATE
)

CREATE TABLE Books
(
	ISBN BIGINT PRIMARY KEY NOT NULL,
	BCount INT NOT NULL,
	PHId INT FOREIGN KEY REFERENCES PublishingHouse(PHId),
	LId INT FOREIGN KEY REFERENCES Languages(LId),
	CategoryID INT FOREIGN KEY REFERENCES Category(CategoryID),
	Author VARCHAR(30),
	YearOfPublication INT,
	CoverType INT FOREIGN KEY REFERENCES CoverType(CVId),
	BDescription VARCHAR(300),
)

CREATE TABLE Votes
(
	VoteID INT PRIMARY KEY IDENTITY,
	ISBN BIGINT FOREIGN KEY REFERENCES Books(ISBN),
	NumberOfStars INT,
	DateOfVote DATE
)
