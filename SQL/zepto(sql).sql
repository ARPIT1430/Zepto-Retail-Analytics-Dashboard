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


/*=================================================================================================================
BUSINESS ANALYSIS 1: CUSTOMER LIFETIME VALUE (CLV) SEGMENTATION

Business Question:
Which customers generate the highest lifetime revenue, and how concentrated is our business among these high-value customers?

Objective:
- Calculate each customer's lifetime revenue.
- Segment customers into four value tiers (VIP, High Value, Medium Value, Low Value).
- Measure the revenue contribution of each customer segment.
- Identify high-value customers for retention and targeted marketing strategies.
=================================================================================================================*/

-- =================================================================================================
-- Customer Lifetime Value (CLV) Segmentation
-- =================================================================================================

WITH CustomerRevenue AS
(
    SELECT
        o.C_ID,
        COUNT(o.Or_ID) AS Total_Orders,
        SUM(o.Qty * p.Final_Price) AS Lifetime_Revenue
    FROM Orders o
    INNER JOIN Products p
        ON o.P_ID = p.P_ID
    GROUP BY o.C_ID
),

CustomerSegment AS
(
    SELECT *,
           NTILE(4) OVER (ORDER BY Lifetime_Revenue DESC) AS Revenue_Quartile
    FROM CustomerRevenue
)

SELECT
    C_ID,
    Total_Orders,
    Lifetime_Revenue,

    CASE
        WHEN Revenue_Quartile = 1 THEN 'VIP'
        WHEN Revenue_Quartile = 2 THEN 'High Value'
        WHEN Revenue_Quartile = 3 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment

FROM CustomerSegment
ORDER BY Lifetime_Revenue DESC;


-- =================================================================================================
-- Revenue Contribution by Customer Segment
-- Calculates the percentage of total revenue generated by each customer segment.
-- =================================================================================================

WITH CustomerRevenue AS
(
    SELECT
        o.C_ID,
        COUNT(o.Or_ID) AS Total_Orders,
        SUM(o.Qty * p.Final_Price) AS Lifetime_Revenue
    FROM Orders o
    INNER JOIN Products p
        ON o.P_ID = p.P_ID
    GROUP BY o.C_ID
),

CustomerSegment AS
(
    SELECT *,
           NTILE(4) OVER (ORDER BY Lifetime_Revenue DESC) AS Revenue_Quartile
    FROM CustomerRevenue
)

SELECT
    CASE
        WHEN Revenue_Quartile = 1 THEN 'VIP'
        WHEN Revenue_Quartile = 2 THEN 'High Value'
        WHEN Revenue_Quartile = 3 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment,

    COUNT(*) AS Customers,
    SUM(Lifetime_Revenue) AS Segment_Revenue,

    CAST(
        100.0 * SUM(Lifetime_Revenue)
        / SUM(SUM(Lifetime_Revenue)) OVER()
        AS DECIMAL(5,2)
    ) AS Revenue_Share_Percent

FROM CustomerSegment
GROUP BY Revenue_Quartile
ORDER BY Revenue_Share_Percent DESC;


/*=================================================================================================================
BUSINESS ANALYSIS 2: REVENUE LEAKAGE DUE TO RETURNS & REFUNDS

Business Question:
How much revenue is potentially lost due to product returns and refunds, and which product categories contribute the most to this revenue leakage?

Objective:
- Measure the financial impact of returns and refunds.
- Calculate revenue exposed to returned orders.
- Identify product categories with the highest revenue leakage.
- Support quality improvement, supplier evaluation, and profitability optimization.
=================================================================================================================*/


-- =================================================================================================
-- Query 1: Revenue Leakage by Product Category
-- Calculates revenue at risk due to returned/refunded orders for each product category.
-- =================================================================================================

WITH RevenueLeakage AS
(
    SELECT
        p.Category,

        COUNT(o.Or_ID) AS Total_Orders,

        SUM(o.Qty * p.Final_Price) AS Total_Revenue,

        COUNT(rr.Or_ID) AS Returned_Orders,

        SUM(
            CASE
                WHEN rr.Or_ID IS NOT NULL
                THEN o.Qty * p.Final_Price
                ELSE 0
            END
        ) AS Revenue_At_Risk

    FROM Orders o

    INNER JOIN Products p
        ON o.P_ID = p.P_ID

    LEFT JOIN Returns_Refunds rr
        ON o.Or_ID = rr.Or_ID

    GROUP BY p.Category
)

SELECT

    Category,

    Total_Orders,

    Total_Revenue,

    Returned_Orders,

    Revenue_At_Risk,

    CAST(
        100.0 * Revenue_At_Risk / Total_Revenue
        AS DECIMAL(5,2)
    ) AS Revenue_Leakage_Percent

