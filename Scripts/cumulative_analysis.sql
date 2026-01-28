
/*
===============================================================================
Query: Monthly Running Total of Sales

Description:
This query calculates the cumulative (running) total of sales over time
at a monthly level.

Steps:
1) Inner Query:
   - Truncates order_date to the first day of each month.
   - Aggregates total sales per month from gold.fact_sales.
   - Excludes records with NULL order dates.

2) Outer Query:
   - Uses a window function (SUM OVER ORDER BY) to compute the running
     total of monthly sales ordered chronologically.

The result shows:
- Month (order_date truncated to month)
- Total sales for that month
- Cumulative sales up to that month
===============================================================================
*/

USE DataWarehouse;

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_date) running_total_sales
FROM
(
    SELECT 
        DATETRUNC(MONTH, order_date) order_date,
        SUM(sales_amount) total_sales
    FROM 
        gold.fact_sales
    WHERE   
        order_date IS NOT NULL
    GROUP BY 
        DATETRUNC(MONTH, order_date)
) t
ORDER BY
    order_date;











