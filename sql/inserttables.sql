

INSERT INTO Orders
(
    OrderID,
    OrderDate,
    ShipDate,
    ShipMode,
    CustomerKey,
    GeographyKey,
    RegionID,
    OrderPriority,
    PostalCode
)
SELECT 
    O.[Order ID],
    O.[Order Date],
    O.[Ship Date],
    O.[Ship Mode],
    C.CustomerKey,
    G.GeographyKey,
    R.RegionID,
    O.[Order Priority] ,
    O.[Postal Code]
FROM Orders$ O
JOIN DimCustomer C
    ON C.CustomerKey = O.[Customer ID]
JOIN DimGeography G
    ON G.CityName = O.City
   AND G.StateName = O.State
   AND G.CountryName = O.Country
JOIN DimMarket M
    ON M.MarketName = O.Market
JOIN DimRegion R
    ON R.RegionName = O.Region
   AND R.MarketID = M.MarketID
GROUP BY 
    O.[Order ID],
    O.[Order Date],
    O.[Ship Date],
    O.[Ship Mode],
    C.CustomerKey,
    G.GeographyKey,
    R.RegionID,
    O.[Order Priority],
    O.[Postal Code];


INSERT INTO OrderItem
(
    RowID,
    OrderKey,
    ProductKey,
    Sales,
    Quantity,
    Discount,
    Profit,
    ShippingCost
)
SELECT
    E.[Row ID],
    O.OrderKey,
    P.ProductKey,
    E.[Sales],
    E.[Quantity],
    E.[Discount],
    E.[Profit],
    E.[Shipping Cost]
FROM Orders$ E

INNER JOIN Orders O
    ON O.OrderID = E.[Order ID]
    AND O.OrderDate = E.[Order Date]
    AND O.CustomerKey = E.[Customer ID]

INNER JOIN DimProduct P
     ON P.ProductID = E.[Product ID]
    AND P.ProductName = E.[Product Name];


INSERT INTO Returns
(MarketID,
Returned,
OrderID)
SELECT 
M.MarketID,
R.Returned,
R.[Order ID]
FROM Returns$ R
JOIN DimMarket M
ON  M.MarketName = R.Market;

ALTER TABLE DimPeople
ADD RegionName VARCHAR(25)

INSERT INTO DimPeople (PersonName, RegionName)
SELECT DISTINCT
    [Person],
    [Region]
FROM People$
WHERE [Person] IS NOT NULL 
  AND [Region] IS NOT NULL;