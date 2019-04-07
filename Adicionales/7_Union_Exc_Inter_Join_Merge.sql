-- https://opentextbc.ca/dbdesign01/back-matter/appendix-d-sql-lab-with-solution/

-- Consultas MultiTabla     MultiTable Queries

-- Union Except Intersect  INNER / OUTER Join
--

DROP DATABASE IF EXISTS multitabla
GO
CREATE DATABASE multitabla
GO
USE multitabla
GO
-- USE Tempdb
-- GO
DROP TABLE IF EXISTS Productos
GO
DROP TABLE IF EXISTS Frutas
GO

-- Otra posiblidad
IF object_id('Productos') IS NOT NULL
	DROP TABLE Productos ;
IF object_id('Frutas') IS NOT NULL
	DROP TABLE Frutas ;



CREATE TABLE Productos (
	Nombre NVARCHAR(20),
	Precio SMALLMONEY );

CREATE TABLE Frutas (
	Nombre NVARCHAR(20),
	Precio SMALLMONEY );
GO

INSERT Productos
	VALUES	('Leche', 2.4),
			('Miel', 4.99),
			('Manzanas', 3.99),
			('Pan', 2.45),
			('Uvas', 4.00);
GO
INSERT Frutas
	VALUES	('Manzanas', 6.0),
			('Uvas', 4.00),
			('Bananas', 4.95),
			('Mandarinas', 3.95),
			('Naranjas', 2.50);
GO

SELECT *
	FROM Productos
	ORDER BY Nombre ;

SELECT *
	FROM Frutas
	ORDER BY Nombre ;
GO


-- Union (sin filas duplicadas)
SELECT Nombre
FROM Productos
	UNION
SELECT Nombre
FROM Frutas ;
GO
--Nombre
--Bananas
--Leche
--Mandarinas
--Manzanas
--Miel
--Naranjas
--Pan
--Uvas

-- Union (aparecen campos duplicados, porque los valores del segundo
--	campo son diferentes y entonces los considera distintos)
SELECT Nombre, Precio
FROM Productos
	UNION
SELECT Nombre, Precio
FROM Frutas ;
GO

--Nombre	Precio
--Bananas	4,95
--Leche	2,40
--Mandarinas	3,95
--Manzanas	3,99
--Manzanas	6,00
--Miel	4,99
--Naranjas	2,50
--Pan	2,45
--Uvas	4,00

-- Union ALL (forzamos que aparezcan todos los registros, aunque sean
--	duplicados)

SELECT Nombre
FROM Productos
	UNION ALL 
SELECT Nombre
FROM Frutas 
order by Nombre desc;
GO

--Nombre
--Uvas
--Uvas
--Pan
--Naranjas
--Miel
--Manzanas
--Manzanas
--Mandarinas
--Leche
--Bananas

SELECT Nombre, Precio
FROM Productos
	UNION ALL
SELECT Nombre, Precio
FROM Frutas
ORDER BY Nombre,Precio ;
GO

--Nombre	Precio
--Bananas	4,95
--Leche	2,40
--Mandarinas	3,95
--Manzanas	3,99
--Manzanas	6,00
--Miel	4,99
--Naranjas	2,50
--Pan	2,45
--Uvas	4,00
--Uvas	4,00


SELECT Nombre, Precio
FROM Productos
	UNION 
SELECT Nombre, Precio
FROM Frutas
ORDER BY Nombre,Precio ;
GO


-- Intersect (de un único campo)

SELECT Nombre
FROM Productos
	INTERSECT
SELECT Nombre
FROM Frutas ;
GO
--Nombre
--Manzanas
--Uvas

-- Intersect (de un único campo)

SELECT Precio
FROM Productos
	INTERSECT
SELECT Precio
FROM Frutas ;
GO

-- 4

-- Intersect (de dos campos)



SELECT Nombre, Precio
FROM Productos
	INTERSECT
SELECT Nombre, Precio
FROM Frutas ;
GO

--Nombre	Precio
--Uvas	4,00











-- Except (de un único campo)
SELECT Nombre
FROM Productos
	EXCEPT
SELECT Nombre
FROM Frutas ;
GO
--Nombre
--Leche
--Miel
--Pan

-- Except (de un único campo)
SELECT Nombre
FROM Frutas
	EXCEPT
SELECT Nombre
FROM Productos ;
GO
--Nombre
--Bananas
--Mandarinas
--Naranjas


-- Except (de un único campo)
SELECT Precio
FROM Productos
	EXCEPT
SELECT Precio
FROM Frutas ;
GO

--Precio
--2,40
--2,45
--3,99
--4,99

-- Except (de dos campos)
SELECT Nombre, Precio
	FROM Productos
EXCEPT
SELECT Nombre, Precio
	FROM Frutas ;
GO
--Nombre	Precio
--Leche	2,40
--Manzanas	3,99
--Miel	4,99
--Pan	2,45

-- Except (de dos campos)
SELECT Nombre, Precio
FROM Frutas
	EXCEPT
SELECT Nombre, Precio
FROM Productos ;
GO
--Nombre	Precio
--Bananas	4,95
--Mandarinas	3,95
--Manzanas	6,00
--Naranjas	2,50


-- JOIN

-- INNER JOIN			COMBINACIÓN iNTERNA

SELECT * 
FROM Frutas f INNER JOIN Productos p  -- f p son ALIAS
ON f.Nombre = p.Nombre  -- sería igual Frutas.Nombre = Productos.Nombre 
GO


--Nombre	Precio	Nombre	Precio
--Manzanas	6,00	Manzanas	3,99
--Uvas	4,00	Uvas	4,00

-- Formato antiguo, pero aún en uso

SELECT * 
FROM Frutas f, Productos p
WHERE f.Nombre = p.Nombre
GO

--Nombre	Precio	Nombre	Precio
--Manzanas	6,00	Manzanas	3,99
--Uvas	    4,00	          Uvas	4,00

-- Variante con WHERE

SELECT * 
FROM Frutas f INNER JOIN Productos p  -- f p son ALIAS
ON f.Nombre = p.Nombre  -- sería igual Frutas.Nombre = Productos.Nombre 
WHERE f.Nombre LIKE 'U%'
GO
--Nombre	Precio	Nombre	Precio
--Uvas	4,00	Uvas	4,00




SELECT f.Nombre, f.Precio [Precio Frutas], p.Precio [Precio Productos]
FROM Frutas f INNER JOIN Productos p
ON f.Nombre = p.Nombre
GO

--Nombre	Precio Frutas	Precio Productos
--Manzanas	6,00	3,99
--Uvas	4,00	4,00


-- OUTER	 COMBINACIONES EXTERNAS
USE multitabla
GO
SELECT *
	FROM Productos
	ORDER BY Nombre ;

SELECT *
	FROM Frutas
	ORDER BY Nombre ;
GO

-- Repetidas Manzanas Uvas
-- INNER JOIN
SELECT f.Nombre, f.Precio [Precio Frutas], p.Precio [Precio Productos]
FROM Productos p JOIN Frutas f
ON f.Nombre = p.Nombre
GO

-- LEFT OUTER JOIN

SELECT  p.Nombre as NombreProducto,p.Precio [Precio Productos],
				f.Nombre, f.Precio [Precio Frutas]
FROM Productos p LEFT OUTER JOIN Frutas f
ON f.Nombre = p.Nombre
GO

--Nombre	Precio Frutas	Precio Productos
--Manzanas	6,00	3,99
--Uvas	4,00	4,00
--Bananas	4,95	NULL
--Mandarinas	3,95	NULL
--Naranjas	2,50	NULL
------------------------------------------------------
-- JOIN with DATABASE Pubs

USE Pubs
GO
SELECT *
INTO Empleado
FROM [dbo].[employee]
GO
SELECT *
INTO Trabajo
FROM [dbo].[jobs]
GO
SELECT *
INTO Editoriales
FROM [dbo].[publishers]
GO
SELECT *
INTO Editoriales_Info
FROM [dbo].[pub_info]
GO


-- INNER JOIN 2 Tables
-- Información sobre Empleados
-- ID Empleado Nombre Apellidos			Descripción del Trabajo
-- PMA42628M	    Paolo	Accorti	      Sales Representative

SELECT E.emp_id [Codigo Empleado],E.fname as Nombre ,E.lname as Apellidos,
			T.job_desc as 'Descripción Trabajo'
FROM [dbo].[Trabajo] T INNER JOIN [dbo].[Empleado] E
ON T.[job_id] = E.[job_id]
GO

-- INNER JOIN 3 Tables
-- Nombre Apellidos Empleado  Descripción Trabajo  Editorial donde trabaja y Ciudad de la Editorial
SELECT E.fname,E.lname,T.job_desc,P.pub_name,P.city
FROM [dbo].[Trabajo] T JOIN [dbo].[Empleado] E 
ON T.[job_id] = E.[job_id] 
INNER Join [dbo].[publishers] P
ON  E.pub_id = P.pub_id
GO
-- Variante con WHERE
SELECT E.fname,E.lname,T.job_desc,P.pub_name,P.city,P.pub_id
FROM [dbo].[Trabajo] T INNER JOIN [dbo].[Empleado] E 
ON T.[job_id] = E.[job_id] 
INNER Join [dbo].[publishers] P
ON  E.pub_id = P.pub_id
WHERE P.city LIKE 'W%'
GO
-- INNER JOIN 4 Tables
-- Nombre Apellidos Empleado  Descripción Trabajo  Editorial donde trabaja y Ciudad de la Editorial
-- Comentarios sobre Editorial

SELECT E.fname,E.lname,T.job_desc,P.pub_name,P.city,P.pub_id,PU.pr_info
FROM [dbo].[Trabajo] T INNER JOIN [dbo].[Empleado] E 
ON T.[job_id] = E.[job_id] 
INNER Join [dbo].[publishers] P
ON  E.pub_id = P.pub_id
INNER Join [dbo].pub_info PU
ON  P.pub_id = PU.pub_id
--WHERE P.city LIKE 'W%'
GO



-- CROSS JOIN Producto Cartesiano
SELECT COUNT(*) FROM Trabajo
SELECT COUNT(*) FROM Empleado

-- 14 x 43 = 602

SELECT  *
FROM [dbo].[Trabajo] T CROSS JOIN [dbo].[Empleado] E
GO
-- (602 row(s) affected)
-- Formato antiguo
SELECT  *
FROM [dbo].[Trabajo] T,[dbo].[Empleado] E
GO

SELECT  *
FROM [dbo].[Empleado] E,[dbo].[Trabajo] T
GO

-- LEFT OUTER JOIN
SELECT T.job_id,T.job_desc,T.job_id,E.fname,E.lname
FROM [dbo].[Trabajo] T LEFT OUTER JOIN [dbo].[Empleado] E
ON T.[job_id] = E.[job_id]
GO

--job_id job_desc                                           job_id fname                lname
-------- -------------------------------------------------- ------ -------------------- ------------------------------
--1      New Hire - Job not specified                       1      NULL                 NULL
--2      Chief Executive Officer                            2      Philip               Cramer
--3      Business Operations Manager                        3      Ann                  Devon

-- Try Out

INSERT INTO [dbo].[Trabajo]
           ([job_desc],[min_lvl],[max_lvl])
     VALUES ('DBA',13,33)
GO
SELECT T.job_id,T.job_desc,E.fname,E.lname
FROM [dbo].[Trabajo] T LEFT OUTER JOIN [dbo].[Empleado] E
ON T.[job_id] = E.[job_id]
ORDER By E.fname
GO


SELECT T.job_id,T.job_desc,E.fname,E.lname
FROM [dbo].[Trabajo] T RIGHT OUTER JOIN [dbo].[Empleado] E
ON T.[job_id] = E.[job_id]
ORDER By E.fname
GO
INSERT INTO [dbo].[Empleado]
           ([emp_id],[fname],[minit],[lname],[job_id],[job_lvl],[pub_id],[hire_date])
     VALUES
           ('AAAAA','Ana','A','Arias',99,99,'9999',GETDATE())
GO
SELECT T.job_id,T.job_desc,E.fname,E.lname
FROM [dbo].[Trabajo] T RIGHT OUTER JOIN [dbo].[Empleado] E
ON T.[job_id] = E.[job_id]
ORDER By E.fname
GO

-- FULL OUTER JOIN
SELECT T.job_id,T.job_desc,E.fname,E.lname
FROM [dbo].[Trabajo] T FULL  JOIN [dbo].[Empleado] E
ON T.[job_id] = E.[job_id]
ORDER By E.fname
GO