FROM RevenueLeakage

ORDER BY Revenue_At_Risk DESC;



-- =================================================================================================
-- Query 2: Revenue Leakage Executive Summary
-- Summarizes the overall financial impact of returns and refunds across the business.
-- =================================================================================================

WITH RevenueLeakage AS
(
    SELECT

        SUM(o.Qty * p.Final_Price) AS Total_Revenue,

        SUM(
            CASE
                WHEN rr.Or_ID IS NOT NULL
                THEN o.Qty * p.Final_Price
                ELSE 0
            END
        ) AS Revenue_At_Risk,

        COUNT(o.Or_ID) AS Total_Orders,

        COUNT(rr.Or_ID) AS Returned_Orders

    FROM Orders o

    INNER JOIN Products p
        ON o.P_ID = p.P_ID

    LEFT JOIN Returns_Refunds rr
        ON o.Or_ID = rr.Or_ID
)

SELECT

    Total_Revenue,

    Revenue_At_Risk,

    Total_Orders,

    Returned_Orders,

    CAST(
        100.0 * Returned_Orders / Total_Orders
        AS DECIMAL(5,2)
    ) AS Return_Rate_Percent,

    CAST(
        100.0 * Revenue_At_Risk / Total_Revenue
        AS DECIMAL(5,2)
    ) AS Revenue_Leakage_Percent

FROM RevenueLeakage;



/*=================================================================================================================
BUSINESS ANALYSIS 3: ROOT CAUSE ANALYSIS OF RETURNS & REFUNDS

Business Question:
What are the primary reasons behind product returns and refunds, and which return reasons have the greatest financial impact on the business?

Objective:
- Identify the leading causes of product returns.
- Quantify the financial impact associated with each return reason.
- Rank return reasons based on revenue impact.
- Support operational improvements in product quality, supplier management, and order fulfillment.
=================================================================================================================*/


-- =================================================================================================
-- Query 1: Return Reason Analysis
-- Calculates the number of returns and associated revenue impact for each
-- return reason to identify the major drivers of revenue leakage.
-- =================================================================================================

WITH ReturnReasonAnalysis AS
(
    SELECT

        rr.Reason,

        COUNT(rr.Or_ID) AS Total_Returns,

        SUM(o.Qty * p.Final_Price) AS Revenue_Impact

    FROM Returns_Refunds rr

    INNER JOIN Orders o
        ON rr.Or_ID = o.Or_ID

    INNER JOIN Products p
        ON o.P_ID = p.P_ID

    GROUP BY rr.Reason
)

SELECT

    Reason,

    Total_Returns,

    Revenue_Impact,

    CAST(
        100.0 * Total_Returns
        / SUM(Total_Returns) OVER()
        AS DECIMAL(5,2)
    ) AS Return_Share_Percent,

    CAST(
        100.0 * Revenue_Impact
        / SUM(Revenue_Impact) OVER()
        AS DECIMAL(5,2)
    ) AS Revenue_Impact_Percent

FROM ReturnReasonAnalysis

ORDER BY Revenue_Impact DESC;



-- =================================================================================================
-- Query 2: Return Reason Executive Summary
-- Ranks return reasons based on their financial impact to prioritize business
-- initiatives focused on quality improvement, supplier performance, and
-- fulfillment accuracy.
-- =================================================================================================

WITH ReturnReasonAnalysis AS
(
    SELECT

        rr.Reason,

        COUNT(*) AS Total_Returns,

        SUM(o.Qty * p.Final_Price) AS Revenue_Impact

    FROM Returns_Refunds rr

    INNER JOIN Orders o
        ON rr.Or_ID = o.Or_ID

    INNER JOIN Products p
        ON o.P_ID = p.P_ID

    GROUP BY rr.Reason
)

SELECT

    Reason,

    Total_Returns,

    Revenue_Impact,

    DENSE_RANK() OVER
    (
        ORDER BY Revenue_Impact DESC
    ) AS Revenue_Impact_Rank

FROM ReturnReasonAnalysis

ORDER BY Revenue_Impact DESC;




/*=================================================================================================================
BUSINESS ANALYSIS 4: CUSTOMER RETENTION & REPEAT PURCHASE ANALYSIS

Business Question:
How effectively does the business retain customers, and what proportion of customers make repeat purchases?

Objective:
- Measure customer retention through purchase frequency analysis.
- Classify customers into one-time, repeat, and loyal customer segments.
- Evaluate repeat purchase behavior across the customer base.
- Support customer retention, loyalty, and long-term growth strategies.
=================================================================================================================*/


