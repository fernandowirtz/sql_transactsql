-- https://www.w3resource.com/sql-exercises/subqueries/index.php
-- https://www.w3resource.com/sql/subqueries/understanding-sql-subqueries.php

USE PUBS
GO

-- Nombres de Editoriales que  publican Libros de Negocios

SELECT pub_name, pub_id 
FROM publishers
WHERE pub_id  IN
   (SELECT pub_id
   FROM titles
   WHERE type = 'business')
GO


-- Nombres de Editoriales que no publican Libros de Negocios


SELECT pub_name
FROM publishers
WHERE pub_id NOT IN
   (SELECT pub_id
   FROM titles
   WHERE type = 'business')
GO

--pub_name
--Binnet & Hardley
--Five Lakes Publishing
--Ramona Publishers
--GGG&G
--Scootney Books
--Lucerne Publishing

SELECT pub_name
FROM publishers
WHERE  EXISTS
   (SELECT *
   FROM titles
   WHERE pub_id = publishers.pub_id
      AND type = 'business')
GO

-- JOIN 

SELECT DISTINCT pub_name
FROM publishers p join titles t
ON p.pub_id = t.pub_id
WHERE  type = 'business'
GO


-- For example, if you assume each publisher is located in only one city, and you want 
-- to find the names of authors who live in the city in which Algodata Infosystems is located,
--  you can write a statement with a subquery introduced with the simple = comparison operator.

Find the names of authors who live in the city in which Algodata Infosystems is located
SELECT au_lname, au_fname
FROM authors
WHERE city =
   (SELECT city
   FROM publishers
   WHERE pub_name = 'Algodata Infosystems')
GO

-- Find the names of authors who live in the city in which 
-- Algodata Infosystems is located

SELECT au_lname, au_fname
FROM authors
WHERE city =
   (SELECT city
   FROM publishers
   WHERE pub_name = 'Algodata Infosystems')
GO




SELECT  city FROM Publishers order by city
GO
--city
--Berkeley
--Boston
--Chicago
--Dallas
--Mnchen
--New York
--Paris
--Washington

SELECT  distinct city from Authors order by city
GO

--city
--Ann Arbor
--Berkeley
--Corvallis
--Covelo
--Gary
--Lawrence
--Menlo Park
--Nashville
--Oakland
--Palo Alto
--Rockville
--Salt Lake City
--San Francisco
--San Jose
--Vacaville
--Walnut Creek


SELECT *
FROM authors a JOIN publishers p
ON a.city = p.city
GO


ALTER PROC ciudad_Autor
	@Editorial varchar(50)
as
SELECT au_lname, au_fname
FROM authors
WHERE city =
   (SELECT city
   FROM publishers
   WHERE pub_name = @Editorial)
GO



ciudad_Autor

EXEC ciudad_Autor 'Algodata Infosystems'

EXEC ciudad_Autor 'New Moon Books'
GO
EXEC ciudad_Autor 'Five Lakes Publishing'
GO
EXEC ciudad_Autor 'Lucerne Publishing'

USE Northwind
GO

-- Find the name of the company that placed order 10290.

SELECT CompanyName
FROM Customers
WHERE CustomerID = (SELECT CustomerID
			FROM Orders
			WHERE OrderID = 10290);
GO


-- -- Find the Companies that placed orders in 1997

SELECT CompanyName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID
			FROM Orders
			WHERE OrderDate BETWEEN '1997-01-01' AND '1997-12-31')
GO

SELECT CompanyName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID
			FROM Orders
			WHERE OrderDate BETWEEN '1997-01-01' AND getdate())
GO
-- Error
SELECT CompanyName, Orders.OrderDate
FROM Customers
WHERE CustomerID IN (SELECT CustomerID
			FROM Orders
			WHERE OrderDate BETWEEN '1997-01-01' AND getdate())
GO

SELECT CompanyName, Orders.OrderDate
FROM Customers
WHERE CustomerID IN (SELECT CustomerID
			FROM Orders
			WHERE OrderDate BETWEEN '1997-01-01' AND getdate())
GO


-- https://www.webucator.com/tutorial/learn-sql/subqueries-joins-unions/subqueries-exercise.cfm#tutorial

