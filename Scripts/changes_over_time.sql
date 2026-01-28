
/*
===============================================================================
Query: Monthly Sales Aggregation

Description:
This query generates a monthly sales performance summary from the
gold.fact_sales table.

It groups transactions by year and month of the order date and computes:
- Total sales amount
- Number of distinct customers
- Total quantity sold

Only records with valid (non-NULL) order dates are included.
The results are ordered chronologically to support trend analysis.
===============================================================================
*/

USE DataWarehouse;

SELECT  
    YEAR(order_date) order_year,
    Month(order_date) order_month,
    SUM(sales_amount) total_sales,
    COUNT(DISTINCT customer_key) total_customers,
    SUM(quantity) total_quantity
FROM    
    gold.fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY    
    YEAR(order_date), Month(order_date)
ORDER BY 
    YEAR(order_date), Month(order_date);





