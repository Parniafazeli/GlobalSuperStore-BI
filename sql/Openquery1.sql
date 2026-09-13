USE Globalsuperstore;

---- Total Sale today& last year same day
SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE
    
   VAR CurrentDate=
	MAXX(
	FILTER(ALL(DimDate),
	[Total Sales] <> BLANK()
	),
	DimDate[Date]
	)
	
	VAR LastyearDate=DATE(
	YEAR(CurrentDate)-1,
	MONTH(CurrentDate),
	DAY(CurrentDate)
	)
	
	VAR CurrentSales=CALCULATE(
	[Total Sales],
	DimDate[Date]=CurrentDate
	)
	
	VAR LastYearSales=
	CALCULATE(
	[Total Sales],
	DimDate[Date]=LastyearDate
	)
	
	VAR DifferenceSales=
	 CurrentSales - LastYearSales
	
	VAR GrowthPercent= DIVIDE(
	CurrentSales - LastYearSales,
	LastYearSales
	)
	
	RETURN
	ROW(
	"Today Sales" , CurrentSales,
	"Last Year Same Day Sales" , LastYearSales,
	"Growth Percent" , GrowthPercent
	)'
)


----------Total Profit today&last year same day


SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE
    
   VAR CurrentDate=
	MAXX(
	FILTER(ALL(DimDate),
	[Total Profit] <> BLANK()
	),
	DimDate[Date]
	)
	
	VAR LastyearDate=DATE(
	YEAR(CurrentDate)-1,
	MONTH(CurrentDate),
	DAY(CurrentDate)
	)
	
	VAR CurrentProfit=CALCULATE(
	[Total Profit],
	DimDate[Date]=CurrentDate
	)
	
	VAR LastYearProfit=
	CALCULATE(
	[Total Profit],
	DimDate[Date]=LastyearDate
	)
	
	VAR GrowthPercent= DIVIDE(
	CurrentProfit - LastYearProfit,
	LastYearProfit
	)
	
	RETURN
	ROW(
	"Today Profit" , CurrentProfit,
	"Last Year Same Day Profit" , LastYearProfit,
	"Growth Percent" , GrowthPercent
	)'
)

------- active customer today& last year same day
SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE
    
   VAR CurrentDate=
	MAXX(
	FILTER(ALL(DimDate),
	[active customer] <> BLANK()
	),
	DimDate[Date]
	)
	
	VAR LastyearDate=DATE(
	YEAR(CurrentDate)-1,
	MONTH(CurrentDate),
	DAY(CurrentDate)
	)
	
	VAR CurrentCustomers=CALCULATE(
	[active customer],
	DimDate[Date]=CurrentDate
	)
	
	VAR LastYearCustomers=
	CALCULATE(
	[active customer],
	DimDate[Date]=LastyearDate
	)
	
	VAR GrowthPercent= DIVIDE(
	CurrentCustomers - LastYearCustomers,
	LastYearCustomers
	)
	
	RETURN
	ROW(
	"Current Customers" , CurrentCustomers,
	"Last Year Customers" , LastYearCustomers,
	"Growth Percent" , GrowthPercent
	)'
)
------- Regional Manager  YTD this year & YTD last year  based on total sale
SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE
VAR CurrentDate=
	MAXX(
	FILTER(ALL(DimDate),
	[Total Sales] <> BLANK()
	),
	DimDate[Date]
	)
	
	VAR LastyearDate=DATE(
	YEAR(CurrentDate)-1,
	MONTH(CurrentDate),
	DAY(CurrentDate)
	)
	
	
	VAR TopCurrentEmployee=
	TOPN(	
	1,
	 ALL(DimRegionMarket[RegionalManager]),
	 CALCULATE(
	 [Total Sales],
	 YEAR(DimDate[Date])=YEAR(CurrentDate)
	 ),
	 DESC
	)
	
	VAR TopCurrentEmployeeSales=
	CALCULATE(
	[Total Sales],
	 TopCurrentEmployee,
	 YEAR(DimDate[Date]) = YEAR(CurrentDate)
	)
	
	VAR TopLastYearEmployee=TOPN(
	
	1,
	 ALL(DimRegionMarket[RegionalManager]),
	 CALCULATE(
	 [Total Sales],
	 DimDate[Date] >= DATE(YEAR(CurrentDate) - 1, 1, 1),
    DimDate[Date] <= DATE(
        YEAR(CurrentDate) - 1,
        MONTH(CurrentDate),
        DAY(CurrentDate)
    )
	 ),
	 DESC
	)
	
	VAR TopLastYearEmployeeSales=
	CALCULATE(
	[Total Sales],
	TopLastYearEmployee,
	 DimDate[Date] >= DATE(YEAR(CurrentDate) - 1, 1, 1),
    DimDate[Date] <= DATE(
        YEAR(CurrentDate) - 1,
        MONTH(CurrentDate),
        DAY(CurrentDate)
    )
	)
	
	RETURN
	ROW(
	"Top Current Employee", TopCurrentEmployee,
	"Current Sales" , TopCurrentEmployeeSales,
	"Top Last Year Employee" , TopLastYearEmployee,
	"Last Year Sales" ,TopLastYearEmployeeSales
	
	)'
)