--Create a report that shows the product name and supplier id for all products supplied by Exotic Liquids, Grandma Kelly's Homestead, and Tokyo Traders.
--You will need to escape the apostrophe in "Grandma Kelly's Homestead." To do so, place another apostrophe in front of it. For example,
--SELECT *
--FROM Suppliers
--WHERE CompanyName='Grandma Kelly''s Homestead';
--Create a report that shows all products by name that are in the Seafood category.
--Create a report that shows all companies by name that sell products in CategoryID 8.
--Create a report that shows all companies by name that sell products in the Seafood category.
--Solution:

SELECT ProductName, SupplierID
FROM Products
WHERE SupplierID IN (SELECT SupplierID
			FROM Suppliers
			WHERE CompanyName IN 
				('Exotic Liquids', 'Grandma Kelly''s Homestead', 'Tokyo Traders'));
GO


SELECT ProductName
FROM Products
WHERE CategoryID = (SELECT CategoryID
			FROM Categories
			WHERE CategoryName = 'Seafood');
GO
SELECT CompanyName
FROM Suppliers
WHERE SupplierID IN (SELECT SupplierID
			FROM Products
			WHERE CategoryID = 8); 
GO
SELECT CompanyName
FROM Suppliers
WHERE SupplierID IN (SELECT SupplierID
			FROM Products
			WHERE CategoryID = (SELECT CategoryID
						FROM Categories
						WHERE CategoryName = 'Seafood'));
GO
------------------------

-- http://www.geeksengine.com/database/subquery/return-single-value.php

/*
This query returns data for all customers and their 
orders where the orders were shipped on the most 
recent recorded day.
 
The execution steps:
 
1. The subquery 
 
   select max(ShippedDate) from orders
 
in the WHERE clause uses aggregate function max to return 
the maximum ship date in the orders table and it returns 
1998-05-06 00:00:00
 
2. Then, 1998-05-06 00:00:00 is used in the outer query to 
compare with ShippedDate.
 
   select OrderID, CustomerID
   from orders
   where ShippedDate = '1998-05-06 00:00:00'
 
*/
select OrderID, CustomerID
from orders
where ShippedDate = 
(select max(ShippedDate) from orders);
GO

/*
This query returns all products whose unit price
is greater than average unit price.
*/
select distinct ProductName, UnitPrice
from products
where UnitPrice>(select avg(UnitPrice) from products)
order by UnitPrice desc;
GO

/*
This query lists the percentage of total units in 
stock for each product.
 
The subquery 
 
    select sum(UnitsInStock) from products
 
works out the total units in stock which is 3119.
 
Then 3119 is used in the outer query to calculate the
percentage of total units in stock for each product.
*/
select ProductID,
       ProductName,
       concat((UnitsInStock / (select sum(UnitsInStock) from products))*100, '%')
       as Percent_of_total_units_in_stock
from products
order by ProductID;
 
/*
This query returns the same result as query above.
Here 3119 is hardcoded whereas query above uses
subquery to calculate 3119 on the fly.
*/
select ProductID,
       ProductName,
       concat((UnitsInStock / 3119)*100, '%')
       as Percent_of_total_units_in_stock
from products
order by ProductID;


/*
This query finds the shipping company (or companies)
that charged the highest freight. 
 
The subquery returns the max freight from orders table.
Then the max freight is used in outer query as criteria
to retrieve the shipping company's ID and name in the
joined table shippers.
*/
select a.ShipperID, 
       a.CompanyName,
       b.Freight
from shippers as a
inner join orders as b on a.ShipperID=b.ShipVia
where b.Freight = (select max(Freight) from orders);
GO

-- http://www.geeksengine.com/database/subquery/return-a-list-of-values.php

/*
This query retrieves a list of customers that made 
purchases after the date 1998-05-01.
 
The subquery returns a list of CustomerIDs which is
used in outer query.
*/
select CustomerID, CompanyName
from customers
where CustomerID in 
(
   select CustomerID 
   from orders 
   where orderDate > '1998-05-01'
);
 Go

 /*
This query returns the same result as the one
in Practice #1 but here no subquery is used. 
Instead, we used inner join. 
 
Often, a query that contains subqueries can be 
rewritten as a join.
 
Using inner join allows the query optimizer to 
retrieve data in the most efficient way.
*/
select a.CustomerID, a.CompanyName
from customers as a
inner join orders as b on a.CustomerID = b.CustomerID
where b.orderDate > '1998-05-01'
GO

