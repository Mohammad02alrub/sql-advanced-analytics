
/*
===============================================================================
Analysis: Product Cost Segmentation & Customer Spending Segmentation

Part 1: Product Cost Segmentation
---------------------------------
This section classifies products into cost ranges based on product_cost
and counts how many products fall into each range.

Steps:
1) CTE (product_segments):
   - Reads from gold.dim_products.
   - Assigns each product to a cost range bucket:
        * Below 100
        * 100 - 500
        * 500 - 1000
        * Above 1000

2) Final Query:
   - Groups by cost_range.
   - Counts total products in each segment.
   - Orders by number of products (descending).

Part 2: Customer Spending Segmentation
--------------------------------------
This section analyzes customer purchase behavior and segments customers
based on lifespan and total spending.

Steps:
1) CTE (customer_spending):
   - Joins gold.fact_sales with gold.dim_customers.
   - Calculates per-customer:
        * Total spending
        * First and last order dates
        * Lifespan in months

2) Final Query:
   - Classifies customers into:
        * VIP      (lifespan >= 12 and spending > 5000)
        * Regular  (lifespan >= 12 and spending <= 5000)
        * New      (lifespan < 12)
   - Counts number of customers in each segment.
   - Orders segments by total customers (descending).

These queries support product pricing analysis and customer segmentation
for business and marketing insights.
===============================================================================
*/


USE DataWarehouse;

WITH product_segments as(
SELECT 
    product_key,
    product_name,
    product_cost,
    CASE
        WHEN product_cost < 100 THEN 'Below 100'
        WHEN product_cost BETWEEN 100 AND 500 THEN '100 - 500'
        WHEN product_cost BETWEEN 500 AND 1000 THEN '500 - 1000'
        ELSE 'Above 1000'
    END cost_range
FROM    
    gold.dim_products
)

SELECT  
    cost_range,
    COUNT(product_key) total_products
FROM 
    product_segments
GROUP BY 
    cost_range
ORDER BY
    total_products DESC;
GO



SELECT * FROM gold.dim_customers;

WITH customer_spending as(
SELECT 
    c.customer_key,
    SUM(f.sales_amount) total_spending,
    MIN(f.order_date) first_order,
    MAX(f.order_date) last_order,
    DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) lifespan
FROM    
    gold.fact_sales f
LEFT JOIN  
    gold.dim_customers c
ON
    f.customer_key = c.customer_key
GROUP BY
    c.customer_key
)

SELECT
    customer_segment,
    COUNT(customer_key) as total_customers
FROM(
    SELECT 
        customer_key,
        CASE
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP' 
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular' 
            ELSE 'New'
        END customer_segment
    FROM
        customer_spending
) t

GROUP BY
    customer_segment
ORDER BY 
    total_customers DESC;






