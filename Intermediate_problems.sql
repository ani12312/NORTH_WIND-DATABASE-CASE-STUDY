use NorthWind;
/*20.
 Categories, and the total products in each category
For this problem, we’d like to see the total number of products in each
category. Sort the results by the total number of products, in descending
order.*/

select 
	category_name,
    count(product_id) 
from categories,products
where products.category_id=categories.category_id
group by category_name
order by count(product_id) desc ;

/*21.
 Total customers per country/city
In the Customers table, show the total number of customers per Country
and City.*/

select 
	country,
    city,
    count(customer_id)
from customers
group by country,city
order by country;

/*22.
 Products that need reordering
What products do we have in our inventory that should be reordered?
For now, just use the fields UnitsInStock and ReorderLevel, where
UnitsInStock is less than the ReorderLevel, ignoring the fields
UnitsOnOrder and Discontinued.
Order the results by ProductID.*/

SELECT
Product_id,
product_name,
discontinued
from products
where 'UnitsInStock' + 'UnitsOnOrder' <=' recorder_level' and discontinued=0
order by product_id LIMIT 2;

-- 24. CUSTOMER LIST BY REGION
-- A salesperson for Northwind is going on a business trip to visit customers, and would like to see a list of all customers, sorted by
-- region, alphabetically.However, he wants the customers with no region (null in the Region field) to be at the end, instead of at the top, where you’d normally find
-- the null values. Within the same region, companies should be sorted by customer ID.

select 
customer_id,
company_name, 
region,
case
when region is null then 1
else 0 
end as status
from customers;

-- 25. HIGH FREIGHT CHARGES
-- Some of the countries we ship to have very high freight charges. We'd like to investigate some more shipping options for our customers, to be
-- able to offer them lower freight charges. Return the three ship countries with the highest average freight overall, in descending order by average freigh

SELECT
ship_country,
AVG(freight)
FROM orders
GROUP BY ship_country
ORDER BY AVG (freight) DESC LIMIT 3;

-- 26. HIGH FREIGHT CHARGES- 2015
-- We're continuing on the question above on high freight charges. Now, instead of using all the orders we have, 
-- we only want to see orders from the year 2015.

select 
ship_country,
AVG(freight)
from orders
where order_date >= '2015-01-01'
group by ship_country
ORDER BY AVG(freight) DESC LIMIT 3;

-- 27. HIGH FREIGHT CHARGES WITH BETWEEN
-- Notice when you run this, it gives Sweden as the ShipCountry with the third highest freight charges. However, this is wrong - it should be France.
-- What is the OrderID of the order that the (incorrect) answer above is missing?

select
AVG(freight)
from orders
WHERE order_date BETWEEN '1/1/2015' AND '12/31/2015'
GROUP BY ship_country;

-- 28. HIGH FREIGHT CHARGES- LAST YEAR
--  We're continuing to work on high freight charges. We now want to get the three ship countries with the highest average freight charges. But
-- instead of filtering for a particular year, we want to use the last 12 months of order data, using as the end date the last OrderDate in Orders.

select 
max(order_date)
from orders ;

-- 29. INVENTORY LIST
-- We're doing inventory, and need to show information like the below, for all orders. Sort by OrderID and Product ID

select
employees.employee_id,employees.last_name, orders.order_id, products.product_name,products.quantity_per_unit
from employees,orders,products
where employees.employee_id=orders.employee_id and orders.ship_via=products.supplier_id
order by orders.order_id ;

-- 30. CUSTOMERS WITH NO ORDERS
-- There are some customers who have never actually placed an order. Show these customers.



(select customers.customer_id from customers)
EXCEPT
(select orders.customer_id from orders );
-- 31. CUSTOMERS WITH NO ORDERS FOR EMPLOYEE ID 4
-- One employee (Margaret Peacock, EmployeeID 4) has placed the most orders. However, there are some customers who've never placed an order
-- with her. Show only those customers who have never placed an order with her.

Select
customers.customer_id
,orders.customer_id
From customers
left join orders
on orders.customer_id = customers.customer_id
and orders.employee_id = 4
Where
orders.customer_id is null

	