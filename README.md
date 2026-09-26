# 📊 SQL Exploratory Data Analysis (EDA) & Advanced Analytics

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Data Analytics](https://img.shields.io/badge/Data_Analytics-FF6F00?style=for-the-badge&logo=google-analytics&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

## 📌 Project Overview
This repository contains a collection of **T-SQL** scripts for performing **Exploratory Data Analysis (EDA)** and **Advanced Data Analytics**[cite: 2, 4, 6]. Building upon my [SQL Data Warehouse Project](https://github.com/AhmadBKiswani/sql-data-warehouse-project), this project queries the **Gold Layer** star schema (`gold.fact_sales`, `gold.dim_customers`, and `gold.dim_products`) to uncover business trends, segment data, and build BI-ready reporting views[cite: 2, 3, 4, 5].

---

## 🗺️ Project Roadmap

![Project Roadmap](Project%20Roadmap.jpg)

The project follows a structured 12-step analytical workflow divided into two main tracks[cite: 6]:

---

## 🔍 Analytical Workflow & Scripts

### 1️⃣ Exploratory Data Analysis (EDA)
📄 **Script:** [`scripts/EDA Analysis Project.sql`](scripts/EDA%20Analysis%20Project.sql)[cite: 4]

Covers Steps 1 to 6 of the roadmap to profile the database and calculate foundational KPIs[cite: 4, 6]:
* **Database & Dimensions Exploration:** Inspects tables and columns via `INFORMATION_SCHEMA` and profiles unique product hierarchies (`category`, `subcategory`, `product_name`)[cite: 4, 6].
* **Date Exploration:** Identifies the historical timespan of orders (`first_order_date`, `last_order_date`) and customer age boundaries using `MIN()`, `MAX()`, and `DATEDIFF()`[cite: 4, 6].
* **Measures Exploration (Big Numbers):** Generates a unified executive KPI report using `UNION ALL` covering Total Sales, Total Quantity, Average Price, Total Orders, Total Products, and Total Customers[cite: 4, 6].
* **Magnitude Analysis:** Aggregates sales, quantities, average costs, and customer counts across key dimensions (countries, gender, and product categories)[cite: 4, 6].
* **Ranking Analysis (Top N / Bottom N):** Ranks the top/bottom 5 products by revenue and top 10 customers using `TOP` and window ranking functions (`RANK() OVER`)[cite: 4, 6].

---

### 2️⃣ Advanced Data Analytics
📄 **Script:** [`scripts/All Advanced Data Analytics Project Queries.sql`](scripts/All%20Advanced%20Data%20Analytics%20Project%20Queries.sql)[cite: 2]

Covers Steps 7 to 11 to answer complex business questions using Window Functions and CTEs[cite: 2, 6]:
* **Change-Over-Time Trends:** Tracks monthly and yearly sales, customer counts, and quantities using `YEAR()`, `MONTH()`, and `DATETRUNC()`[cite: 2, 6].
* **Cumulative Analysis:** Calculates running total sales (`SUM() OVER`) and moving average prices (`AVG() OVER`) partitioned by year[cite: 2, 6].
* **Performance Analysis (YoY & Benchmark):** Compares yearly product sales against each product's historical average (`Above/Below Avg`) and prior-year performance (`Year-over-Year`) using `LAG()`[cite: 2, 6].
* **Part-to-Whole Analysis:** Computes the percentage contribution of each product category to overall revenue[cite: 2, 6].
* **Data Segmentation:** 
  * Groups products into 4 cost tiers (`Below 100`, `100-500`, `500-1000`, `Above 1000`)[cite: 2].
  * Segments customers into `VIP`, `Regular`, and `New` based on spending behavior and lifespan[cite: 2].

---

### 3️⃣ Consolidated BI Reporting Views (Step 12)
Reusable SQL views designed for direct connection to BI and reporting tools[cite: 3, 5, 6]:

| View Name | Script | Key Highlights & KPIs |
| :--- | :--- | :--- |
| **`gold.report_customers`** | [`Customer Report.sql`](scripts/Customer%20Report.sql) | Consolidates customer demographics, age groups, behavioral segments (`VIP`, `Regular`, `New`), total orders/spending, **Recency**, **Average Order Value (AOV)**, and **Average Monthly Spend**[cite: 3]. |
| **`gold.report_products`** | [`Products Report.sql`](scripts/Products%20Report.sql) | Consolidates product hierarchy, revenue segments (`High-Performer`, `Mid-Range`, `Low-Performer`), customer reach, **Recency**, **Average Order Revenue (AOR)**, and **Average Monthly Revenue**[cite: 5]. |

---

## 📂 Repository Structure

    sql-exploratory-data-analysis-project/
    │
    ├── datasets/                                            # CSV source files for the Gold Layer tables
    ├── scripts/
    │   ├── EDA Analysis Project.sql                         # Steps 1–6: Exploratory Data Analysis queries
    │   ├── All Advanced Data Analytics Project Queries.sql  # Steps 7–12: Advanced Analytics queries
    │   ├── Customer Report.sql                              # DDL for gold.report_customers view
    │   └── Products Report.sql                              # DDL for gold.report_products view
    │
    ├── Project Roadmap.jpg                                  # Visual roadmap of the 12 analytical steps
    ├── LICENSE                                              # MIT License
    └── README.md                                            # Project documentation

---

## 🛠️ Key SQL Techniques Used
* **Window Functions:** `SUM() OVER()`, `AVG() OVER()`, `LAG() OVER()`, `RANK() OVER()`[cite: 2, 4]
* **Modular Querying:** Multi-stage Common Table Expressions (`CTEs`) and subqueries[cite: 2, 3, 4, 5]
* **Date Functions:** `DATETRUNC()`, `DATEDIFF()`, `GETDATE()`, `YEAR()`, `MONTH()`[cite: 2, 3, 4, 5]
* **Conditional & Defensive Logic:** `CASE WHEN`, `NULLIF()`, `CAST()`, `ROUND()`, `CONCAT()`[cite: 2, 3, 5]

---

## 👤 Author
**Ahmad Kiswani**  
🔗 **GitHub:** [@AhmadBKiswani](https://github.com/AhmadBKiswani)

## 📄 License
This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.