--------------------------------------------
-- RIGHT OUTER JOIN
USE multitabla
GO
SELECT * FROM Frutas
SELECT * FROM Productos
GO
SELECT p.Nombre [Nombre Productos], f.Precio [Precio Frutas], p.Precio [Precio Productos]
FROM Frutas f RIGHT JOIN Productos p
ON f.Nombre = p.Nombre
GO


SELECT p.Nombre [Nombre Productos], f.Precio [Precio Frutas], p.Precio [Precio Productos]
FROM Frutas f RIGHT JOIN Productos p
ON f.Nombre = p.Nombre
ORDER BY p.Nombre
GO

--Nombre Productos	Precio Frutas	Precio Productos
--Leche	NULL	2,40
--Miel	NULL	4,99
--Manzanas	6,00	3,99
--Pan	NULL	2,45
--Uvas	4,00	4,00


-- FULL OUTER JOIN

SELECT f.Nombre, p.Nombre,f.Precio [Precio Frutas], p.Precio [Precio Productos]
FROM Frutas f FULL  OUTER JOIN Productos p
ON f.Nombre = p.Nombre
GO

--Nombre	Nombre	Precio Frutas	Precio Productos
--Manzanas	Manzanas	6,00	3,99
--Uvas	Uvas	4,00	4,00
--Bananas	NULL	4,95	NULL
--Mandarinas	NULL	3,95	NULL
--Naranjas	NULL	2,50	NULL
--NULL	Leche	NULL	2,40
--NULL	Miel	NULL	4,99
--NULL	Pan	NULL	2,45



-- CROSS JOIN    Producto Cartesiano

SELECT * 
FROM Frutas  f CROSS JOIN Productos
ORDER BY f.Nombre,f.Precio DESC
GO

SELECT * 
FROM Frutas, Productos
GO

--Nombre	Precio	Nombre	Precio
--Bananas	4,95	Leche	2,40
--Bananas	4,95	Miel	4,99
--Bananas	4,95	Manzanas	3,99
--Bananas	4,95	Pan	2,45
--Bananas	4,95	Uvas	4,00
--Mandarinas	3,95	Leche	2,40
--Mandarinas	3,95	Miel	4,99
--Mandarinas	3,95	Manzanas	3,99
--Mandarinas	3,95	Pan	2,45
--Mandarinas	3,95	Uvas	4,00
--Manzanas	6,00	Leche	2,40
--Manzanas	6,00	Miel	4,99
--Manzanas	6,00	Manzanas	3,99
--Manzanas	6,00	Pan	2,45
--Manzanas	6,00	Uvas	4,00
--Naranjas	2,50	Leche	2,40
--Naranjas	2,50	Miel	4,99
--Naranjas	2,50	Manzanas	3,99
--Naranjas	2,50	Pan	2,45
--Naranjas	2,50	Uvas	4,00
--Uvas	4,00	Leche	2,40
--Uvas	4,00	Miel	4,99
--Uvas	4,00	Manzanas	3,99
--Uvas	4,00	Pan	2,45
--Uvas	4,00	Uvas	4,00


SELECT * 
FROM Frutas f, Productos
ORDER BY f.Nombre,f.Precio DESC
GO

-------------------------------------------
-- Subqueries   Subconsultas
-- Correlacionadas (Misma Tabla en Consulta Interna y Externa) - No Correlacionadas

-- Operador de Comparación - Operador de Comparación+ ANY or SOME (Aguno) / ALL (Todos)
-- IN - EXISTS


-- Operador de Comparación (Comparison)
DROP DATABASE  IF EXISTS multiTabla
GO
CREATE DATABASE  multiTabla
GO
USE multiTabla
GO

CREATE TABLE Productos (
	Nombre NVARCHAR(20),
	Precio SMALLMONEY );

CREATE TABLE Frutas (
	Nombre NVARCHAR(20),
	Precio SMALLMONEY );
GO

INSERT Productos
	VALUES	('Leche', 2.4),
			('Miel', 4.99),
			('Manzanas', 3.99),
			('Pan', 2.45),
			('Uvas', 4.00);
GO
INSERT Frutas
	VALUES	('Manzanas', 6.0),
			('Uvas', 4.00),
			('Bananas', 4.95),
			('Mandarinas', 3.95),
			('Naranjas', 2.50);
GO
SELECT Nombre
FROM Frutas
GO
SELECT Nombre
FROM Productos
GO

-- Subconsulta que devuelve Error

SELECT Nombre,Precio
FROM Productos
WHERE Nombre = (SELECT Nombre
								FROM Frutas)
GO

-- Error devuelve más de un valor
--Msg 512, Level 16, State 1, Line 1
--Subquery returned more than 1 value. This is not permitted when the 
-- subquery 
-- follows =, !=, <, <= , >, >= or when the subquery is used as an expression.


SELECT Nombre,Precio
FROM Productos
WHERE Nombre IN (SELECT Nombre
								FROM Frutas)
GO
-- Subconsulta con Operador de Comparación

-- Precio de Productos menores que el precio mayor de las frutas

SELECT Nombre,Precio
FROM Productos
WHERE Precio < (SELECT MAX(Precio)
				FROM Frutas)
GO

SELECT MAX(Precio)
FROM Frutas

-- 6

SELECT Nombre,Precio
FROM Productos
WHERE Precio < 6



SELECT Nombre,Precio
FROM Productos
Order by Precio
GO

--Nombre	Precio
--Leche	2,40
--Pan	2,45
--Manzanas	3,99
--Uvas	4,00
--Miel	4,99


SELECT Nombre,Precio
FROM Productos
WHERE Precio < (SELECT MIN(Precio)
				FROM Frutas
							)
GO

--Nombre	Precio
--Leche	2,40
--Pan	2,45

SELECT Nombre,Precio
FROM Productos
WHERE Precio < (SELECT AVG(Precio)
				FROM Frutas
							)
GO

--Nombre	Precio
--Leche	2,40
--Manzanas	3,99
--Pan	2,45
--Uvas	4,00


-- IN

-- Nombre y Precio de los Articulos comunes en ambas tablas

SELECT Nombre,Precio
FROM Productos
WHERE Nombre IN (SELECT Nombre
							FROM Frutas)
GO

--Nombre	Precio
--Manzanas	3,99
--Uvas	4,00

SELECT Nombre,Precio
FROM Productos
WHERE Nombre IN ('Manzanas','Uvas')
GO
--Nombre	Precio
--Manzanas	3,99
--Uvas	4,00

---------------------------------
-- Example using INNER JOIN - SUBQUERY IN
USE Pubs
GO
-- Diagram authors 
SELECT * FROM authors 
-- 172-32-1176	White	Johnson	408 496-7223	10932 Bigge Rd.	Menlo Park	CA	94025	1
SELECT * FROM titleauthor
-- 172-32-1176	PS3333	1	100
SELECT * FROM titles
-- BU1032	The Busy Executive's Database Guide	business    	1389	19.99	5000.00	10	4095	An overview of available database systems with emphasis on common business applications. Illustrated.	1991-06-12 00:00:00.000
GO





/*
   Authors and their titles.   
   
  
      Remember, authors can write more than one book, so there are 
   three tables involved */

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

-- Abraham	Bennet	        The Busy Executive's Database Guide
-- Reginald	Blotchet-Halls	Fifty Years in Buckingham Palace Kitchens


/* DELETE an author's link (in titleauthor)  to their books */
DROP TABLE TitulosAutor
GO
SELECT *
INTO TitulosAutor
FROM titleauthor
GO
SELECT * FROM TitulosAutor order By au_id,title_id
GO
-- (25 row(s) affected)
-- au_lname = 'Dull'  au_fname='Ann'
-- Try Out 

SELECT *
FROM authors
WHERE au_lname = 'Dull' AND au_fname='Ann'
GO
SELECT authors.au_fname, authors.au_lname, titles.title,titleauthor.au_id
   FROM authors   INNER JOIN titleauthor
   ON authors.au_id = titleauthor.au_id
   INNER JOIN titles 
   ON titleauthor.title_id = titles.title_id
   WHERE au_lname = 'Dull' AND au_fname='Ann'
   -- ORDER BY authors.au_lname
GO
-- au_fname	au_lname	               title	                    au_id
-- Ann	      Dull	           Secrets of Silicon Valley	   427-17-2319

-- Without SP
DELETE TitulosAutor
WHERE TitulosAutor.au_id IN
           (SELECT au_id 
		    FROM authors
            WHERE au_lname = 'Dull' AND au_fname='Ann')
GO
-- (1 row(s) affected)

--au_id
--427-17-2319


SELECT authors.au_fname, authors.au_lname, titles.title
   FROM authors   LEFT JOIN TitulosAutor
   ON authors.au_id = TitulosAutor.au_id
   JOIN titles 
   ON TitulosAutor.title_id = titles.title_id
   ORDER BY authors.au_lname
GO
SELECT authors.au_fname, authors.au_lname, titles.title
   FROM authors   INNER JOIN TitulosAutor
   ON authors.au_id = TitulosAutor.au_id
   INNER JOIN titles 
   ON TitulosAutor.title_id = titles.title_id
   WHERE au_lname = 'Dull' AND au_fname='Ann'
   ORDER BY authors.au_lname
GO
 

-- With SP
IF OBJECT_ID('Borrar_Titulos_Autor','P') is not null 
	DROP PROCEDURE Borrar_Titulos_Autor
GO

CREATE PROC Borrar_Titulos_Autor
	@Apellidos Varchar(50),@Nombre Varchar(50)
AS
BEGIN
DELETE FROM TitulosAutor
WHERE TitulosAutor.au_id IN
           (SELECT au_id 
		    FROM authors
            WHERE au_lname = @Apellidos AND au_fname=@Nombre)
END
GO
EXECUTE Borrar_Titulos_Autor  @Apellidos='Dull', @Nombre= 'Ann'
GO
EXEC Borrar_Titulos_Autor  @Apellidos='Panteley', @Nombre= 'Sylvia'
GO
--------

-- Borrar Autores que tengan un Titulo con una determinada cadena (String)
IF OBJECT_ID ('Autor','U') is not null
		DROP TABLE Autor
GO
   /* Now get rid of the author */
SELECT *
INTO Autor
FROM Authors
GO
-- Just One
DELETE  autor
WHERE au_lname = 'Dull' AND au_fname='Anne';
GO

-- DELETE Authors whose title has the word The
-- First

SELECT autor.au_id,autor.au_lname,Autor.au_fname,titles.title
FROM autor   INNER JOIN titleauthor
ON autor.au_id = titleauthor.au_id
INNER JOIN titles 
ON titleauthor.title_id = titles.title_id 
WHERE titles.title LIKE '%the%' -- LIKE 'the%'
-- WHERE titles.title LIKE 'the%'
GO
--(7 row(s) affected)

--au_id	au_lname	au_fname	title
--213-46-8915	Green	Marjorie	The Busy Executive's Database Guide
--409-56-7008	Bennet	Abraham	The Busy Executive's Database Guide
--722-51-5454	DeFrance	Michel	The Gourmet Microwave
--807-91-6654	Panteley	Sylvia	Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean
--899-46-2035	Ringer	Anne	Is Anger the Enemy?
--899-46-2035	Ringer	Anne	The Gourmet Microwave
--998-72-3567	Ringer	Albert	Is Anger the Enemy?

