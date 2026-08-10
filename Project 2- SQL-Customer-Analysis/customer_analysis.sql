-- ================================================
-- Project 2: Customer Behaviour Analysis
-- Tool: SQL Server (SSMS)
-- Dataset: Northwind Database
-- Analyst: Aisha Omotola
-- ================================================

USE Northwind;
GO

-- Q1: Customer distribution by country
SELECT 
    Country,
    COUNT(CustomerID) AS Total_Customers
FROM Customers
GROUP BY Country
ORDER BY Total_Customers DESC;
-- FINDING: USA has the highest number of customers, spread across 21 countries globally.


-- Q2: Overall total revenue
SELECT 
    ROUND(SUM(UnitPrice * Quantity * (1 - Discount)), 2) AS Total_Revenue
FROM [Order Details];
-- FINDING: The business generated a total revenue of $1,265,793.04 across all orders.


-- Q3: Top 10 customers by revenue
SELECT TOP 10
    C.CompanyName,
    C.Country,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Total_Revenue
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName, C.Country
ORDER BY Total_Revenue DESC;
--FINDING: Quick-Stop from Germany is the top customer with $110,277.30 in revenue,
-- significantly ahead of 2nd place Ernst Handel from Austria.


-- Q4: Top 10 best selling products
SELECT TOP 10
    P.ProductName,
    SUM(OD.Quantity) AS Total_Quantity_Sold,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Total_Revenue
FROM Products P
JOIN [Order Details] OD ON P.ProductID = OD.ProductID
GROUP BY P.ProductName
ORDER BY Total_Quantity_Sold DESC;
-- FINDING: Camembert Pierrot is the best selling product by quantity (1,577 units)
-- however Tarte au sucre generates the most revenue at $47,234.97
-- This suggests Tarte au sucre has a significantly higher unit price.


-- Q5: Revenue by product category
SELECT 
    CAT.CategoryName,
    COUNT(DISTINCT OD.ProductID) AS Products_Sold,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Total_Revenue
FROM Categories CAT
JOIN Products P ON CAT.CategoryID = P.CategoryID
JOIN [Order Details] OD ON P.ProductID = OD.ProductID
GROUP BY CAT.CategoryName
ORDER BY Total_Revenue DESC;
-- FINDING: Beverages is the top performing category by revenue
-- while Grains/Cereals generates the least revenue despite having 
-- multiple products. This suggests an opportunity to review the 
-- Grains/Cereals product line.


-- Q6: Monthly order volume trend
SELECT 
    YEAR(OrderDate) AS Order_Year,
    MONTH(OrderDate) AS Order_Month,
    DATENAME(MONTH, OrderDate) AS Month_Name,
    COUNT(OrderID) AS Total_Orders
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)
ORDER BY Order_Year, Order_Month;

-- Q6b: Average orders per month across all years
SELECT 
    MONTH(OrderDate) AS Order_Month,
    DATENAME(MONTH, OrderDate) AS Month_Name,
    COUNT(OrderID) AS Total_Orders
FROM Orders
GROUP BY MONTH(OrderDate), DATENAME(MONTH, OrderDate)
ORDER BY Total_Orders DESC;

-- FINDING: Q4 (October, November, December) is consistently the busiest 
-- period across 1996 and 1997. January also shows strong order volume 
-- suggesting post-holiday restocking drives early Q1 demand.
-- Note: 1998 data is incomplete (cuts off April) which skews 
-- the overall monthly totals.


-- Q7: Revenue by customer country
SELECT 
    C.Country,
    COUNT(DISTINCT O.OrderID) AS Total_Orders,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Total_Revenue
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.Country
ORDER BY Total_Revenue DESC;
-- FINDING: USA generates the most revenue and also has the most customers,
-- confirming it is the most valuable market both in volume and spend.



-- Q8: Average shipping time by shipping company
SELECT 
    S.CompanyName AS Shipper,
    ROUND(AVG(CAST(DATEDIFF(day, O.OrderDate, O.ShippedDate) AS FLOAT)), 1) 
        AS Avg_Shipping_Days,
    COUNT(O.OrderID) AS Total_Orders_Handled
FROM Orders O
JOIN Shippers S ON O.ShipVia = S.ShipperID
WHERE O.ShippedDate IS NOT NULL
GROUP BY S.CompanyName
ORDER BY Avg_Shipping_Days ASC;

-- FINDING: There are 3 shippers. Federal Shipping is the fastest at 7.5 days
-- average while United Package is the slowest at 9.2 days -- a 1.7 day 
-- difference which could impact customer satisfaction.


-- Q9: Employee performance by orders and revenue
SELECT 
    E.FirstName + ' ' + E.LastName AS Employee_Name,
    COUNT(DISTINCT O.OrderID) AS Total_Orders,
    ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Total_Revenue
FROM Employees E
JOIN Orders O ON E.EmployeeID = O.EmployeeID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.FirstName, E.LastName
ORDER BY Total_Revenue DESC;
-- FINDING: Margaret Peacock is the top performing employee handling
-- 156 orders and generating $232,890.85 in revenue, leading both 
-- in order volume and total revenue generated.


-- Q10: High value customers above average spend using a CTE
WITH CustomerRevenue AS (
    SELECT 
        C.CompanyName,
        C.Country,
        ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Total_Revenue
    FROM Customers C
    JOIN Orders O ON C.CustomerID = O.CustomerID
    JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY C.CompanyName, C.Country
)
SELECT 
    CompanyName,
    Country,
    Total_Revenue
FROM CustomerRevenue
WHERE Total_Revenue > (SELECT AVG(Total_Revenue) FROM CustomerRevenue)
ORDER BY Total_Revenue DESC;
-- FINDING: 30 out of 91 customers (33%) are classified as high value,
-- spending above the average customer revenue. Quick-Stop remains the 
-- top customer confirming their importance to the business.
-- These 30 customers should be the focus of retention strategies.