-------- Top Product Category YTD this Year & last year based on total sale

SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE

	VAR CurrentDate=
	MAXX(
	FILTER(ALL(DimDate),
	[Total Sales] <> BLANK()
	),
	DimDate[Date]
	)
	
	VAR LastyearDate=DATE(
	YEAR(CurrentDate)-1,
	MONTH(CurrentDate),
	DAY(CurrentDate)
	)
	
	VAR TOPCurrentCategory=
	TOPN(1,
	ALL(DimProducts[CategoryName]),
	CALCULATE(
	[Total Sales],
	YEAR(DimDate[Date])=YEAR(CurrentDate)
	),
	DESC
	)
	
	VAR TOPLastYearCategory=
	TOPN(1,
	ALL(DimProducts[CategoryName]),
	CALCULATE(
	[Total Sales],
	 DimDate[Date] >= DATE(YEAR(CurrentDate) - 1, 1, 1),
    DimDate[Date] <= DATE(
        YEAR(CurrentDate) - 1,
        MONTH(CurrentDate),
        DAY(CurrentDate)
    )
	),
	DESC
	)
	
	VAR TOPCurrentCategorySale=
	CALCULATE(
	[Total Sales],
 	TOPCurrentCategory,
 	YEAR(DimDate[Date]) = YEAR(CurrentDate)
 	)
 	
 	VAR TOPLastYearCategorySale=
 	CALCULATE(
 	[Total Sales],
 	TOPLastYearCategory,
 	 DimDate[Date] >= DATE(YEAR(CurrentDate) - 1, 1, 1),
    DimDate[Date] <= DATE(
        YEAR(CurrentDate) - 1,
        MONTH(CurrentDate),
        DAY(CurrentDate)
    )
 	)
 	
 	RETURN ROW(
 	"Top Current Category" , TOPCurrentCategory,
 	"Top Current Category Sale" , TOPCurrentCategorySale,
 	"Top Last Year Category" ,  TOPLastYearCategory,
 	"Top Last Year Category Sale" , TOPLastYearCategorySale
 	)'
	)



--------Top Market YTD this Year & last year based on total sale


SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE

VAR CurrentDate=
MAXX(
FILTER(ALL(DimDate),
[Total Sales] <> BLANK()
),
DimDate[Date]
)

VAR LastyearDate=DATE(
YEAR(CurrentDate)-1,
MONTH(CurrentDate),
DAY(CurrentDate)
)
	
	
VAR TOPCurrentMarket=
TOPN(1,
DISTINCT(DimRegionMarket[MarketName]),
CALCULATE(
[Total Profit],
YEAR(DIMDATE[Date])=YEAR(CurrentDate)
),
DESC)

	
VAR TOPLastYearMarket=
TOPN(1,
DISTINCT(DimRegionMarket[MarketName]),
CALCULATE(
[Total Profit],
DimDate[Date]>=DATE(YEAR(LastyearDate),1,1),
DimDate[Date]<=LastyearDate
),
DESC)

RETURN ROW("TOP Current Market", TOPCurrentMarket,
"TOPLastYearMarket" , TOPLastYearMarket
)'
)


