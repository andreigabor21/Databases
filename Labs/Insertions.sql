--INSERTs for CoverType
USE BookLibrary;

INSERT INTO CoverType
VALUES ('Paperback');

INSERT INTO CoverType
VALUES ('Hardcover');

INSERT INTO CoverType
VALUES ('Flexibound');

INSERT INTO CoverType
VALUES ('Plastified');

INSERT INTO CoverType
VALUES ('Spiral-Bound');

SELECT * FROM CoverType;

--INSERTs for Category

INSERT INTO Category
VALUES ('SF', 8);

INSERT INTO Category
VALUES ('History', 6);

INSERT INTO Category
VALUES ('Medicine', 7);

INSERT INTO Category
VALUES ('Computers', 9);

INSERT INTO Category
VALUES ('Health', 10);

INSERT INTO Category
VALUES ('Psychology', 5);

INSERT INTO Category
VALUES ('Math', 8);

SELECT * FROM Category;

--INSERTs for Languages

INSERT INTO Languages
VALUES('Romanian');

INSERT INTO Languages
VALUES('English');

INSERT INTO Languages
VALUES('Spanish');

INSERT INTO Languages
VALUES('Italian');

INSERT INTO Languages
VALUES('German');

SELECT * FROM Languages;

--INSERTs for PublishingHouse

INSERT INTO PublishingHouse
VALUES(1, 'Polirom', 'Bd. Carol I, nr. 4, 700506', 'office@polirom.ro', '0232217440', 'www.polirom.ro');

INSERT INTO PublishingHouse
VALUES(2, 'Litera', 'Strada Moeciu Nr. 7A, Bucuresti 077190', 'info@litera.ro', '0752101770', 'www.litera.ro');

INSERT INTO PublishingHouse
VALUES(3, 'RAO', 'Strada Bargaului 11, Bucuresti', 'libraria.rao@rao.ro', '0729166965', 'www.raobooks.com')

INSERT INTO PublishingHouse
VALUES(4, 'Humanitas', 'Piata Presei Libere nr. 1 Bucuresti', 'contact@humanitas.ro', '0234765919', 'www.humanitas.ro');

INSERT INTO PublishingHouse
VALUES(5, 'Curtea Veche', 'Strada Aurel Vlaicu 35, Bucuresti 030167', 'comenzi@curteaveche.ro', '0212224765', 'www.curteaveche.ro');

SELECT * FROM PublishingHouse;

--INSERTs for Books

INSERT INTO Books
VALUES(9789734681815, 4, 1, 1, 2, 'IOAN T. MORAR', 2020, 1, 'Fake news in Epoca de Aur', 'Fie ca si-a propus, fie ca nu, Ioan T. Morar ne ofera o savuroasa contra-istorie.');

INSERT INTO Books
VALUES(9786063366796, 2, 2, 2, 6, 'BARACK OBAMA', 2020, 2, 'Pamantul fagaduintei', 'Nimic nu se compara cu sentimentul pe care-l ai cand termini de scris o carte.');

INSERT INTO Books
VALUES(9786060063919, 1, 3, 3, 1, 'WILBUR SMITH', 2019, 3, 'Faraonul', 'Povestea aduce in prim-planul prezentului o ipostaza istorica uimitoare: faraonul Tamose este ranit mortal, iar orasul Luxor este inconjurat de hicsosi intr-un asediu fara precedent.');

INSERT INTO Books
VALUES(9789735067892, 3, 4, 4, 2, 'BILL MESLER', 2018, 4, 'Scurta istorie a creatiei', 'Aparitia vietii este poate cea mai provocatoare si mai importanta enigma pe care stiinta incearca s-o rezolve.');

INSERT INTO Books
VALUES(9789734731961, 5, 2, 3, 4, 'ANGIE SMIBERT', 2020, 1, 'Inteligenta artificiala', 'Afla totul despre masinile care opereaza cu date si invata, despre roboti care pot ajuta oamenii intr-un mod uimitor.');

