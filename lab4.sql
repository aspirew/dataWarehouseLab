CREATE TABLE Behrendt.DIM_CUSTOMER
(
	CustomerID int NOT NULL PRIMARY KEY,
	Names nvarchar(255),
	Title nvarchar(8),
	City nvarchar(30),
	TerritoryName nvarchar(50),
	CountryRegionCode nvarchar(3),
	[Group] nvarchar(50)
);

CREATE TABLE Behrendt.DIM_PRODUCT
(
	ProductID int NOT NULL PRIMARY KEY,
	Name nvarchar(50),
	ListPrice money,
	Color nvarchar(15),
	SubCategoryName nvarchar(50),
	CategoryName nvarchar(50),
	Weight decimal(8,2),
	Size nvarchar(5),
	IsPurchased  BIT
);

CREATE TABLE Behrendt.DIM_SALESPERSON
(
	SalesPersonID int NOT NULL PRIMARY KEY,
	FirstName nvarchar(50),
	LastName nvarchar(50),
	Title nvarchar(8),
	Gender nchar(1),
	CountryRegionCode nvarchar(3),
	[Group] nvarchar(50)
);

CREATE TABLE Behrendt.FACT_SALES
(
	ProductID int,
	CustomerID int,
	SalesPersonID int,
	OrderDate int,
	ShipDate int,
	OrderQty smallint,
	UnitPrice money,
	UnitPriceDiscount money,
	LineTotal money
);

--Zad 3

INSERT INTO Behrendt.DIM_CUSTOMER
SELECT DISTINCT C.CustomerID, CONCAT(P.FirstName, ' ', P.LastName), P.Title, PA.City, ST.Name TerritoryName, ST.CountryRegionCode, ST.[Group]
FROM Sales.Customer C
	LEFT JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
	LEFT JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
	LEFT JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = P.BusinessEntityID
	LEFT JOIN Person.Address PA ON PA.AddressID = BEA.AddressID
	LEFT JOIN Person.AddressType PAT ON BEA.AddressTypeID = PAT.AddressTypeID
WHERE PAT.AddressTypeID IS NULL OR PAT.Name = 'Home';

INSERT INTO Behrendt.DIM_SALESPERSON
SELECT DISTINCT SP.BusinessEntityID SalesPersonID, CONCAT(P.FirstName, ' ', P.LastName), P.Title, E.Gender, ST.CountryRegionCode, ST.[Group]
FROM Sales.SalesPerson SP 
	LEFT JOIN Person.Person P ON P.BusinessEntityID = SP.BusinessEntityID
	LEFT JOIN Sales.SalesTerritory ST ON SP.TerritoryID = ST.TerritoryID
	LEFT JOIN HumanResources.Employee E ON E.BusinessEntityID = SP.BusinessEntityID;

INSERT INTO Behrendt.DIM_PRODUCT
SELECT DISTINCT P.ProductID, P.Name, P.ListPrice, P.Color, PS.Name SubCategoryName, PC.Name CategoryName, P.Weight, P.Size, IIF(SOD.SalesOrderDetailID IS NULL, 0, 1)
FROM Production.Product P 
	LEFT JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
	LEFT JOIN Production.ProductCategory PC ON PC.ProductCategoryID = PS.ProductCategoryID
	LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.ProductID = P.ProductID;

INSERT INTO Behrendt.FACT_SALES
SELECT DISTINCT SOD.ProductID, SOH.CustomerID, SOH.SalesPersonID, 
	DATEPART(yyyy, SOH.OrderDate) * 10000 + DATEPART(mm, SOH.OrderDate) * 100 + DATEPART(dd, SOH.OrderDate) OrderDate, 
	DATEPART(yyyy, SOH.ShipDate) * 10000 + DATEPART(mm, SOH.ShipDate) * 100 + DATEPART(dd, SOH.ShipDate) ShipDate, 
	SOD.OrderQty, SOD.UnitPrice, SOD.UnitPriceDiscount, SOD.LineTotal
FROM Sales.SalesOrderDetail SOD
	JOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderID;


-- zad 4

ALTER TABLE Behrendt.FACT_SALES
ADD CONSTRAINT fk_prod FOREIGN KEY(ProductID) REFERENCES Behrendt.DIM_PRODUCT(ProductID);
ALTER TABLE Behrendt.FACT_SALES
ADD CONSTRAINT fk_sales FOREIGN KEY(SalesPersonID) REFERENCES Behrendt.DIM_SALESPERSON(SalesPersonID);
ALTER TABLE Behrendt.FACT_SALES
ADD CONSTRAINT fk_cust FOREIGN KEY(CustomerID) REFERENCES Behrendt.DIM_CUSTOMER(CustomerID);


INSERT INTO Behrendt.FACT_SALES VALUES (1, 1, 1, 123455, 1234123451, 4, 43.22, 0.00, 43.55)
INSERT INTO Behrendt.DIM_CUSTOMER VALUES(11000, 'abc', 'cba', NULL, 'wroclaw', 'Poland', 'PL', 'Europe')
