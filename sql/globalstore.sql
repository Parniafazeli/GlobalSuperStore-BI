USE Globalsuperstore;


CREATE TABLE DimProductCategory
(
	CategoryKey int IDENTITY(1,1) PRIMARY KEY,
	CategoryName VARCHAR(20) NOT NULL,

)
CREATE TABLE DimProductSubCategory(
	SubCategoryKey int IDENTITY(1,1) PRIMARY KEY,
	SubCategoryName VARCHAR(30) NOT NULL,
	CategoryKey INT NOT NULL,
	FOREIGN KEY(CategoryKey) REFERENCES DimProductCategory(CategoryKey)
)

CREATE TABLE DimProduct(
	ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID VARCHAR(50),
	ProductName VARCHAR(200) NOT NULL,
	ProductSubCategoryKey INT NOT NULL,
	FOREIGN KEY(ProductSubCategoryKey) REFERENCES  DimProductSubCategory(SubCategoryKey) 
)
CREATE TABLE DimMarket(
MarketID INT  IDENTITY(1,1) PRIMARY KEY,
MarketName VARCHAR(30) NOT NULL,
)


CREATE TABLE DimRegion(
RegionID INT IDENTITY(1,1) PRIMARY KEY,
RegionName VARCHAR(25) NOT NULL
)

ALTER TABLE DimRegion
ADD  MarketID INT

ALTER TABLE DimRegion
DROP COLUMN MarketID
ALTER TABLE DimRegion
DROP  FK_Dimregion_market


INSERT INTO DimGeography( CountryName, StateName,CityName)
SELECT  DISTINCT
    Country,
    [State],
    City
FROM Orders$ 


CREATE TABLE DimGeography(
GeographyKey INT IDENTITY(1,1) PRIMARY KEY,
CountryName VARCHAR(25) NOT NULL,
StateName VARCHAR(25) NOT NULL,
CityName VARCHAR(30) NOT NULL,
RegionID INT NOT NULL,
FOREIGN KEY (RegionID) REFERENCES DimRegion(RegionID)
)
ALTER TABLE  DimGeography
DROP COLUMN RegionID
ALTER TABLE DimGeography
ALTER COLUMN CountryName NVARCHAR(50);
CREATE TABLE DimCustomer(
CustomerKey VARCHAR(15) PRIMARY KEY,
CustomerName VARCHAR(100) NOT NULL,
Segment VARCHAR(20) NOT NULL
)

CREATE TABLE DimPeople(
PersonID INT IDENTITY(1,1) PRIMARY KEY,
PersonName VARCHAR(50) NOT NULL,
RegionID INT NOT NULL,
FOREIGN KEY (RegionID) REFERENCES DimRegion(RegionID)
)
INSERT INTO DimPeople(PersonName,RegionID)
SELECT DISTINCT P.Person, R.RegionID
FROM People$ P
JOIN DimRegion R
ON P.Region=R.RegionName
WHERE P.Person IS NOT NULL


CREATE TABLE Orders(
OrderKey INT IDENTITY(1,1) PRIMARY KEY,
OrderID VARCHAR(50) NOT NULL,
OrderDate DATE NOT NULL,
ShipDate DATE NOT NULL,
ShipMode VARCHAR(20) NOT NULL,
CustomerKey VARCHAR(15) NOT NULL,
GeographyKey INT NOT NULL,
RegionID INT NOT NULL,
MarketID INT NOT NULL,
OrderPriority VARCHAR(15) ,
FOREIGN KEY(CustomerKey) REFERENCES DimCustomer(CustomerKey),
FOREIGN KEY(GeographyKey) REFERENCES DimGeography(GeographyKey),
FOREIGN KEY (RegionID) REFERENCES DimRegion(RegionID),
FOREIGN KEY (MarketID) REFERENCES DimMarket(MarketID),
UNIQUE (OrderID, CustomerKey, OrderDate)
)
UPDATE People$
SET Region='EMEA'
WHERE Region='AMEA'

ALTER TABLE Orders
ADD CONSTRAINT FK_ORDER_MARKET
FOREIGN KEY(MarketID) REFERENCES DimMarket(MarketID)

CREATE TABLE  OrderItem(
RowID INT PRIMARY KEY,
OrderKey INT NOT NULL,
ProductKey INT NOT NULL,
Sales DECIMAL(15,4) NOT NULL,
Quantity INT NOT NULL,
Discount  DECIMAL(5,2),
Profit DECIMAL(15,4),
ShippingCost DECIMAL(12,4) NOT NULL,
FOREIGN KEY(OrderKey) REFERENCES Orders(OrderKey),
FOREIGN KEY(ProductKey) REFERENCES DimProduct(ProductKey)
)
CREATE TABLE Returns(
ReturnID INT IDENTITY(1,1) PRIMARY KEY,
MarketID INT NOT NULL,
Returned VARCHAR(5) NOT NULL,
OrderID VARCHAR(50) NOT NULL,
FOREIGN KEY(MarketID) REFERENCES DimMarket(MarketID)
)

INSERT INTO DimMarket(MarketName)
SELECT DISTINCT Market
FROM Orders$
WHERE Market IS NOT NULL

INSERT INTO DimRegion(RegionName)
SELECT DISTINCT Region
FROM Orders$ 
WHERE Region IS NOT NULL

DELETE FROM DimPeople
DBCC CHECKIDENT ('DimPeople', RESEED, 0);

INSERT INTO DimProductCategory (CategoryName)
SELECT DISTINCT Category
FROM Orders$
WHERE Category IS NOT NULL;

INSERT INTO DimProductSubCategory
(
    SubCategoryName,
    CategoryKey
)
SELECT DISTINCT
    O.[Sub-Category],
    c.CategoryKey
FROM Orders$ O
JOIN DimProductCategory c
    ON c.CategoryName = O.Category
WHERE O.[Sub-Category] IS NOT NULL;



INSERT INTO DimProduct
(
    ProductID,
    ProductName,
    ProductSubCategoryKey
)
SELECT DISTINCT
    O.[Product ID],
    O.[Product Name],
    s.SubCategoryKey
FROM Orders$ O
JOIN DimProductSubCategory s
    ON s.SubCategoryName = O.[Sub-Category]
JOIN DimProductCategory c
    ON c.CategoryKey = s.CategoryKey
   AND c.CategoryName = O.Category;


ALTER TABLE Orders
ADD PostalCode  VARCHAR(30)

SELECT
    [Product ID],
    COUNT(DISTINCT [Product Name]) AS NameCount
FROM Orders$
WHERE [Product ID] IS NOT NULL
GROUP BY [Product ID]
HAVING COUNT(DISTINCT [Product Name]) > 1
ORDER BY NameCount DESC;


SELECT
    O.[Row ID],
    O.[Order ID],
    O.[Product ID],
    O.[Product Name],
    P.ProductKey
FROM Orders$ O
JOIN DimProduct P
    ON P.ProductID = O.[Product ID]
   AND P.ProductName = O.[Product Name];