------ Top Country YTD this Year & last year based on Total orders

SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE
VAR CurrentDate=
MAXX(
FILTER(ALL(DimDate),
[Total Sales] <> BLANK()
),
DimDate[Date]
)

VAR LastyearDate=DATE(
YEAR(CurrentDate)-1,
MONTH(CurrentDate),
DAY(CurrentDate)
)

VAR CurrentCountries=
ADDCOLUMNS(
DISTINCT(DimGeography[CountryName]),
"Orders",
CALCULATE(
[Total orders],
YEAR(DimDate[Date])=YEAR(CurrentDate)
)
)

VAR MAXCurrentOrders=
MAXX(
CurrentCountries,
[Orders]
)

VAR TOPCurrentCountry=
FILTER(
CurrentCountries,
[Orders]= MAXCurrentOrders
)
VAR CurrentCountryName =
    CONCATENATEX(
        TOPCurrentCountry,
        DimGeography[CountryName],
        ", "
    )


VAR LastYearCountries=
ADDCOLUMNS(
DISTINCT(DimGeography[CountryName]),
"OrdersLastYear",
CALCULATE(
[Total orders],
DimDate[Date]>= DATE(YEAR(LastyearDate),1,1),
DimDate[Date]<=LastyearDate
)
)

VAR MaxLastYearOrders=
MAXX(LastYearCountries,
[OrdersLastYear]
)

VAR TopLastYearCountry=
FILTER( LastYearCountries,
[OrdersLastYear]=MaxLastYearOrders
)

VAR LastYearCountryName =
    CONCATENATEX(
        TopLastYearCountry,
        DimGeography[CountryName],
        ", "
    )

RETURN ROW(" Top Current Country",  CurrentCountryName,
"Max Current Orders",MAXCurrentOrders,
"Top Last Year Country",LastYearCountryName,
"Max Last Year Orders", MaxLastYearOrders
)'
)


-------- Quantity Sold Today & last year same day 

SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE

VAR CurrentDate=
MAXX(
FILTER(ALL(DimDate),
[Quantity Sold] <> BLANK()
),
DimDate[Date]
)


VAR LastyearDate=DATE(
YEAR(CurrentDate)-1,
MONTH(CurrentDate),
DAY(CurrentDate)
)

VAR CuurentQuantitySold=
CALCULATE(
[Quantity Sold],
DimDate[Date]=CurrentDate
)
VAR LastYearQuantitySold=
CALCULATE(
[Quantity Sold],
DimDate[Date]=LastyearDate
)

RETURN ROW(
"Today Quantity Sold", CuurentQuantitySold,
"Last Year Same Day Quantity Sold" ,LastYearQuantitySold
)'
)

-------- Products with top returned rate YTD this year & last year 


SELECT *
FROM OPENQUERY(SSAS_TABULAR,'EVALUATE

VAR CurrentDate=
MAXX(
FILTER(ALL(DimDate),
[returned rate] <> BLANK()
),
DimDate[Date]
)


VAR LastyearDate=DATE(
YEAR(CurrentDate)-1,
MONTH(CurrentDate),
DAY(CurrentDate)
)

VAR TopCurrentProductReturned=
TOPN(1,
DISTINCT(DimProducts[ProductName]),
CALCULATE(
[returned rate],
YEAR(DimDate[Date])=YEAR(CurrentDate)
),
DESC)

VAR TopCurrentProductName=CONCATENATEX(
TopCurrentProductReturned
,DimProducts[ProductName],
 UNICHAR(10))


VAR TopLastYearProductReturned=
TOPN(1,
DISTINCT(DimProducts[ProductName]),
CALCULATE(
[returned rate],
DimDate[Date]>=DATE(YEAR(LastyearDate),1,1),
DimDate[Date]<=LastyearDate
),
DESC)

VAR TopLastYearProductName=CONCATENATEX(
TopLastYearProductReturned
,DimProducts[ProductName],
 UNICHAR(10))

RETURN ROW(
"Top Current Product Returned",TopCurrentProductName,
"Top Last Year Product Returned",TopLastYearProductName
)'
)



