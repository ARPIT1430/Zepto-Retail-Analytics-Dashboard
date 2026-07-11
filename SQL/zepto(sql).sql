USE ZeptoBusinessAnalysis

select * from customers;
select * from orders ;
select * from products;
select * from delivery;
select * from ratings;
select * from returns_refunds;

/* ===========================
   CUSTOMERS
   =========================== */

UPDATE Customers
SET
    C_ID = COALESCE(NULLIF(LTRIM(RTRIM(C_ID)), ''), 'not available'),
    CName = COALESCE(NULLIF(LTRIM(RTRIM(CName)), ''), 'not available'),
    Gender = COALESCE(NULLIF(LTRIM(RTRIM(Gender)), ''), 'not available'),
    State = COALESCE(NULLIF(LTRIM(RTRIM(State)), ''), 'not available'),
    Address = COALESCE(NULLIF(LTRIM(RTRIM(Address)), ''), 'not available');


/* ===========================
   ORDERS
   =========================== */

UPDATE Orders
SET
    Or_ID = COALESCE(NULLIF(LTRIM(RTRIM(Or_ID)), ''), 'not available'),
    C_ID = COALESCE(NULLIF(LTRIM(RTRIM(C_ID)), ''), 'not available'),
    P_ID = COALESCE(NULLIF(LTRIM(RTRIM(P_ID)), ''), 'not available'),
    DP_ID = COALESCE(NULLIF(LTRIM(RTRIM(DP_ID)), ''), 'not available');


/* ===========================
   PRODUCTS
   =========================== */

UPDATE Products
SET
    P_ID = COALESCE(NULLIF(LTRIM(RTRIM(P_ID)), ''), 'not available'),
    Product_Name = COALESCE(NULLIF(LTRIM(RTRIM(Product_Name)), ''), 'not available'),
    Category = COALESCE(NULLIF(LTRIM(RTRIM(Category)), ''), 'not available'),
    Features = COALESCE(NULLIF(LTRIM(RTRIM(Features)), ''), 'not available');


/* ===========================
   RATINGS
   =========================== */

UPDATE Ratings
SET
    Or_ID = COALESCE(NULLIF(LTRIM(RTRIM(Or_ID)), ''), 'not available');


/* ===========================
   RETURNS & REFUNDS
   =========================== */

UPDATE Returns_Refunds
SET
    Or_ID = COALESCE(NULLIF(LTRIM(RTRIM(Or_ID)), ''), 'not available'),
    Reason = COALESCE(NULLIF(LTRIM(RTRIM(Reason)), ''), 'not available'),
    Return_Refund = COALESCE(NULLIF(LTRIM(RTRIM(Return_Refund)), ''), 'not available');



/* ===========================
   TRANSACTIONS
   =========================== */

UPDATE Transactions
SET
    Tr_ID = COALESCE(NULLIF(LTRIM(RTRIM(Tr_ID)), ''), 'not available'),
    Or_ID = COALESCE(NULLIF(LTRIM(RTRIM(Or_ID)), ''), 'not available'),
    Transaction_Mode = COALESCE(NULLIF(LTRIM(RTRIM(Transaction_Mode)), ''), 'not available'),
    Tran_Status = COALESCE(NULLIF(LTRIM(RTRIM(Tran_Status)), ''), 'not available');


/* ===========================
   Delivery 
   =========================== */

UPDATE Delivery
SET
    DP_ID = COALESCE(NULLIF(LTRIM(RTRIM(DP_ID)), ''), 'not available'),
    DP_Name = COALESCE(NULLIF(LTRIM(RTRIM(DP_Name)), ''), 'not available');

-- -------------------------------------------------------------------------------------------------------------------------
/*====================================================
                    KPI GENERATION
====================================================*/

/*-------------------- Orders KPI --------------------*/

