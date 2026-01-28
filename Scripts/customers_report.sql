
/*
===============================================================================
View Name: gold.customers_report

Description:
This view generates a customer-level analytics report based on sales
transactions and customer master data. It is built in three main layers:

1) Base Query:
   - Joins fact_sales with dim_customers.
   - Retrieves core transactional and customer attributes.
   - Calculates customer age.
   - Filters out records with NULL order dates.

2) Customer Aggregation:
   - Aggregates data at the customer level.
   - Calculates key KPIs such as:
        * Total orders
        * Total sales and quantity
        * Total distinct products purchased
        * Last order date
        * Customer lifespan in months

3) Final Output:
   - Creates business segments and analytics fields including:
        * Age groups
        * Customer segments (VIP / Regular / New)
        * Recency in months
        * Average order value
        * Average monthly spend

The resulting view supports customer profiling, segmentation, and
performance analysis in the Gold analytics layer.
===============================================================================
*/

IF OBJECT_ID('gold.customers_report', 'V') IS NOT NULL
    DROP VIEW gold.customers_report;
GO

CREATE VIEW gold.customers_report AS
WITH base_query as(
-- 1) Base Query: Retrieves core columns from fact_sales and dim_customers
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) customer_name,
    DATEDIFF(YEAR, c.birth_date, GETDATE()) age
FROM
    gold.fact_sales f
LEFT JOIN
    gold.dim_customers c
ON
    f.customer_key = c.customer_key
WHERE 
    order_date IS NOT NULL
)

, customer_aggregation as(
-- 2) Customer Aggregations: Summarizes key metrics at the customer level
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) total_orders,
    SUM(sales_amount) total_sales,
    SUM(quantity) total_quantity,
    COUNT(DISTINCT product_key) total_products,
    MAX(order_date) last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan
FROM
    base_query
GROUP BY
    customer_key,
    customer_number,
    customer_name,
    age
)

-- 3) Final Query: Combines all customer results into one output
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END age_group,
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP' 
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular' 
        ELSE 'New'
    END customer_segment,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END average_order_value,
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END avg_monthly_spend
FROM 
    customer_aggregation;
GO

SELECT * FROM gold.customers_report;