--998-72-3567	Ringer	Albert
-- Hint
-- WHERE autor.au_id = ( SELECT autor.au_id
--Msg 512, Level 16, State 1, Line 695
--Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
--The statement has been terminated.

DELETE  autor
WHERE autor.au_id IN ( SELECT autor.au_id
				FROM autor INNER JOIN titleauthor
				ON autor.au_id = titleauthor.au_id
				INNER JOIN titles 
				ON titleauthor.title_id = titles.title_id
				WHERE titles.title LIKE '%the%')
GO
-- (6 row(s) affected)

--HINT:
-- Really only 6 Authors 
-- 899-46-2035	Ringer	Anne
-- 899-46-2035	Ringer	Anne
-- 998-72-3567	Ringer	Albert

-- Comprobar
SELECT autor.au_id,autor.au_lname
FROM autor   INNER JOIN titleauthor
ON autor.au_id = titleauthor.au_id
INNER JOIN titles 
ON titleauthor.title_id = titles.title_id
WHERE titles.title LIKE '%the%'
GO
-- (0 row(s) affected)

-- With SP
IF OBJECT_ID ('Autor','U') is not null
		DROP TABLE Autor
GO
SELECT *
INTO Autor
FROM Authors
GO
SELECT COUNT(*) FROM autor
GO
-- 23
IF OBJECT_ID('BorrarAutores','P') is not null
	DROP PROCEDURE BorrarAutores
go
CREATE PROC BorrarAutores
 -- @texto varchar(50) = '%the%' -- Default Value
 @texto varchar(50) 
AS
BEGIN
DELETE  autor
WHERE autor.au_id IN ( SELECT autor.au_id
				FROM autor INNER JOIN titleauthor
				ON autor.au_id = titleauthor.au_id
				INNER JOIN titles 
				ON titleauthor.title_id = titles.title_id
				WHERE titles.title LIKE @texto)
END
GO
ALTER PROC BorrarAutores
 @texto varchar(50) = '%the%' -- Default Value
AS
BEGIN
DELETE  autor
WHERE autor.au_id IN ( SELECT autor.au_id
				FROM autor INNER JOIN titleauthor
				ON autor.au_id = titleauthor.au_id
				INNER JOIN titles 
				ON titleauthor.title_id = titles.title_id
				WHERE titles.title LIKE @texto)
END
GO
-- Default THE
EXEC BorrarAutores
GO
-- (6 row(s) affected)
SELECT autor.au_id
FROM autor INNER JOIN titleauthor
ON autor.au_id = titleauthor.au_id
INNER JOIN titles 
ON titleauthor.title_id = titles.title_id
WHERE titles.title LIKE '%Busy%'
GO
-- (2 row(s) affected)

--au_id
--213-46-8915
--409-56-7008
EXEC BorrarAutores '%Busy%'
GO
-- (2 row(s) affected)
SELECT COUNT(*) FROM autor
GO
-- 21
-------------------
-- Borrando Links y Titulos

USE Pubs
GO
DROP TABLE TitulosAutor,Titulos,Autores
GO
SELECT *
INTO TitulosAutor
FROM titleauthor
GO
SELECT *
INTO Titulos
FROM titles
GO
SELECT *
INTO Autores
FROM authors
GO
-- With SP
IF OBJECT_ID('Borrar_Titulos_Autores','P') is not null 
	DROP PROCEDURE Borrar_Titulos_Autores
GO

CREATE PROC Borrar_Titulos_Autores
	@Apellidos Varchar(50),@Nombre Varchar(50)
AS
BEGIN
DECLARE @Titulos TABLE (title_id varchar(12))
DELETE FROM TitulosAutor
OUTPUT deleted.title_id
INTO @Titulos
WHERE TitulosAutor.au_id IN
           (SELECT au_id 
		    FROM Autores
            WHERE au_lname = @Apellidos AND au_fname=@Nombre)
DELETE Titulos
WHERE Titulos.title_id = (select title_id FROM @Titulos)
END
GO
SELECT authors.au_fname, authors.au_lname, titles.title
   FROM authors   INNER JOIN TitulosAutor
   ON authors.au_id = TitulosAutor.au_id
   INNER JOIN titles 
   ON TitulosAutor.title_id = titles.title_id
   WHERE au_lname = 'Dull' AND au_fname='Ann'
   ORDER BY authors.au_lname
GO
-- Ann	Dull	Secrets of Silicon Valley
EXECUTE Borrar_Titulos_Autores  @Apellidos='Dull', @Nombre= 'Ann'
GO
SELECT authors.au_fname, authors.au_lname, titles.title
   FROM authors   INNER JOIN TitulosAutor
   ON authors.au_id = TitulosAutor.au_id
   INNER JOIN titles 
   ON TitulosAutor.title_id = titles.title_id
   WHERE au_lname = 'Panteley' AND au_fname='Sylvia'
   ORDER BY authors.au_lname
GO
-- Sylvia	Panteley	Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean
EXEC Borrar_Titulos_Autores  @Apellidos='Panteley', @Nombre= 'Sylvia'
GO

---
--  EXISTS
-- Articulos que existan en las 2 tablas y cuyo precio sea superior en la Tabla Frutas

SELECT Nombre,Precio
FROM Productos P
WHERE  EXISTS (SELECT *
				FROM Frutas as F
				WHERE (F.Nombre = P.Nombre)
					AND  (F.Precio > P.Precio)	)
GO

--Nombre	Precio
--Manzanas	3,99

SELECT Nombre,Precio
FROM Productos P
WHERE  EXISTS (SELECT *
				FROM Frutas
				WHERE Nombre = P.Nombre
					AND  Precio <= P.Precio
							)
GO

--Nombre	Precio
--Uvas	4,00

-------------------------
-- Subqueries with Aliases

-- Many statements in which the subquery and the outer query refer to the same table can be stated as self-joins
--  (joining a table to itself). 


-- Find authors who live in the same city as, e.g., Livia Karsen :

USE pubs
GO
-- Oakland
SELECT au_lname, au_fname, city
FROM authors
WHERE city IN
   (SELECT city
   FROM authors
   WHERE au_fname = 'Livia'
      AND au_lname = 'Karsen')
GO
-- (5 row(s) affected)
-- Names of the publishers which have published business books.

-- SubQuery

SELECT pub_name 
FROM publishers
WHERE pub_id IN
   (SELECT pub_id
   FROM titles 
   WHERE type = 'business')
GO

--pub_name
--New Moon Books
--Algodata Infosystems

-- http://stackoverflow.com/questions/9999946/sql-server-use-columns-from-the-main-query-in-the-subquery

-- INNER JOIN

SELECT pub_name
FROM publishers p JOIN titles t
ON p.pub_id = t.pub_id
WHERE type = 'business'
GO
--pub_name
--Algodata Infosystems
--Algodata Infosystems
--New Moon Books
--Algodata Infosystems

SELECT DISTINCT pub_name
FROM publishers p JOIN titles t
ON p.pub_id = t.pub_id
WHERE type = 'business'
GO

--pub_name
--Algodata Infosystems
--New Moon Books

SELECT DISTINCT pub_name, t.title
FROM publishers p JOIN titles t
ON p.pub_id = t.pub_id
WHERE type = 'business'
GO

--pub_name						title
--Algodata Infosystems	Cooking with Computers: Surreptitious Balance Sheets
--Algodata Infosystems	Straight Talk About Computers
--Algodata Infosystems	The Busy Executive's Database Guide
--New Moon Books		You Can Combat Computer Stress!


-- EXISTS
-- Consulta Correlacionada (Tabla de la Consulta Externa participa 
-- en la Consulta Interna)
SELECT pub_name
FROM publishers
WHERE  EXISTS
   (SELECT *
   FROM titles
   WHERE pub_id = publishers.pub_id
      AND type = 'business')
GO

--pub_name
--New Moon Books
--Algodata Infosystems

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
WHERE NOT EXISTS
   (SELECT *
   FROM titles
   WHERE pub_id = publishers.pub_id
      AND type = 'business')
GO

--pub_name
--Binnet & Hardley
--Five Lakes Publishing
--Ramona Publishers
--GGG&G
--Scootney Books
--Lucerne Publishing


-- Here is another example of a query that can be formulated with either a subquery or a join. 

-- Finds the names of all second authors who live in California 
-- and who receive less than 30 percent of the royalties for a book.


-- au_id	       title_id	  au_ord	  royaltyper
-- 172-32-1176	   PS3333	     1	       100
-- 213-46-8915	   BU1032	     2	        40



SELECT au_lname, au_fname
FROM authors
WHERE state = 'CA'
   AND au_id IN
      (SELECT au_id
      FROM titleauthor
      WHERE royaltyper < 30
         AND au_ord = 2)
GO

-- MacFeather


-- Using a join, the same query is expressed like this:

SELECT au_lname, au_fname
FROM authors INNER JOIN titleauthor 
ON authors.au_id = titleauthor.au_id
WHERE state = 'CA'
   AND royaltyper < 30
   AND au_ord = 2
GO

-- MacFeather	Stearns


-- A join can always be expressed as a subquery. 
-- A subquery can often, but not always, be expressed as a join. 
-- This is because joins are symmetric: you can join table A to B in either order and get the same answer.
-- The same is not true if a subquery is involved.

-- For example, if you assume each publisher is located in only one city, and you want 
-- to find the names of authors who live in the city in which Algodata Infosystems is located,
--  you can write a statement with a subquery introduced with the simple = comparison operator.

SELECT au_lname, au_fname
FROM authors
WHERE city =
   (SELECT city
   FROM publishers
   WHERE pub_name = 'Algodata Infosystems')
GO


--au_lname	au_fname
--Carson	Cheryl
--Bennet	Abraham


-- Finds the names of all books priced higher than 
-- the current minimum price.

SELECT DISTINCT title
FROM titles
WHERE price >
   (SELECT MIN(price)
   FROM titles)
Go

-- Because subqueries introduced with unmodified comparison operators must return a single value, 
-- they cannot include GROUP BY or HAVING clauses unless you know the GROUP BY or HAVING clause 
-- itself returns a single value. 
-- For example, this query finds the books priced higher than the lowest priced book that has 
-- a type 'trad_cook'.

SELECT DISTINCT title
FROM titles
WHERE price >
   (SELECT MIN(price)
   FROM titles
   GROUP BY type
   HAVING type = 'trad_cook')
GO

SELECT DISTINCT title,price
FROM titles
WHERE price >
   (SELECT AVG(price)
   FROM titles
   GROUP BY type)
   HAVING type = 'trad_cook')
GO
-- 15.9633

SELECT DISTINCT title,price
FROM titles
WHERE price >
   (SELECT AVG(price)
   FROM titles
   GROUP BY type)
 GO
-- Find authors who live in the same city as a publisher:


SELECT au_lname, au_fname,city
FROM authors
WHERE city = ANY
   (SELECT city
   FROM publishers)
GO

-- JOIN
SELECT au_lname, au_fname,p.city -- Referencia ambigua de city
FROM authors a JOIN publishers p
ON a.city = p.city
GO
--au_lname	au_fname
--Carson	Cheryl
--Bennet	Abraham

-- Or

SELECT au_lname, au_fname
FROM authors
WHERE exists
   (SELECT *
   FROM publishers
   WHERE authors.city = publishers.city)
GO

--au_lname	au_fname
--Carson	Cheryl
--Bennet	Abraham

-- Find titles of books published by any publisher located in a city that begins with the letter B:

SELECT title
FROM titles
WHERE pub_id IN
   (SELECT pub_id
   FROM publishers
   WHERE city LIKE 'B%')
GO
-- (11 row(s) affected)
-- Or

SELECT title
FROM titles
WHERE EXISTS
   (SELECT *
   FROM publishers
   WHERE pub_id = titles.pub_id
      AND city LIKE 'B%')
GO
-- (11 row(s) affected)


--  Find the names of publishers who do not publish business books


SELECT pub_name
FROM publishers
WHERE NOT EXISTS
   (SELECT *
   FROM titles
   WHERE pub_id = publishers.pub_id
      AND type = 'business')
GO

-- This query finds the titles for which there have been no sales.
USE pubs
SELECT title
FROM titles
WHERE NOT EXISTS
   (SELECT title_id
   FROM sales
   WHERE title_id = titles.title_id)
GO

-- The intersection of authors and publishers over the city column is the set of cities in which 
-- both an author and a publisher are located.

SELECT DISTINCT city
FROM authors
WHERE EXISTS
   (SELECT *
   FROM publishers
   WHERE authors.city = publishers.city)
GO

-- Of course, this query could be written as a simple join.

SELECT DISTINCT authors.city
FROM authors INNER JOIN publishers
ON authors.city = publishers.city
GO

-- The difference between authors and publishers over the city column is the set of cities 
-- where an author lives but no publisher is located, that is, all the cities except Berkeley.

SELECT DISTINCT city
FROM authors
WHERE NOT EXISTS
   (SELECT *
   FROM publishers
   WHERE authors.city = publishers.city)
GO

-- (15 row(s) affected)

-- This query could also be written as:

SELECT DISTINCT city
FROM authors
WHERE city NOT IN
   (SELECT city 
   FROM publishers)
GO

-- (15 row(s) affected)

--Titulo de los libros cuyo precio sea superior a todos los precios de los libros de cocina (mod_cook) 
-- Sólo conocer contenido de la Tabla

Select title, price
	from titles;
go

select title, price
	from titles
	where price > all (select price
				from titles
				where type='mod_cook');
GO

--title																price
--But Is It User Friendly?											22.95
--Secrets of Silicon Valley											20.00
--Computer Phobic AND Non-Phobic Individuals: Behavior Variations	21.59
--Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean	0.95
-- Usando funciones de Agregado

						
select title, price
	from titles
	where price > (select MAX(price)
			from titles	
			where type='mod_cook');