SELECT
    COUNT(*) AS Total_Orders,
    SUM(Orders.Qty) AS Total_Quantity_Ordered,
    AVG(CAST(Products.Final_Price AS FLOAT)) AS Average_Order_Value
FROM Orders
INNER JOIN Products
ON Orders.P_ID = Products.P_ID;


/*------------------ Customers KPI -------------------*/

SELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE
            WHEN From_Date >= DATEADD(MONTH, -1, CAST(GETDATE() AS DATE))
            THEN 1
            ELSE 0
        END) AS New_Customers_Last_Month
FROM Customers;


/*------------------- Products KPI -------------------*/

SELECT TOP (5)
    Products.Product_Name,
    SUM(Orders.Qty) AS Quantity_Sold
FROM Orders
INNER JOIN Products
ON Orders.P_ID = Products.P_ID
GROUP BY Products.Product_Name
ORDER BY Quantity_Sold DESC;


/*--------------- Delivery Person KPI ----------------*/

SELECT
    AVG(CAST(DP_Ratings AS FLOAT)) AS Average_Delivery_Rating
FROM Delivery;


/*-------------------- Ratings KPI -------------------*/

SELECT
    AVG(CAST(Prod_Rating AS FLOAT)) AS Average_Product_Rating
FROM Ratings;

SELECT
    AVG(CAST(Delivery_Service_Rating AS FLOAT)) AS Average_Delivery_Service_Rating
FROM Ratings;


-- -------------------------------------------------------------------------------------------------------------------------

/*====================================================
                    BUSINESS INSIGHTS
====================================================*/


/* 1. Analyze the number of orders placed each month */

SELECT
    CONVERT(char(7), Order_Date, 120) AS [Month],
    COUNT(*) AS Total_Orders
FROM Orders
GROUP BY CONVERT(char(7), Order_Date, 120)
ORDER BY [Month];


/* 2. How frequently customers place orders */

SELECT
    C_ID,
    COUNT(*) AS Total_Orders
FROM Orders
GROUP BY C_ID
ORDER BY Total_Orders DESC;


/* 3. Identify the top-selling products */

SELECT
    Orders.P_ID,
    Products.Product_Name,
    SUM(Orders.Qty) AS Total_Quantity_Sold
FROM Orders
INNER JOIN Products
ON Orders.P_ID = Products.P_ID
GROUP BY
    Orders.P_ID,
    Products.Product_Name
ORDER BY Total_Quantity_Sold DESC;


/* 4. Calculate the average order value */

SELECT
    AVG(CAST(Products.Final_Price AS FLOAT)) AS Average_Order_Value
FROM Orders
INNER JOIN Products
ON Orders.P_ID = Products.P_ID;


/* 5. Determine the most common reasons for product returns/refunds */

SELECT
    Reason,
    COUNT(*) AS Total_Returns_Refunds
FROM Returns_Refunds
GROUP BY Reason
ORDER BY Total_Returns_Refunds DESC;


/* 6. Analyze the impact of coupon usage on order volume and revenue */

SELECT
    Coupon,
    COUNT(*) AS Total_Orders,
    SUM(Products.Final_Price) AS Total_Revenue
FROM Orders
INNER JOIN Products
ON Orders.P_ID = Products.P_ID
GROUP BY Coupon
ORDER BY Total_Revenue DESC;


/* 7. Explore customer demographics */

SELECT
    Gender,
    State,
    COUNT(*) AS Total_Customers,
    AVG(CAST(Age AS FLOAT)) AS Average_Age
FROM Customers
GROUP BY
    Gender,
    State
ORDER BY Total_Customers DESC;


/* 8. Evaluate the distribution of transaction modes and their success rates */

SELECT
    Transaction_Mode,
    COUNT(*) AS Total_Transactions,
    CAST(
        100.0 * SUM(CASE WHEN Tran_Status = 'Success' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Success_Rate
FROM Transactions
GROUP BY Transaction_Mode
ORDER BY Total_Transactions DESC;







