create database AutoMobile;
use AutoMobile;

drop table automobile_sales;

select * from automobile_sales;
desc automobile_sales;

alter table automobile_sales rename column Year to fy;
-- ALTER TABLE automobile_sales
-- MODIFY fy int;

set sql_safe_updates = 0;
UPDATE automobile_sales
SET fy = SUBSTRING_INDEX(fy, '-', -1);

UPDATE automobile_sales
SET fy = SUBSTRING_INDEX(fy, '-', -1);

UPDATE automobile_sales
SET fy = CONCAT('20', fy);


-- 🔹 Step-by-Step Guide to Build Dashboard Cards and Charts
-- 1. Total Units Sold in FY 2023-24 (Card)
-- 	Visual: Card Steps:
-- 	Create a measure:
-- 	Total Units FY24 = CALCULATE(SUM('Sales'[Units Sold (in 1000s)]), 'Sales'[Year] = "2023-24")
-- 	Insert a Card visual, drag Total Units FY24 into it.
select * from automobile_sales where fy = 2024;
select fy, sum(Units_Sold) as total from automobile_sales where fy = 2024 group by fy;

-- ---

-- 2. Top-Selling Company in FY 2024 (Card or Bar Chart)
select fy, company, sum(Units_sold) as total_sales from automobile_sales 
where fy = 2024 
group by company,fy order by company desc limit 1;

-- 	Visual: Bar Chart or Card Steps:
-- 	Add a clustered bar chart.
-- 	Axis: Company, Value: Units Sold
-- 	Add Visual Level Filter: Year = "2023-24"
-- 	Sort by Units Sold descending.

-- 3. Segment-wise Performance Over Years (Stacked Column Chart)
select *, sum(units_sold) over(partition by segment order by fy ) as sales_over_year from automobile_sales;
-- 	Visual: Stacked Column Chart Steps:

-- 	Axis: Year
-- 	Legend: Segment
-- 	Values: Units Sold

-- 4. YoY Growth % for Each Company (Matrix or Table)
SELECT
    company,
    fy,
    ROUND(
        (units_sold - LAG(units_sold) OVER (PARTITION BY company ORDER BY fy))
        / LAG(units_sold) OVER (PARTITION BY company ORDER BY fy) * 100, 2
    ) AS yoy_growth_pct
FROM automobile_sales;


-- 	Visual: Table Steps:
-- 	Create two measures:



-- 	Current Year Sales = CALCULATE(SUM('Sales'[Units Sold (in 1000s)]), 'Sales'[Year] = "2023-24")
-- 	Previous Year Sales = CALCULATE(SUM('Sales'[Units Sold (in 1000s)]), 'Sales'[Year] = "2022-23")
-- 	YoY Growth % = DIVIDE([Current Year Sales] - [Previous Year Sales], [Previous Year Sales])

-- 	Use a Table: Company | YoY Growth %




-- ---
select * from automobile_sales;  -- 1/6
-- 5. CAGR for Each Company (Over 5 Years)
-- First year total
SELECT SUM(units_sold)
INTO @f_value
FROM automobile_sales
WHERE fy = 2020;

-- Last year total
SELECT SUM(units_sold)
INTO @l_value
FROM automobile_sales
WHERE fy = 2024;

-- CAGR
SET @cagr = POWER(@l_value / @f_value, 1.0/4) - 1;
SELECT ROUND(@cagr * 100, 2) AS cagr_percent;


-- 	Manual calculation recommended (Calculated Columns) 
-- 	Use formula:
-- 	CAGR = ((End_Value / Start_Value) ^ (1/Number_of_years)) - 1


-- ---

-- 6. Electric Vehicle Sales Growth (Line Chart)
SELECT
    fy,
    SUM(units_sold) AS total_ev_sales,
    ROUND(
        (SUM(units_sold) - 
         LAG(SUM(units_sold)) OVER (ORDER BY fy))
        /
         LAG(SUM(units_sold)) OVER (ORDER BY fy)
        * 100, 2
    ) AS yoy_growth_percent