INSERT INTO Books
VALUES(9789736499708, 3, 5, 1, 7, 'GHEORGHE TITEICA', 2014, 1, 'Probleme de geometrie...', 'Volumul de fata reuneste o selectie de articole ale lui Gheorghe Titeica din revista Natura – Revista stiintifica de popularizare.');

INSERT INTO Books
VALUES(9789735065546, 4, 4, 5, 7, 'PIETRO GRECO', 2019, 5, 'Povestea numarului PI', 'Nici un alt numar n-a dobandit celebritatea (matematica si nu numai) de care se bucura numarul Pi, raportul dintre circumferinta unui cerc si diametrul lui');

SELECT * FROM Books;

--INSERTs for Votes

INSERT INTO Votes
VALUES(9789734681815, 4, '06-09-2020');

INSERT INTO Votes
VALUES(9789734681815, 5, '10-08-2020');

INSERT INTO Votes
VALUES(9789734731961, 3, '10-07-2020');

INSERT INTO Votes
VALUES(9789735065546, 4, '07-07-2020');

INSERT INTO Votes
VALUES(9789735067892, 5, '02-02-2019');

INSERT INTO Votes
VALUES(9786060063919, 2, '06-15-2020');

INSERT INTO Votes
VALUES(9789736499708, 4, '05-21-2020');

SELECT * FROM Votes;

--INSERTs for ClientsGroups

INSERT INTO ClientsGroups
VALUES('Best', 0);

INSERT INTO ClientsGroups
VALUES('Good', 0);

INSERT INTO ClientsGroups
VALUES('Average', 0);

INSERT INTO ClientsGroups
VALUES('Bad', 1);

INSERT INTO ClientsGroups
VALUES('Worst', 1);

SELECT * FROM ClientsGroups;

--INSERTs for Client

INSERT INTO Client
VALUES(1, 'Andrei', 'Gabor', '5000521125835', 'Cluj Republicii Nr.928', '0751487959', 'andreigabor36@gmail.com', '06-06-2020', 1);

INSERT INTO Client
VALUES(2, 'Matei', 'Giurgiu', '5000528946210', 'Sopor Nr.87', '0264897123', 'mateigiurgiu@yahoo.com', '10-10-2019', 3);

INSERT INTO Client
VALUES(3, 'Vlad', 'Ghetina', '5000529276810', 'Satu Mare, Str.Brutariei, Nr.2', '0751849134', 'vladghetina@gmail.com', '08-15-2019', 4);

INSERT INTO Client
VALUES(4, 'Dragos', 'Muresan', '5000987123501', 'Cluj Manastur Bl.3 Ap.4', '0264371498', 'muresandragos@yahoo.com', '10-15-2019', 2);

INSERT INTO Client
VALUES(5, 'Andrei', 'Ardelean', '5000123456789', 'Cluj Calea Floresti Nr.5', '0751490231', 'ardeleanandrei@gmail.com', '08-08-2018', 5);

--INSERTs for Loans

INSERT INTO Loans
VALUES(1, 9789735065546, '09-10-2020', '09-20-2020', 1, '09-16-2020');

INSERT INTO Loans
VALUES(4, 9789735067892, '2020-08-16', '2020-08-28', 1, '2020-08-30'); --plata mica

INSERT INTO Loans
VALUES(5, 9786060063919, '2020-07-02', '2020-08-05', 0, NULL); --plata mare

INSERT INTO Loans
VALUES(3, 9786063366796, '2020-08-16', '2020-08-27', 1, '2020-08-29'); --plata mica

INSERT INTO Loans
VALUES(2, 9789734731961, '2020-09-15', '2020-09-30', 1, '2020-09-28');

SELECT * FROM Loans;

--INSERTs for Debtors

INSERT INTO Debtors
VALUES(4, 2, 5);

INSERT INTO Debtors
VALUES(5, 5, 60);

INSERT INTO Debtors
VALUES(3, 4, 3);

SELECT * FROM Debtors;


