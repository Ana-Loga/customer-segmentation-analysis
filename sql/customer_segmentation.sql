-- ========================================
-- Customer Segmentation Analysis
-- ========================================


-- ========================================
-- 1. Data Cleaning Check
-- Remove blank CustomerIDs and cancelled orders
-- ========================================

SELECT 
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM Online_Retail
WHERE CustomerID <> ''
  AND InvoiceNo NOT LIKE 'C%'
GROUP BY CustomerID
ORDER BY total_orders DESC;


-- ========================================
-- 2. Distribution Summary
-- Used to define segmentation thresholds
-- ========================================

SELECT 
    MIN(Revenue) AS min_revenue,
    MAX(Revenue) AS max_revenue,
    AVG(Revenue) AS avg_revenue,
    MIN(Total_Orders) AS min_orders,
    MAX(Total_Orders) AS max_orders,
    AVG(Total_Orders) AS avg_orders
FROM (
    SELECT 
        CustomerId,
        COUNT(DISTINCT InvoiceNo) AS Total_Orders,
        ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue
    FROM Online_Retail
    WHERE CustomerId <> ''
      AND InvoiceNo NOT LIKE 'C%'
    GROUP BY CustomerId
) AS t;


-- ========================================
-- 3. Final Customer Segmentation
-- ========================================

WITH Customer_Segmentation AS (
    SELECT 
        CustomerId,
        Total_Orders,
        Revenue,
        CASE
            WHEN Total_Orders > 80 OR Revenue > 25000 THEN 'High_Value_Customer'
            WHEN Total_Orders = 1 THEN 'Low_Value_Customer'
            ELSE 'Moderate_Value_Customer'
        END AS Customer_Segment
    FROM (
        SELECT 
            CustomerId,
            COUNT(DISTINCT InvoiceNo) AS Total_Orders,
            ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue 
        FROM Online_Retail
        WHERE CustomerId <> ''
          AND InvoiceNo NOT LIKE 'C%'
        GROUP BY CustomerId
    ) AS RevenueByCustomer
)

SELECT 
    Customer_Segment,
    COUNT(*) AS num_customers,
    SUM(Revenue) AS total_revenue,
    ROUND(SUM(Revenue) * 100.0 / (SELECT SUM(Revenue) FROM Customer_Segmentation), 0) AS percentage_of_revenue,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Customer_Segmentation), 0) AS percentage_of_customers
FROM Customer_Segmentation 
GROUP BY Customer_Segment;
