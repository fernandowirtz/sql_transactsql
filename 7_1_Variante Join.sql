USE [Gestion8]
GO

SELECT o.[oficina],o.[ciudad],e.[numemp],e.[nombre]
FROM  [oficinas] o  JOIN [empleados] e
ON o. [oficina] = e.[oficina]
ORDER BY o.oficina
GO

SELECT o.[oficina],o.[ciudad],e.[numemp],e.[nombre]
FROM  [oficinas] o  LEFT OUTER JOIN [empleados] e
ON o. [oficina] = e.[oficina]
ORDER BY o.oficina
GO

SELECT o.[oficina],o.[ciudad],e.[numemp],e.[nombre]
FROM  [oficinas] o  RIGHT OUTER JOIN [empleados] e
ON o. [oficina] = e.[oficina]
ORDER BY o.oficina
GO

SELECT o.[oficina],o.[ciudad],e.[numemp],e.[nombre]
FROM  [oficinas] o  FULL  JOIN [empleados] e
ON o. [oficina] = e.[oficina]
ORDER BY o.oficina
GO



SELECT o.[oficina],o.[ciudad],e.[numemp],e.[nombre]
FROM  [oficinas] o  CROSS JOIN [empleados] e
ORDER BY o.oficina
GO


USE Northwind
GO
SELECT OrderID,e.EmployeeID,e.lastname
FROM employees e  JOIN Orders o
ON e.EmployeeID = o.EmployeeID
ORDER BY e.EmployeeID
GO
-- (830 row(s) affected)




SELECT OrderID,e.EmployeeID,lastname
FROM employees e LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GO

-- (830 row(s) affected)

SELECT OrderID,e.EmployeeID,lastname
FROM employees e LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
WHERE  o.EmployeeID is null
GO

SELECT OrderID,e.EmployeeID,lastname
FROM employees e FULL JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GO
-- (830 row(s) affected)

SELECT OrderID,e.EmployeeID,lastname
FROM employees e LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
WHERE  e.EmployeeID is null
GO

SELECT OrderID,e.EmployeeID,lastname
FROM employees e LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
WHERE  e.EmployeeID is not null
GO

-- (830 row(s) affected)

 USE Pubs
   GO

   SELECT authors.au_fname, authors.au_lname, titles.title
   FROM authors   INNER JOIN titleauthor
   ON authors.au_id = titleauthor.au_id
   INNER JOIN titles 
   ON titleauthor.title_id = titles.title_id
   ORDER BY authors.au_lname
    -- ORDER BY Title
GO

-------------------

-- Using a Subquery in a WHERE Clause
--The following query implicitly joins the authors table (pubs database) with
--itself to find all authors living in the same city as the author with the last name
--“Green”.

-- SELF-JOIN
USE Pubs
GO
SELECT a1.au_lname, a1.au_fname, a1.city, a1.[state]
FROM dbo.authors AS a1, dbo.authors AS a2
WHERE a1.city = a2.city
			AND a2.au_lname = 'Green'
GO

ALTER PROC Misma_Ciudad
	  @apellido varchar(50) ='Green'
AS
	BEGIN
		SELECT a1.au_lname, a1.au_fname, a1.city, a1.[state]
		FROM dbo.authors AS a1, dbo.authors AS a2
		WHERE a1.city = a2.city
			AND a2.au_lname = @apellido
	END
GO
-- SELECT * FROM Authors
Misma_Ciudad 
EXEC Misma_Ciudad 
EXECUTE Misma_Ciudad 'Green'
EXECUTE Misma_Ciudad 'Carson'  -- White

-- Using Subqueries

SELECT au_lname, au_fname, city, [state]
FROM dbo.authors
WHERE city =
(SELECT city
FROM dbo.authors
WHERE au_lname = 'Green');
GO

CREATE PROC Misma_Ciudad_Sub
	  @apellido varchar(50) ='Green'
AS
	BEGIN
		SELECT au_lname, au_fname, city, [state]
		FROM dbo.authors
		WHERE city =
							(SELECT city
							FROM dbo.authors
							WHERE au_lname =  @apellido)
	END
GO