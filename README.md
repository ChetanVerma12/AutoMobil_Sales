# 🚗 Automobile Sales Analytics using MySQL (2019–2024)

## 📌 Project Overview

This project performs business analysis on automobile sales data (2019–2024) using **MySQL 8+**.

The objective is to extract meaningful insights using:

- SQL Aggregation
- Window Functions
- Growth Calculations
- Business KPI Analysis

No visualization tool was used. All insights were generated using pure SQL.

---

## 🗄️ Dataset Structure

**Table Name:** `automobile_sales`

| Column       | Data Type | Description |
|-------------|-----------|-------------|
| company     | VARCHAR   | Company name |
| segment     | VARCHAR   | Vehicle segment (SUV, EV, Sedan, etc.) |
| fy          | INT       | Financial year (e.g., 2020, 2021) |
| units_sold  | INT       | Units sold (in thousands) |

---

# 📊 Business Problems Solved Using SQL

---

## 1️⃣ Market Share by Company (FY 2024)

```sql
SELECT 
    company,
    SUM(units_sold) AS total_units,
    ROUND(
        SUM(units_sold) /
        SUM(SUM(units_sold)) OVER () * 100,
    2) AS market_share_percent
FROM automobile_sales
WHERE fy = 2024
GROUP BY company;

