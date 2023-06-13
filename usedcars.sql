-- create a temp table for clean data

Drop Table if exists #usedcars
Create Table #usedcars
(
price numeric,
year numeric,
manufacturer nvarchar(255),
model nvarchar(255),
condition nvarchar(255),
cylinders nvarchar(255),
fuel nvarchar(255),
odometer numeric,
title_status nvarchar(255),
type nvarchar(255),
paint_color nvarchar(255),
state nvarchar(255),
lat nvarchar(255),
long nvarchar(255),
)
Insert into #usedcars
SELECT price, year, manufacturer, model, condition, cylinders, fuel, odometer,title_status, type, paint_color, state, lat, long
FROM PortfolioProject..vehicles
where manufacturer is not null
AND
(price < 200000 AND price > 2000)
AND year > 1960



-- price analysis (CTE)
With ctetbl (price, yr, manufacturer, model, condition, cylinders, fuel, title_status, type, paint_color, state, lat, long, post_YYYYMM)
as(
SELECT price, year, manufacturer, model, condition, cylinders, fuel, title_status, type, paint_color, state, lat, long, left(posting_date,7) as post_YYYYMM
FROM PortfolioProject..vehicles
where manufacturer is not null
AND
(price < 200000 AND price > 2000)
)
SELECT 
    AVG(price) AS average_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM ctetbl

-- Calculating Median
SELECT
(
 (SELECT MAX(price) FROM
   (SELECT TOP 50 PERCENT price FROM #usedcars ORDER BY price) AS BottomHalf)
 +
 (SELECT MIN(price) FROM
   (SELECT TOP 50 PERCENT price FROM #usedcars ORDER BY price DESC) AS TopHalf)
) / 2 AS Median

-- Price Distribution
SELECT 
    price,
    COUNT(*) AS count
FROM #usedcars
GROUP BY price
ORDER BY price

-- Finding Outliers

SELECT *
FROM PortfolioProject..vehicles
WHERE price < (SELECT AVG(price) - 3 * STDEV(price) FROM PortfolioProject..vehicles)
   OR price > (SELECT AVG(price) + 3 * STDEV(price) FROM PortfolioProject..vehicles)



-- Compare prices across Manufacturers, Year, Models using AVG price 
--(3)
SELECT
    manufacturer,
    AVG(price) AS average_price
FROM #usedcars
GROUP BY manufacturer
ORDER BY average_price DESC;

SELECT
    manufacturer,model,
    AVG(price) AS average_price
FROM #usedcars
GROUP BY manufacturer,model
ORDER BY average_price DESC
-- (2)
SELECT
year, AVG(price) as average_price
FROM #usedcars
WHERE fuel = 'electric'
GROUP BY year
ORDER BY average_price ASC

-- Relationship between Year and Mileage

SELECT year, AVG(odometer) as AVG_mileage, title_status
from #usedcars
WHERE fuel = 'electric'
GROUP BY year, title_status
ORDER BY year ASC

-- analysis by state (1)

SELECT UPPER(state) as state, ROUND(AVG(price),2) as AVG_price, type,fuel
FROM #usedcars
WHERE state != ''
AND type is not null
AND fuel is not null
GROUP by state, type, fuel
ORDER by AVG_price

-- AVG price trend by manufacturer (Price Depreciation analysis) (4)

SELECT manufacturer, year, ROUND(AVG(price),2) as AVG_price
FROM #usedcars
GROUP by manufacturer, year
ORDER by manufacturer,year DESC

-- Get number of rows by manufacturer to see which manufacturer had most used car listing on Craigslist (5)

SELECT TOP 5 manufacturer,COUNT(manufacturer) as Listing_COUNT
FROM #usedcars
GROUP BY manufacturer
ORDER BY COUNT(manufacturer) DESC



-- Creating View for Visualization

Create View usedcars as 
SELECT price, year, manufacturer, model, condition, cylinders, fuel, odometer,title_status, type, paint_color, state, lat, long
FROM PortfolioProject..vehicles
where manufacturer is not null
AND
(price < 200000 AND price > 2000)
AND year > 1960
