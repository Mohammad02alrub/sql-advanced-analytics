
/*
===============================================================================
Analysis: Year-over-Year Product Performance & Trend Comparison

Description:
This query analyzes yearly sales performance for each product and compares
each year’s results against:

1) The product’s historical average sales.
2) The previous year’s (PY) sales.

Steps:
1) CTE (yearly_product_sales):
   - Joins gold.fact_sales with gold.dim_products.
   - Aggregates total sales by product and year.
   - Filters out records with NULL order dates.

2) Final Query:
   - Calculates:
        * Average yearly sales per product (window AVG).
        * Difference from the product’s average (avg_diff).
        * Classification as Above Avg / Below Avg / Avg.
        * Previous year sales using LAG.
        * Year-over-year difference (py_diff).
        * Trend direction: Increasing / Decreasing / No Change.

The output supports:
- Trend analysis
- Performance benchmarking
- Year-over-year growth evaluation at product level
===============================================================================
*/

USE DataWarehouse;

--------------------------
WITH yearly_product_sales AS(
    SELECT
    YEAR(f.order_date) order_year,
    p.product_name,
    sum(f.sales_amount) total_sales
FROM    
    gold.fact_sales f
LEFT JOIN 
    gold.dim_products P
ON
    f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(f.order_date), 
    p.product_name
)

SELECT 
    order_year,
    product_name,
    total_sales,
    AVG(total_sales) OVER(PARTITION BY product_name) sales_avg,
    total_sales - AVG(total_sales) OVER(PARTITION BY product_name) avg_diff,
    CASE
        WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END avg_change,
    LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales,
    total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_diff,
    CASE
        WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increasing'
        WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreasing'
        ELSE 'No Change'
    END py_change
FROM 
    yearly_product_sales
ORDER BY
    product_name, order_year













