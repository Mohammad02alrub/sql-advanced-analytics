
/*
===============================================================================
Analysis: Part-to-Whole (Category Sales Contribution)

Description:
This query performs a part-to-whole analysis by showing how each product
category contributes to total company sales.

Steps:
1) CTE (category_sales):
   - Joins gold.fact_sales with gold.dim_products.
   - Aggregates total sales per category.

2) Final Query:
   - Calculates overall sales using a window function.
   - Computes each category’s percentage share of total sales.
   - Orders categories by total sales (descending).

This analysis helps identify which categories drive the largest portion
of overall revenue.
===============================================================================
*/

USE DataWarehouse;

WITH category_sales as (
SELECT 
    category,
    SUM(f.sales_amount) total_sales
FROM    
    gold.fact_sales f
LEFT JOIN
    gold.dim_products p
ON
    f.product_key = p.product_key
GROUP BY p.category
)

SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER() overall_sales,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') as percentage_of_total
FROM
    category_sales
ORDER BY 
    total_sales DESC







