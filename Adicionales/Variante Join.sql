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
   -- ORDER BY authors.au_lname
   -- ORDER BY Title
   ORDER BY authors.au_lname,Title
GO