GO

/*obtener los titulos de los libros que tuvieron un anticipo
inferior a los libros editados por 'new age books'
subconsulta correlacionada: datos tabla externa participan
en la consulta interna; no se puede ejecutar por separado*/
						
select title,advance
	from titles
	where advance < all (select advance
			from publishers, titles
			where titles.pub_id=publishers.pub_id
			and pub_name='Algodata Infosystems'
				and advance is not null)
GO

-- Obtenemos el mismo resultado utilizando la funcion agregada min

select title,advance
	from titles
	where advance < (select min(advance)
			from publishers, titles
			where titles.pub_id=publishers.pub_id
				and pub_name='Algodata Infosystems');
GO

-- Returns total year-to-date sales and the amounts due to each author and publisher. 
-- In the second example, the total revenue is calculated for each book.

SELECT ytd_sales AS Sales, 
   authors.au_fname + ' '+ authors.au_lname AS Author, 
   ToAuthor = (ytd_sales * royalty) / 100,
   ToPublisher = ytd_sales - (ytd_sales * royalty) / 100
FROM titles INNER JOIN titleauthor
   ON titles.title_id = titleauthor.title_id 
   INNER JOIN authors
   ON titleauthor.au_id = authors.au_id
ORDER BY Sales DESC, Author ASC
GO

-- Calculates the revenue for each book:

SELECT 'Total income is', price * ytd_sales AS Revenue,'for', title_id AS Book#, title AS [Titulo libro]
FROM titles 
ORDER BY Book# ASC
GO

-- Use correlated subqueries

-- This example shows queries that are semantically equivalent and illustrates the difference between using the EXISTS keyword and the IN keyword. Both are examples of a valid subquery retrieving one instance of each publisher name for which the book title is a business book, and the publisher ID numbers match between the titles and publishers tables.

SELECT DISTINCT pub_name
FROM publishers
WHERE EXISTS
   (SELECT *
   FROM titles
   WHERE pub_id = publishers.pub_id
   AND type = 'business')
GO

--pub_name
--Algodata Infosystems
--New Moon Books

--or

SELECT distinct pub_name
FROM publishers
WHERE pub_id IN
   (SELECT pub_id
   FROM titles
   WHERE type = 'business')
GO


-- This example uses IN in a correlated (or repeating) subquery, which is a query that depends on the outer query for its values. It is executed repeatedly, once for each row that may be selected by the outer query. This query retrieves one instance of each author's first and last name for which the royalty percentage in the titleauthor table is 100 and for which the author identification numbers match in the authors and titleauthor tables.

SELECT DISTINCT au_lname, au_fname
FROM authors
WHERE 100 IN
   (SELECT royaltyper
   FROM titleauthor
   WHERE titleauthor.au_id = authors.au_id)
GO
-- The above subquery in this statement cannot be evaluated independently of the outer query. It needs a value for authors.au_id, but this value changes as Microsoft® SQL Server™ examines different rows in authors.

-- A correlated subquery can also be used in the HAVING clause of an outer query. This example finds the types of books for which the maximum advance is more than twice the average for the group.

SELECT t1.type
FROM titles t1
GROUP BY t1.type
HAVING MAX(t1.advance) >= ALL
   (SELECT 2 * AVG(t2.advance)
   FROM titles t2
   WHERE t1.type = t2.type)
GO
-- mod_cook    

-- This example uses two correlated subqueries to find the names of authors who have participated in writing at least one popular computing book.

SELECT au_lname, au_fname
FROM authors
WHERE au_id IN
   (SELECT au_id
   FROM titleauthor
   WHERE title_id IN
      (SELECT title_id
      FROM titles
      WHERE type = 'popular_comp'))
GO

-- (4 row(s) affected)

-- Finds the average price and the sum of year-to-date sales, grouped by type and publisher ID.

SELECT type, pub_id, AVG(price) AS 'avg', sum(ytd_sales) AS 'sum'
FROM titles
GROUP BY type, pub_id
ORDER BY type, pub_id
GO


------------------------------------

-- http://www.incanatoit.com/2015/01/sentencia-left-join-right-join-cross-join-sql-server-2014.html
-- https://www.youtube.com/watch?v=DGAyBXXM8wU&list=PLZPrWDz1MolrT1ID3CRIeR6jPLJ7Fp1x6&index=21
USE [DBRESERVA]
GO
--


-- http://oscarsotorrio.com/post/2010/09/11/Consultas-SQL-sobre-multiples-tablas.aspx

--Primeramente ejecutamos la base de datos.
use Northwind

--------------------------------------------------------------------------------------------------------------------
--CONSULTAS DE VARIAS TABLAS (Producto cartesiano de filas)--
--------------------------------------------------------------------------------------------------------------------

-- Si no se hacen coincir los valores de las columnas relacionadas se obtiene gran duplicidad de filas. Tantas como
-- el producto cartesiano de las filas de las tablas a las que se hace referencia. Ejemplo:

select * from dbo.Products, dbo.Orders

--------------------------------------------------------------------------------------------------------------------
--UTILIZAR ALIAS EN UNA TABLA--
--------------------------------------------------------------------------------------------------------------------

-- Cuando se relacionan varias tablas es normal que una misma columna forme parte de varias tablas. Para evitar 
-- errores de nombres duplicados podemos hacer dos cosas. Una es utilizar la sintaxis de nombre completo:
-- NombreTabla.NombreColumna.

select * from dbo.Products, dbo.Categories
where dbo.Products.CategoryID = dbo.Categories.CategoryID

-- La otra forma es dar un alias a cada tabla. Ejemplo:

select * from dbo.Products P, dbo.Categories C
where P.CategoryID = C.CategoryID

--------------------------------------------------------------------------------------------------------------------
--INSTRUCCIÓN JOIN ON(Coincidencia INTERNAS de columnas)--
--------------------------------------------------------------------------------------------------------------------

--NOTA: La instrucción INNER JOIN  es exactamente lo mismo que JOIN, dado que es el valor predeterminado.

--TEORÍA--

-- La instrucción JOIN nos permite combinar varias tablas haciendo coincidir los valores de las columas que nos 
-- interesen. Es decir, si tenemos dos tablas A y B que contienen una (o varias) columnas con el mismo nombre,
-- podemos relacionar ambas tablas por la columna del mismo nombre.

-- Por cada registro de la columna en la tabla A que también esté en la columna de la tabla B, obtendremos un
-- una relación. Lo que quiere decir que se produce un producto cartesiano de cada valor de la columna de la tabla A,
-- por todos los valores coincidentes de la columna en la tabla B.


--VOLVIENDO A LA BASE DE DATOS NORTHWIND--

-- 1. Por ejemplo, la tabla empleados nos facilita bastante información de los mismos. La más significativa es el
-- número de empleado, el nombre y la ciudad donde vive. Sin embargo, no nos dice nada de las ventas efectuadas por
-- cada empleado.

-- Si miramos la tabla de ventas veremos que además del número de ventas, tenemos información del empleado que
-- realizo estas ventas. Por lo tanto, por medio de la columna EmployeeID presente en las dos tablas podemos
-- relacionar los empleados con el número de venta. Ejemplo:

select OrderID, LastName, FirstName, City
from dbo.Orders O join dbo.Employees E
on  O.EmployeeID = E.EmployeeID
order by OrderID

-- De este modo podemos concluir que la columna que pertenece a una tabla A y otra B sirve de nexo para relacionar
-- los datos de otras columnas de la tabla A que no estan incluidos en la tabla B y viceversa.

--2. Otro caso es la tabla de productos que nos da mucha información sobre los mismos pero apenas nos dice nada de 
-- la categoría a la que pertenece cada producto. Mostremos una tabla productos personal que muestre la información
-- más interesante de los productos, más el nombre de la categoría y una descripción de esta.

select ProductID, ProductName, C.CategoryID, CategoryName, Description, UnitPrice, UnitsInStock
from dbo.Products P join dbo.Categories C
on P.CategoryID = C.CategoryID

--3. COMBINACIÓN DE TRES TABLAS. Si nos fijamos en las tablas de empleados y de clientes nos damos cuenta que no hay
-- forma de relacionar que empleado atendió (o vendió) a que cliente. Podemos hacerlo a través de la tabla de ventas
-- que tiene los números de empleados y de clientes. 

select E.EmployeeID, LastName, FirstName, OrderID, C.CustomerID, CompanyName, ContactName
from dbo.Orders O 
join dbo.Employees E on O.EmployeeID = E.EmployeeID 
join dbo.Customers C on O.CustomerID = C.CustomerID
order by EmployeeID

--4. Puede darse el caso en que solo interese esta información para los clientes de España.

select E.EmployeeID, LastName, FirstName, OrderID, C.CustomerID, CompanyName, ContactName
from dbo.Orders O 
join dbo.Employees E on O.EmployeeID = E.EmployeeID 
join dbo.Customers C on O.CustomerID = C.CustomerID
where C.Country = 'Spain'
order by EmployeeID

--5. La instrucción JOIN también podemos utilizarla para sustituir a las subconsultas. La forma de hacerlo es dando
-- dos alias diferentes a una misma tabla. Ejemplo:
--	(Mostrar los empleados que son mayores que el empleado 5 (1955-03-04) ).

-- Técnica de subconsultas.
select EmployeeID, LastName, FirstName, BirthDate from dbo.Employees
where BirthDate > (select BirthDate from dbo.Employees
					where EmployeeID = 5)

-- Instrucción JOIN.
select E1.EmployeeID, E1.LastName, E1.FirstName, E1.BirthDate from dbo.Employees E1 join dbo.Employees E2
on E1.BirthDate > E2.BirthDate
where E2.EmployeeID = 5

--------------------------------------------------------------------------------------------------------------------
--INSTRUCCIÓN OUTER JOIN (Coincidencias EXTERNAS de columnas)--
--------------------------------------------------------------------------------------------------------------------

-- Puede darse el caso que nos interese mostrar todos los valores de una columna (todas las filas) aunque no tengan 
-- correspondencia en la otra tabla. Así podemos tener 3 casos:

--1.Mostrar todos los valores de la tabla IZQ (LEFT), con NULL para la tabla DCH cuando no hay correspondencia
select ProductID, ProductName, C.CategoryID, CategoryName, C.Description, UnitPrice, UnitsInStock
from dbo.Products P left outer join dbo.Categories C
on P.CategoryID = C.CategoryID

--2.Mostrar todos los valores de la tabla DCH (RIGHT), con NULL para la tabla IZQ cuando no hay correspondencia.
select ProductID, ProductName, C.CategoryID, CategoryName, C.Description, UnitPrice, UnitsInStock
from dbo.Products P right outer join dbo.Categories C
on P.CategoryID = C.CategoryID

--3.Mostrar todos los valores de ambas tablas (FULL) con NULL cuando no hay correspondencia.
select ProductID, ProductName, C.CategoryID, CategoryName, C.Description, UnitPrice, UnitsInStock
from dbo.Products P full outer join dbo.Categories C
on P.CategoryID = C.CategoryID

--NOTA: La sentencia OUTER es opcional. Al incluir las sentencias LEFT, RIGHT Y FULL el sistema sabe que es una
--		consulta de combinación externa. Ejemplo anterior:

select ProductID, ProductName, C.CategoryID, CategoryName, C.Description, UnitPrice, UnitsInStock
from dbo.Products P full join dbo.Categories C
on P.CategoryID = C.CategoryID

--------------------------------------------------------------------------------------------------------------------
-- INSTRUCCIÓN UNION (Unión de filas en distintas tablas)--
--------------------------------------------------------------------------------------------------------------------

--1. Unir (UNION) todas (ALL) las filas de dos columnas de tablas diferentes.
select City from dbo.Employees
union all
select City from dbo.Customers -- Devuelve la suma de todas las filas en ambas columnas.

--2. Unir (UNION) las filas de dos columnas de tablas diferentes sin repetir ningún valor.
select City from dbo.Employees
union
select City from dbo.Customers -- Devuelve la suma de todas las filas en ambas columnas pero con valores únicos.

--NOTA: Se debe cumplir que las columnas en ambas instruciones SELECT coincidan en el tipo de datos.

-------------------------------------------------------------------------------------------------------------------- 
-- INSTRUCCIÓNES EXCEPT Y INTERSECT (Diferencia e Intersección de conjuntos)--
--------------------------------------------------------------------------------------------------------------------

