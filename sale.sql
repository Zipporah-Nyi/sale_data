CREATE DATABASE northwind;
USE northwind;

--Creating the first table named 'orders'

CREATE TABLE orders 
(order_id INT(11) NOT NULL PRIMARY KEY,
customer_id VARCHAR(20),
order_date DATE,
required_date DATE,
shipped_date DATE,
ship_country VARCHAR (64));
 
 -- I forgot to create column for employee_id, so I will insert and move to the correct place.
ALTER TABLE orders ADD COLUMN employee_id INT(11);
ALTER TABLE orders MODIFY COLUMN employee_id INT(11) AFTER customer_id;

DESC orders;

 --loading csv data file to the table. 
 LOAD DATA INFILE "C:\\Users\\Public\\Northwind orders.csv"
 INTO TABLE orders
 FIELDS TERMINATED BY ','
 ENCLOSED BY ','
 LINES TERMINATED BY "\n"
 IGNORE 1 ROWS;
 
 SELECT*FROM orders LIMIT 5;
 
 --Now, I will create another table for order details name "details"
 
 CREATE TABLE details
 (order_id INT(11),
 product_id INT(11),
 unit_price DECIMAL(5,2),
 quantity INT(11),
 discount DECIMAL (3,3));
 
RENAME TABLE details TO order_details;

 LOAD DATA INFILE "C:\\Users\\Public\\northwind_order_details.csv"
 INTO TABLE order_details
 FIELDS TERMINATED BY ','
 ENCLOSED BY ','
 LINES TERMINATED BY "\n"
 IGNORE 1 ROWS;
 
 SELECT*FROM order_details LIMIT 5;
 
  -- Calculating Total Revenue for all orders
 SELECT SUM(unit_price*quantity*(1-discount)) as total_sales FROM order_details;
 -- 1265793.03950 
 
 -- Calculating Total Number of orders
 SELECT COUNT(order_id) FROM orders;
-- 809

-- Average revenue per Transaction 
SELECT SUM(unit_price*quantity*(1-discount))/ COUNT(DISTINCT(order_id)) FROM order_details;
-- 1525.051854819 

--Calculating Total Sales by Year
SELECT YEAR(orders.order_date),SUM(od.unit_price*od.quantity*(1-od.discount)) as total_sales 
FROM orders
LEFT JOIN order_details od
ON orders.order_id=od.order_id
GROUP BY YEAR(orders.order_date)
ORDER BY YEAR(orders.order_date);
-- 1996	208083.97000
-- 1997	617085.20350
-- 1998	414686.43550

--Number of Transactions per year
SELECT YEAR(order_date), COUNT(order_id) FROM orders
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

--Calculating Total Sales of the countries with total sales of more than 100,000;
SELECT orders.ship_country, SUM(od.unit_price * od.quantity * (1-od.discount)) as total_sales 
FROM orders
LEFT JOIN order_details od
ON orders.order_id=od.order_id
GROUP BY orders.ship_country
HAVING total_sales > 100000;
Germany
	227796.65850
Brazil
	103060.69650
Austria
	118104.93850
USA
	243618.89000

--Finding Total Sales of USA and UK 
SELECT orders.ship_country, SUM(od.unit_price* od.quantity* (1-od.discount)) as total_sales 
FROM orders
LEFT JOIN order_details od
ON orders.order_id=od.order_id
WHERE orders.ship_country LIKE "U%"
GROUP BY orders.ship_country;
-- USA
	243618.89000
-- UK
	58971.31000
    
-- Top 3 Customers and their Countries 
SELECT orders.customer_id, orders.ship_country as country, SUM(od.unit_price* od.quantity* (1-od.discount)) AS total_sales FROM orders
LEFT JOIN order_details od
ON orders.order_id=od.order_id 
GROUP BY orders.customer_id, orders.ship_country
ORDER BY total_sales DESC 
LIMIT 3;
-- QUICK	Germany
	110277.30500
-- SAVEA	USA
	104361.95000
-- ERNSH	Austria
	94976.07850

--Total number of orders which were delayed after the required date 
SELECT YEAR(order_date), COUNT(order_id) FROM orders
WHERE shipped_date > required_date
GROUP BY YEAR(order_date);
-- 1996	7
-- 1997	22
-- 1998	8 