FROM automobile_sales
WHERE segment = 'Electric'
GROUP BY fy
ORDER BY fy;

-- 	Visual: Line Chart Steps:

-- 	Filter: Segment = "Electric"
-- 	Axis: Year
-- 	Legend: Company
-- 	Value: Units Sold
-- ---

-- 7. SUV Segment Leader in FY 2023-24
select company ,sum(units_sold) as total from automobile_sales where segment = "SUV" and fy = 2024 group by company order by total desc limit 1;
-- 	Visual: Bar Chart Steps:
-- 	Filter: Segment = "SUV", Year = "2023-24"
-- 	Axis: Company, Value: Units Sold

-- ---

-- 8. Market Share by Company (Donut/Pie Chart)
SELECT 
    company,
    SUM(units_sold) AS total_units,
    ROUND(
        SUM(units_sold) /
        (SELECT SUM(units_sold) 
         FROM automobile_sales 
         WHERE fy = 2024) * 100,
    2) AS market_share_percent
FROM automobile_sales
WHERE fy = 2024
GROUP BY company;

-- 	Visual: Donut Chart Steps:
-- 	Filter: Year = "2023-24"
-- 	Legend: Company
-- 	Value: Units Sold
-- 	Create DAX for share:
-- 	Market Share % = 
-- 	DIVIDE(
-- 	    SUM('Sales'[Units Sold (in 1000s)]),
-- 	    CALCULATE(SUM('Sales'[Units Sold (in 1000s)]), ALL('Sales'[Company])))


-- ---

-- 9. Company Trend Lines (Line Chart)

-- 	Visual: Line Chart Steps:
-- 	Axis: Year
-- 	Legend: Company
-- 	Values: Units Sold
-- ---

-- 🌟 Bonus Insights

-- 10. Which Segment Grew the Most in 5 Years?

-- 	Visual: Line/Column Chart Steps:
-- 	Axis: Year
-- 	Legend: Segment
-- 	Values: Units Sold
-- 	Observe slope or calculate growth from first to last year.



-- 11. Most Diversified Company (Operates in All 5 Segments)
-- 	Visual: Matrix or Table Steps:
-- 	Create a measure to count distinct segments per company:
-- 	Distinct Segments = CALCULATE(DISTINCTCOUNT('Sales'[Segment]))
-- 	Place it in a table: Company | Distinct Segments
SELECT DISTINCT segment
FROM automobile_sales;

SELECT 
    company, 
    COUNT(DISTINCT segment) AS segment_count
FROM automobile_sales
GROUP BY company
ORDER BY segment_count DESC;



-- 12. EV Market Leader in FY 2023-24
-- 	Visual: Bar Chart Steps:
-- 	Filter: Year = "2023-24" and Segment = "Electric"
-- 	Axis: Company, Value: Units Sold
select company, sum(units_sold) as total from automobile_sales where fy = 2024 and segment = "Electric" group by company order by total desc limit 1;


-- 13. Performance Dashboard with Dynamic Slicers
-- 	Visual: Use slicers for: Year
-- 				Company
-- 				Segment


-- 	These slicers should be placed at the top of your dashboard to dynamically filter all visuals.



-- 14. Declining Segment Detector
select segment, sum(units_sold) as total from automobile_sales  ;
-- 	Visual: Line Chart Steps:
-- 	Plot Segment-wise data over time.
-- 	Use conditional formatting or slope to highlight declines.
SELECT *
FROM (
    SELECT
        segment,
        fy,
        SUM(units_sold) AS total_sales,
        SUM(units_sold) -
        LAG(SUM(units_sold)) OVER 
            (PARTITION BY segment ORDER BY fy) 
        AS change_in_sales
    FROM automobile_sales
    GROUP BY segment, fy
) t
WHERE change_in_sales < 0
ORDER BY segment, fy;


-- ---