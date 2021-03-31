-- zad 1

SELECT COUNT(*) "Num of products" FROM Production.Product
SELECT COUNT(*) "Num of product categories" FROM Production.ProductCategory
SELECT COUNT(*) "Num of product subcategories" FROM Production.ProductSubcategory

-- zad 2

SELECT * FROM Production.Product WHERE Color IS NULL

-- zad 3

SELECT YEAR(P.OrderDate) "Year", SUM(S.TotalDue) - SUM(P.TotalDue) "Turnover" 
FROM Purchasing.PurchaseOrderHeader P, Sales.SalesOrderHeader S
GROUP BY YEAR(P.OrderDate)

-- zad 4

--SELECT COUNT(*) Customers FROM Sales.Customer

SELECT StoreID, COUNT(StoreID) c FROM Sales.SalesPerson
GROUP BY StoreID
HAVING StoreID IS NOT NULL
ORDER BY c

SELECT S.BusinessEntityID storeID, COUNT(S.SalesPersonID) sellers 
FROM Sales.Store S
GROUP BY S.BusinessEntityID

-- zad 5

SELECT Year, SUM(qty.Qty) FROM (

	SELECT YEAR(T.TransactionDate) "Year" , COUNT(*) "Qty" FROM Production.TransactionHistory T
	GROUP BY YEAR(T.TransactionDate)

	UNION

	SELECT YEAR(T.TransactionDate) "Year" , COUNT(*) "Qty" FROM Production.TransactionHistoryArchive T
	GROUP BY YEAR(T.TransactionDate)

) qty

GROUP BY Year

-- zad 6

SELECT DISTINCT PC.Name, P.* FROM Production.Product P
JOIN Sales.SalesOrderDetail S ON S.ProductID = P.ProductID
JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
ORDER BY PC.Name

-- zad 7

SELECT PS.Name, MIN(UnitPriceDiscount * OrderQty) Min, MAX(UnitPriceDiscount * OrderQty) Max 
FROM Sales.SalesOrderDetail S
JOIN Production.Product P ON P.ProductID = S.ProductID
JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
WHERE UnitPriceDiscount > 0
GROUP BY PS.Name

-- zad 8

SELECT * FROM Production.Product
WHERE StandardCost > (SELECT AVG(StandardCost) FROM Production.Product)

-- zad 9

SELECT AVG(cnt.cnt) "Average num" FROM (
    SELECT SUM(SOD.OrderQty) cnt, MONTH(S.OrderDate) m FROM Sales.SalesOrderHeader S
	JOIN Sales.SalesOrderDetail SOD ON S.SalesOrderID = SOD.SalesOrderID
    GROUP BY YEAR(S.OrderDate), MONTH(S.OrderDate)
) cnt
GROUP BY m

-- zad 10

SELECT CR.Name, AVG(DATEDIFF(day, S.OrderDate, S.ShipDate)) FROM Sales.SalesOrderHeader S
JOIN Sales.SalesTerritory T ON T.TerritoryID = S.TerritoryID
JOIN Person.CountryRegion CR ON CR.CountryRegionCode = T.CountryRegionCode
GROUP BY CR.Name
