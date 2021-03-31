-- zad1

SELECT MAX(CONCAT(P.FirstName, ' ', P.LastName)) Klient, YEAR(OrderDate) Rok, SUM(SubTotal) Kwota FROM Sales.SalesOrderHeader S
JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
GROUP BY P.BusinessEntityID, ROLLUP(YEAR(OrderDate) )

SELECT MAX(CONCAT(P.FirstName, ' ', P.LastName)) Klient, YEAR(OrderDate) Rok, SUM(SubTotal) Kwota FROM Sales.SalesOrderHeader S
JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
GROUP BY P.BusinessEntityID, CUBE(YEAR(OrderDate) )

SELECT MAX(CONCAT(P.FirstName, ' ', P.LastName)) Klient, YEAR(OrderDate) Rok, SUM(SubTotal) Kwota FROM Sales.SalesOrderHeader S
JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
GROUP BY GROUPING SETS
(
	
	(P.BusinessEntityID),
	(YEAR(OrderDate), P.BusinessEntityID)

)


-- zad2

SELECT MAX(PC.Name) Kategoria, MAX(Product.Name) Produkt, YEAR(SOH.OrderDate) Rok, SUM(SOD.UnitPriceDiscount) Kwota FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN Production.Product Product ON SOD.ProductID = Product.ProductID
JOIN Production.ProductSubcategory PS ON Product.ProductSubcategoryID = PS.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID 
JOIN Person.Person Person ON Person.BusinessEntityID = C.PersonID
GROUP BY PC.ProductCategoryID, Product.ProductID, ROLLUP(YEAR(SOH.OrderDate))
ORDER BY Kategoria, Produkt

SELECT MAX(PC.Name) Kategoria, MAX(Product.Name) Produkt, YEAR(SOH.OrderDate) Rok, SUM(SOD.UnitPriceDiscount) Kwota FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN Production.Product Product ON SOD.ProductID = Product.ProductID
JOIN Production.ProductSubcategory PS ON Product.ProductSubcategoryID = PS.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID 
JOIN Person.Person Person ON Person.BusinessEntityID = C.PersonID
GROUP BY PC.ProductCategoryID, Product.ProductID, CUBE(YEAR(SOH.OrderDate))
ORDER BY Kategoria, Produkt

SELECT MAX(PC.Name) Kategoria, MAX(Product.Name) Produkt, YEAR(SOH.OrderDate) Rok, SUM(SOD.UnitPriceDiscount) Kwota FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN Production.Product Product ON SOD.ProductID = Product.ProductID
JOIN Production.ProductSubcategory PS ON Product.ProductSubcategoryID = PS.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID 
JOIN Person.Person Person ON Person.BusinessEntityID = C.PersonID
GROUP BY GROUPING SETS (
	(PC.ProductCategoryID, Product.ProductID, YEAR(SOH.OrderDate)),
	(PC.ProductCategoryID, Product.ProductID)
)
ORDER BY Kategoria, Produkt


-- zad 3

SELECT DISTINCT PC.Name name, YEAR(SOH.OrderDate),
SUM(LineTotal) OVER (PARTITION BY PC.ProductCategoryID, YEAR(SOH.OrderDate))
/ SUM(LineTotal) OVER (PARTITION BY PC.ProductCategoryID)
*100
FROM Sales.SalesOrderDetail SOD
JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN Production.Product P ON SOD.ProductID = P.ProductID
JOIN Production.ProductSubcategory PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
WHERE PC.name = 'Bikes'


SELECT MAX(PC.Name), YEAR(SOH.OrderDate),
SUM(LineTotal)
/ SUM(SUM(LineTotal)) OVER (PARTITION BY PC.ProductCategoryID)
*100
FROM Sales.SalesOrderDetail SOD
JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN Production.Product P ON SOD.ProductID = P.ProductID
JOIN Production.ProductSubcategory PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
WHERE PC.name = 'Bikes'
GROUP BY PC.ProductCategoryID, YEAR(SOH.OrderDate)

-- zad 4

SELECT DISTINCT CustomerID Klient, YEAR(OrderDate) Rok, 
COUNT(*) OVER (PARTITION BY CustomerID ORDER BY YEAR(OrderDate))
FROM Sales.SalesOrderHeader
--WHERE CustomerID = 30117


-- zad 5

SELECT *, inmnt + LAG(s.inmnt) OVER (ORDER BY yr, mnt) FROM (
	SELECT DISTINCT CONCAT(SP.FirstName, ' ', SP.LastName) seller, YEAR(SOH.OrderDate) yr, MONTH(SOH.OrderDate) mnt,
	COUNT(SOH.OrderDate) OVER (PARTITION BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate)) inmnt,
	COUNT(SOH.OrderDate) OVER (PARTITION BY YEAR(SOH.OrderDate)) inyr,
	COUNT(SOH.OrderDate) OVER (PARTITION BY YEAR(SOH.OrderDate) ORDER BY MONTH(SOH.OrderDate)) inyrinc
	FROM Sales.SalesOrderHeader SOH
	JOIN Person.Person SP ON SOH.SalesPersonID = SP.BusinessEntityID
	WHERE SalesPersonID IS NOT NULL AND CONCAT(SP.FirstName, ' ', SP.LastName) = 'Amy Alberts'
) s
ORDER BY yr, mnt


-- zad 6

SELECT DISTINCT MAX(C.Name), SUM(MAX(P.ListPrice)) OVER (PARTITION BY C.ProductCategoryID)  FROM Production.Product P
JOIN Production.ProductSubcategory S ON S.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory C ON S.ProductCategoryID = C.ProductCategoryID
GROUP BY S.ProductSubcategoryID, C.ProductCategoryID