-- http://www.geeksengine.com/database/subquery/return-rows-of-values.php

/*
This query finds out all the employees who live
in the same city  as customers.
 

*/
select EmployeeID, FirstName, LastName, City, Country
from employees
where City in
(select City from customers);
GO

/*
This query uses EXISTS keyword in WHERE clause 
to return a list of customers whose products 
were shipped to UK.
 
Note that the outer query only returns a row
where the subquery returns TRUE.
*/
select CustomerID, CompanyName 
from customers as a
where exists
(
    select * from orders as b
    where a.CustomerID = b.CustomerID
    and ShipCountry = 'UK'
);
 
/*
This query uses INNER JOIN and returns the same 
result set as the query above. It shows you that
the correlated subquery can be rewritten as join
operation.
*/
select distinct a.CustomerID, a.CompanyName 
from customers as a
inner join orders as b
on a.CustomerID = b.CustomerID
where b.ShipCountry = 'UK';
GO

/*
This query uses NOT EXISTS keyword in WHERE clause 
to return a list of customers whose products were 
NOT shipped to UK.
 
Note that this query returns two more rows than
the query in Practice #1. This is because Customer
PARIS and FISSA do not have records in orders table.
*/
select CustomerID, CompanyName 
from customers as a
where not exists
(
    select * from orders as b
    where a.CustomerID = b.CustomerID
    and ShipCountry <> 'UK'
);
 
/*
This query uses left join and returns the same result as 
the query above. The left join returns all records from the
customers table and included the customers who have not 
placed any orders - PARIS and FISSA.
*/
select distinct a.CustomerID, a.CompanyName 
from customers as a
left join orders as b on a.CustomerID = b.CustomerID
where b.ShipCountry = 'UK' or b.ShipCountry is null;
GO





-- https://msdn.microsoft.com/en-us/library/office/ff192664.aspx

-- Returns all products whose unit price is greater than that of any product sold at a discount of 25 percent or more:
SELECT * 
FROM Products 
WHERE UnitPrice > ANY 
(SELECT UnitPrice FROM  [dbo].[Order Details]
WHERE Discount >= .25);
GO


-- returns all products with a discount of 25 percent or more

SELECT * FROM Products 
WHERE ProductID IN 
(SELECT ProductID FROM [dbo].[Order Details]
WHERE Discount >= .25);
GO


-- You can also use table name aliases in a subquery to refer to tables 
-- listed in a FROM clause outside the subquery. 
--The following example returns the names of employees whose salaries 
-- are equal to or greater than the average salary of all employees having the same job title. The Employees table is given the alias "T1":

SELECT LastName,FirstName, Title, Salary 
FROM Employees AS T1 
WHERE Salary >= (SELECT Avg(Salary) 
FROM Employees 
WHERE T1.Title = Employees.Title) Order by Title;
GO


-- All customers that are from the same countries as the suppliers:

SELECT * 
FROM Customers
WHERE Country IN 
	(SELECT Country 
	FROM Suppliers)
GO

-- (69 row(s) affected)

-- Lists the suppliers with a product price less than 20:

SELECT [CompanyName]
FROM Suppliers
WHERE EXISTS 
		(SELECT ProductName 
		FROM Products 
		WHERE SupplierId = Suppliers.supplierId 
				AND [UnitPrice] < 20);
GO

-- Lists the product names if it finds ANY records in the OrderDetails table 
-- that quantity = 10

SELECT ProductName
FROM Products
WHERE ProductID = ANY 
	(SELECT ProductID 
	FROM [dbo].[Order Details]
	WHERE Quantity = 10);
GO

------------------
-- https://github.com/sqlservercurry/sql-sub-queries/blob/master/listofallqueries

-- http://www.sqlservercurry.com/2014/02/sql-server-nested-sub-queries-and_2.html


