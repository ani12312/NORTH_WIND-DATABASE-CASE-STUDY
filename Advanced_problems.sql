use northwind;

/* 32. High-value customers
We want to send all of our high - value customers a special VIP gift.
We're defining high-value customers as those who've made at least 1
order with a total value (not including the discount) equal to $10,000 or
more. We only want to consider orders made in the year 2016.*/

-- here 1998 is considered as 2016 according to the question
select 
	customers.customer_id,
    customers.company_name,
    orders.order_id,
    sum(unit_price * quantity) value
from orders
left join customers on orders.customer_id=customers.customer_id 
left join order_details on orders.order_id=order_details.order_id 
where orders.order_date>='19980101' and orders.order_date<'19990101'
group by customers.customer_id,orders.order_id 

having value>10000
order by value desc;

Select
Customers.Customer_ID
,Customers.Company_Name
,Orders.Order_ID
,sum(Quantity * Unit_Price) TotalOrderAmount
From Customers
Join Orders
on Orders.Customer_ID = Customers.Customer_ID
Join Order_Details
on Orders.Order_ID = Order_Details.Order_ID
Where
Order_Date >= '19980101'
and Order_Date < '19990101'
Group By
Customers.Customer_ID
,Customers.Company_Name
,Orders.Order_ID
having TotalOrderAmount>10000 
order by TotalOrderAmount desc;
/* 33. High-value customers - total orders
The manager has changed his mind. Instead of requiring that customers
have at least one individual orders totaling $10,000 or more, he wants to
define high-value customers as those who have orders totaling $15,000
or more in 2016. How would you change the answer to the problem
above? */

select 
	customers.customer_id,
    customers.company_name,
    sum(unit_price*quantity) total
from orders left join customers on orders.customer_id=customers.customer_id
			left join order_details on orders.order_id=order_details.order_id
where order_date>='19980101' and order_date<'19990101'
group by customers.customer_id
having total>15000
order by total desc;

/* 34. High-value customers - with discount
Change the above query to use the discount when calculating high-value
customers. Order by the total amount which includes the discount.*/

select 
	customers.customer_id,
    customers.company_name,
    sum(unit_price*quantity) total,
    sum(unit_price*quantity*(1-discount)) discount_total
from orders left join customers on orders.customer_id=customers.customer_id
			left join order_details on orders.order_id=order_details.order_id
where order_date>='19980101' and order_date<'19990101'
group by customers.customer_id
having discount_total>10000
order by discount_total desc;

/* 35. Month-end orders
At the end of the month, salespeople are likely to try much harder to get
orders, to meet their month-end quotas. Show all orders made on the last
day of the month. Order by EmployeeID and OrderID*/

select 
	employees.employee_id,
    orders.order_id,
    last_day(order_date)
from orders left join employees on orders.employee_id=employees.employee_id
where order_date=last_day(order_date)
order by employee_id,order_id desc;

/*36. Orders with many line items
The Northwind mobile app developers are testing an app that customers
will use to show orders. In order to make sure that even the largest
orders will show up correctly on the app, they'd like some samples of
orders that have lots of individual line items. Show the 10 orders with
the most line items, in order of total line items.*/



select 
     o.order_id,
    count(product_id) as  Total_Order
from orders as o
   left join order_details as od
       on o.order_id = od.order_id
group by o.order_id
order by total_order desc limit 10;


/*37. Orders - random assortment
The Northwind mobile app developers would now like to just get a
random assortment of orders for beta testing on their app. Show a
random set of 2% of all orders.*/

select
	order_id from orders
where rand()<.02;

/*38. Orders - accidental double-entry
Janet Leverling, one of the salespeople, has come to you with a request.
She thinks that she accidentally double-entered a line item on an order,
with a different ProductID, but the same quantity. She remembers that
the quantity was 60 or more. Show all the OrderIDs with line items that
match this, in order of OrderID.*/

select 
	order_details.order_id
from order_details
where quantity>=60 
group by quantity,order_id 
having count(order_id)>1 ;
	