-- EXCEPT -- Devuelve los valores de la primera consulta que no se encuentran en la segunda.
select City from dbo.Employees
except
select City from dbo.Customers

-- INTERSECT -- Devueleve una intersección de todos los valores, es decir, solo los que se encuentran ambas columnas.
select City from dbo.Employees
intersect
select City from dbo.Customers


-------------------
-- JOIN con GROUP BY - Windows Function: OVER

--

USE Prueba
GO
CREATE TABLE Clientes (
	cliente_id int identity primary key, 
	nombre varchar(50)
)
GO

INSERT Clientes 
	VALUES ('Luis'),
					('Juan'),
					('Ana')
GO
CREATE TABLE Facturas (
	factura_id int identity (100,100) primary key, 
	cliente_id int,
	cantidad money
)
GO
INSERT Facturas
	VALUES (1, 3),
					(1, 6),
					(1, 2),
					(2,3),
					(3,7),
					(3,8)
GO


-- Obtener Codigo Cllente   Nombre Cliente Total Factura

-- GROUP BY

SELECT  C.cliente_id as CodigoCliente, c.nombre as NombreCliente, 
				SUM(F.cantidad) AS [TOTAL Factura]
FROM Clientes C JOIN Facturas F
ON C.cliente_id = F.cliente_id
GROUP BY C.cliente_id
GO

--CodigoCliente	 NombreCliente	TOTAL Factura
--1							Luis					11,00
--2							Juan					3,00
--3							Ana					15,00

-- OVER

SELECT DISTINCT C.cliente_id as CodigoCliente, c.nombre as NombreCliente, 
				SUM(F.cantidad)  	OVER ( PARTITION BY C.cliente_id) AS [TOTAL Factura]
FROM Clientes C JOIN Facturas F
ON C.cliente_id = F.cliente_id
GO

--CodigoCliente	NombreCliente	TOTAL Factura
--1	Luis	11,00
--2	Juan	3,00
--3	Ana	15,00
------------------

-- http://www.codeproject.com/Tips/57496/SQL-Group-by-With-Joins


-- Join               Derive Table (Tabla Derivada)

 USE Prueba
 GO
 create table Empleado(
	EmployeeID int identity primary key,
	EmployeeFirstName varchar(30),
	EmployeeLastName varchar(30),
	EmployeeContactNo int
)
GO
 Create table Ventas (
	SalesID int identity primary key,
	SalesEmployeeID int,
	SalesDate date,
	SalesTotal money
)
GO
INSERT Empleado
	VALUES ('Luis', 'Arias',11),
					('Pedro', 'Garcia',22),
					('Ana', 'Feranandez',33)
GO
INSERT Ventas
	VALUES (1,'9/2/2015',3),
					 (1,'9/3/2015',5),
					  (1,'10/2/2015',1),
					   (2,'9/2/2015',4),
					    (3,'9/2/2015',3),
						 (3,'9/3/2015',4)
		
GO

SELECT * from Empleado
GO
SELECT * from Ventas
GO

--  Total sales done by employee with employee name
--             Nombre		Apellido	Total Ventas


Select EmployeeFirstName,EmployeeLastName,sum(SalesTotal) as [Total Ventas]
from Empleado  inner join Ventas
 on EmployeeID= SalesEmployeeID
group by EmployeeID,EmployeeFirstName,EmployeeLastName
GO

--EmployeeFirstName	EmployeeLastName	Total Ventas
--Luis	Arias	9,00
--Pedro	Garcia	4,00
--Ana	Feranandez	7,00


-- But there is one problem in the above Query. I have to add two more extra fields 
-- Añado SalesEmployeeID
Select SalesEmployeeID, EmployeeFirstName,EmployeeLastName,sum(SalesTotal) as [Total Ventas]
from Empleado  inner join Ventas
 on EmployeeID= SalesEmployeeID
group by EmployeeID,EmployeeFirstName,EmployeeLastName 
GO

--Mens. 8120, Nivel 16, Estado 1, Línea 1
--La columna 'Ventas.SalesEmployeeID' de la lista de selección no es válida, porque no está contenida en una función de agregado ni en la cláusula GROUP BY.


-- So the solution for this is to use derive table (Tablas Derivadas) which makes sense logically and clears query

Select EmployeeID,EmployeeFirstName,EmployeeLastName,TotalSales,
									 SalesEmployeeID
from Empleado inner join 
 (Select SalesEmployeeID,sum(SalesTotal) as TotalSales
    from  Ventas 
	group by SalesEmployeeID) empventas 
on empventas.SalesEmployeeID= EmployeeID
GO

--EmployeeID	EmployeeFirstName	EmployeeLastName	TotalSales
--1	Luis	Arias	9,00
--2	Pedro	Garcia	4,00
--3	Ana	Feranandez	7,00


--EmployeeID	EmployeeFirstName	EmployeeLastName	TotalSales	SalesEmployeeID
--1	Luis	Arias	9,00	1
--2	Pedro	Garcia	4,00	2
--3	Ana	Feranandez	7,00	3
-- --------------------------------
-- Recupera el número de empleados de cada City de la tabla Address combinada con la tabla 
-- EmployeeAddress de la base de datos AdventureWorks2014

USE AdventureWorks2014
GO
SELECT a.City, COUNT(bea.AddressID) EmployeeCount
FROM Person.BusinessEntityAddress AS bea 
    INNER JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
GROUP BY a.City
ORDER BY a.City;

------------------

-- http://www.codeproject.com/Tips/712941/Types-of-Join-in-SQL-Server

USE Prueba
GO
create table Employee(
 id int identity(1,1) primary key,
Username varchar(50),
FirstName varchar(50),
LastName varchar(50),
DepartID int
 )
 GO

 create table Departments(
 id int identity(1,1) primary key,
DepartmentName varchar(50)
 )
GO

select e1.Username,e1.FirstName,e1.LastName,e2.DepartmentName _
from Employee e1 inner join Departments e2 on e1.DepartID=e2.id

SELECT * FROM Employee e1 JOIN Departments e2 ON e1.DepartID = e2.id 

SELECT * FROM Employee e1 LEFT OUTER JOIN Departments e2
ON e1.DepartID = e2.id

SELECT * FROM Employee e1 RIGHT OUTER JOIN Departments e2
ON e1.DepartID = e2.id

SELECT * FROM Employee e1 FULL OUTER JOIN Departments e2
ON e1.DepartID = e2.id

SELECT * FROM Employee cross join Departments e2 

SELECT e1.Username,e1.FirstName,e1.LastName from Employee e1 _
inner join Employee e2 on e1.id=e2.DepartID

Here, I have taken one example of self join in this scenario where manager name can be retrieved by managerid with reference of employee id from one table.

select e1.empName as ManagerName,e2.empName as EmpName _
from employees e1 inner join employees e2 on e1.id=e2.managerid

 --------------

CREATE DATABASE Combinar
go
Use Combinar

