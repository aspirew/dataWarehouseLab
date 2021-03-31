-- zad 1

CREATE SCHEMA Behrendt;

-- zad 2

CREATE TABLE Behrendt.DIM_CUSTOMER (
	CustomerID INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	City NVARCHAR(30) NOT NULL,
	TerritoryName NVARCHAR(50) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	"Group" NVARCHAR(50) NOT NULL
)

CREATE TABLE Behrendt.DIM_PRODUCT (
	ProductID INT PRIMARY KEY NOT NULL,
	"Name" NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL,
	Color NVARCHAR(15),
	SubCategoryName NVARCHAR(50),
	CategoryName NVARCHAR(50),
	"Weight" DECIMAL(8, 2),
	Size NVARCHAR(5),
	IsPurchased BIT NOT NULL
)

CREATE TABLE Behrendt.DIM_SALESPERSON (
	SalesPersonID INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	Gender NCHAR(1) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	"Group" NVARCHAR(50) NOT NULL
)

CREATE TABLE Behrendt.FACT_SALES (
	ProductID INT NOT NULL,
	CustomerID INT NOT NULL,
	SalesPersonID INT NOT NULL,
	OrderDate INT NOT NULL,
	ShipDate INT NOT NULL,
	OrderQty SMALLINT NOT NULL,
	UnitPrice MONEY NOT NULL,
	UnitPrieDiscount Money NOT NULL,
	LineTotal Numeric(38, 6) NOT NULL
)

-- zad 3

INSERT INTO Behrendt.DIM_CUSTOMER
SELECT CustomerID, P.FirstName, P.LastName, P.Title, MAX(A.City), ST.Name, SP.CountryRegionCode, ST."Group" FROM Sales.Customer C
JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
JOIN Person.BusinessEntity BE ON BE.BusinessEntityID = P.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = BE.BusinessEntityID
JOIN Person.Address A ON A.AddressID = BEA.AddressID
JOIN Person.StateProvince SP ON SP.StateProvinceID = A.StateProvinceID
JOIN Sales.SalesTerritory ST ON SP.TerritoryID = ST.TerritoryID
GROUP BY CustomerID, P.FirstName, P.LastName, P.Title, ST.Name, SP.CountryRegionCode, ST."Group"


INSERT INTO Behrendt.DIM_PRODUCT
SELECT DISTINCT P.ProductID, P.Name, ListPrice, Color, PS.Name, PC.Name, Weight, Size,
CASE
WHEN SOD.ProductID IS NULL THEN 0
ELSE 1 END
FROM Production.Product P
LEFT JOIN Production.ProductSubcategory PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.ProductID = P.ProductID


INSERT INTO Behrendt.DIM_SALESPERSON
SELECT SP.BusinessEntityID, FirstName, LastName, Title, Gender, S.CountryRegionCode, T."Group" FROM Sales.SalesPerson SP
JOIN Person.Person P ON SP.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.Employee E ON P.BusinessEntityID = E.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = P.BusinessEntityID
JOIN Person.Address A ON BEA.AddressID = A.AddressID
JOIN Person.StateProvince S ON A.StateProvinceID = S.StateProvinceID
JOIN Sales.SalesTerritory T ON T.TerritoryID = S.TerritoryID

INSERT INTO Behrendt.FACT_SALES
SELECT P.ProductID, C.CustomerID, SOH.SalesPersonID, 
DATEPART(yyyy,SOH.OrderDate) * 10000 + DATEPART(mm,SOH.OrderDate) * 100 + DATEPART(dd,SOH.OrderDate),
DATEPART(yyyy,SOH.OrderDate) * 10000 + DATEPART(mm,SOH.OrderDate) * 100 + DATEPART(dd,SOH.OrderDate),
OrderQty, UnitPrice, UnitPriceDiscount, LineTotal
FROM Production.Product P
JOIN Sales.SalesOrderDetail SOD ON SOD.ProductID = P.ProductID
JOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Sales.Customer C ON C.CustomerID = SOH.CustomerID
JOIN SALES.SalesPerson S ON S.BusinessEntityID = SOH.SalesPersonID

-- zad 4

ALTER TABLE Behrendt.FACT_SALES
ADD FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID),
FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID),
FOREIGN KEY (SalesPersonID) REFERENCES Sales.SalesPerson(BusinessEntityID)

INSERT INTO Behrendt.FACT_SALES VALUES (1, 1, 1, 123455, 1234123451, 4, 43.22, 0.00, 43.55)
INSERT INTO Behrendt.DIM_CUSTOMER VALUES(11000, 'abc', 'cba', NULL, 'wroclaw', 'Poland', 'PL', 'Europe')


-- zad 5