-- (item->value) a->1,a->2,a->3; b->1,b->2,b->3,c->3.... to show the items only 3 you have to group by..distinct alphabet will give wrong 
-- if another (item->value) tuple is present as d->4. 
-- to get the no. of items you have to use aggregate value and aggregated function which gives the result of only a,b,c 
-- but does not provide the details of multiple a,b,c
-- to get this result you have to use nested query ....in the next question you can see we are using 
-- ******************select item from table1 where item in (select item (#aggregate value )from table1 group by item) **********************


/* 39. Orders - accidental double-entry details
Based on the previous question, we now want to show details of the
order, for orders that match the above criteria.*/


select * from order_details
where order_id in (select order_id 
from order_details
where quantity>=60
group by order_id, quantity having count(quantity)>1 
order by order_id) ;

/* 40. Orders - accidental double-entry details, above problem is done by join  */

Select
Order_Details.Order_ID
,Product_ID
,Unit_Price
,Quantity
,Discount
From Order_Details
Join (
Select
Order_ID
From Order_Details
Where Quantity >= 60
Group By Order_ID, Quantity
Having Count(*) > 1
) PotentialProblemOrders
on PotentialProblemOrders.Order_ID = Order_Details.Order_ID
Order by Order_ID, Product_ID;

/* 41. Late orders
Some customers are complaining about their orders arriving late. Which
orders are late? */

select 
	order_id,
    required_date,
    shipped_date
from orders 
where required_date <= shipped_date;

/* 42. Late orders - which employees?
Some salespeople have more orders arriving late than others. Maybe
they're not following up on the order process, and need more training.
Which salespeople have the most orders arriving late? */

select
    employees.employee_id,
    concat(employees.first_name,' ',employees.last_name) name,
    count(orders.order_id) as total_late_orders
from orders left join employees
on orders.employee_id=employees.employee_id
where orders.required_date <= orders.shipped_date
group by employees.employee_id
order by total_late_orders desc;

/* 43. Late orders vs. total orders
Andrew, the VP of sales, has been doing some more thinking some more
about the problem of late orders. He realizes that just looking at the
number of orders arriving late for each salesperson isn't a good idea. It
needs to be compared against the total number of orders per
salesperson. */

#using cte
with cte1 as	(select orders.employee_id, concat(employees.first_name," ",employees.last_name) as employee_name, count(*) as number_of_delayed_orders 
				from orders join employees on orders.employee_id=employees.employee_id
				where shipped_date>required_date
				group by orders.employee_id
                ),
	cte2 as 	(select employee_id, count(*) as total_orders from orders group by employee_id)
select cte1.*,cte2.total_orders from cte1 left join cte2 on cte1.employee_id= cte2.employee_id
order by cte1.number_of_delayed_orders desc, cte2.total_orders desc;

/* checking from creating views
create view cte1 as(select orders.employee_id, concat(employees.first_name," ",employees.last_name) as employee_name, count(*) as number_of_delayed_orders 
				from orders join employees on orders.employee_id=employees.employee_id
				where shipped_date>required_date
				group by orders.employee_id
                );
create view cte2 as(select employee_id, count(*) as total_orders from orders group by employee_id);
select cte1.*,cte2.total_orders from cte1 join cte2 on cte1.employee_id= cte2.employee_id
order by cte1.number_of_delayed_orders desc, cte2.total_orders desc;;
*/


/* 44. Late orders vs. total orders - missing employee
There's an employee missing in the answer from the problem above. Fix
the SQL to show all employees who have taken orders */

with late_order as ( select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_late_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id
					where orders.required_date <= orders.shipped_date
					group by employees.employee_id ),

		total_order as (select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id 
					group by employees.employee_id )

select total_order.*,late_order.total_late_orders from total_order left join late_order
on total_order.id=late_order.id 
order by total_order.total_orders and late_order.total_late_orders desc;

/* 45. Late orders vs. total orders - fix null
Continuing on the answer for above query, let's fix the results for row 5
- Buchanan. He should have a 0 instead of a Null in LateOrders. */

with late_order as ( select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_late_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id
					where orders.required_date <= orders.shipped_date
					group by employees.employee_id ),

		total_order as (select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id 
					group by employees.employee_id )

select total_order.*, ifnull(late_order.total_late_orders,0) as total_late_order from total_order left join late_order
on total_order.id=late_order.id 
order by total_order.total_orders and late_order.total_late_orders desc;

-- Error Code: 1582. Incorrect parameter count in the call to native function 'isnull'
-- we are using ifnull() function instead of isnull() function because 
-- *****The MySQL equivalent of ISNULL is IFNULL*****

/* 46. Late orders vs. total orders - percentage
Now we want to get the percentage of late orders over total orders*/

with late_order as ( select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_late_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id
					where orders.required_date <= orders.shipped_date
					group by employees.employee_id ),

		total_order as (select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id 
					group by employees.employee_id )

select total_order.*, ifnull(late_order.total_late_orders,0) as total_late_order, 
((late_order.total_late_orders*100)/(total_order.total_orders)) as percentage
from total_order left join late_order
on total_order.id=late_order.id 
order by total_order.total_orders and late_order.total_late_orders desc;

/* 47. Late orders vs. total orders - fix decimal
So now for the PercentageLateOrders, we get a decimal value like we
should. But to make the output easier to read, let's cut the
PercentLateOrders off at 2 digits to the right of the decimal point.*/


with late_order as ( select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_late_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id
					where orders.required_date <= orders.shipped_date
					group by employees.employee_id ),

		total_order as (select
					employees.employee_id as id,
					concat(employees.first_name,' ',employees.last_name) name,
					count(orders.order_id) as total_orders
					from orders left join employees
					on orders.employee_id=employees.employee_id 
					group by employees.employee_id )

select total_order.*, ifnull(late_order.total_late_orders,0) as total_late_order, 
cast(((late_order.total_late_orders*100)/(total_order.total_orders))as decimal(5,2))as percentage
from total_order left join late_order
on total_order.id=late_order.id 
order by total_order.total_orders and late_order.total_late_orders desc;


/* 48. Customer grouping
Andrew Fuller, the VP of sales at Northwind, would like to do a sales
campaign for existing customers. He'd like to categorize customers into
groups, based on how much they ordered in 2016. Then, depending on
which group the customer is in, he will target the customer with
different sales materials.
The customer grouping categories are 0 to 1,000, 1,000 to 5,000, 5,000
to 10,000, and over 10,000.
A good starting point for this query is the answer from the problem
“High-value customers - total orders. We don’t want to show customers
who don’t have any orders in 2016.
-- 2016 will be treated as 1998
Order the results by CustomerID. */

with cte1 as (Select
					Customers.Customer_ID
					,Customers.Company_Name
					, cast(SUM(Quantity * Unit_Price) as decimal (10,2) ) as TotalOrderAmount
					From Customers
					Join Orders
					on Orders.Customer_ID = Customers.Customer_ID
					Join Order_Details
					on Orders.Order_ID = Order_Details.Order_ID
					Where
					Order_Date >= '19980101'
					and Order_Date < '19990101'
					Group By
					Customers.Customer_ID
					,Customers.Company_Name )
select cte1.*,
case
	when cte1.TotalOrderAmount >=0 and cte1.TotalOrderAmount< 1000 then "low"
    when cte1.TotalOrderAmount >=1000 and cte1.TotalOrderAmount < 5000 then "medium"
    when cte1.TotalOrderAmount >=5000 and cte1.TotalOrderAmount <10000 then "high"
    when cte1.TotalOrderAmount >10000 then "very high"
end as CustomerGroup 
from cte1
order by cte1.customer_id;

-- Q49. is skipped 

/* 50. Customer grouping with percentage
Based on the above query, show all the defined CustomerGroups, and
the percentage in each. Sort by the total in each group, in descending
order.*/
with cte1 as (Select
					Customers.Customer_ID
					,Customers.Company_Name
					, cast(SUM(Quantity * Unit_Price) as decimal (10,2) ) as TotalOrderAmount
					From Customers
					Join Orders
					on Orders.Customer_ID = Customers.Customer_ID
					Join Order_Details
					on Orders.Order_ID = Order_Details.Order_ID
					Where
					Order_Date >= '19980101'
					and Order_Date < '19990101'
					Group By
					Customers.Customer_ID
					,Customers.Company_Name ),
	cte2 as (select 
					case
						when cte1.TotalOrderAmount >=0 and cte1.TotalOrderAmount< 1000 then "low"
						when cte1.TotalOrderAmount >=1000 and cte1.TotalOrderAmount < 5000 then "medium"
						when cte1.TotalOrderAmount >=5000 and cte1.TotalOrderAmount <10000 then "high"
						when cte1.TotalOrderAmount >10000 then "very high"
					end as CustomerGroup 
					from cte1)
select cte2.*,count(cte2.customergroup) as total, (count(cte2.customergroup)*100/(select count(*)from cte2)) as percentage  
from cte2
group by customergroup
order by total desc;

/*51. Customer grouping - flexible
Andrew, the VP of Sales is still thinking about how best to group
customers, and define low, medium, high, and very high value
customers. He now wants complete flexibility in grouping the
customers, based on the dollar amount they've ordered. He doesn’t want
to have to edit SQL in order to change the boundaries of the customer
groups.
How would you write the SQL?
There's a table called CustomerGroupThreshold that you will need to
use. Use only orders from 2016.*/

delimiter %
create procedure bondaries(in lower_bound int,in high_bound int, in Vhigh_bound int) 
with cte as (select orders.customer_id,customers.company_name, sum(order_details.unit_price*order_details.quantity) as total 
from order_details join orders on orders.order_id= order_details.order_id 
					left join customers on orders.customer_id=customers.customer_id
where year(orders.order_date) =1998
group by orders.customer_id)
select cte.customer_id, cte.company_name, cte.total,
case when total >=0 and total<1000 then "low"
	when total >=1000 and total<5000 then "medium"
    when total >=5000 and total<10000 then "high"
    when total >=10000  then "very high"
end as categories
from  cte order by cte.customer_id%

call bondaries(1000,5000,10000) %
delimiter ;

/* 52. Countries with suppliers or customers
Some Northwind employees are planning a business trip, and would like
to visit as many suppliers and customers as possible. For their planning,
they’d like to see a list of all countries where suppliers and/or customers
are based.*/

select distinct suppliers.country as country from suppliers 
union 
select distinct customers.country as country from customers
order by country;

/* 53. Countries with suppliers or customers, version 2
The employees going on the business trip don’t want just a raw list of
countries, they want more details. We’d like to see output like the
below, in the Expected Results.
SupplierCountry CustomerCountry
--------------- ---------------
NULL Argentina
Australia NULL
NULL Austria
NULL Belgium
Brazil Brazil
Canada Canada
Denmark Denmark etc...*/
-- method 1
select 
				suppliers.country as suppliers_country,
				customers.country as customers_country
				from suppliers left join customers 
				on suppliers.country=customers.country
               
               
UNION
select 
				suppliers.country as suppliers_country,
				customers.country as customers_country
				from suppliers right join customers 
				on suppliers.country=customers.country;

-- method 2
With SupplierCountries as
(Select Distinct Country from Suppliers)
,CustomerCountries as
(Select Distinct Country from Customers)
Select
 SupplierCountries .Country as supplier_country
,CustomerCountries .Country as customer_country
From SupplierCountries
left Join CustomerCountries
on CustomerCountries.Country = SupplierCountries.Country
union 
Select
SupplierCountries .Country as supplier_country
,CustomerCountries .Country as customer_country
From SupplierCountries
right Join CustomerCountries
on CustomerCountries.Country = SupplierCountries.Country;
                
/* 54. Countries with suppliers or customers - version 3
The output of the above is improved, but it’s still not ideal
What we’d really like to see is the country name, the total suppliers, and
the total customers.*/
     
With SupplierCountries as
(Select Country , Count(*) as total from Suppliers group by Country)
,CustomerCountries as
(Select Country , Count(*) as total from Customers group by Country)
Select
 ifnull( SupplierCountries.Country, CustomerCountries.Country)as country
,ifnull(SupplierCountries.Total,0) as TotalSuppliers
,ifnull(CustomerCountries.Total,0) as TotalCustomers
From SupplierCountries
left Join CustomerCountries
on CustomerCountries.Country = SupplierCountries.Country
union
Select
 ifnull( SupplierCountries.Country, CustomerCountries.Country)as country
,ifnull(SupplierCountries.Total,0) as TotalSuppliers
,ifnull(CustomerCountries.Total,0) as TotalCustomers
From SupplierCountries
right Join CustomerCountries
on CustomerCountries.Country = SupplierCountries.Country
order by country;
	
/* 55. First order in each country
Looking at the Orders table—we’d like to show details for each order
that was the first in that particular country, ordered by OrderID.
So, we need one row per ShipCountry, and CustomerID, OrderID, and
OrderDate should be of the first order from that country.*/

select 
    customers.country,
    orders.customer_id,
    orders.order_id,
    orders.order_date
from orders left join customers
on orders.customer_id=customers.customer_id
group by customers.country
order by customers.country;

/* 56. Customers with multiple orders in 5 day period
There are some customers for whom freight is a major expense when
ordering from Northwind.
However, by batching up their orders, and making one larger order
instead of multiple smaller orders in a short period of time, they could
reduce their freight costs significantly.
Show those customers who have made more than 1 order in a 5 day
period. The sales people will use this to help customers reduce their
costs.
Note: There are more than one way of solving this kind of problem. For
this problem, we will not be using Window functions*/

-- cross join or self join can be  used also
Select
InitialOrder.Customer_ID
, InitialOrder.Order_ID as InitialorderId
, cast(InitialOrder.Order_Date as date) as initialOrderDate
,NextOrder.Order_ID as NextOrderId
,cast( NextOrder.Order_Date as date) as nextorderdate
,datediff( NextOrder.Order_Date,InitialOrder.Order_Date) as DaysBetween
from Orders InitialOrder
join Orders NextOrder
on InitialOrder.Customer_ID = NextOrder.Customer_ID
where
InitialOrder.Order_ID < NextOrder.Order_ID
and datediff(NextOrder.Order_Date,InitialOrder.Order_Date) <= 5
Order by
InitialOrder.Customer_ID
,InitialOrder.Order_ID;

/* 57. Customers with multiple orders in 5 day period, version
2
There’s another way of solving the problem above, using Window
functions. We would like to see the following results.*/

With NextOrderDate as (
Select
Customer_ID
,cast(Order_Date as date) as Order_Date
,
cast(
Lead(Order_Date,1)
OVER (Partition by Customer_ID order by Customer_ID, Order_Date) as date
) as NextOrderDate
From Orders
)
Select
Customer_ID
,Order_Date
,NextOrderDate
,DateDiff (  NextOrderDate,Order_Date) as DaysBetween
From NextOrderDate
Where
DateDiff ( NextOrderDate,Order_Date) <= 5