-- =================================================================================================
-- Query 1: Customer Purchase Frequency Analysis
-- Classifies customers based on the number of orders placed to identify
-- one-time, repeat, and loyal customers.
-- =================================================================================================

WITH CustomerOrders AS
(
    SELECT
        C_ID,
        COUNT(Or_ID) AS Total_Orders
    FROM Orders
    GROUP BY C_ID
)

SELECT

    C_ID,

    Total_Orders,

    CASE
        WHEN Total_Orders = 1 THEN 'One-Time Customer'
        WHEN Total_Orders BETWEEN 2 AND 4 THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END AS Customer_Type

FROM CustomerOrders

ORDER BY Total_Orders DESC;



-- =================================================================================================
-- Query 2: Customer Retention Executive Summary
-- Summarizes customer distribution by purchase frequency to evaluate
-- customer retention and identify opportunities for loyalty initiatives.
-- =================================================================================================

WITH CustomerOrders AS
(
    SELECT
        C_ID,
        COUNT(Or_ID) AS Total_Orders
    FROM Orders
    GROUP BY C_ID
)

SELECT

    CASE
        WHEN Total_Orders = 1 THEN 'One-Time Customer'
        WHEN Total_Orders BETWEEN 2 AND 4 THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END AS Customer_Type,

    COUNT(*) AS Customers,

    CAST
    (
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER()
        AS DECIMAL(5,2)
    ) AS Customer_Percentage,

    AVG(Total_Orders) AS Avg_Orders_Per_Customer

FROM CustomerOrders

GROUP BY
CASE
    WHEN Total_Orders = 1 THEN 'One-Time Customer'
    WHEN Total_Orders BETWEEN 2 AND 4 THEN 'Repeat Customer'
    ELSE 'Loyal Customer'
END

ORDER BY Avg_Orders_Per_Customer DESC;





/*=================================================================================================================
BUSINESS ANALYSIS 5: COUPON EFFECTIVENESS & CUSTOMER PURCHASE BEHAVIOR

Business Question:
Do coupon campaigns improve customer purchasing behavior and revenue, or are they simply reducing selling prices without increasing customer value?

Objective:
- Compare customer purchasing behavior between coupon and non-coupon orders.
- Measure revenue contribution and average order value for each customer group.
- Evaluate the effectiveness of promotional campaigns.
- Support data-driven marketing and pricing strategies.
=================================================================================================================*/


-- =================================================================================================
-- Query 1: Coupon Performance Analysis
-- Compares revenue, customer reach, and average order value between
-- coupon and non-coupon purchases.
-- =================================================================================================

WITH CouponAnalysis AS
(
    SELECT

        CASE
            WHEN Coupon = 'TRUE' THEN 'Coupon Used'
            ELSE 'No Coupon'
        END AS Coupon_Status,

        COUNT(Or_ID) AS Orders,

        COUNT(DISTINCT C_ID) AS Customers,

        SUM(o.Qty * p.Final_Price) AS Revenue,

        AVG(o.Qty * p.Final_Price) AS Avg_Order_Value

    FROM Orders o

    INNER JOIN Products p
        ON o.P_ID = p.P_ID

    GROUP BY
        CASE
            WHEN Coupon = 'TRUE' THEN 'Coupon Used'
            ELSE 'No Coupon'
        END
)

SELECT *

FROM CouponAnalysis

ORDER BY Revenue DESC;



-- =================================================================================================
-- Query 2: Coupon Campaign Executive Summary
-- Summarizes coupon performance by comparing order volume, customer reach,
-- revenue contribution, average order value, and revenue share to evaluate
-- the effectiveness of promotional campaigns.
-- =================================================================================================

WITH CouponAnalysis AS
(
    SELECT

        CASE
            WHEN Coupon = 'TRUE' THEN 'Coupon Used'
            ELSE 'No Coupon'
        END AS Coupon_Status,

        COUNT(Or_ID) AS Orders,

        COUNT(DISTINCT C_ID) AS Customers,

        SUM(o.Qty * p.Final_Price) AS Revenue,

        AVG(o.Qty * p.Final_Price) AS Avg_Order_Value

    FROM Orders o

    INNER JOIN Products p
        ON o.P_ID = p.P_ID

    GROUP BY
        CASE
            WHEN Coupon = 'TRUE' THEN 'Coupon Used'
            ELSE 'No Coupon'
        END
)

SELECT

    Coupon_Status,

    Orders,

    Customers,

    Revenue,

    CAST(Avg_Order_Value AS DECIMAL(10,2)) AS Avg_Order_Value,

    CAST(
        100.0 * Revenue
        / SUM(Revenue) OVER()
        AS DECIMAL(5,2)
    ) AS Revenue_Share_Percent

FROM CouponAnalysis

ORDER BY Revenue DESC;





