/*

	-This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend

*/
CREATE VIEW gold.report_customers AS
WITH base_query AS(

	SELECT
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name , ' ' , c.last_name) AS customer_name,
		DATEDIFF(YEAR , birthdate , GETDATE()) AS age,
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.sales_quantity
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
	WHERE order_date IS NOT NULL
),

 customer_aggregation AS(
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		SUM(sales_amount) AS total_spending,
		MAX(order_date) AS last_order,
		DATEDIFF(MONTH , MIN(order_date),MAX(order_date)) AS life_span
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
	)

SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE WHEN age < 20 THEN 'Below 20'
		 WHEN age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN age BETWEEN 30 AND 39 THEN '30-39'
		 WHEN age BETWEEN 40 AND 49 THEN '40-49'
		 ELSE '50 And Above'
	END AS age_group,
	last_order,
	DATEDIFF(month , last_order , GETDATE()) AS recency,
	total_orders,
	total_quantity,
	total_products,
	total_spending,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_spending/ total_orders 
		 END AS average_order_value,
	CASE WHEN life_span = 0 THEN 0
		 ELSE total_spending/ life_span 
		 END AS average_monthly_spend,
	life_span,
	CASE WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_category
FROM customer_aggregation
