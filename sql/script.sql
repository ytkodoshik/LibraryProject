/*
 * LIBRARY MANAGEMENT SYSTEM - DATABASE SCRIPT
 * * Description: Full database schema, constraints, triggers, and stored procedures.
 * Author: [Twoje Imie]
 */

USE Biblioteka;
GO

-- =============================================
-- 1. TABLES & CONSTRAINTS
-- =============================================

-- Table: Library (Biblioteka)
CREATE TABLE Biblioteka (
    ID_Biblioteki INT PRIMARY KEY,
    Nazwa NVARCHAR(100) NOT NULL CHECK (Nazwa NOT LIKE '%[!@#\$%^&*(),.?":{}|<>]%' AND Nazwa <> ''),
    Adres NVARCHAR(255) NOT NULL,
    Kierownik NVARCHAR(100),
    CONSTRAINT CK_Biblioteka_Kierownik_NotEmpty CHECK (Kierownik IS NOT NULL)
);

-- Table: Reader (Czytelnik)
CREATE TABLE Czytelnik (
    ID_Czytelnika INT PRIMARY KEY,
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(50) NOT NULL,
    PESEL CHAR(11) NOT NULL,
    Adres NVARCHAR(255) NOT NULL,
    Data_Rejestracji DATE NOT NULL CHECK (Data_Rejestracji <= GETDATE()),
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Aktywny', 'Nieaktywny')),
    CONSTRAINT CK_PESEL_Format CHECK (ISNUMERIC(PESEL) = 1 AND LEN(PESEL) = 11)
);

-- Table: Book (Ksiazka)
CREATE TABLE Ksiazka (
    ID_Ksiazki INT PRIMARY KEY,
    Tytul NVARCHAR(200) NOT NULL,
    Autor NVARCHAR(100) NOT NULL,
    ISBN CHAR(13) NOT NULL,
    Rok_Wydania INT CHECK (Rok_Wydania BETWEEN 1000 AND YEAR(GETDATE())),
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Dostępna', 'Wypożyczona', 'Zarezerwowana', 'Usunięta')),
    CONSTRAINT CK_ISBN_Format CHECK (ISNUMERIC(ISBN) = 1 AND LEN(ISBN) = 13)
);

-- Table: Loan (Wypozyczenie)
CREATE TABLE Wypozyczenie (
    ID_Wypozyczenia INT PRIMARY KEY,
    ID_Czytelnika INT NOT NULL,
    ID_Ksiazki INT NOT NULL,
    Data_Wypozyczenia DATE NOT NULL CHECK (Data_Wypozyczenia <= GETDATE()),
    Termin_Zwrotu DATE NOT NULL,
    Data_Zwrotu DATE,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('W trakcie', 'Zwrócona', 'Przeterminowana')),
    FOREIGN KEY (ID_Czytelnika) REFERENCES Czytelnik(ID_Czytelnika),
    FOREIGN KEY (ID_Ksiazki) REFERENCES Ksiazka(ID_Ksiazki)
);

-- Table: Reservation (Rezerwacja)
CREATE TABLE Rezerwacja (
    ID_Rezerwacji INT PRIMARY KEY,
    ID_Czytelnika INT NOT NULL,
    ID_Ksiazki INT NOT NULL,
    Data_Rezerwacji DATE NOT NULL,
    Status_Rezerwacji NVARCHAR(20) NOT NULL CHECK (Status_Rezerwacji IN ('Aktywna', 'Anulowana', 'Zrealizowana')),
    FOREIGN KEY (ID_Czytelnika) REFERENCES Czytelnik(ID_Czytelnika),
    FOREIGN KEY (ID_Ksiazki) REFERENCES Ksiazka(ID_Ksiazki)
);
GO

-- =============================================
-- 2. TRIGGERS
-- =============================================

-- Trigger: Validate Loan Return Date
CREATE TRIGGER TRG_Wypozyczenie_Termin
ON Wypozyczenie
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Termin_Zwrotu <= Data_Wypozyczenia)
    BEGIN
        RAISERROR('Return date must be later than loan date.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger: Validate Reservation Date
CREATE TRIGGER TRG_Rezerwacja_Data
ON Rezerwacja
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Data_Rezerwacji < CAST(GETDATE() AS DATE))
    BEGIN
        RAISERROR('Reservation date cannot be in the past.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- =============================================
-- 3. STORED PROCEDURES
-- =============================================

-- Add Reader
CREATE PROCEDURE DodajCzytelnika
    @ID_Czytelnika INT, @Imie NVARCHAR(50), @Nazwisko NVARCHAR(50), 
    @PESEL CHAR(11), @Adres NVARCHAR(255), @Data_Rejestracji DATE, @Status NVARCHAR(20)
AS
BEGIN
    INSERT INTO Czytelnik (ID_Czytelnika, Imie, Nazwisko, PESEL, Adres, Data_Rejestracji, Status)
    VALUES (@ID_Czytelnika, @Imie, @Nazwisko, @PESEL, @Adres, @Data_Rejestracji, @Status);
END
GO

-- Register Loan
CREATE PROCEDURE ZarejestrujWypozyczenie
    @ID_Wypozyczenia INT, @ID_Czytelnika INT, @ID_Ksiazki INT, 
    @Data_Wypozyczenia DATE, @Termin_Zwrotu DATE, @Status NVARCHAR(20)
AS
BEGIN
    INSERT INTO Wypozyczenie (ID_Wypozyczenia, ID_Czytelnika, ID_Ksiazki, Data_Wypozyczenia, Termin_Zwrotu, Status)
    VALUES (@ID_Wypozyczenia, @ID_Czytelnika, @ID_Ksiazki, @Data_Wypozyczenia, @Termin_Zwrotu, @Status);
END
GO

-- Register Return
CREATE PROCEDURE ZarejestrujZwrot
    @ID_Wypozyczenia INT, @Data_Zwrotu DATE
AS
BEGIN
    DECLARE @ID_Ksiazki INT;
    SELECT @ID_Ksiazki = ID_Ksiazki FROM Wypozyczenie WHERE ID_Wypozyczenia = @ID_Wypozyczenia;

    UPDATE Wypozyczenie
    SET Data_Zwrotu = @Data_Zwrotu, Status = 'Zwrócona'
    WHERE ID_Wypozyczenia = @ID_Wypozyczenia;

    UPDATE Ksiazka
    SET Status = 'Dostępna'
    WHERE ID_Ksiazki = @ID_Ksiazki;
END
GO
