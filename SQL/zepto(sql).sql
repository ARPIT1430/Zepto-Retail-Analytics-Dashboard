# database use # 
use capstone_project;
# selection of tabels #
select * from customers;
select * from orders ;
select * from products;
select * from delivery;
select * from ratings;
select * from returns_refunds;
select * from transactions;

select * from zepto_pass_features;

# treating null  values #
update customers 
set
C_ID = coalesce(nullif(trim(C_ID), ''), 'not available'),
CName = coalesce(nullif(trim(CName), ''), 'not available'), 
From_Date = coalesce(nullif(trim(From_Date), ''), 'not available'),
Gender= coalesce(nullif(trim(Gender), ''), 'not available'),
Age = coalesce(nullif(trim(Age), ''), 'not available'), 
State= coalesce(nullif(trim(State), ''), 'not available'), 
Address= coalesce(nullif(trim(Address), ''), 'not available'), 
Mobile= coalesce(nullif(trim(Mobile), ''), 'not available');

# Update orders table
update orders 
set c_id = coalesce(nullif(trim(c_id), ''), 'not available'),
    p_id = coalesce(nullif(trim(p_id), ''), 'not available'),
    order_date = coalesce(nullif(trim(order_date), ''), 'not available'),
    order_time = coalesce(nullif(trim(order_time), ''), 'not available'),
    qty = coalesce(nullif(trim(qty), ''), 'not available'),
    coupon = coalesce(nullif(trim(coupon), ''), 'not available'),
    dp_id = coalesce(nullif(trim(dp_id), ''), 'not available');

# Update products table
update products 
set p_id = coalesce(nullif(trim(p_id), ''), 'not available'),
    product_name = coalesce(nullif(trim(product_name), ''), 'not available'),
    category = coalesce(nullif(trim(category), ''), 'not available'),
    price = coalesce(nullif(trim(price), ''), 'not available'),
    features = coalesce(nullif(trim(features), ''), 'not available'),
    affected_price = coalesce(nullif(trim(Affected_Price), ''), 'not available'),
    del_charge = coalesce(nullif(trim(del_charge), ''), 'not available'),
    total_price = coalesce(nullif(trim(total_price), ''), 'not available'),
    final_price = coalesce(nullif(trim(final_price), ''), 'not available');

# Update delivery table
update delivery 
set dp_id = coalesce(nullif(trim(dp_id), ''), 'not available'),
    dp_name = coalesce(nullif(trim(dp_name), ''), 'not available'),
    dp_ratings = coalesce(nullif(trim(dp_ratings), ''), 'not available');

# Update ratings table
update ratings 
set or_id = coalesce(nullif(trim(or_id), ''), 'not available'),
    prod_rating = coalesce(nullif(trim(prod_rating), ''), 'not available'),
    delivery_service_rating = coalesce(nullif(trim(delivery_service_rating), ''), 'not available');

# Update returns_refunds table
update returns_refunds 
set or_id = coalesce(nullif(trim(or_id), ''), 'not available'),
    reason = coalesce(nullif(trim(reason), ''), 'not available'),
    `return/refund` = coalesce(nullif(trim(`return/refund`), ''), 'not available'),
    date = coalesce(nullif(trim(date), ''), 'not available');

# Update transactions table
update transactions 
set Tr_ID = coalesce(nullif(trim(Tr_ID), ''), 'not available'),
    Or_ID = coalesce(nullif(trim(Or_ID), ''), 'not available'),
    Transaction_Mode = coalesce(nullif(trim(Transaction_Mode), ''), 'not available'),
    Tran_Status = coalesce(nullif(trim(Tran_Status), ''), 'not available');




# KPI Generation #

# orders #
select COUNT(or_id) as Total_Orders, 
Sum(qty) as Total_Quantity_Ordered,
 Avg(final_price) as Average_Order_Value from orders join products on 
 orders.p_id = products.p_id;
 

 # customers #
 select count(c_id) as Total_Customers, 
count(c_id) as New_Customers_Last_Month from 
customers where from_date >= date_sub(curdate(), Interval 1 Month);

# products #
select Product_Name, sum(qty) as Quantity_Sold from orders 
join products on orders.p_id = products.p_id group by product_name 
order by Quantity_Sold desc limit 5;

# Delivery Person #
Select avg(DP_Ratings) as Average_Delivery_Rating from delivery;

# Ratings #
select avg(prod_rating) as Average_Product_Rating from ratings;
Select avg(Delivery_Service_Rating) as Average_Delivery_Service_Rating 
from ratings;

# Insights # 
 
/*Analyze the number of orders placed each month */
select 
  date_format(order_date, '%Y-%m') as Month,
  count(or_id) as Total_Orders
from orders group by Month order by Month;

/* how frequently customers place orders */
select 
  c_id,
  count(or_id) as Total_Orders 
  from orders group by c_id
order by 
  Total_Orders desc;
  
  
  
/* Identify the top-selling products based on quantity sold */
 SELECT orders.p_id,products.product_name, SUM(orders.qty) AS Total_Quantity_Sold
FROM orders JOIN products ON orders.p_id = products.p_id GROUP BY 
orders.p_id, products.product_name ORDER BY 
Total_Quantity_Sold DESC;


/* Calculate the average value of each order */
select avg(final_price) as Average_Order_Value from 
orders join products on orders.p_id = products.p_id;



/* Determine the most common reasons for product returns or refunds */
select reason,count(or_id) as Total_Returns_Refunds
from returns_refunds group by reason order by Total_Returns_Refunds desc;


/* Analyze the impact of coupon usage on order volume and revenue */

select coupon,count(or_id) as Total_Orders,sum(final_price) as Total_Revenue
from orders join products on orders.p_id = products.p_id
group by coupon order by Total_Revenue desc;

/* Explore the demographics of  customers */
select 
  gender, count(c_id) as Total_Customers, avg(age) as Average_Age,state, 
  count(c_id) as Customers_Per_State from customers group by gender, 
  state order by Customers_Per_State desc;


/* Evaluate the distribution of transaction modes and their success rates */
select Transaction_Mode,
count(Tr_ID) as Total_Transactions, (count(case when tran_status = 'Success' then 1 end)
 / count(Tr_ID)) * 100 
as Success_Rate from transactions group by Transaction_Mode order by 
Total_Transactions desc;








