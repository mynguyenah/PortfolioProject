-- Raw data has 541.909 rows
-- 406.829 rows with CustomerID != 0
-- 397.884 
SELECT *
FROM PortfolioProject.dbo.OnlineRetail;
-- Clean data
WITH online_retail AS(
	SELECT *
	FROM PortfolioProject.dbo.OnlineRetail
	WHERE CustomerID != 0
), quantity_unitprice AS(
--- There are some negative values in quantity column. I consider it as the return. Then remove out of data. 397.894 rows left.
SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0
), dup_check AS(
--duplicatecheck, 392.670 total rows left
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY InvoiceNo, StockCode, Quantity, InvoiceDate ORDER BY InvoiceDate) AS dup_flag
FROM quantity_unitprice
), clean_tbl AS(
SELECT *
FROM dup_check
WHERE dup_flag = 1
)
SELECT *
INTO #ready_tbl
FROM clean_tbl


SELECT *
FROM #ready_tbl
-- START COHORT ANALYSIS
SELECT
	mm.*
INTO #tbl
FROM
	(
	SELECT
		CustomerID,
		the_first_date,
		cohort_date
		/*YEAR(the_first_date) AS year_cohort,
		MONTH(the_first_date) AS month_cohort,
		YEAR(cohort_date) AS year_value,
		MONTH(cohort_date) AS month_value _ lam du*/ 
	FROM
		(
		SELECT 
			CustomerID,
			MIN(InvoiceDate) AS the_first_date,
			DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) AS cohort_date
		FROM #ready_tbl
		GROUP BY CustomerID
		)m
	)mm;

--
WITH cohort_tbl AS(
SELECT 
	a.CustomerID,
	a.Invoicedate,
	b.cohort_date,
	YEAR(a.InvoiceDate) AS year_invoice,
	MONTH(a.InvoiceDate) AS month_invoice,
	YEAR(b.cohort_date) AS year_cohort,
	MONTH(b.cohort_date) AS month_cohort
FROM #ready_tbl a LEFT JOIN #tbl b ON a.CustomerID = b.CustomerID
)
SELECT
	CustomerID,
	cohort_date,
	year_invoice,
	month_invoice,
	year_cohort,
	month_cohort,
	(year_invoice - year_cohort)* 12 + (month_invoice - month_cohort) + 1 AS cohort_index
INTO #result
FROM cohort_tbl
GROUP BY CustomerID, cohort_date, year_invoice,
	month_invoice,
	year_cohort,
	month_cohort
-- pivot table

SELECT *
INTO #cohort_pivot
FROM
	(SELECT 
		CustomerID,
		cohort_date,
		cohort_index
	FROM #result
	) tbl
pivot(
COUNT(CustomerID)
for cohort_index IN
(
	[1],
	[2],
	[3],
	[4],
	[5],
	[6],
	[7],
	[8],
	[9],
	[10],
	[11],
	[12],
	[13]
)) AS pivot_table
ORDER BY cohort_date

SELECT *
FROM #result