USE Globalsuperstore;


SELECT
    [Customer ID],
    [Order Date],
    [Ship Date],
    [Ship Mode],
    [Order Priority],
    COUNT(*) AS LineCount
FROM Orders$
GROUP BY
    [Customer ID],
    [Order Date],
    [Ship Date],
    [Ship Mode],
    [Order Priority]
ORDER BY LineCount DESC;


SELECT
    [Customer ID],
    [Order Date],
    [Ship Date],
    [Ship Mode],
    [Order Priority],
    COUNT(DISTINCT [Order ID]) AS OrderIDCount,
    COUNT(*) AS LineCount
FROM Orders$
GROUP BY
    [Customer ID],
    [Order Date],
    [Ship Date],
    [Ship Mode],
    [Order Priority]
HAVING COUNT(DISTINCT [Order ID]) > 1
ORDER BY OrderIDCount DESC;



SELECT
    [Order ID],

    COUNT(*) AS RowCounts,
    COUNT(DISTINCT [Customer ID]) AS CustomerCount,
    COUNT(DISTINCT [Order Date]) AS OrderDateCount,
    COUNT(DISTINCT [Ship Date]) AS ShipDateCount,
    COUNT(DISTINCT [Ship Mode]) AS ShipModeCount,
    COUNT(DISTINCT [Order Priority]) AS PriorityCount,
    COUNT(DISTINCT City) AS CityCount,
    COUNT(DISTINCT State) AS StateCount,
    COUNT(DISTINCT Country) AS CountryCount,
    COUNT(DISTINCT Region) AS RegionCount,
    COUNT(DISTINCT Market) AS MarketCount

FROM Orders$
WHERE [Order ID] IS NOT NULL
GROUP BY [Order ID]

HAVING
       COUNT(DISTINCT [Customer ID]) > 1
    OR COUNT(DISTINCT [Order Date]) > 1
    OR COUNT(DISTINCT [Ship Date]) > 1
    OR COUNT(DISTINCT [Ship Mode]) > 1
    OR COUNT(DISTINCT [Order Priority]) > 1
    OR COUNT(DISTINCT City) > 1
    OR COUNT(DISTINCT State) > 1
    OR COUNT(DISTINCT Country) > 1
    OR COUNT(DISTINCT Region) > 1
    OR COUNT(DISTINCT Market) > 1

ORDER BY RowCounts DESC;



--- (orderid,customerid,orderdate) -> unique
SELECT
    [Order ID]
    [Customer ID],
    [Order Date],
    COUNT(DISTINCT [Ship Date]) AS ShipDateCount,
    COUNT(DISTINCT [Ship Mode]) AS ShipModeCount,
    COUNT(DISTINCT [Order Priority]) AS PriorityCount,
    COUNT(DISTINCT City) AS CityCount,
    COUNT(DISTINCT State) AS StateCount
FROM Orders$
GROUP BY   [Order ID],
    [Customer ID],
    [Order Date]
HAVING
       COUNT(DISTINCT [Order Priority]) >1 
       or
       COUNT(DISTINCT [Ship Date]) > 1
    OR COUNT(DISTINCT [Ship Mode]) > 1
    OR COUNT(DISTINCT [Order Priority]) > 1
    OR COUNT(DISTINCT City) > 1
    OR COUNT(DISTINCT State) > 1
     OR COUNT(DISTINCT Region) > 1
      OR COUNT(DISTINCT Market) > 1;