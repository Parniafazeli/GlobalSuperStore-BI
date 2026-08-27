CREATE OR ALTER FUNCTION dbo.fn_GregorianToPersian (@GDate DATE)
RETURNS VARCHAR(10)
AS
BEGIN
    IF @GDate IS NULL RETURN NULL;

    DECLARE @gy INT = YEAR(@GDate),
            @gm INT = MONTH(@GDate),
            @gd INT = DAY(@GDate);

    DECLARE @g_d_m TABLE (m INT, d INT);
    INSERT INTO @g_d_m VALUES (1,0),(2,31),(3,59),(4,90),(5,120),(6,151),(7,181),(8,212),(9,243),(10,273),(11,304),(12,334);

    DECLARE @jy INT, @jm INT, @jd INT;
    DECLARE @gy2 INT = CASE WHEN @gm > 2 THEN @gy + 1 ELSE @gy END;
    DECLARE @days INT = 355666 + (365 * @gy) + ((@gy2 + 3) / 4) - ((@gy2 + 99) / 100) + ((@gy2 + 399) / 400) + @gd + (SELECT d FROM @g_d_m WHERE m = @gm);

    SET @jy = -1595 + (33 * (@days / 12053));
    SET @days = @days % 12053;
    SET @jy = @jy + 4 * (@days / 1461);
    SET @days = @days % 1461;

    IF @days > 365
    BEGIN
        SET @jy = @jy + ((@days - 1) / 365);
        SET @days = (@days - 1) % 365;
    END

    IF @days < 186
    BEGIN
        SET @jm = 1 + (@days / 31);
        SET @jd = 1 + (@days % 31);
    END
    ELSE
    BEGIN
        SET @jm = 7 + ((@days - 186) / 30);
        SET @jd = 1 + ((@days - 186) % 30);
    END

    RETURN CAST(@jy AS VARCHAR(4)) + '/' + 
           RIGHT('0' + CAST(@jm AS VARCHAR(2)), 2) + '/' + 
           RIGHT('0' + CAST(@jd AS VARCHAR(2)), 2);
END;
GO




CREATE TABLE dbo.DimDate (
    DateKey INT PRIMARY KEY,
    [Date] DATE NOT NULL,
   
    [Year] INT,
    [Quarter] VARCHAR(2),
    [QuarterName] VARCHAR(10),
    MonthNumber INT,
    MonthName VARCHAR(20),
    MonthShort VARCHAR(3),
    YearMonth VARCHAR(7),
    YearMonthNumber INT,
    DayOfMonth INT,
    DayOfWeekName VARCHAR(15),
    DayOfWeekShort VARCHAR(3),
    DayOfWeekNumber INT,
    IsWeekend BIT,
    PersianDate VARCHAR(10),
    PersianYear INT,
    PersianMonthNumber INT,
    PersianMonthName NVARCHAR(20),
    PersianYearMonth VARCHAR(7),
    PersianYearMonthNumber INT,
    PersianDayOfMonth INT,
    PersianQuarter VARCHAR(10),
    PersianDayOfWeek NVARCHAR(20),
    PersianDayOfWeekNumber INT,
    PersianIsWeekend BIT
);


DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate   DATE = '2017-12-31';

WITH DateSequence AS (
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM DateSequence
    WHERE [Date] < @EndDate
),
DateConverted AS (
    SELECT 
        [Date],
        dbo.fn_GregorianToPersian([Date]) AS PDate
    FROM DateSequence
)
INSERT INTO dbo.DimDate
SELECT 
   
    CAST(CONVERT(VARCHAR(8), [Date], 112) AS INT) AS DateKey,
    [Date],
    YEAR([Date]) AS [Year],
    'Q' + CAST(DATEPART(QUARTER, [Date]) AS VARCHAR(1)) AS [Quarter],
    'Q' + CAST(DATEPART(QUARTER, [Date]) AS VARCHAR(1)) + ' ' + CAST(YEAR([Date]) AS VARCHAR(4)) AS [QuarterName],
    MONTH([Date]) AS MonthNumber,
    DATENAME(MONTH, [Date]) AS MonthName,
    LEFT(DATENAME(MONTH, [Date]), 3) AS MonthShort,
    LEFT(CONVERT(VARCHAR(10), [Date], 120), 7) AS YearMonth,
    CAST(FORMAT([Date], 'yyyyMM') AS INT) AS YearMonthNumber,
    DAY([Date]) AS DayOfMonth,
    DATENAME(WEEKDAY, [Date]) AS DayOfWeekName,
    LEFT(DATENAME(WEEKDAY, [Date]), 3) AS DayOfWeekShort,
    DATEPART(WEEKDAY, [Date]) AS DayOfWeekNumber,
    CASE WHEN DATEPART(WEEKDAY, [Date]) IN (7, 1) THEN 1 ELSE 0 END AS IsWeekend,
    
  
    PDate AS PersianDate,
    CAST(LEFT(PDate, 4) AS INT) AS PersianYear,
    CAST(SUBSTRING(PDate, 6, 2) AS INT) AS PersianMonthNumber,
    CASE CAST(SUBSTRING(PDate, 6, 2) AS INT)
        WHEN 1 THEN N'فروردین'
        WHEN 2 THEN N'اردیبهشت'
        WHEN 3 THEN N'خرداد'
        WHEN 4 THEN N'تیر'
        WHEN 5 THEN N'مرداد'
        WHEN 6 THEN N'شهریور'
        WHEN 7 THEN N'مهر'
        WHEN 8 THEN N'آبان'
        WHEN 9 THEN N'آذر'
        WHEN 10 THEN N'دی'
        WHEN 11 THEN N'بهمن'
        WHEN 12 THEN N'اسفند'
    END AS PersianMonthName,
    LEFT(PDate, 7) AS PersianYearMonth,
    CAST(REPLACE(LEFT(PDate, 7), '/', '') AS INT) AS PersianYearMonthNumber,
    CAST(RIGHT(PDate, 2) AS INT) AS PersianDayOfMonth,
    'فصل ' + CAST(CASE 
        WHEN CAST(SUBSTRING(PDate, 6, 2) AS INT) BETWEEN 1 AND 3 THEN 1
        WHEN CAST(SUBSTRING(PDate, 6, 2) AS INT) BETWEEN 4 AND 6 THEN 2
        WHEN CAST(SUBSTRING(PDate, 6, 2) AS INT) BETWEEN 7 AND 9 THEN 3
        ELSE 4 END AS VARCHAR(1)) AS PersianQuarter,
    CASE DATEPART(WEEKDAY, [Date])
        WHEN 7 THEN N'شنبه'
        WHEN 1 THEN N'یک‌شنبه'
        WHEN 2 THEN N'دوشنبه'
        WHEN 3 THEN N'سه‌شنبه'
        WHEN 4 THEN N'چهارشنبه'
        WHEN 5 THEN N'پنج‌شنبه'
        WHEN 6 THEN N'جمعه'
    END AS PersianDayOfWeek,
    CASE DATEPART(WEEKDAY, [Date])
        WHEN 7 THEN 1
        WHEN 1 THEN 2
        WHEN 2 THEN 3
        WHEN 3 THEN 4 
        WHEN 4 THEN 5 
        WHEN 5 THEN 6 
        WHEN 6 THEN 7 
    END AS PersianDayOfWeekNumber,
    CASE WHEN DATEPART(WEEKDAY, [Date]) = 6 THEN 1 ELSE 0 END AS PersianIsWeekend
FROM DateConverted
OPTION (MAXRECURSION 0);
GO