--* Author: Pravin Dabade
--Website: www.sqlservercurry.com */
USE Northwind
GO

SELECT * FROM Customers
SELECT * FROM Orders
SELECT * FROM [Order Details]
SELECT * FROM Employees
SELECT * FROM Categories
SELECT * FROM Products
SELECT * FROM Suppliers

--SELECT ALL THE ORDERS PLACED BY CUSTOMER WHOSE Phone No IS  030-0074321
SELECT * FROM Orders WHERE CustomerID=
(SELECT CustomerID FROM Customers
 WHERE Phone='030-0074321')

--SELECT ALL THE PRODUCTS which belongs to Seafood category
SELECT * FROM Products WHERE CategoryID=
(SELECT CategoryID FROM Categories 
WHERE CategoryName='Seafood')

--Select all the Products which are supplied by company 'Pavlova, Ltd.'
SELECT * FROM Products WHERE SupplierID=
(SELECT SupplierID FROM Suppliers 
WHERE CompanyName='Pavlova, Ltd.')

------Error - Sub Query Returns More than one Row.
SELECT * FROM Orders WHERE CustomerID =
(SELECT CustomerID FROM Customers 
WHERE City='London')
-----------------------------------------------------------
--When Sub Query returns more than one row, you can make use of special operators. Special Operator - IN, NOT IN, ANY, ALL, EXISTS

--IN Operator - Inner Query returns list of values which will be used by outer query to fetch the matching rows.
SELECT * FROM Orders WHERE CustomerID IN(
SELECT CustomerID FROM Customers WHERE City='London')
--NOT IN Operator - Inner Query returns list of values. The outer query to fetch the non-matching rows.
SELECT * FROM Orders WHERE CustomerID NOT IN(
SELECT CustomerID FROM Customers WHERE City='London')

-->ANY/SOME Operator - Compares the list of values and returns the rows greater than the min value.
SELECT * FROM Products WHERE UnitPrice>ANY(
SELECT MAX(UnitPrice) FROM Products GROUP BY CategoryID)

SELECT * FROM Products WHERE UnitPrice>SOME(
SELECT MAX(UnitPrice) FROM Products GROUP BY CategoryID)

--<ANY/SOME Operator - Compares the list of values and returns the rows less than the max value.
SELECT * FROM Products WHERE UnitPrice<ANY(
SELECT MAX(UnitPrice) FROM Products GROUP BY CategoryID)

SELECT * FROM Products WHERE UnitPrice<SOME(
SELECT MAX(UnitPrice) FROM Products GROUP BY CategoryID)

-->ALL Operator - Compares the list of values and returns the rows greater than the max value.
SELECT * FROM Products WHERE UnitPrice>ALL(
SELECT MAX(UnitPrice) FROM Products 
GROUP BY CategoryID)

SELECT * FROM Products WHERE UnitPrice>=ALL(
SELECT MAX(UnitPrice) FROM Products 
GROUP BY CategoryID)
--<ALL Operator - Compares the list of values and returns the rows less than the min value.
SELECT * FROM Products WHERE UnitPrice<ALL(
SELECT MAX(UnitPrice) FROM Products GROUP BY CategoryID)

--EXISTS/ NOT EXISTS Operator
SELECT * FROM Customers WHERE EXISTS(
SELECT COUNT(*) FROM Orders 
WHERE ShipCity='London' GROUP BY ShipCity 
HAVING COUNT(*)>30)

--Co-Related Sub Query
SELECT * FROM Orders O WHERE EmployeeID IN(
SELECT EmployeeID FROM Employees E 
WHERE O.ShipCity=E.City)

--Nested Sub Queries with Multi-Levels
SELECT * FROM Orders WHERE OrderID IN(
SELECT OrderID FROM [Order Details] WHERE ProductID=(
SELECT ProductID FROM Products WHERE ProductName='Chai'))

--DELETE Statement USING Sub Query
DELETE FROM Customers WHERE City IN(
SELECT ShipCity FROM Orders WHERE ShipCountry='France')

UPDATE Products SET Discontinued=0 WHERE SupplierID=(
SELECT SupplierID FROM Suppliers WHERE City='London') 



