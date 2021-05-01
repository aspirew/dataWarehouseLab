-- a

SELECT
[Measures].[Customer ID Distinct Count] ON COLUMNS,
NONEMPTY (
[DIM CUSTOMER].[Territory Name].MEMBERS
)
ON ROWS
FROM [Adventure Works2016]

-- b

SELECT
{[Order Date].[Rok].&[2012], [Order Date].[Rok].&[2013]} ON COLUMNS,
NONEMPTY (
[DIM CUSTOMER].[Territory Name].MEMBERS
) ON ROWS
FROM [Adventure Works2016]
WHERE [Measures].[Customer ID Distinct Count]

-- c

 SELECT 
{[Measures].[Order Qty], [Measures].[Customer ID Distinct Count]}
*
{
    [Order Date].[Hierarchy].[Rok].&[2012],
    [Order Date].[Hierarchy].[Rok].&[2013]
} ON COLUMNS,
NONEMPTY(
    [DIM CUSTOMER].[Hierarchy].[Country Region Code]
 )  ON ROWS
 FROM [Adventure Works2016]

-- d

SELECT
[Measures].[Order Qty] ON COLUMNS,
([DIM PRODUCT].[Category Name].CHILDREN, [DIM PRODUCT].[Sub Category Name].CHILDREN) ON ROWS
FROM [Adventure Works2016]

-- e

SELECT
[Measures].[Order Qty] ON COLUMNS,
ORDER (
    FILTER (
        ([DIM PRODUCT].[Category Name].CHILDREN, [DIM PRODUCT].[Sub Category Name].CHILDREN),
        [Measures].[Product ID Distinct Count] > 10
    ), 
	[Measures].[Order Qty],
	BDESC
) ON ROWS
FROM [Adventure Works2016]

--f
WITH MEMBER [Measures].[MovingAVG] AS AVG(LastPeriods(12, [Order date].[Miesiac]), [Measures].[Line Total]),
FORMAT_STRING='Currency'
SELECT
    {[Order date].[Rok].&[2012], [Order date].[Rok].&[2013]} ON COLUMNS,
    NON EMPTY
    [Order date].[Miesiac].[Miesiac] ON ROWS
FROM [Adventure Works2016]
WHERE [Measures].[MovingAVG]

--g
WITH MEMBER [Measures].[NazwaMiesiaca]
AS '[Order date].[Miesiac].CurrentMember.Name'
SELECT { [Measures].[NazwaMiesiaca], [Measures].[Order Qty] } ON COLUMNS, 
{
    HEAD(
        ORDER(
            DESCENDANTS([Order date].[Hierarchy].[Rok].&[2013], 3), [Measures].[Order Qty], BDESC
        ), 1
    )
} ON ROWS 
FROM [Adventure Works2016]