-- zad1

SELECT SalesPersonID, P.ProductID, P.Name, YEAR(SH.OrderDate) yr, COUNT(P.ProductID) amount
FROM Sales.SalesOrderHeader SH
JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID
JOIN Production.Product P ON P.ProductID = SD.ProductID
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID, YEAR(SH.OrderDate), P.ProductID, P.Name


DECLARE @cols NVARCHAR (255);

DECLARE @query NVARCHAR (MAX);

SELECT @cols = COALESCE (@cols + ',[' + CAST(yr as NVARCHAR(16)) + ']',
	'[' + CAST(yr as NVARCHAR(16)) + ']')
	FROM (SELECT DISTINCT YEAR(OrderDate) yr FROM Sales.SalesOrderHeader) PV
	ORDER BY PV.yr;


set @query = 'SELECT * FROM (
				SELECT SalesPersonID seller, P.ProductID product, P.Name productName, YEAR(SH.OrderDate) yr
				FROM Sales.SalesOrderHeader SH
				JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID
				JOIN Production.Product P ON P.ProductID = SD.ProductID
				WHERE SalesPersonID IS NOT NULL
				GROUP BY SalesPersonID, YEAR(SH.OrderDate), P.ProductID, P.Name
			) sourceTab
			PIVOT (
				COUNT(sourceTab.product)
				FOR sourceTab.yr IN (' + @cols + ')
			) AS pivot_table'


execute(@query)


DECLARE @cols2 NVARCHAR (255);
DECLARE @query2 NVARCHAR (MAX);

SELECT @cols2 = COALESCE (@cols2 + ',[' + CAST(cols.s as NVARCHAR(16)) + ']',
	'[' + CAST(cols.s as NVARCHAR(16)) + ']')
	FROM (
		SELECT TOP 5 top_sells.seller s, SUM(top_sells.amount) amount FROM (

			SELECT SalesPersonID seller, P.ProductID, P.Name, YEAR(SH.OrderDate) yr, COUNT(P.ProductID) amount
			FROM Sales.SalesOrderHeader SH
			JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID
			JOIN Production.Product P ON P.ProductID = SD.ProductID
			WHERE SalesPersonID IS NOT NULL
			GROUP BY SalesPersonID, YEAR(SH.OrderDate), P.ProductID, P.Name

		) top_sells

		GROUP BY top_sells.seller
		ORDER BY amount DESC
	) cols;


set @query2 = 'SELECT * FROM (
				SELECT SalesPersonID seller, P.ProductID product, P.Name productName, YEAR(SH.OrderDate) yr
				FROM Sales.SalesOrderHeader SH
				JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID
				JOIN Production.Product P ON P.ProductID = SD.ProductID
				WHERE SalesPersonID IS NOT NULL
				GROUP BY SalesPersonID, YEAR(SH.OrderDate), P.ProductID, P.Name
			) sourceTab
			PIVOT (
				COUNT(sourceTab.product)
				FOR sourceTab.seller IN (' + @cols2 + ')
			) AS pivot_table'


execute(@query2)


-- zad2

SELECT c.yr, c.mnth, COUNT(*) amount FROM (
	SELECT DISTINCT CustomerID, YEAR(OrderDate) yr, MONTH(OrderDate) mnth FROM Sales.SalesOrderHeader
	GROUP BY CustomerID, OrderDate, YEAR(OrderDate), MONTH(OrderDate)
	) c
GROUP BY c.yr, c.mnth
ORDER BY yr, mnth


SELECT * FROM (
	SELECT DISTINCT CustomerID, YEAR(OrderDate) yr, MONTH(OrderDate) mnth FROM Sales.SalesOrderHeader
	GROUP BY CustomerID, OrderDate, YEAR(OrderDate), MONTH(OrderDate)
) res
PIVOT(
	COUNT(res.CustomerID)
	FOR res.yr IN ([2011], [2012], [2013], [2014])
) piv
ORDER BY mnth


-- zad3

	SELECT * FROM (
		SELECT CONCAT(P.FirstName, ' ', P.LastName) name, SOH.CustomerID customer, YEAR(SOH.OrderDate) yr FROM Sales.SalesOrderHeader SOH
		JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
		JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
		WHERE YEAR(SOH.OrderDate) NOT IN (2011, 2013)
	) res
	PIVOT(
		COUNT(res.customer)
		FOR res.yr IN ([2012], [2014])
	) pivot_res


-- zad4

	SELECT pivot_price.*, pivot_amount.[2011], pivot_amount.[2012], pivot_amount.[2013], pivot_amount.[2014] FROM (
		SELECT SOH.SubTotal total, YEAR(SOH.OrderDate) y, MONTH(SOH.OrderDate) m, DAY(SOH.OrderDate) d FROM Sales.SalesOrderHeader SOH
		JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
		) res
		PIVOT(
			SUM(res.total)
			FOR res.y in ([2011], [2012], [2013], [2014])
		) pivot_price

	JOIN (
	SELECT * FROM (
		SELECT SOD.OrderQty qty, YEAR(SOH.OrderDate) y, MONTH(SOH.OrderDate) mnth, DAY(SOH.OrderDate) day FROM Sales.SalesOrderHeader SOH
		JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
		) res
		PIVOT(
			SUM(res.qty)
			FOR res.y in ([2011], [2012], [2013], [2014])
	) pivot_res
	) pivot_amount
	ON pivot_price.m = pivot_amount.mnth AND pivot_amount.day = pivot_price.d
	ORDER BY m, d

-- zad 7

DECLARE @avgQuery TABLE (customer INT, cnt int);
DECLARE @avgQueryInYears TABLE (customer INT);

INSERT INTO @avgQuery
SELECT S2.CustomerID customer, COUNT(*) c
FROM Sales.SalesOrderHeader S2
WHERE S2.TotalDue > (SELECT AVG(TotalDue) a FROM Sales.SalesOrderHeader) * 1.5
GROUP BY S2.CustomerID;


INSERT INTO @avgQueryInYears
SELECT customer customer FROM (
		SELECT S2.CustomerID customer, COUNT(*) c
		FROM Sales.SalesOrderHeader S2
		WHERE S2.TotalDue > (SELECT AVG(TotalDue) a FROM Sales.SalesOrderHeader) * 1.5
		GROUP BY S2.CustomerID, YEAR(S2.OrderDate)
	) res
	GROUP BY res.customer
	HAVING COUNT(*) > 3

SELECT P.FirstName, P.LastName, COUNT(*) num_of_t, SUM(S.TotalDue) total_sum, cardd =
	CASE
	WHEN S.CustomerID IN (SELECT customer FROM @avgQueryInYears q) THEN 'Platinum'
	WHEN (
		SELECT res.cnt FROM @avgQuery res
		WHERE res.customer = S.CustomerID
	) > 1 THEN 'Golden'
	WHEN COUNT(*) > 5 THEN 'Silver'
	END
FROM Sales.SalesOrderHeader S
JOIN Sales.Customer C ON C.CustomerID = S.CustomerID
JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
GROUP BY P.FirstName, P.LastName, S.CustomerID
ORDER BY cardd DESC