/****** Object:  Table [dbo].[tblCustomer]    Script Date: 21 Marzo 2013 Ejemplo JOIN ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblCustomer](
	[CustID] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[Address] [varchar](200) NULL,
	[ContactNo] [varchar](20) NULL,
 CONSTRAINT [PK_tblCustomer] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[tblCustomer] ([CustID], [Name], [Address], [ContactNo]) VALUES (1, N'Sam', N'New Delhi', N'9555555555')
INSERT [dbo].[tblCustomer] ([CustID], [Name], [Address], [ContactNo]) VALUES (2, N'Rahul', N'Gurgaon', N'9666666666')
INSERT [dbo].[tblCustomer] ([CustID], [Name], [Address], [ContactNo]) VALUES (3, N'Hans', N'Noida', N'9444444444')
INSERT [dbo].[tblCustomer] ([CustID], [Name], [Address], [ContactNo]) VALUES (4, N'Jeetu', N'Delhi', N'9333333333')
INSERT [dbo].[tblCustomer] ([CustID], [Name], [Address], [ContactNo]) VALUES (5, N'Ankit', N'Noida', N'9222222222')
/****** Object:  Table [dbo].[tblProduct]    Script Date: 10/18/2012 23:45:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblProduct](
	[ProductID] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[UnitPrice] [float] NULL,
	[CatID] [int] NULL,
	[EntryDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (1, N'Dell Computer', 25000, 1, CAST(0x0000A0EC017C6D51 AS DateTime), CAST(0x0000A0EC017C6D51 AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (2, N'HCL Computer', 20000, 1, CAST(0x0000A0EC017C9DE1 AS DateTime), CAST(0x0000A0EC017C9DE1 AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (3, N'Apple Mobile', 40000, 3, CAST(0x0000A0EC017CBA59 AS DateTime), CAST(0x0000A0EC017CBA59 AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (4, N'Samsung Mobile', 25000, 3, CAST(0x0000A0EC017CCECA AS DateTime), CAST(0x0000A0EC017CCECA AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (5, N'Sony Laptop', 35000, 2, CAST(0x0000A0EC017CEA3B AS DateTime), CAST(0x0000A0EC017CEA3B AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (6, N'Dell Laptop', 36000, 2, CAST(0x0000A0EC017CFC16 AS DateTime), CAST(0x0000A0EC017CFC16 AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (7, N'HP Printer', 12000, 4, CAST(0x0000A0EC017D1C77 AS DateTime), CAST(0x0000A0EC017D1C77 AS DateTime))
INSERT [dbo].[tblProduct] ([ProductID], [Name], [UnitPrice], [CatID], [EntryDate], [ExpiryDate]) VALUES (8, N'Canon Printer', 10000, 4, CAST(0x0000A0EC017D32F8 AS DateTime), CAST(0x0000A0EC017D32F8 AS DateTime))
/****** Object:  Table [dbo].[tblOrder]    Script Date: 10/18/2012 23:45:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblOrder](
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NULL,
	[Price] [float] NULL,
	[CustomerID] [int] NULL,
	[ContactNo] [varchar](20) NULL,
 CONSTRAINT [PK_tblOrder] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (1, 1, 6, 150000, 1, N'9555555555')
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (2, 2, 4, 80000, 2, NULL)
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (3, 2, 2, 40000, 3, N'9444444444')
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (4, 3, 5, 200000, 4, N'9333333333')
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (5, 5, 1, 35000, 5, N'9666666666')

-- Añadir
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (1, 2, 13, 150000, 1, N'9555555555')
INSERT [dbo].[tblOrder] ([OrderID], [ProductID], [Quantity], [Price], [CustomerID], [ContactNo]) VALUES (1, 3, 13, 150000, 1, N'9555555555')



/****** Object:  Default [DF_Product_EntryDate]    Script Date: 10/18/2012 23:45:47 ******/
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Product_EntryDate]  DEFAULT (getdate()) FOR [EntryDate]
GO
/****** Object:  Default [DF_Product_ExpiryDate]    Script Date: 10/18/2012 23:45:47 ******/
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Product_ExpiryDate]  DEFAULT (getdate()) FOR [ExpiryDate]
GO
/****** Object:  ForeignKey [FK_tblOrder_tblCustomer]    Script Date: 10/18/2012 23:45:47 ******/
ALTER TABLE [dbo].[tblOrder]  WITH CHECK ADD  CONSTRAINT [FK_tblOrder_tblCustomer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[tblCustomer] ([CustID])
GO
ALTER TABLE [dbo].[tblOrder] CHECK CONSTRAINT [FK_tblOrder_tblCustomer]
GO
/****** Object:  ForeignKey [FK_tblProduct_tblCategory]    Script Date: 10/18/2012 23:45:47 ******/
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblCategory] FOREIGN KEY([CatID])
REFERENCES [dbo].[tblCategory] ([CatID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblCategory]
GO

--Select data

SELECT * FROM tblCustomer
SELECT * FROM tblProduct
SELECT * FROM tblOrder
------------------

--Inner Join 
SELECT  t1.OrderID,  t0.ProductID,  t0.Name,  t0.UnitPrice,  t1.Quantity,  t1.Price
FROM  tblProduct AS  t0
INNER JOIN  tblOrder AS  t1 
ON  t0.ProductID =  t1.ProductID
ORDER BY  t1.OrderID


--Inner Join 

SELECT  t1.OrderID, SUM (t1.Quantity) as Cantidad, SUM( t1.Price) as Precio,t0.Name
FROM  tblProduct AS  t0
INNER JOIN  tblOrder AS  t1 
ON  t0.ProductID =  t1.ProductID
GROUP BY  t1.OrderID, t0.Name
ORDER BY  t1.OrderID
GO


SELECT  t1.OrderID, SUM (t1.Quantity) as Cantidad, SUM( t1.Price) as Precio,t0.Name
FROM  tblProduct AS  t0
INNER JOIN  tblOrder AS  t1 
ON  t0.ProductID =  t1.ProductID
ORDER BY  t1.OrderID
GO
--Inner Join among more than two tables

SELECT  t1.OrderID,  t0.ProductID,  t0.Name as Producto,  t0.UnitPrice PrecioProducto,  t1.Quantity,  t1.Price, t2.CustID as IdCliente, t2.Name AS  Cliente
FROM  tblProduct AS  t0
INNER JOIN  tblOrder AS  t1 ON  t0.ProductID =  t1.ProductID
INNER JOIN  tblCustomer AS  t2 ON  t1.CustomerID =  t2.CustID
ORDER BY  t1.OrderID
GO




--Inner join on multiple conditions

SELECT  t1.OrderID,  t0.ProductID,  t0.Name,  t0.UnitPrice,  t1.Quantity,  t1.Price,  t2.Name AS  Customer
FROM  tblProduct AS  t0
INNER JOIN  tblOrder AS  t1 ON  t0.ProductID =  t1.ProductID
INNER JOIN  tblCustomer AS  t2 ON t1.CustomerID = t2.CustID --AND t1.ContactNo =  t2.ContactNo
ORDER BY  t1.OrderID


--OrderID	ProductID	Name	UnitPrice	Quantity	Price	Customer
--1	1	Dell Computer	25000	6	150000	Sam
--2	2	HCL Computer	20000	4	80000	Rahul
--3	2	HCL Computer	20000	2	40000	Hans
--4	3	Apple Mobile	40000	5	200000	Jeetu
--5	5	Sony Laptop	35000	1	35000	Ankit

SELECT  t1.OrderID,  t0.ProductID,  t0.Name,  t0.UnitPrice,  t1.Quantity,  t1.Price,  t2.Name AS  Customer
FROM  tblProduct AS  t0
INNER JOIN  tblOrder AS  t1 ON  t0.ProductID =  t1.ProductID
INNER JOIN  tblCustomer AS  t2 ON t1.CustomerID = t2.CustID AND t1.ContactNo =  t2.ContactNo
ORDER BY  t1.OrderID




--Left Outer Join

SELECT  t1.OrderID  AS  OrderID ,  t0.ProductID ,  t0.Name ,  t0.UnitPrice ,  t1.Quantity  AS  Quantity ,  t1.Price  AS  Price 
FROM  tblProduct  AS  t0 
LEFT OUTER JOIN  tblOrder  AS  t1  ON  t0.ProductID  =  t1.ProductID 
--ORDER BY  t0.ProductID 

SELECT    t0.ProductID ,  t0.Name ,  t0.UnitPrice , t1.OrderID  AS  OrderID , t1.Quantity  AS  Cantidad ,  t1.Price  AS  Precio
FROM  tblProduct  AS  t0 
LEFT OUTER JOIN  tblOrder  AS  t1  ON  t0.ProductID  =  t1.ProductID 
--ORDER BY  t0.ProductID 

--ProductID	Name	UnitPrice	OrderID	Cantidad	Precio
--1	Dell Computer	25000	1	6	150000
--2	HCL Computer	20000	2	4	80000
--2	HCL Computer	20000	3	2	40000
--3	Apple Mobile	40000	4	5	200000
--4	Samsung Mobile	25000	NULL	NULL	NULL
--5	Sony Laptop	35000	5	1	35000
--6	Dell Laptop	36000	NULL	NULL	NULL
--7	HP Printer	12000	NULL	NULL	NULL
--8	Canon Printer	10000	NULL	NULL	NULL
--OrderID	ProductID	Name	UnitPrice	Quantity	Price
--1	1	Dell Computer	25000	6	150000
--2	2	HCL Computer	20000	4	80000
--3	2	HCL Computer	20000	2	40000
--4	3	Apple Mobile	40000	5	200000
--NULL	4	Samsung Mobile	25000	NULL	NULL
--5	5	Sony Laptop	35000	1	35000
--NULL	6	Dell Laptop	36000	NULL	NULL
--NULL	7	HP Printer	12000	NULL	NULL
--NULL	8	Canon Printer	10000	NULL	NULL


--Right Outer Join

select * from tblOrder
go

--OrderID	ProductID	Quantity	Price	CustomerID	ContactNo
--1	1	6	150000	1	9555555555
--2	2	4	80000	2	NULL
--3	2	2	40000	3	9444444444
--4	3	5	200000	4	9333333333
--5	5	1	35000	5	9666666666

SELECT  t1.OrderID  AS  OrderID ,  t0.ProductID ,  t0.Name ,  t0.UnitPrice ,  t1.Quantity  AS  Quantity ,  t1.Price  AS  Price 
FROM  tblProduct  AS  t0 
RIGHT OUTER JOIN  tblOrder  AS  t1  ON  t0.ProductID  =  t1.ProductID 
ORDER BY  t0.ProductID 

--Full Outer Join

SELECT  t1.OrderID  AS  OrderID ,  t0.ProductID ,  t0.Name ,  t0.UnitPrice ,  t1.Quantity  AS  Quantity ,  t1.Price  AS  Price 
FROM  tblProduct  AS  t0 
FULL OUTER JOIN  tblOrder  AS  t1  ON  t0.ProductID  =  t1.ProductID 
ORDER BY  t0.ProductID 

--Cross Join

SELECT  t1.OrderID,  t0.ProductID,  t0.Name,  t0.UnitPrice,  t1.Quantity,  t1.Price
FROM  tblProduct AS  t0,  tblOrder AS  t1
ORDER BY  t0.ProductID

select count(*) from tblProduct
select count(*) from tblOrder
-- 8 5 
--(40 filas afectadas)



SELECT * FROM tblCustomer
SELECT * FROM tblProduct
SELECT * FROM tblOrder

DROP DATABASE Combinar

-----------------------------
-- Ejemplo Self Join (Autocombinación)
-- Sumas Acumuladas

USE Prueba
GO
CREATE TABLE [dbo].[testsum](
[name] [varchar](10) NULL,
[val] [int] NULL,
[ID] [int] NULL
) ON [PRIMARY]
GO
insert into [testsum] (id,name,val)
values(1,'A',10),
(2,'B',20),
(3,'C',30)
GO

SELECT * FROM  [testsum] 
GO

name	val	ID
A			10		1
B			20		2
C			30		3

Queremos obtener

Suma Acumulada
10
10 + 20 = 30
30 + 30 = 60

select t1.id, t1.val as Valor, SUM(t2.val) as SumaAcumulada
from testsum t1 inner join testsum t2 
on t1.id >= t2.id
group by t1.id, t1.val
order by t1.id
GO

id	Valor	SumaAcumulada
1	10				10
2	20				30
3	30				60

insert into [testsum] (id,name,val)
values(4,'d',13),
(5,'e',20),
(6,'f',33)
GO

select t1.id, t1.val as Valor, SUM(t2.val) as SumaAcumulada
from testsum t1 inner join testsum t2 
on t1.id >= t2.id
group by t1.id, t1.val
order by t1.id
GO

id	Valor	SumaAcumulada
1	10				10
2	20				30
3	30				60
4	13				73
5	20				93
6	33				126

---------------------------------

Use GestionSimples
go
SELECT	nombre
FROM	empleados
WHERE	cuota >=	(SELECT	SUM(importe) FROM	pedidos
					WHERE	rep	=	numemp)


-- (8 filas afectadas)


SELECT	nombre
FROM	empleados
WHERE	cuota <=	(SELECT	SUM(importe) FROM	pedidos
					WHERE	rep	=	numemp)

SELECT	rep,SUM(importe) 
FROM	pedidos
GROUP BY rep
ORDER BY rep
go

Select numemp,nombre,cuota
from empleados
order by nombre;
go

Select nombre,cuota,p.rep
from empleados e join pedidos p
on p.rep	=	e.numemp
order by nombre;
go

----
http://technet.microsoft.com/es-es/library/ms175838(v=sql.105).aspx

Por ejemplo, si supone que cada vendedor sólo cubre un territorio de ventas y desea 
localizar los clientes del territorio que cubre Linda Mitchell, puede escribir una 
instrucción con una subconsulta presentada con el operador de comparación 

USE [AdventureWorks2014]
GO
select [BusinessEntityID],[FirstName],[MiddleName],[LastName]
from [Person].[Contact]
WHERE BusinessEntityID = 276
go
Select * 
FROM Sales.SalesPerson s inner join [Person].[Contact] c
on s.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 276
go

-- Ejemplo Subconsulta

SELECT CustomerID
FROM Sales.Customer
WHERE TerritoryID =
    (SELECT TerritoryID
     FROM Sales.SalesPerson
     WHERE BusinessEntityID = 276)

--Sin embargo, si Linda Mitchell cubre más de un territorio de ventas, 
--se genera un mensaje de error. En lugar del operador de comparación =,
-- se podría usar una formulación IN (= ANY también funciona).

Las subconsultas presentadas con operadores de comparación sin modificar incluyen, a menudo, funciones de agregado, puesto que éstas devuelven un valor individual. 
Por ejemplo, la instrucción siguiente localiza los nombres de todos 
los productos cuya lista de precios es superior al precio medio de la lista.

Use AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE ListPrice >
    (SELECT AVG (ListPrice)
     FROM Production.Product)
go

--Puesto que las subconsultas presentadas con operadores de comparación sin modificar
-- deben devolver un valor individual, no pueden incluir cláusulas GROUP BY o HAVING,
--  a menos que sepa que las propias cláusulas devuelven un valor individual.

--  Por ejemplo, la siguiente consulta busca los productos con un precio superior al producto con el precio mínimo incluido en la subcategoría 14.

SELECT Name
FROM Production.Product
WHERE ListPrice >
    (SELECT MIN (ListPrice)
     FROM Production.Product
     GROUP BY ProductSubcategoryID
     HAVING ProductSubcategoryID = 14)

---------------------

IN

--El resultado de una subconsulta especificada con IN (o con NOT IN) es una lista de cero o más valores. Una vez que la consulta devuelve los resultados, la consulta externa hace uso de ellos.
--La siguiente consulta busca los nombres de todos los productos de ruedas que Adventure Works Cycles fabrica.

SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels');

-- La expresión se evalua en 2 pasos

SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels'


-- Esto devuelve 17


SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID IN ('17');

En la siguiente consulta se busca el nombre de todos los proveedores cuya solvencia de crédito sea buena, de los que Adventure Works Cycles solicita al menos 20 artículos y cuyo tiempo hasta la entrega es de menos de 16 días.

SELECT Name
FROM Purchasing.Vendor
WHERE CreditRating = 1
AND BusinessEntityID IN
    (SELECT BusinessEntityID
     FROM Purchasing.ProductVendor
     WHERE MinOrderQty >= 20
     AND AverageLeadTime < 16);

-- Lo mismo mediante una combinación

SELECT DISTINCT Name
FROM Purchasing.Vendor v
INNER JOIN Purchasing.ProductVendor p
ON v.BusinessEntityID = p.BusinessEntityID
WHERE CreditRating = 1
AND MinOrderQty >= 20
AND AverageLeadTime < 16;

-------------------

ANY

Los operadores de comparación que presentan una subconsulta se pueden modificar mediante las palabras clave ALL o ANY. SOME es un equivalente del estándar ISO de ANY.
Las subconsultas presentadas con un operador de comparación modificado devuelven una lista de cero o más valores y pueden incluir una cláusula GROUP BY o HAVING. Estas subconsultas se pueden formular con EXISTS.
Si se usa como ejemplo el operador de comparación >, >ALL significa mayor que cualquier valor. Es decir, significa mayor que el valor máximo. Por ejemplo, >ALL (1, 2, 3) significa mayor que 3. >ANY significa mayor que por lo menos un valor; es decir, mayor que el mínimo. Entonces, >ANY (1, 2, 3) significa mayor que 1.
Para que una fila de una subconsulta con >ALL satisfaga la condición especificada en la consulta externa, el valor de la columna que presenta la subconsulta debe ser mayor que cada valor de la lista de los valores devueltos por la subconsulta.
De forma parecida, >ANY significa que, para que una fila satisfaga la condición especificada en la consulta externa, el valor de la columna que presenta la subconsulta debe ser mayor que, como mínimo, uno de los valores de la lista devuelta por la subconsulta.

La siguiente consulta proporciona un ejemplo de una subconsulta presentada con un operador de comparación modificado por ANY. Busca los productos cuyos precios de venta sean mayores o iguales que el precio de venta máximo de cualquier subcategoría de producto.

SELECT Name
FROM Production.Product
WHERE ListPrice >= ANY
    (SELECT MAX (ListPrice)
     FROM Production.Product
     GROUP BY ProductSubcategoryID) ;

Para cada subcategoría de producto, la consulta interna busca el precio de venta máximo. La consulta externa consulta todos estos valores y determina los precios de venta de cada producto que sean mayores o iguales que cualquier precio de venta máximo de la subcategoría de producto. Si ANY se cambia a ALL, la consulta devolverá sólo los productos cuyos precios de venta sean mayores o iguales que todos los precios de venta devueltos en la consulta interna.
Si la subconsulta no devuelve ningún valor, la consulta completa no puede devolver ningún valor.
El operador =ANY es equivalente a IN. Por ejemplo, para buscar los nombres de todos los productos de ruedas que fabrica Adventure Works Cycles, puede usar IN o =ANY.


--Using =ANY
USE AdventureWorks2014
GO
SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID =ANY
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels') ;

--Using IN

GO
SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels') ;

---------------

EXISTS

Cuando una subconsulta se especifica con la palabra clave EXISTS, funciona como una prueba de existencia. La cláusula WHERE de la consulta externa comprueba si existen las filas devueltas por la subconsulta. En realidad, la subconsulta no produce ningún dato, devuelve el valor TRUE o FALSE.

SELECT Name
FROM Production.Product
WHERE EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND Name = 'Wheels')

