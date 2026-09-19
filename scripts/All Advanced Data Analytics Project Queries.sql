-- Analyze The Change of Sales Performance over Time 

SELECT
	YEAR(order_date) AS order_years ,
	MONTH(order_date) AS order_months,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) , MONTH(order_date)
ORDER BY YEAR(order_date) , MONTH(order_date)

-- Another Way to do it 

SELECT
	DATETRUNC(MONTH ,order_date) AS order_date ,     --Here I combined the 2 columns into one But I prefer the previous one
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH ,order_date)
ORDER BY DATETRUNC(MONTH ,order_date)


-----------------------------------------------------------------------------------------------------------------------------
--Cumulative Analysis


--Calculate the total sales per month
--and the running total of sales over time

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) AS moving_average_price
FROM
	(
	SELECT
		DATETRUNC(MONTH ,order_date) AS order_date ,    
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH ,order_date)
	)t


-----------------------------------------------------------------------------------------------------------------------------
-- Performance Analysis


/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */

WITH yearly_product_sales AS (
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f. sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY
		YEAR(f.order_date),
		p.product_name
	)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	--average sales performance
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	ELSE 'Avg'
	END AS flag_avg,
	--Total sales compared to previous year (Year-over-Year Analysis)
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	ELSE 'No Change'
	END py_change
FROM yearly_product_sales
ORDER BY product_name,order_year


-----------------------------------------------------------------------------------------------------------------------------
-- Part To Whole Analysis


-- Which Category Contribute the Most to the Overall sales ?

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100) , 2) , '%')AS total_contribution
FROM(
	SELECT
		p.category,
		SUM(s.sales_amount) AS total_sales
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
	GROUP BY p.category
	)t
ORDER BY total_sales DESC


-----------------------------------------------------------------------------------------------------------------------------

--Data Segmentation

WITH product_segments AS(
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
	END cost_range
FROM gold.dim_products)


SELECT
	cost_range,
	COUNT (product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS (
	SELECT
		c.customer_key,
		SUM(s.sales_amount) AS total_spending,
		MIN(s.order_date) AS first_order,	
		MAX(s.order_date) AS last_order,
		DATEDIFF(month  ,MIN(s.order_date) , MAX(s.order_date)) AS life_span
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customers AS c
	ON s.customer_key = c.customer_key
	GROUP BY c.customer_key
)


SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM(
	SELECT
		customer_key,
		total_spending,
		life_span,
		CASE WHEN life_span <= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN life_span <= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending
	)t
GROUP BY customer_segment
ORDER BY COUNT(customer_key) DESC


-------------------------------------------------------------------------------------------------------------------
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
	CASE WHEN life_span <= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN life_span <= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_category
FROM customer_aggregation