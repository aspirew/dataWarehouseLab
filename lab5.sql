-- zad 1

DROP TABLE IF EXISTS Behrendt.FACT_SALES;
DROP TABLE IF EXISTS Behrendt.DIM_CUSTOMER;
DROP TABLE IF EXISTS Behrendt.DIM_PRODUCT;
DROP TABLE IF EXISTS Behrendt.DIM_TIME;

GO
IF (
SELECT COUNT(*) FROM  INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'DIM_SALESPERSON'
AND TABLE_SCHEMA = 'Behrendt'
AND TABLE_CATALOG = 'AdventureWorks2016'
 ) > 0
 DROP TABLE Behrendt.DIM_SALESPERSON;

 -- zad 2

 CREATE TABLE Behrendt.MONTHS (
     MonthID INT PRIMARY KEY NOT NULL,
     [Name] NVARCHAR(20)
 )

  INSERT INTO Behrendt.MONTHS VALUES (1, 'styczen'), (2, 'luty'), (3, 'marzec'), (4, 'kwiecien'), (5, 'maj'), (6, 'czerwiec'), (7, 'lipiec'),
  (8, 'sierpien'), (9, 'wrzesien'), (10, 'pazdziernik'), (11, 'listopad'), (12, 'grudzien')

 CREATE TABLE Behrendt.WEEKS (
     WeekID INT PRIMARY KEY NOT NULL,
     [Name] NVARCHAR(20)
 )

 INSERT INTO Behrendt.WEEKS VALUES (1, 'niedziela'), (2, 'poniedzialek'), (3, 'wtorek'), (4, 'sroda'), (5, 'czwartek'), (6, 'piatek'), (7, 'sobota')

 CREATE TABLE Behrendt.DIM_TIME (
     PK_TIME INT NOT NULL PRIMARY KEY,
     Rok INT,
     Kwartal INT,
     Miesiac INT,
     Miesiac_slownie NVARCHAR(20),
     Dzien_tyg_slownie NVARCHAR(20),
     Dzien_miesiaca INT
 )

-- ALTER TABLE Behrendt.DIM_TIME
-- ADD CONSTRAINT fk_PK_TIME FOREIGN KEY(PK_TIME) REFERENCES Behrendt.FACT_SALES(OrderDate, ShipDate);

INSERT INTO Behrendt.DIM_TIME (PK_TIME)
SELECT DISTINCT OrderDate FROM Behrendt.FACT_SALES
UNION 
SELECT DISTINCT ShipDate FROM Behrendt.FACT_SALES
ORDER BY 1


DECLARE @currentDate date;

UPDATE Behrendt.DIM_TIME
SET 
@currentDate = CONVERT(date,convert(char(8), PK_TIME)),
Rok = DATEPART(yy, @currentDate),
Kwartal = DATEPART(qq, @currentDate),
Miesiac = DATEPART(mm, @currentDate),
Miesiac_slownie = Behrendt.MONTHS.[Name],
Dzien_tyg_slownie = Behrendt.WEEKS.[Name],
Dzien_miesiaca = DATEPART(dd, @currentDate)
FROM Behrendt.MONTHS, Behrendt.WEEKS WHERE MonthID = DATEPART(mm, CONVERT(date,convert(char(8), PK_TIME)))
AND WeekID = DATEPART(dw, CONVERT(date,convert(char(8), PK_TIME)))


-- zad 3

UPDATE Behrendt.DIM_PRODUCT
SET Color = 'Unknown'
WHERE Color IS NULL

UPDATE Behrendt.DIM_PRODUCT
SET SubCategoryName = 'Unknown'
WHERE SubCategoryName IS NULL

UPDATE Behrendt.DIM_SALESPERSON
SET CountryRegionCode = 000
WHERE CountryRegionCode IS NULL

UPDATE Behrendt.DIM_CUSTOMER
SET CountryRegionCode = 000
WHERE CountryRegionCode IS NULL

UPDATE Behrendt.DIM_SALESPERSON
SET [Group] = 'Unknown'
WHERE [Group] IS NULL

UPDATE Behrendt.DIM_CUSTOMER
SET [Group] = 'Unknown'
WHERE [Group] IS NULL