--Observe que las subconsultas que se especifican con EXISTS son ligeramente distintas de las demás subconsultas en los aspectos siguientes:
--La palabra clave EXISTS no viene precedida de un nombre de columna, constante u otra expresión.
--La lista de selección de una subconsulta que se especifica con EXISTS casi siempre consta de un asterisco (*). No hay razón para enumerar los nombres de las columnas porque simplemente se está comprobando la existencia de filas que cumplan las condiciones especificadas en la subconsulta.
--La palabra clave EXISTS es importante, porque a menudo no hay una formulación alternativa sin subconsultas. Aunque algunas consultas creadas con EXISTS no se pueden expresar de otra forma, muchas consultas pueden usar IN o un operador de comparación modificado por ANY o ALL para lograr resultados similares.
--Por ejemplo, la consulta anterior se puede expresar con IN:

SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels')




------------------------------
-- Subquery in Column List

USE AdventureWorks2014
GO
-- Warning Fechas en español
--Mens. 242, Nivel 16, Estado 3, Línea 1
-- La conversión del tipo de datos varchar en datetime produjo un valor fuera de intervalo.

SELECT ROW_NUMBER() OVER (ORDER BY SalesOrderID) RowNumber
      , (SELECT COUNT(*) 
         FROM [Sales].[SalesOrderHeader] 
         WHERE ModifiedDate = '19-02-2007 00:00:00.000') 
                     AS TotalOrders
      , *
FROM [Sales].[SalesOrderHeader]
WHERE OrderDate = '19-02-2007 00:00:00.000';
GO

SELECT COUNT(*) 
         FROM [Sales].[SalesOrderHeader] 
         WHERE ModifiedDate = '19-02-2007 00:00:00.000'
Go
-- 10

-- Example of Subquery in WHERE Clause

SELECT * FROM [Sales].[SalesOrderDetail]
WHERE ProductID = (SELECT ProductID 
                   FROM [Production].[Product]
             	   WHERE Name = 'Long-Sleeve Logo Jersey, XL'); 
GO

-- Example Using a Subquery to Control the TOP Clause

SELECT TOP (SELECT TOP 1 OrderQty 
            FROM [Sales].[SalesOrderDetail]
            ORDER BY ModifiedDate) *  
FROM [Sales].[SalesOrderDetail]
WHERE ProductID = 716;
GO

--Example of Subquery in the HAVING Clause

SELECT count(*), OrderDate 
FROM [Sales].[SalesOrderHeader]
GROUP BY OrderDate
HAVING count(*) >
       (SELECT count(*) 
        FROM [Sales].[SalesOrderHeader]
        WHERE OrderDate = '2006-05-01 00:00:00.000');
Go

-- Example of using a Subquery in a Function Call

SELECT count(*), OrderDate 
FROM [Sales].[SalesOrderHeader]
GROUP BY OrderDate
HAVING count(*) >
       (SELECT count(*) 
        FROM [Sales].[SalesOrderHeader]
        WHERE OrderDate = '2006-05-01 00:00:00.000');
GO

-- Examples of Subqueries that Return Multiple Values

-- Example of Subquery in the FROM clause

SELECT SalesOrderID 
FROM (SELECT TOP 10 SalesOrderID 
      FROM [Sales].[SalesOrderDetail]
      WHERE ProductID = 716
      ORDER BY ModifiedDate DESC) AS Last10SalesOrders;
GO

-- Joining a Derived table with a real table

SELECT DISTINCT OrderDate
FROM (SELECT TOP 10 SalesOrderID 
      FROM [Sales].[SalesOrderDetail]
      WHERE ProductID = 716
      ORDER BY ModifiedDate DESC) AS Last10SalesOrders
JOIN [Sales].[SalesOrderHeader] AS SalesOrderHeader
ON Last10SalesOrders.SalesOrderID = SalesOrderHeader.SalesOrderID
ORDER BY OrderDate
GO

-- Passing values to the IN keyword using a subquery

SELECT * FROM [Sales].[SalesOrderDetail] 
WHERE ProductID IN 
        (SELECT ProductID 
         FROM [Production].[Product]
         WHERE Name like '%XL%');
GO

-- Example of using a Subquery in a Statement that Modifies Data

DECLARE @SQTable TABLE (
OrderID int,
OrderDate datetime,
TotalDue money,
MaxOrderDate datetime);

-- INSERT with SubQuery
INSERT INTO @SQTable 
   SELECT SalesOrderID,
          OrderDate, 
		  TotalDue, 
		  (SELECT MAX(OrderDate) 
		   FROM [Sales].[SalesOrderHeader]) 
   FROM [Sales].[SalesOrderHeader]
   WHERE CustomerID = 29614;

-- Display Records
SELECT * FROM @SQtable;
GO


-- Performance Considerations between Subqueries and JOIN

-- In Transact-SQL, there is usually no performance difference between a statement that includes a subquery and a semantically equivalent version that does not.”

-- To compare the performance of a query using subquery with an equivalent query that doesn’t use a subquery I’m going rewrite my subquery in Listing 3 to use a JOIN operation

SELECT SOD.* 
FROM [Sales].[SalesOrderDetail] AS SOD
INNER JOIN 
[Production].[Product] AS P
ON SOD.ProductID = P.ProductID
WHERE P.Name = 'Long-Sleeve Logo Jersey, XL';
Go
--
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Suquery
SELECT * FROM [Sales].[SalesOrderDetail]
WHERE ProductID = (SELECT ProductID 
                   FROM Production.Product
             	   WHERE Name = 'Long-Sleeve Logo Jersey, XL'); 

-- INNER JOIN
SELECT SOD.* 
FROM [Sales].[SalesOrderDetail] AS SOD
INNER JOIN 
[Production].[Product] AS P
ON SOD.ProductID = P.ProductID
WHERE P.Name = 'Long-Sleeve Logo Jersey, XL';
GO

--(1076 filas afectadas)
--Tabla 'SalesOrderDetail'. Recuento de exámenes 1, lecturas lógicas 3310, lecturas físicas 0, lecturas anticipadas 0, lecturas lógicas de LOB 0, lecturas físicas de LOB 0, lecturas anticipadas de LOB 0.
--Tabla 'Product'. Recuento de exámenes 0, lecturas lógicas 2, lecturas físicas 0, lecturas anticipadas 0, lecturas lógicas de LOB 0, lecturas físicas de LOB 0, lecturas anticipadas de LOB 0.

-- Tiempos de ejecución de SQL Server:
--   Tiempo de CPU = 31 ms, tiempo transcurrido = 231 ms.

--(1076 filas afectadas)
--Tabla 'SalesOrderDetail'. Recuento de exámenes 1, lecturas lógicas 3310, lecturas físicas 0, lecturas anticipadas 0, lecturas lógicas de LOB 0, lecturas físicas de LOB 0, lecturas anticipadas de LOB 0.
--Tabla 'Product'. Recuento de exámenes 0, lecturas lógicas 2, lecturas físicas 0, lecturas anticipadas 0, lecturas lógicas de LOB 0, lecturas físicas de LOB 0, lecturas anticipadas de LOB 0.

-- Tiempos de ejecución de SQL Server:
--   Tiempo de CPU = 0 ms, tiempo transcurrido = 307 ms.

-- After running the code in listing 12 I reviewed the messages produced by the “SET STATISTICS” statements. By reviewing the statistics I found that both queries had 3,309 logical reads against the SalesOrderDetail table, and 2 logical reads against the Product table, and each used 31 ms of CPU. Additionally I reviewed the execution plan that SQL Server created for both of these queries. I found that SQL Server produced the same execution plan for both. Hence using a subquery or a JOIN query for my situation produced equivalent performance, just as documented by Microsoft.


----------------------------

--Todos los productos que tengan un precio igual 
--al precio de un producto dado

-- primero obtengo el precio de un producto determinado
-- despues muestro una lista de todos los productos con ese
--precio

use AdventureWorks2014
go

update Production.Product
set ListPrice = 13
where ListPrice = 0
go

select name 
from Production.Product
where ListPrice = (select ListPrice 
			from Production.Product
			where Name = 'Chainring Bolts')

-- Consulta Externa sólo
select name 
from Production.Product
where ListPrice = 13
go
			
select name,listprice
			from Production.Product
			where Name = 'Chainring Bolts'
			
-- Join

select prd1.name 
from Production.Product as prd1 join Production.Product as prd2
	on prd1.ListPrice = prd2.ListPrice
	where prd2.Name = 'Chainring Bolts'

-- Nombre de los productos cuyo precio es menor que la media de los
-- productos de la tabla Product


select name, ListPrice
from Production.Product
where ListPrice > (select AVG (ListPrice)
					from Production.Product)	


select AVG (ListPrice)
					from Production.Product
					
-- ID Clientes que atiende la vendedora con el ID 276					
					
select customerID 
from Sales.Customer
where TerritoryID = (select TerritoryID
				from Sales.SalesPerson
				where SalesPersonID = 276)
	
-- solo la consulta interna	(consigue la zona donde trabaja la vendedora 276)			
select TerritoryID 
from Sales.SalesPerson
where SalesPersonID = 276

-- Saca los productos cuyo precio es más alto que el precio más bajo
-- de los productos de la subcategoria 14

select name 
from Production.Product
where ListPrice > (select min (ListPrice)
							from Production.Product
							group by ProductSubcategoryID
							having ProductSubcategoryID = 14)

--------------------------
/*http://msdn.microsoft.com/es-es/library/ms189259%28v=sql.105%29.aspx

Cuando una subconsulta se especifica con la palabra clave EXISTS, funciona como una prueba de existencia. La cláusula WHERE de la consulta externa comprueba si existen las filas devueltas por la subconsulta. En realidad, la subconsulta no produce ningún dato, devuelve el valor TRUE o FALSE.

Una subconsulta que se especifica con EXISTS tiene la sintaxis siguiente:

WHERE [NOT] EXISTS (subquery)

La consulta siguiente busca los nombres de todos los productos presentes en la subcategoría Wheels:
*/
USE AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND Name = 'Wheels');
        
select name
	from Production.Product
	where ProductSubcategoryID in (select ProductSubcategoryID
									from production.ProductSubcategory
									where name='wheels');
/*
El conjunto de resultados es el siguiente.

Name
--------------------------------------------------
LL Mountain Front Wheel
ML Mountain Front Wheel
HL Mountain Front Wheel
LL Road Front Wheel
ML Road Front Wheel
HL Road Front Wheel
Touring Front Wheel
LL Mountain Rear Wheel
ML Mountain Rear Wheel
HL Mountain Rear Wheel
LL Road Rear Wheel
ML Road Rear Wheel
HL Road Rear Wheel
Touring Rear Wheel

(14 row(s) affected)

Para comprender el resultado de esta consulta, considere el nombre de cada producto de uno en uno. ¿Este valor hace que la subconsulta devuelva como mínimo una fila? En otras palabras, ¿la consulta hace que la prueba de existencia se evalúe como TRUE?

Observe que las subconsultas que se especifican con EXISTS son ligeramente distintas de las demás subconsultas en los aspectos siguientes:

    La palabra clave EXISTS no viene precedida de un nombre de columna, constante u otra expresión.

    La lista de selección de una subconsulta que se especifica con EXISTS casi siempre consta de un asterisco (*). No hay razón para enumerar los nombres de las columnas porque simplemente se está comprobando la existencia de filas que cumplan las condiciones especificadas en la subconsulta. 

La palabra clave EXISTS es importante, porque a menudo no hay una formulación alternativa sin subconsultas. Aunque algunas consultas creadas con EXISTS no se pueden expresar de otra forma, muchas consultas pueden usar IN o un operador de comparación modificado por ANY o ALL para lograr resultados similares.

Por ejemplo, la consulta anterior se puede expresar con IN:
*/
USE AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels')
GO
/*
-----------

http://msdn.microsoft.com/es-es/library/ms188336%28v=sql.105%29.aspx

---------------

NOT EXISTS funciona igual que EXISTS, con la diferencia de que la cláusula WHERE en la que se utiliza se cumple si la subconsulta no devuelve ninguna fila.

Por ejemplo, para buscar los nombres de productos que no pertenecen a la subcategoría de ruedas:
*/
USE AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE NOT EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND Name = 'Wheels')

/*
------------------
http://www.simple-talk.com/sql/sql-training/subqueries-in-sql-server/

--------------------

*/

use GestionA;

select numemp,nombre,oficina	
	from empleados
	where not exists (select * 
						from oficinas 
						where dir = '108' and empleados.oficina=oficinas.oficina);
						
select *
	from empleados
	where exists (select *
					from pedidos
					where numemp =rep and fab = 'aci');

select productos.idfab, productos.idproducto, productos.descripcion
	from productos
	where not exists (select *
						from pedidos
						where pedidos.producto=productos.idproducto 
						and pedidos.importe > '10' );
						
select oficinas.oficina, oficinas.ciudad
	from oficinas
	where exists (select *
					from empleados
					where empleados.oficina=oficinas.oficina 
					and empleados.cuota > (.55*oficinas.objetivo));
					

select empleados.numemp, empleados.nombre, empleados.edad
	from empleados
	where not exists (select *
					from oficinas
					where oficinas.dir=empleados.numemp);


--------------------------
/*Todos los productos que tengan un precio igual al precio de un producto dado

primero obtengo el precio de un producto determinado despues muestro una lista de todos los productos con ese precio*/

use AdventureWorks2014;

select name 
	from production.Product
	where ListPrice=(select ListPrice
		from Production.Product
		where name='Chainring Bolts');

-- o lo que es lo mismo
select name
	from Production.Product
	where ListPrice=0;
	
select p1.Name
	from production.Product p1 join Production.Product p2
	on p1.ListPrice=p2.ListPrice
		where p2.name='Chainring Bolts';
--Nombre de los productos cuyo precio es menor que la media de los productos de la tabla product
select name,ListPrice
	from Production.Product
	where ListPrice <(select AVG(ListPrice)
		from production.Product);
	
select AVG(ListPrice)
		from production.Product;
		
--id clientes que atiende el comercial con el id 276
select customerid
	from sales.Customer
	where TerritoryID=(select TerritoryID
		from sales.SalesPerson
		where SalesPersonID=276);
	
--saca los productos cuyo precio es mas alto que el precio es mas bajo de los productos de la subcategoria 14

select name
	from production.Product
	where ListPrice > (select MIN(ListPrice)
						from Production.Product
						group by ProductSubcategoryID
						having ProductSubcategoryID=14);
--ejercicios aula click pagina 	257					
use GestionA;

select idfab,idproducto,descripcion,existencias
	from productos
	where idfab='aci' and 
	existencias > (select existencias
					from productos
					where idfab='aci' and idproducto = '41004');
					
select numemp,nombre,edad
	from empleados
	where cuota > (select AVG(cuota)
					from empleados);
					
--La siguiente consulta la entendi mal a la hora de leer lo que pedía.
select COUNT(*) as [EMPLEADOS CON EDAD Y CUOTA SUPERIOR A LA MEDIA]
	from empleados
	where cuota > (select avg(cuota)
					from empleados)
				and
			edad > (select AVG(edad)
					from empleados);

select COUNT(*) as [EMPLEADOS CUOTA SUPERIOR A LA MEDIA], avg(edad) as [EDAD MEDIA]
	from empleados
	where cuota > (select avg(cuota)
					from empleados);

select oficina,ciudad
	from oficinas
	where objetivo>(select SUM(cuota)
					from empleados
					where oficina=oficinas.oficina);					
------------------

--titulo de los libros cuyo precio sea superior a todos los precios de los libros de cocina (mod_cook) 



Use Pubs

go


-- Sólo conocer contenido de la Tabla


select title, price
	from titles;
go

select title, price
	from titles
	where price > all (select price
				from titles
				where type='mod_cook');








-- Usando funciones de Agregado

						
select title, price
	from titles
	where price > (select MAX(price)
			from titles	
			where type='mod_cook');
---------------------

use GestionA;

select *
	from empleados
	where cuota > all (select cuota
			from empleados empleados2
			where empleados.oficina=empleados2.oficina);

---------------------

/*obtener los titulos de los libros que tuvieron un anticipo
inferior a los libros editados por 'new age books'
subconsulta correlacionada: datos tabla externa participan
en la consulta interna; no se puede ejecutar por separado*/
						
use pubs;

select title,advance
	from titles
	where advance < all (select advance
			from publishers, titles
			where titles.pub_id=publishers.pub_id
			and pub_name='Algodata Infosystems'
				and advance is not null);

-- obtenemos el mismo resultado utilizando la funcion agregada min

select title,advance
	from titles
	where advance < (select min(advance)
			from publishers, titles
			where titles.pub_id=publishers.pub_id
				and pub_name='Algodata Infosystems');


use GestionA;

select numclie,nombre
	from clientes
	where numclie in (select clie
							from pedidos
							where fab='aci'
							and producto like '4100%' 
							and fechapedido >= '01/01/90' 
							and fechapedido < '15/04/90');

--------------------------

/*http://msdn.microsoft.com/es-es/library/ms189259%28v=sql.105%29.aspx

Cuando una subconsulta se especifica con la palabra clave EXISTS, funciona como una prueba de existencia. La cláusula WHERE de la consulta externa comprueba si existen las filas devueltas por la subconsulta. En realidad, la subconsulta no produce ningún dato, devuelve el valor TRUE o FALSE.

Una subconsulta que se especifica con EXISTS tiene la sintaxis siguiente:

WHERE [NOT] EXISTS (subquery)

La consulta siguiente busca los nombres de todos los productos presentes en la subcategoría Wheels:
*/
USE AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND Name = 'Wheels');
        
select name
	from Production.Product
	where ProductSubcategoryID in (select ProductSubcategoryID
									from production.ProductSubcategory
									where name='wheels');
/*
El conjunto de resultados es el siguiente.

Name
--------------------------------------------------
LL Mountain Front Wheel
ML Mountain Front Wheel
HL Mountain Front Wheel
LL Road Front Wheel
ML Road Front Wheel
HL Road Front Wheel
Touring Front Wheel
LL Mountain Rear Wheel
ML Mountain Rear Wheel
HL Mountain Rear Wheel
LL Road Rear Wheel
ML Road Rear Wheel
HL Road Rear Wheel
Touring Rear Wheel

(14 row(s) affected)

Para comprender el resultado de esta consulta, considere el nombre de cada producto de uno en uno. ¿Este valor hace que la subconsulta devuelva como mínimo una fila? En otras palabras, ¿la consulta hace que la prueba de existencia se evalúe como TRUE?

Observe que las subconsultas que se especifican con EXISTS son ligeramente distintas de las demás subconsultas en los aspectos siguientes:

    La palabra clave EXISTS no viene precedida de un nombre de columna, constante u otra expresión.

    La lista de selección de una subconsulta que se especifica con EXISTS casi siempre consta de un asterisco (*). No hay razón para enumerar los nombres de las columnas porque simplemente se está comprobando la existencia de filas que cumplan las condiciones especificadas en la subconsulta. 

La palabra clave EXISTS es importante, porque a menudo no hay una formulación alternativa sin subconsultas. Aunque algunas consultas creadas con EXISTS no se pueden expresar de otra forma, muchas consultas pueden usar IN o un operador de comparación modificado por ANY o ALL para lograr resultados similares.

Por ejemplo, la consulta anterior se puede expresar con IN:
*/
USE AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels')
/*
-----------

http://msdn.microsoft.com/es-es/library/ms188336%28v=sql.105%29.aspx

---------------

NOT EXISTS funciona igual que EXISTS, con la diferencia de que la cláusula WHERE en la que se utiliza se cumple si la subconsulta no devuelve ninguna fila.

Por ejemplo, para buscar los nombres de productos que no pertenecen a la subcategoría de ruedas:
*/
USE AdventureWorks2014;
GO
SELECT Name
FROM Production.Product
WHERE NOT EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND Name = 'Wheels')

/*
------------------
http://www.simple-talk.com/sql/sql-training/subqueries-in-sql-server/

--------------------

*/

use GestionA;

select numemp,nombre,oficina	
	from empleados
	where not exists (select * 
						from oficinas 
						where dir = '108' and empleados.oficina=oficinas.oficina);
						
select *
	from empleados
	where exists (select *
					from pedidos
					where numemp =rep and fab = 'aci');

select productos.idfab, productos.idproducto, productos.descripcion
	from productos
	where not exists (select *
						from pedidos
						where pedidos.producto=productos.idproducto 
						and pedidos.importe > '10' );
						
select oficinas.oficina, oficinas.ciudad
	from oficinas
	where exists (select *
					from empleados
					where empleados.oficina=oficinas.oficina 
					and empleados.cuota > (.55*oficinas.objetivo));
					

select empleados.numemp, empleados.nombre, empleados.edad
	from empleados
	where not exists (select *
					from oficinas
					where oficinas.dir=empleados.numemp);

----------------------

USE pubs;
   GO
   
   /* Simple select */
   SELECT * 
   FROM authors
   ORDER BY au_lname;
   GO
   
   /* SELECT with JOIN
   Authors and their titles. 
   Remember, authors can write more
   than one book, so there are 
   three tables involved */
   SELECT authors.au_fname
   , authors.au_lname
   , titles.title
   FROM authors
   INNER JOIN titleauthor
   ON authors.au_id = titleauthor.au_id
   INNER JOIN titles
   ON titleauthor.title_id = titles.title_id
   ORDER BY authors.au_lname
   
   /* INSERT a new author */
   INSERT INTO [pubs].[dbo].[authors]
            ([au_id]
            ,[au_lname]
            ,[au_fname]
            ,[phone]
            ,[address]
            ,[city]
            ,[state]
            ,[zip]
            ,[contract])
      VALUES
            ('123-12-1234'
            ,'Woody'
            ,'Buck'
            ,'123-123-1234'
            ,'123 Sunny Side Ave'
            ,'Tampa'
            ,'FL'
            ,'12345'
            ,1)
   GO
   
   /* Give that new author a book */
   INSERT INTO [pubs].[dbo].[titles]
            ([title_id]
            ,[title]
            ,[type]
            ,[pub_id]
            ,[price]
            ,[advance]
            ,[royalty]
            ,[ytd_sales]
            ,[notes]
            ,[pubdate])
      VALUES
            ('BW1234'
            ,'Why living in Florida is great!'
            ,'psychology '
            ,'0736'
            ,25
            ,1234567889
            ,100
            ,23456789
            ,'What an amazing guy. We have to get more books from him!'
            ,'05/05/1985')
   GO
   
   /* Now tie the book to the author */
   INSERT INTO [pubs].[dbo].[titleauthor]
            ([au_id]
            ,[title_id]
            ,[au_ord]
            ,[royaltyper])
      VALUES
            ('123-12-1234'
            ,'BW1234'
            ,1
            ,100)
   GO
   /* Now you can run the SELECT with JOIN 
   query to see the new book and author */
   
   /* UPDATE an Book's info */
   UPDATE titles
   SET title = 'Why living in Florida is extremely awesome!'
   WHERE title_id = 'BW1234';
   GO
   
   /* DELETE an author's link to their books */
   DELETE FROM titleauthor
   WHERE titleauthor.au_id IN
   (SELECT au_id FROM authors
   WHERE au_lname = 'Woody' 
   AND au_fname='Buck')
   /* Now get rid of the author */
   DELETE from authors
   WHERE au_lname = 'Woody' 
   AND au_fname='Buck';
   GO

   -----------------------






