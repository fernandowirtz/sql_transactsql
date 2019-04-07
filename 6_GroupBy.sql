-- http://www.campusmvp.es/recursos/post/Fundamentos-de-SQL-Agrupaciones-y-funciones-de-agregacion.aspx

-- sql server ya

-- Primeros ejemplos probando group by con funciones de Agregado

-- Problema:

--Trabajamos con la tabla "libros" de una librería.
--Eliminamos la tabla, si existe:

USE Tempdb
go
 if object_id('libros') is not null
  drop table libros;

-- Creamos la tabla:

 create table libros(
  codigo int identity primary key(codigo),
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(15),
  precio decimal(5,2),
  cantidad tinyint,
  
 )
 GO
-- Ingresamos algunos registros:

 insert into libros
  values('El aleph','Borges','Planeta',15,null);
 insert into libros
  values('Martin Fierro','Jose Hernandez','Emece',22.20,200);
 insert into libros
  values('Antologia poetica','J.L. Borges','Planeta',null,150);
 insert into libros
  values('Aprenda PHP','Mario Molina','Emece',18.20,null);
 insert into libros
  values('Cervantes y el quijote','Bioy Casares- J.L. Borges','Paidos',null,100);
 insert into libros
  values('Manual de PHP', 'J.C. Paez', 'Siglo XXI',31.80,120);
 insert into libros
  values('Harry Potter y la piedra filosofal','J.K. Rowling',default,45.00,90);
 insert into libros
  values('Harry Potter y la camara secreta','J.K. Rowling','Emece',null,100);
 insert into libros
  values('Alicia en el pais de las maravillas','Lewis Carroll','Paidos',22.50,200);
 insert into libros
  values('PHP de la A a la Z',null,null,null,0);
GO
SELECT * 
FROM Libros
GO

-- Queremos saber la cantidad de libros de cada editorial     --  utilizando la cláusula "group by":

 select editorial, count(*) as [Número de Libros]
  from libros
  group by editorial
GO
-- Hay 2 Editoriales con Null

--Editorial	Número de Libros
--NULL	2
--Emece	3
--Paidos	2
--Planeta	2
--Siglo XXI	1

-- El resultado muestra los nombres de las editoriales y la cantidad de registros para cada valor del campo.
-- Los valores nulos se procesan como otro grupo.

select editorial, count(*) as [Número de Libros],precio
  from libros
  group by editorial
GO

select editorial, count(*) as [Número de Libros],avg(precio)
  from libros
  group by editorial
GO

--Msg 8120, Level 16, State 1, Line 70
--Column 'libros.precio' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.


select editorial, count(*) as [Número de Libros]
  from libros
  group by editorial,precio
GO

-- Obtenemos la cantidad libros con precio no nulo de cada editorial:

 select editorial, count(precio)
  from libros
  group by editorial
GO
--editorial	(No column name)
--NULL	1
--Emece	2
--Paidos	1
--Planeta	1
--Siglo XXI	1
-- La salida muestra los nombres de las editoriales y la cantidad de registros de cada una, 
-- sin contar los que tienen precio nulo.
select editorial, count(precio)
  from libros
  Where precio is not null
  group by editorial
GO

select editorial, count(precio)
  from libros
  Where editorial is not null
  group by editorial
GO

select editorial, count(precio)
  from libros
  group by editorial
  having editorial is not null
GO


-- Total en dinero de los libros agrupados por editorial

 select editorial, sum(precio)
  from libros
  group by editorial;
GO

 select editorial, sum(precio)
  from libros
  group by editorial
  Having editorial is not null
GO

-- Obtenemos el máximo y mínimo valor de los libros agrupados por editorial, 
-- en una sola sentencia:

 select editorial,
  max(precio) as mayor,
  min(precio) as menor
  from libros
  where editorial is not null
  group by editorial;

-- Calculamos el promedio del valor de los libros agrupados por editorial:

 select editorial, avg(precio)
  from libros
  where editorial is not null
  group by editorial;


  select editorial, cast(avg(precio) as bigint)
  from libros
  where editorial is not null
  group by editorial;

   
  select editorial, convert(int,avg(precio))
  from libros
  where editorial is not null
  group by editorial;


--Es posible limitar la consulta con "where". Vamos a contar y agrupar por editorial considerando solamente los libros cuyo precio es menor a 30 pesos:

 select editorial, count(*)
  from libros
  where precio<30
  group by editorial;

-- Las editoriales que no tienen libros que cumplan la condición, no aparecen en la salida.
-- Para que aparezcan todos los valores de editorial, incluso los que devuelven cero o "null" en la columna de agregado, 
-- debemos emplear la palabra clave "all" al lado de "group by":

 select editorial, count(*)
  from libros
  where precio<30
  group by all editorial;
GO
--------------------
-- sqlserverya 


--Primer problema: 
--Un comercio que tiene un stand en una feria registra en una tabla llamada "visitantes" algunos datos 
--de las personas que visitan o compran en su stand para luego enviarle publicidad de sus productos.
--1- Elimine la tabla "visitantes", si existe:
 if object_id('visitantes') is not null
  drop table visitantes;

2- Cree la tabla con la siguiente estructura:
 create table visitantes(
  nombre varchar(30),
  edad tinyint,
  sexo char(1) default 'f',
  domicilio varchar(30),
  ciudad varchar(20) default 'Cordoba',
  telefono varchar(11),
  mail varchar(30) default 'no tiene',
  montocompra decimal (6,2)
 );


 insert into visitantes
  values ('Susana Molina',35,default,'Colon 123',default,null,null,59.80);
 insert into visitantes
  values ('Marcos Torres',29,'m',default,'Carlos Paz',default,'marcostorres@hotmail.com',150.50);
 insert into visitantes
  values ('Mariana Juarez',45,default,default,'Carlos Paz',null,default,23.90);
 insert into visitantes (nombre, edad,sexo,telefono, mail)
  values ('Fabian Perez',36,'m','4556677','fabianperez@xaxamail.com');
 insert into visitantes (nombre, ciudad, montocompra)
  values ('Alejandra Gonzalez','La Falda',280.50);
 insert into visitantes (nombre, edad,sexo, ciudad, mail,montocompra)
  values ('Gaston Perez',29,'m','Carlos Paz','gastonperez1@gmail.com',95.40);
 insert into visitantes
  values ('Liliana Torres',40,default,'Sarmiento 876',default,default,default,85);
 insert into visitantes
  values ('Gabriela Duarte',21,null,null,'Rio Tercero',default,'gabrielaltorres@hotmail.com',321.50);

4- Queremos saber la cantidad de visitantes de cada ciudad utilizando la cláusula "group by" (4 filas devueltas)

5- Queremos la cantidad visitantes con teléfono no nulo, de cada ciudad (4 filas devueltas)

6- Necesitamos el total del monto de las compras agrupadas por sexo (3 filas)

7- Se necesita saber el máximo y mínimo valor de compra agrupados por sexo y ciudad (6 filas)

8- Calcule el promedio del valor de compra agrupados por ciudad (4 filas)

9- Cuente y agrupe por ciudad sin tener en cuenta los visitantes que no tienen mail (3 filas):

10- Realice la misma consulta anterior, pero use la palabra clave "all" para mostrar todos los 
valores de ciudad, incluyendo las que devuelven cero o "null" en la columna de agregado (4 filas)

 if object_id('visitantes') is not null
  drop table visitantes;

 create table visitantes(
  nombre varchar(30),
  edad tinyint,
  sexo char(1) default 'f',
  domicilio varchar(30),
  ciudad varchar(20) default 'Cordoba',
  telefono varchar(11),
  mail varchar(30) default 'no tiene',
  montocompra decimal (6,2)
 );

 insert into visitantes
  values ('Susana Molina',35,default,'Colon 123',default,null,null,59.80);
 insert into visitantes
  values ('Marcos Torres',29,'m',default,'Carlos Paz',default,'marcostorres@hotmail.com',150.50);
 insert into visitantes
  values ('Mariana Juarez',45,default,default,'Carlos Paz',null,default,23.90);
 insert into visitantes (nombre, edad,sexo,telefono, mail)
  values ('Fabian Perez',36,'m','4556677','fabianperez@xaxamail.com');
 insert into visitantes (nombre, ciudad, montocompra)
  values ('Alejandra Gonzalez','La Falda',280.50);
 insert into visitantes (nombre, edad,sexo, ciudad, mail,montocompra)
  values ('Gaston Perez',29,'m','Carlos Paz','gastonperez1@gmail.com',95.40);
 insert into visitantes
  values ('Liliana Torres',40,default,'Sarmiento 876',default,default,default,85);
 insert into visitantes
  values ('Gabriela Duarte',21,null,null,'Rio Tercero',default,'gabrielaltorres@hotmail.com',321.50);
  GO
 select ciudad, count(*) as [Número de Visitantes]
  from visitantes
  group by ciudad;

 select ciudad, count(telefono)
  from visitantes
  group by ciudad;

 select sexo, sum(montocompra)
  from visitantes
  group by sexo;

 select sexo,ciudad,
  max(montocompra) as mayor,
  min(montocompra) as menor
  from visitantes
  group by sexo,ciudad;

 select ciudad,
  avg(montocompra) as 'promedio de compras'
  from visitantes
  group by ciudad;

 select ciudad,
  count(*) as 'cantidad con mail'
  from visitantes
  where mail is not null and
  mail<>'no tiene'
  group by ciudad;

 select ciudad,
  count(*) as 'cantidad con mail'
  from visitantes
  where mail is not null and
  mail<>'no tiene'
  group by all ciudad;
----------------------------------------

-- Otro Ejemplo

-- Dado el Esquema/Tabla HumanResources.Employee 

USE AdventureWorks2014
Go
SELECT * 
FROM HumanResources.Employee
GO
sp_help [HumanResources.Employee]
GO
SELECT   NationalIdNumber, HireDate
FROM HumanResources.Employee
ORDER BY HireDate DESC
GO 

-- Función podría ser DATEPART(year, HireDate)



-- Obtener Nº de trabajadores contratados cada año

SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
GROUP BY DATEPART(yy, HireDate)
GO

--Año	Contratados
--2006	1
--2007	6
--2008	74
--2009	148
--2010	38
--2011	16
--2012	4
--2013	3
-- Trabajadores contratados un determinado año

SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
WHERE DATEPART(yy, HireDate)= '2009'
GROUP BY DATEPART(yy, HireDate)
GO

--Año	Contratados
--2009	148



SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
GROUP BY DATEPART(yy, HireDate)
HAVING DATEPART(yy, HireDate)= '2009'
GO




SELECT COUNT(*) AS Contratados
FROM HumanResources.Employee
WHERE DATEPART(yy, HireDate)= '2009'
-- GROUP BY DATEPART(yy, HireDate)
GO

SELECT COUNT(*) AS Contratados
FROM HumanResources.Employee
WHERE DATEPART(yy, HireDate)= '2009' OR DATEPART(yy, HireDate)= '2010'
-- GROUP BY DATEPART(yy, HireDate)
GO

-- 186


SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
WHERE DATEPART(yy, HireDate)= '2009' OR DATEPART(yy, HireDate)= '2010'
GROUP BY DATEPART(yy, HireDate)
GO


--Año	Contratados
--2009	148
--2010	38




SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
WHERE DATEPART(yy, HireDate)= 2009
GROUP BY DATEPART(yy, HireDate)
GO

-- Con Parametro Reemplazable

DECLARE @Year DATETIME =2009
SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
WHERE DATEPART(yy, HireDate)= @Year
GROUP BY DATEPART(yy, HireDate)
GO

-- With Stored Procedure
-- SQL Server 2017
-- CREATE or REPLACE  Contratados ........

CREATE  PROC Contratados
	@Year DATETIME 
AS
BEGIN
				SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
				FROM HumanResources.Employee
				WHERE DATEPART(yy, HireDate)= @Year
				GROUP BY DATEPART(yy, HireDate)
END
GO


EXEC Contratados 2009
GO
--Año	Contratados
--2009	148

EXEC Contratados 2013
gO
--Año	Contratados
--2013	3
----


SELECT DATEPART(yy, HireDate) AS Año,COUNT(*) AS Contratados
FROM HumanResources.Employee
GROUP BY DATEPART(yy, HireDate)
HAVING DATEPART(yy, HireDate)= '2009'
GO

--Año	Contratados
--2009	148


SELECT DATEPART(yy, HireDate) AS Año,
	   DATEPART(mm, HireDate) AS Mes,
       COUNT(*) AS Contratados
FROM HumanResources.Employee
GROUP BY DATEPART(yy, HireDate),DATEPART(mm, HireDate)
GO

-- Contratados agrupados por Año y mes
-- Con Order By
SELECT DATEPART(yy, HireDate) AS Año,
	   DATEPART(mm, HireDate) AS Mes,
       COUNT(*) AS Contratados
FROM HumanResources.Employee
GROUP BY DATEPART(yy, HireDate),DATEPART(mm, HireDate)
ORDER BY DATEPART(yy, HireDate) ,DATEPART(mm, HireDate)
GO

--Año         Mes         Contratados
------------- ----------- -----------
--2006        6           1
--2007        1           1
--2007        11          1
--2007        12          4
--2008        1           5
--2008        2           4
--2008        3           3
--2008        12          62

-- -- Contratados agrupados por Año  Mes Dia
SELECT DATEPART(yy, HireDate) AS Año,
	DATEPART(mm, HireDate)as Mes,
	DATEPART(dd, HireDate)as Dia,
       COUNT(*) AS Contratados
FROM HumanResources.Employee
GROUP BY DATEPART(yy, HireDate),
		DATEPART(mm, HireDate),
		DATEPART(DD, HireDate)
ORDER BY DATEPART(yy, HireDate),
		DATEPART(mm, HireDate),
		DATEPART(DD, HireDate)
GO
--Año         Mes         Dia         Contratados
------------- ----------- ----------- -----------
--2006        6           30          1
--2007        1           26          1
--2007        11          11          1
--2007        12          5           1
--2007        12          11          1
--2007        12          20          1
--2007        12          26          1
--2008        1           6           2
--2008        1           7           1
--2008        1           24          1
--2008        1           31          1
--2008        2           2           1
--2008        2           8           1
--2008        2           20          1
--2008        2           27          1
--2008        3           10          1
--2008        3           17          1
--2008        3           28          1
--2008        12          1           2
--2008        12          2           3
--2008        12          3           1
--2008        12          4           3
--2008        12          5           1
--2008        12          6           2
--2008        12          7           5
--2008        12          8           2
--2008        12          9           3
--2008        12          11          1
--2008        12          12          4
--2008        12          13          1
--2008        12          14          3
--2008        12          15          3
--2008        12          16          2
--2008        12          17          3
--2008        12          18          1
--2008        12          19          2
--2008        12          21          1
--2008        12          22          2
--2008        12          23          2
--2008        12          24          2
--2008        12          25          3
--2008        12          26          2
--2008        12          27          3
--2008        12          28          2
--2008        12          29          2
--2008        12          31          1

SELECT Hiredate
FROM HumanResources.Employee
WHERE Hiredate='2008-12-29'
ORDER BY hiredate
GO

--Hiredate
--2008-12-29
--2008-12-29

SELECT Hiredate
FROM HumanResources.Employee
WHERE Hiredate='2008-12-31'
ORDER BY hiredate
GO

--Hiredate
--2008-12-31



SELECT NationalIDNumber,Hiredate 
FROM HumanResources.Employee
WHERE Hiredate='2008-12-31'
ORDER BY hiredate
GO


--NationalIDNumber	Hiredate
--632092621	       2008-12-31
-----------------------------------------



------------------

DROP DATABASE IF EXISTS Prueba_Agrupar
GO
CREATE DATABASE Prueba_Agrupar
GO
USE Prueba_Agrupar
GO
--DROP DATABASE Prueba_Agrupar
--GO

--USE tempdb;
--GO

SET NOCOUNT ON;

-- Create Sales Table   
CREATE TABLE dbo.SalesTransaction 
   (Id INT IDENTITY PRIMARY KEY
   ,CustomerName VARCHAR(65)
   ,TotalSalesAmount money
   ,SalesTypeDesc VARCHAR(200)
   ,SalesDateTime DATETIME
   ,StoreName VARCHAR(100));
GO
  
-- Add data to Sales Table
INSERT INTO dbo.SalesTransaction 
      VALUES ('John Smith', 124.23,'Software','2/09/2011 11:51:12 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Jack Thomas', 29.56,'Computer Supplies','3/09/2011 10:21:49 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sue Hunter', 89.45,'Computer Supplies','3/09/2011 2:51:56 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Karla Johnson', 759.12,'Software','3/09/2011 2:54:37 PM','The Software Outlet');
      INSERT INTO dbo.SalesTransaction 
      VALUES ('Gary Clark', 81.51,'Software','2/09/2011 11:08:52 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Scott Crochet', 12345.78,'Computer Supplies','3/09/2011 3:12:37 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sheri Holtz', 12.34,'Software','3/09/2011 10:51:42 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Mary Lee', 101.34,'Software','3/09/2011 09:37:19 AM','Discount Software');
      INSERT INTO dbo.SalesTransaction 
      VALUES ('Sally Davisson', 871.12,'Software','2/09/2011 05:21:28 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Rod Kaplan', 2345.19,'Computer Supplies','3/09/2011 5:01:11 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sandy Roberts', 76.38,'Books','3/09/2011 4:51:57 PM','Computer Books and Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Marc Trotter', 562.94,'Software','3/09/2011 6:51:43 PM','Computer Books and Software');
GO
SELECT * FROM SalesTransaction 
GO
SELECT COUNT(*) as [Nª de Registros] 
FROM SalesTransaction 
GO

-- Grouping by a Single Column 
-- Ventas Totales en cada Tienda

SELECT StoreName,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY StoreName
GO
--StoreName						StoreSalesAmount
--Computer Books and Software			1278,64
--Discount Software					    31514,56
--The Software Outlet					2004,72

-- Grouping by Multiple Columns

SELECT StoreName, SalesTypeDesc
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY StoreName, SalesTypeDesc
ORDER BY StoreName, SalesTypeDesc
GO

--StoreName	SalesTypeDesc	StoreSalesAmount
--Computer Books and Software	Books	76.38
--Computer Books and Software	Software	562.94
--Discount Software	Computer Supplies	14690.97
--Discount Software	Software	1066.31
--The Software Outlet	Computer Supplies	119.01
--The Software Outlet	Software	883.35

-- Using an Expression in the GROUP BY Clause

SELECT SalesDateTime AS SalesDate 
     ,SUM(TotalSalesAmount) AS TotalSalesAmount
FROM dbo.SalesTransaction
GROUP BY SalesDateTime
GO

--SalesDate							TotalSalesAmount
--2011-02-09 11:08:52.000	81.51
--2011-02-09 11:51:12.000	124.23
--2011-02-09 17:21:28.000	871.12
--2011-03-09 02:51:56.000	89.45
--2011-03-09 09:37:19.000	101.34
--2011-03-09 10:21:49.000	29.56
--2011-03-09 10:51:42.000	12.34
--2011-03-09 14:54:37.000	759.12
--2011-03-09 15:12:37.000	12345.78
--2011-03-09 16:51:57.000	76.38
--2011-03-09 17:01:11.000	2345.19
--2011-03-09 18:51:43.000	562.94


SELECT CONVERT(CHAR(10),SalesDateTime,101) AS SalesDate   
     ,SUM(TotalSalesAmount) AS TotalSalesAmount
FROM dbo.SalesTransaction
GROUP BY CONVERT(CHAR(10),SalesDateTime,101);
GO

--SalesDate		TotalSalesAmount
--09/22/2011			2153,72
--09/23/2011			32644,20




-- HAVING Clause

-- Restricting result set by using HAVING clause

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName
HAVING SUM(TotalSalesAmount) < 2000.00
-- HAVING SUM(TotalSalesAmount) >2000
GO

--StoreName	StoreSalesAmount
--Computer Books and Software	1278,64


-- HAVING con LIKE

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName 
HAVING StoreName LIKE '%Outlet%' 
    OR StoreName LIKE '%Books%'
GO

--StoreName									StoreSalesAmount
--Computer Books and Software		1278,64
--The Software Outlet							2004,72

-- ROLLUP

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY ROLLUP(StoreName)
GO 

--StoreName								StoreSalesAmount
--Computer Books and Software	639,32
--Discount Software						15757,28
--The Software Outlet						1002,36
--NULL												17398,96

-- Evitar el NULL
SELECT COALESCE(StoreName, 'Total Tiendas') AS Tiendas
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY ROLLUP(StoreName)
GO 

--Tiendas	StoreSalesAmount
--Computer Books and Software	639,32
--Discount Software	15757,28
--The Software Outlet	1002,36
--Total Tiendas	17398,96


-- CUBE
SELECT COALESCE(StoreName, 'Total Tiendas') AS Tiendas
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY CUBE(StoreName)
GO 


-- ROLLUP - CUBE - GROUPING SET
-- Otro Ejemplo
CREATE TABLE CheckRegistry (
	CheckNumber smallint, 
	PayTo varchar(20),
	Amount money, 
	CheckFor varchar(20),
	CheckDate date)
GO
INSERT INTO CheckRegistry VALUES
    (1000,'Seven Eleven',12.57,'Food','2011-07-12'),
    (1001,'Costco',128.57,'Clothes','2011-07-15'),
    (1002,'Costco',21.87,'Clothes','2011-07-18'),
    (1003,'AT&T',69.23,'Utilities','2011-07-25'),
    (1004,'Comcast',45.95,'Utilities','2011-07-25'),
    (1005,'Northwest Power',69.18,'Utilities','2011-07-25'),
    (1006,'StockMarket',59.25,'Food','2011-07-25'),
    (1007,'Safeway',120.21,'Food','2011-07-28'),
    (1008,'Albertsons',9.15,'Food','2011-08-02'),
    (1009,'Amazon',158.34,'Clothes','2011-08-05'),
    (1010,'Target',89.21,'Clothes','2011-08-06'),
    (1011,'AT&T',69.23,'Utilities','2011-08-25'),
    (1012,'Comcast',45.95,'Utilities','2011-08-25'),
    (1013,'Nordstrums',259.12,'Clothes','2011-08-27'),
    (1014,'AT&T',69.23,'Utilities','2011-09-25'),
    (1015,'Comcast',45.95,'Utilities','2011-09-25'),
    (1016,'Northwest Power',71.35,'Utilities','2011-09-25'),
    (1017,'Safeway',123.25,'Food','2011-09-25'),
    (1018,'Albertsons',65.11,'Food','2011-09-29'),
    (1019,'McDonalds',12.57,'Food','2011-09-29'),
    (1020,'AT&T',69.23,'Utilities','2011-10-25'),
    (1021,'Comcast',45.95,'Utilities','2011-10-25'),
    (1022,'Black Angus',159.23,'Food','2011-10-25'),
    (1023,'TicketMasters',59.87,'Entertainment','2011-10-30'),
    (1024,'WalMart',25.11,'Clothes','2011-10-31'),
    (1025,'Albertsons',158.50,'Food','2011-10-31')
GO
SELECT * FROM CheckRegistry
GO
-- GROUP BY
SELECT CheckFor, SUM (Amount) As Total
FROM CheckRegistry
GROUP BY CheckFor
GO 

--CheckFor				Total
--Clothes				682,22
--Entertainment		59,87
--Food						719,84
--Utilities				601,25

SELECT PayTo, SUM (Amount) As Total
FROM CheckRegistry
GROUP BY PayTo
Order by PayTo
GO 

SELECT PayTo, CheckFor ,SUM (Amount) As Total
FROM CheckRegistry
GROUP BY PayTo, CheckFor
Order by PayTo
GO 

 
-- Using the ROLLUP operator to Create Subtotals and a Grand Total

SELECT CheckFor
     , SUM (Amount) As Total
FROM CheckRegistry
GROUP BY ROLLUP (CheckFor)
GO  

--CheckFor	Total
--Clothes	682,22
--Entertainment	59,87
--Food	719,84
--Utilities	601,25
--NULL	2063,18

-- Replacing “NULL” reference with “GRAND TOTAL” 
SELECT COALESCE (CheckFor,'GRAND TOTAL') As CheckFor
     , SUM (Amount) AS Total
FROM CheckRegistry
GROUP BY ROLLUP (CheckFor)
GO

--CheckFor	Total
--Clothes	682,22
--Entertainment	59,87
--Food	719,84
--Utilities	601,25
--GRAND TOTAL	2063,18

-- Generating Subtotals and Grand Total

SELECT MONTH(CheckDate) AS CheckMonth 
     , CheckFor
     , SUM (Amount) AS Total
FROM CheckRegistry
GROUP BY ROLLUP (MONTH(CheckDate),CheckFor)
GO

--CheckMonth	CheckFor	Total
--7	Clothes	150,44
--7	Food	192,03
--7	Utilities	184,36
--7	NULL	526,83
--8	Clothes	506,67
--8	Food	9,15
--8	Utilities	115,18
--8	NULL	631,00
--9	Food	200,93
--9	Utilities	186,53
--9	NULL	387,46
--10	Clothes	25,11
--10	Entertainment	59,87
--10	Food	317,73
--10	Utilities	115,18
--10	NULL	517,89
--NULL	NULL	2063,18

-- Creating Multiple Subtotal rows

SELECT MONTH(CheckDate) AS CheckMonth 
     , CheckFor
     , PayTo
     , SUM (Amount) AS Total
FROM CheckRegistry
GROUP BY ROLLUP (MONTH(CheckDate),CheckFor,PayTo)
GO

-- Using the CUBE Operator to create a Superset of Aggregated Values

SELECT CheckFor
     , SUM (Amount) As Total
FROM CheckRegistry
GROUP BY CUBE(CheckFor)
GO

-- Using two columns in the CUBE Specification

SELECT MONTH(CheckDate) AS CheckMonth 
     , CheckFor
     , SUM (Amount) AS Total
FROM CheckRegistry
GROUP BY CUBE (MONTH(CheckDate),CheckFor)
GO            
------------------------
-- Otro ejemplo
 
USE tempdb;
GO

SET NOCOUNT ON;

-- Create Sales Table   
CREATE TABLE dbo.SalesTransaction 
   (Id INT IDENTITY PRIMARY KEY
   ,CustomerName VARCHAR(65)
   ,TotalSalesAmount money
   ,SalesTypeDesc VARCHAR(200)
   ,SalesDateTime DATETIME
   ,StoreName VARCHAR(100));
GO
   
-- Add data to Sales Table
INSERT INTO dbo.SalesTransaction 
      VALUES ('John Smith', 124.23,'Software','2/09/2011 11:51:12 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Jack Thomas', 29.56,'Computer Supplies','3/09/2011 10:21:49 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sue Hunter', 89.45,'Computer Supplies','3/09/2011 2:51:56 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Karla Johnson', 759.12,'Software','3/09/2011 2:54:37 PM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Gary Clark', 81.51,'Software','2/09/2011 11:08:52 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Scott Crochet', 12345.78,'Computer Supplies','3/09/2011 3:12:37 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sheri Holtz', 12.34,'Software','3/09/2011 10:51:42 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Mary Lee', 101.34,'Software','3/09/2011 09:37:19 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sally Davisson', 871.12,'Software','3/09/2011 05:21:28 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Rod Kaplan', 2345.19,'Computer Supplies','3/09/2011 5:01:11 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sandy Roberts', 76.38,'Books','3/09/2011 4:51:57 PM','Computer Books and Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Marc Trotter', 562.94,'Software','3/09/2011 6:51:43 PM','Computer Books and Software');
GO

SElect distinct storename
FROM dbo.SalesTransaction
GO


SELECT StoreName 
FROM  SalesTransaction
go

--Computer Books and Software
--Discount Software
--The Software Outlet

(3 row(s) affected)

SELECT DISTINCT StoreName 
FROM  SalesTransaction
go

SELECT * 
from SalesTransaction
go

--Id          CustomerName                                                      TotalSalesAmount      SalesTypeDesc                                                                                                                                                                                            SalesDateTime           StoreName
------------- ----------------------------------------------------------------- --------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------------------- ----------------------------------------------------------------------------------------------------
--1           John Smith                                                        124.23                Software                                                                                                                                                                                                 2011-02-09 11:51:12.000 The Software Outlet
--2           Jack Thomas                                                       29.56                 Computer Supplies                                                                                                                                                                                        2011-03-09 10:21:49.000 The Software Outlet
--3           Sue Hunter                                                        89.45                 Computer Supplies                                                                                                                                                                                        2011-03-09 02:51:56.000 The Software Outlet
--4           Karla Johnson                                                     759.12                Software                                                                                                                                                                                                 2011-03-09 14:54:37.000 The Software Outlet
--5           Gary Clark                                                        81.51                 Software                                                                                                                                                                                                 2011-02-09 11:08:52.000 Discount Software
--6           Scott Crochet                                                     12345.78              Computer Supplies  

-- Clientes en cada Tienda
SELECT SalesTypeDesc ,COUNT(*) AS Customers
FROM dbo.SalesTransaction  
GROUP BY SalesTypeDesc
ORDER BY SalesTypeDesc
GO

--SalesTypeDesc	Customers
--Books				1
--Computer Supplies	4
--Software			7

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS Ventas
FROM dbo.SalesTransaction  
GROUP BY StoreName
ORDER BY SUM(TotalSalesAmount) desc;
GO

--StoreName			Ventas
--Discount Software	15838.79
--The Software Outlet	1126.59
--Computer Books and Software	639.32


-- Error
SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount, [CustomerName]
FROM dbo.SalesTransaction  
GROUP BY StoreName;
GO
--Mens. 8120, Nivel 16, Estado 1, Línea 3
--La columna 'dbo.SalesTransaction.CustomerName' de la lista de selección no es válida, porque no está contenida en una función de agregado ni en la cláusula GROUP BY.

-- Agrupar por mas de un campo

SELECT StoreName, SalesTypeDesc
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY StoreName, SalesTypeDesc;
GO

--StoreName	SalesTypeDesc	StoreSalesAmount
--Computer Books and Software	Books	76.38
--Discount Software	Computer Supplies	14690.97
--The Software Outlet	Computer Supplies	119.01
--Computer Books and Software	Software	562.94
--Discount Software	Software	1147.82
--The Software Outlet	Software	1007.58

SELECT StoreName, SalesTypeDesc
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY StoreName, SalesTypeDesc
ORDER BY 1
GO

--StoreName                                                                                            SalesTypeDesc                                                                                                                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------
--Computer Books and Software                                                                          Books                                                                                                                                                                                                    76.38
--Computer Books and Software                                                                          Software                                                                                                                                                                                                 562.94
--Discount Software                                                                                    Computer Supplies                                                                                                                                                                                        14690.97
--Discount Software                                                                                    Software                                                                                                                                                                                                 1147.82
--The Software Outlet                                                                                  Computer Supplies                                                                                                                                                                                        119.01
--The Software Outlet                                                                                  Software                                                                                                                                                                                                 1007.58

--(6 row(s) affected)

INSERT INTO dbo.SalesTransaction 
      VALUES ('Pepe Arias', 76.38,'Books','3/09/2011 4:51:57 PM','Computer Books and Software');
GO

SELECT StoreName, SalesTypeDesc
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY StoreName, SalesTypeDesc
ORDER BY 1
GO

--StoreName                                                                                            SalesTypeDesc                                                                                                                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------
--Computer Books and Software                                                                          Books                                                                                                                                                                                                    152.76
--Computer Books and Software                                                                          Software                                                                                                                                                                                                 562.94
--Discount Software                                                                                    Computer Supplies                                                                                                                                                                                        14690.97
--Discount Software                                                                                    Software                                                                                                                                                                                                 1147.82
--The Software Outlet                                                                                  Computer Supplies                                                                                                                                                                                        119.01
--The Software Outlet                                                                                  Software                                                                                                                                                                                                 1007.58

--(6 row(s) affected)


-- Con Funciones Por Fecha

SELECT SalesDateTime AS SalesDate   
     ,SUM(TotalSalesAmount) AS TotalSalesAmount
FROM dbo.SalesTransaction
GROUP BY SalesDateTime
GO
SELECT CONVERT(CHAR(10),SalesDateTime,101) AS SalesDate   
     ,SUM(TotalSalesAmount) AS TotalSalesAmount
FROM dbo.SalesTransaction
GROUP BY CONVERT(CHAR(10),SalesDateTime,101)
GO
SELECT CONVERT(DATE,SalesDateTime,101) AS SalesDate   
     ,SUM(TotalSalesAmount) AS TotalSalesAmount
FROM dbo.SalesTransaction
GROUP BY CONVERT(DATE,SalesDateTime,101)
GO


--SalesDate  TotalSalesAmount
------------ ---------------------
--02/09/2011 81.51
--03/09/2011 17269.60
--12/09/2011 329.97

--(3 row(s) affected)

SELECT  CustomerName
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY CustomerName
GO


-- HAVING

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName
-- HAVING SUM(TotalSalesAmount) < 1000.00
HAVING SUM(TotalSalesAmount) > 1000.00
GO

--StoreName                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ ---------------------
--Discount Software                                                                                    15838.79
--The Software Outlet                                                                                  1126.59

--(2 row(s) affected)
-------------------------------------------------------
-- HAVING más complejo

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName 
HAVING StoreName LIKE '%Outlet%' 
    OR StoreName LIKE '%Books%'
GO

--StoreName                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ ---------------------
--Computer Books and Software                                                                          715.70
--The Software Outlet                                                                                  1126.59



SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName 
HAVING StoreName LIKE '%Outlet%' 
    -- OR StoreName LIKE '%Books%'
GO

--StoreName                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ ---------------------
--The Software Outlet          
-----
-- Otro Ejemplo
--Si la columna de agrupamiento contiene un valor NULL, esa fila se convierte en un grupo en los resultados. Si la columna de agrupamiento contiene varios valores NULL, éstos se colocan en un grupo individual. Este comportamiento se define en el estándar SQL-2003.
--La columna Color de la tabla Product contiene algunos valores NULL. Por ejemplo:
USE AdventureWorks2014
GO
Select *
from Production.Product
go

Select [Name],[Color],[SafetyStockLevel] 
from Production.Product
go

Select  COUNT(*) [Colores nulos]
from Production.Product
WHERE Color is null
go
-- 248

Select  COUNT(DISTINCT Color) [Colores no nulos]
from Production.Product
go
-- 9

Select DISTINCT Color
from Production.Product
WHERE Color is not Null
go
-- (9 row(s) affected)

SELECT Color, AVG (ListPrice) AS 'Precio Medio'
FROM Production.Product
GROUP BY Color
ORDER BY Color
GO
--Color	Precio Medio
--NULL	16.8641
--Black	725.121
--Blue	923.6792
--Grey	125.00
--Multi	59.865
--Red	1401.95
--Silver	850.3053
--Silver/Black	64.0185
--White	9.245
--Yellow	959.0913

-- Esta instrucción SELECT se puede cambiar para que quite los valores NULL si se agrega una cláusula
-- WHERE:

SELECT Color, AVG (ListPrice) AS 'Precio Medio'
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color
ORDER BY Color

SELECT Color, AVG (ListPrice) AS 'Precio Medio'
FROM Production.Product
GROUP BY Color
ORDER BY AVG (ListPrice) desc

SELECT Color, AVG (ListPrice) AS 'Precio Medio'
FROM Production.Product
WHERE color is not null
GROUP BY Color
ORDER BY AVG (ListPrice) 



-- 2 campos como criterio de Agrupamiento

SELECT Color,[SafetyStockLevel],count(*) as Cuenta, 
			AVG (ListPrice) AS 'Precio Medio'
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color,[SafetyStockLevel]
ORDER BY Color


--Black 4 Cuenta 17
-- Comprobación

SELECT Color,[SafetyStockLevel]
FROM Production.Product
WHERE (color='Black') and ([SafetyStockLevel]=4)

-- (17 filas afectadas)
-- 3 campos para agrupar

SELECT Color,[SafetyStockLevel],[ReorderPoint],count(*) as Cuenta, AVG         (ListPrice) AS 'Precio Medio'
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color,[SafetyStockLevel],[ReorderPoint]
ORDER BY Color

-- Cuenta 30

SELECT Color,[SafetyStockLevel],[ReorderPoint]
FROM Production.Product
WHERE (color='Black') and ([SafetyStockLevel]=100)AND([ReorderPoint]=75)

-- (30 filas afectadas)
--------------------


-- HAVING



-- Agrupa la tabla SalesOrderDetail por Id. de producto y sólo se incluyen los grupos de productos con pedidos 
-- cuyo total sea superior a 1.000.000 dólares y cuyas cantidades de pedido promedio sean inferiores a 3.


SELECT ProductID, AVG(OrderQty) AS AverageQuantity, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $1000000.00
		AND AVG(OrderQty) < 3 ;
GO

-- Cuando en HAVING se incluyen varias condiciones, éstas se combinan mediante AND, OR o NOT.

--Para ver los productos con ventas totales superiores a 2.000.000 de dólares, utilice la siguiente consulta:

SELECT ProductID, Total = SUM(LineTotal)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $2000000.00 ;
GO

-- Comprobar que hay al menos 1.500 elementos implicados en los cálculos de cada producto, 
-- utilice HAVING COUNT(*) > 1500 para eliminar los productos que devuelvan totales inferiores a 1.500 elementos vendidos. La consulta sería la siguiente:

SELECT ProductID, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 1500 ;
GO

--En este ejemplo se muestra una cláusula HAVING con una función de agregado. Se agrupan las filas de la tabla SalesOrderDetail por Id. de producto y se eliminan los productos cuyas cantidades de pedido promedio sean cinco o menos.

SELECT ProductID 
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID ;
GO



-- HAVING más complejo

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName 
HAVING StoreName LIKE '%Outlet%' 
    OR StoreName LIKE '%Books%'
GO

--StoreName                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ ---------------------
--Computer Books and Software                                                                          715.70
--The Software Outlet                                                                                  1126.59



SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName 
HAVING StoreName LIKE '%Outlet%' 
    -- OR StoreName LIKE '%Books%'
GO

--StoreName                                                                                            StoreSalesAmount
------------------------------------------------------------------------------------------------------ ---------------------
--The Software Outlet                                                                                  1126.59

-------------------
-- https://www.simple-talk.com/sql/t-sql-programming/sql-group-by-basics/

USE Tempdb
GO
CREATE TABLE Sales
(salesman_name VARCHAR (10) NOT NULL,
 product_name VARCHAR (10) NOT NULL
   CHECK (product_name IN ('scissors', 'paper', 'stone')),
 sale_date DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
 sale_amt DECIMAL(6,2) NOT NULL
   CHECK (sale_amt >= 0.00)
PRIMARY KEY (salesman_name, product_name, sale_date));
GO
INSERT INTO Sales
VALUES
('Fred', 'scissors', '2016-01-01', 100.00),
('Fred', 'stone', '2016-01-01', 75.98),
('Fred', 'paper', '2016-01-01', 40.00),
('John', 'paper', '2016-01-02', 35.85),
('John', 'paper', '2016-01-03', 0.00),
('John', 'stone', '2016-01-01', 100.00),
('John', 'stone', '2016-01-02', 5.00),
('John', 'stone', '2016-01-04', 4.98),
('Mary', 'paper', '2016-01-11', 45.95),
('Mary', 'scissors', '2016-01-10', 0.00),
('Mary', 'stone', '2016-01-12',20.25),
('Vlad', 'stone', '2016-01-11', 23.95),
('Vlad', 'stone', '2016-01-12', 100.00),
('Vlad', 'stone', '2016-01-13', 75.98),
('Vlad', 'stone', '2016-01-14', 16.85);
GO
--  To find the salesman who sold all three products
SELECT salesman_name
  FROM Sales
GROUP BY salesman_name
HAVING COUNT (DISTINCT product_name) = 3;
GO

--salesman_name
--Fred
--Mary


--This will give us 'Mary' and “Fred' as the salesman who sold the whole catalog.
--  Now, tell me if we have a salesman who has sold only one product. 
-- We do not care which product, we are looking for a specialized guy.

SELECT salesman_name, MAX(product_name) AS single_product_name
  FROM Sales
GROUP BY salesman_name
HAVING MIN(product_name) = MAX(product_name);


--salesman_name	single_product_name
--Vlad	stone

-- But why do it this way? Why not use “HAVING COUNT (DISTINCT product_name) = 1” instead?  
--This would look like the first query. The optimizer has to do a scan to count the product names, 
-- but the table statistics in every SQL compiler I know about keeps at least the min, max, 
--and row count for computing execution plans. 
--Once I see the min (or max) value for that column, I know that I have found the min (or max) value for each salesman and can ignore the rest of his values.

-- Try another one: Do we have salesmen who sold over $100.00 or products? The obvious way is:

 SELECT salesman_name
  FROM Sales
 GROUP BY salesman_name
HAVING SUM(sale_amt) >= 100.00;
GO

--salesman_name
--Fred
--John
--Vlad

-- We get 'Fred', 'Vlad' and  'John' as the result set. But there is an alternative.

SELECT salesman_name
  FROM Sales
GROUP BY salesman_name
HAVING SIGN(SUM(sale_amt) - 100.00) >= 0;
GO

--salesman_name
--Fred
--John
--Vlad
---------------

-- http://www.dotnet-tricks.com/Tutorial/sqlserver/HQV8310312-Definition,-Use-of-Group-by-and-Having-Clause.html


USE TempDB
GO
Create table StudentMarks
(
 st_RollNo int ,
 st_Name varchar(50),
 st_Subject varchar(50),
 st_Marks int
)
GO
--Insert data in StudentMarks table
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(1,'Mohan','Physics',75);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(1,'Mohan','Chemistry',65);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(1,'Mohan','Math',70);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks) values(2,'Vipul','Physics',70);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(2,'Vipul','Chemistry',75);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks) values(2,'Vipul','Math',60);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(3,'Jitendra','Physics',85);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(3,'Jitendra','Chemistry',75);
insert into StudentMarks(st_RollNo,st_Name,st_Subject,st_Marks)
values(3,'Jitendra','Math',60);
GO
--Now see data in table
select * from StudentMarks 
GO

-- Group By clause without where condition .Agrupadas por Nombre
SELECT st_Name, AVG(st_Marks) AS Media--SUM(st_Marks) AS 'Total Marks'
FROM StudentMarks
GROUP BY st_Name; 
GO

-- Group By clause with where condition
SELECT st_Name, AVG(st_Marks) AS Media
FROM StudentMarks
where st_Name='Mohan'
GROUP BY st_Name; 
GO

-- Group By clause to find max marks in subject
SELECT st_Subject,max(st_Marks) AS 'Max Marks in Subject'
FROM StudentMarks
GROUP BY st_Subject; 
GO

-- Having clause without where condition
SELECT st_Name, SUM(st_Marks) AS 'Students Scored > 205'
FROM StudentMarks
GROUP BY st_Name
HAVING SUM(st_Marks) > 205
GO

-- Having clause with where condition
SELECT st_Name, SUM(st_Marks) AS 'Students Scored > 205'
FROM StudentMarks
where st_RollNo between 1 and 3
GROUP BY st_Name
HAVING SUM(st_Marks) > 205 
GO



-- Usar las funciones SUM y AVG con una cláusula GROUP BY
-- Cuando se utiliza con una cláusula GROUP BY, cada función de agregado produce un solo valor para cada grupo, en vez de para toda la tabla. En el ejemplo siguiente se obtienen valores de resumen para cada territorio de ventas. El resumen muestra el promedio de bonificaciones recibidas por los vendedores de cada territorio y la suma de las ventas realizadas hasta la fecha en cada territorio.
USE AdventureWorks2014;
GO
SELECT TerritoryID, AVG(Bonus)as 'Average bonus',SUM(SalesYTD) as 'YTD sales'
FROM [Sales].[SalesPerson]
GROUP BY TerritoryID;
GO


A.Usar SUM para devolver datos de resumen
En los ejemplos siguientes se muestra cómo usar la función SUM para devolver datos de resumen.
USE AdventureWorks2014;
GO
SELECT Color, SUM(ListPrice), SUM(StandardCost)
FROM Production.Product
WHERE Color IS NOT NULL 
    AND ListPrice != 0.00 
    AND Name LIKE 'Mountain%'
GROUP BY Color
ORDER BY Color;


--C.Utilizar una cláusula GROUP BY con una expresión
--En el ejemplo siguiente se recuperan las ventas totales de cada año con la función DATEPART. Debe incluirse la misma expresión en la lista SELECT y en la cláusula GROUP BY.
SELECT DATEPART(yyyy,OrderDate) AS N'Year'
    ,SUM(TotalDue) AS N'Total Order Amount'
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(yyyy,OrderDate)
ORDER BY DATEPART(yyyy,OrderDate);
--D.Utilizar una cláusula GROUP BY con una cláusula HAVING
--En el ejemplo siguiente se usa la cláusula HAVING para especificar cuáles de los grupos generados en la cláusula GROUP BY deben incluirse en el conjunto de resultados.
SELECT DATEPART(yyyy,OrderDate) AS N'Year'
    ,SUM(TotalDue) AS 'Total Order Amount'
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(yyyy,OrderDate)
HAVING DATEPART(yyyy,OrderDate) >= '2003'
ORDER BY DATEPART(yyyy,OrderDate);
----------------------


E.Usar la cláusula OVER
En el ejemplo siguiente se usa la función AVG con la cláusula OVER para proporcionar una media móvil de ventas anuales para cada territorio de la tabla Sales.SalesPerson. Se crean particiones de los datos por TerritoryID y se ordenan lógicamente por SalesYTD. Esto significa que la función AVG se calcula para cada territorio en función del año de ventas. Observe que para TerritoryID 1, solo hay dos filas para el año de ventas 2005, que representan los dos vendedores con ventas durante ese año. Se calculan las ventas medias de estas dos filas y la tercera fila que representa las ventas durante el año 2006 se incluye en el cálculo.
USE AdventureWorks2014;
GO
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                           ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;
El conjunto de resultados es el siguiente.
BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           559,697.56           559,697.56
287              NULL        2006        519,905.93           539,801.75           1,079,603.50
285              NULL        2007        172,524.45           417,375.98           1,252,127.95
283              1           2005        1,573,012.94         1,462,795.04         2,925,590.07
280              1           2005        1,352,577.13         1,462,795.04         2,925,590.07
284              1           2006        1,576,562.20         1,500,717.42         4,502,152.27
275              2           2005        3,763,178.18         3,763,178.18         3,763,178.18
277              3           2005        3,189,418.37         3,189,418.37         3,189,418.37
276              4           2005        4,251,368.55         3,354,952.08         6,709,904.17
281              4           2005        2,458,535.62         3,354,952.08         6,709,904.17

(10 row(s) affected)

En este ejemplo, la cláusula OVER no incluye PARTITION BY.Esto significa que la función se aplicará a todas las filas devueltas por la consulta.La cláusula ORDER BY especificada en la cláusula OVER determina el orden lógico al que se aplica la función AVG.La consulta devuelve una media móvil de ventas por año para todos los territorios de ventas especificados en la cláusula WHERE.La cláusula ORDER BY especificada en la instrucción SELECT determina el orden en que se muestran las filas de la consulta.
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;
--------------------




B.Usar la cláusula OVER
En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar los valores agregados de cada departamento en la tabla HumanResources.Department.
USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;
El conjunto de resultados es el siguiente.
Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

 ----------------------





B.Usar la cláusula OVER
En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar valores agregados para cada departamento de la tabla HumanResources.Department.
USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;
El conjunto de resultados es el siguiente.
Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

 -----------------

 SUM

 Ejemplos
A.Usar SUM para devolver datos de resumen
En los ejemplos siguientes se muestra cómo usar la función SUM para devolver datos de resumen.
USE AdventureWorks2014;
GO
SELECT Color, SUM(ListPrice), SUM(StandardCost)
FROM Production.Product
WHERE Color IS NOT NULL 
    AND ListPrice != 0.00 
    AND Name LIKE 'Mountain%'
GROUP BY Color
ORDER BY Color;
GO
El conjunto de resultados es el siguiente.
Color
--------------- --------------------- ---------------------
Black           27404.84              5214.9616
Silver          26462.84              14665.6792
White           19.00                 6.7926
(3 row(s) affected)
B.Usar la cláusula OVER
En el ejemplo siguiente se usa la función SUM con la cláusula OVER para proporcionar un total acumulado de ventas anuales para cada territorio de la tabla Sales.SalesPerson. Se crean particiones de los datos por TerritoryID y se ordenan lógicamente por SalesYTD. Esto significa que la función SUM se calcula para cada territorio en función del año de ventas. Observe que para TerritoryID 1, solo hay dos filas para el año de ventas 2005, que representan los dos vendedores con ventas durante ese año. Se calculan las ventas acumuladas de estas dos filas y la tercera fila que representa las ventas durante el año 2006 se incluye en el cálculo.
USE AdventureWorks2014;
GO
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                           ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;
El conjunto de resultados es el siguiente.

BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           559,697.56           559,697.56
287              NULL        2006        519,905.93           539,801.75           1,079,603.50
285              NULL        2007        172,524.45           417,375.98           1,252,127.95
283              1           2005        1,573,012.94         1,462,795.04         2,925,590.07
280              1           2005        1,352,577.13         1,462,795.04         2,925,590.07
284              1           2006        1,576,562.20         1,500,717.42         4,502,152.27
275              2           2005        3,763,178.18         3,763,178.18         3,763,178.18
277              3           2005        3,189,418.37         3,189,418.37         3,189,418.37
276              4           2005        4,251,368.55         3,354,952.08         6,709,904.17
281              4           2005        2,458,535.62         3,354,952.08         6,709,904.17

(10 row(s) affected)

En este ejemplo, la cláusula OVER no incluye PARTITION BY.Esto significa que la función se aplicará a todas las filas devueltas por la consulta.La cláusula ORDER BY especificada en la cláusula OVER determina el orden lógico al que se aplica la función SUM.La consulta devuelve un total acumulado de ventas por año para todos los territorios de ventas especificados en la cláusula WHERE.La cláusula ORDER BY especificada en la instrucción SELECT determina el orden en que se muestran las filas de la consulta.
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;
El conjunto de resultados es el siguiente.
BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           2,449,684.05         17,147,788.35
275              2           2005        3,763,178.18         2,449,684.05         17,147,788.35
276              4           2005        4,251,368.55         2,449,684.05         17,147,788.35
277              3           2005        3,189,418.37         2,449,684.05         17,147,788.35
280              1           2005        1,352,577.13         2,449,684.05         17,147,788.35
281              4           2005        2,458,535.62         2,449,684.05         17,147,788.35
283              1           2005        1,573,012.94         2,449,684.05         17,147,788.35
284              1           2006        1,576,562.20         2,138,250.72         19,244,256.47
287              NULL        2006        519,905.93           2,138,250.72         19,244,256.47
285              NULL        2007        172,524.45           1,941,678.09         19,416,780.93
(10 row(s) affected)

B.Usar la cláusula OVER
En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar los valores agregados de cada departamento en la tabla HumanResources.Department.
USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;
El conjunto de resultados es el siguiente.
Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

 ----------------------





B.Usar la cláusula OVER
En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar valores agregados para cada departamento de la tabla HumanResources.Department.
USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;
El conjunto de resultados es el siguiente.
Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

 -----------------

 SUM

 Ejemplos
A.Usar SUM para devolver datos de resumen
En los ejemplos siguientes se muestra cómo usar la función SUM para devolver datos de resumen.
USE AdventureWorks2014;
GO
SELECT Color, SUM(ListPrice), SUM(StandardCost)
FROM Production.Product
WHERE Color IS NOT NULL 
    AND ListPrice != 0.00 
    AND Name LIKE 'Mountain%'
GROUP BY Color
ORDER BY Color;
GO
El conjunto de resultados es el siguiente.
Color
--------------- --------------------- ---------------------
Black           27404.84              5214.9616
Silver          26462.84              14665.6792
White           19.00                 6.7926
(3 row(s) affected)
B.Usar la cláusula OVER
En el ejemplo siguiente se usa la función SUM con la cláusula OVER para proporcionar un total acumulado de ventas anuales para cada territorio de la tabla Sales.SalesPerson. Se crean particiones de los datos por TerritoryID y se ordenan lógicamente por SalesYTD. Esto significa que la función SUM se calcula para cada territorio en función del año de ventas. Observe que para TerritoryID 1, solo hay dos filas para el año de ventas 2005, que representan los dos vendedores con ventas durante ese año. Se calculan las ventas acumuladas de estas dos filas y la tercera fila que representa las ventas durante el año 2006 se incluye en el cálculo.
USE AdventureWorks2014;
GO
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                           ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;
El conjunto de resultados es el siguiente.

BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           559,697.56           559,697.56
287              NULL        2006        519,905.93           539,801.75           1,079,603.50
285              NULL        2007        172,524.45           417,375.98           1,252,127.95
283              1           2005        1,573,012.94         1,462,795.04         2,925,590.07
280              1           2005        1,352,577.13         1,462,795.04         2,925,590.07
284              1           2006        1,576,562.20         1,500,717.42         4,502,152.27
275              2           2005        3,763,178.18         3,763,178.18         3,763,178.18
277              3           2005        3,189,418.37         3,189,418.37         3,189,418.37
276              4           2005        4,251,368.55         3,354,952.08         6,709,904.17
281              4           2005        2,458,535.62         3,354,952.08         6,709,904.17

(10 row(s) affected)

En este ejemplo, la cláusula OVER no incluye PARTITION BY.Esto significa que la función se aplicará a todas las filas devueltas por la consulta.La cláusula ORDER BY especificada en la cláusula OVER determina el orden lógico al que se aplica la función SUM.La consulta devuelve un total acumulado de ventas por año para todos los territorios de ventas especificados en la cláusula WHERE.La cláusula ORDER BY especificada en la instrucción SELECT determina el orden en que se muestran las filas de la consulta.
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;
El conjunto de resultados es el siguiente.
BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           2,449,684.05         17,147,788.35
275              2           2005        3,763,178.18         2,449,684.05         17,147,788.35
276              4           2005        4,251,368.55         2,449,684.05         17,147,788.35
277              3           2005        3,189,418.37         2,449,684.05         17,147,788.35
280              1           2005        1,352,577.13         2,449,684.05         17,147,788.35
281              4           2005        2,458,535.62         2,449,684.05         17,147,788.35
283              1           2005        1,573,012.94         2,449,684.05         17,147,788.35
284              1           2006        1,576,562.20         2,138,250.72         19,244,256.47
287              NULL        2006        519,905.93           2,138,250.72         19,244,256.47
285              NULL        2007        172,524.45           1,941,678.09         19,416,780.93
(10 row(s) affected)



--Departamento comercial necesita saber el precio de venta
-- promedio de cada producto
CREATE TABLE [dbo].[Customers](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Order Details](
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
 CONSTRAINT [PK_Order_Details] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

Use [Northwind]

Select Productid, avg(unitprice) as Precio
from [Order Details]
group by productid
order by 1
-- Mostar un listado de las ciudades en orden del numero de clientes 

select city, count(*) Numero
from customers
group by city
order by count(*) desc

USE AdventureWorks2014
GO

--Utilizar una cláusula GROUP BY simple
--En el ejemplo siguiente se recupera el total de cada SalesOrderID de la tabla SalesOrderDetail de la base de datos AdventureWorks2014.
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail 
GROUP BY SalesOrderID
ORDER BY SalesOrderID;
--B.Utilizar una cláusula GROUP BY con varias tablas
--En el ejemplo siguiente se recupera el número de empleados de cada City de la tabla Address combinada con la tabla EmployeeAddress de la base de datos AdventureWorks2014.
SELECT a.City, COUNT(bea.AddressID) EmployeeCount
FROM Person.BusinessEntityAddress AS bea 
    INNER JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
GROUP BY a.City
ORDER BY a.City;


---------------------------

Primer problema: 
Un comercio que tiene un stand en una feria registra en una tabla llamada "visitantes" algunos datos 
de las personas que visitan o compran en su stand para luego enviarle publicidad de sus productos.
1- Elimine la tabla "visitantes", si existe:
 if object_id('visitantes') is not null
  drop table visitantes;

2- Cree la tabla con la siguiente estructura:
 create table visitantes(
  nombre varchar(30),
  edad tinyint,
  sexo char(1) default 'f',
  domicilio varchar(30),
  ciudad varchar(20) default 'Cordoba',
  telefono varchar(11),
  mail varchar(30) default 'no tiene',
  montocompra decimal (6,2)
 );

3- Ingrese algunos registros:
 insert into visitantes
  values ('Susana Molina',35,default,'Colon 123',default,null,null,59.80);
 insert into visitantes
  values ('Marcos Torres',29,'m',default,'Carlos Paz',default,'marcostorres@hotmail.com',150.50);
 insert into visitantes
  values ('Mariana Juarez',45,default,default,'Carlos Paz',null,default,23.90);
 insert into visitantes (nombre, edad,sexo,telefono, mail)
  values ('Fabian Perez',36,'m','4556677','fabianperez@xaxamail.com');
 insert into visitantes (nombre, ciudad, montocompra)
  values ('Alejandra Gonzalez','La Falda',280.50);
 insert into visitantes (nombre, edad,sexo, ciudad, mail,montocompra)
  values ('Gaston Perez',29,'m','Carlos Paz','gastonperez1@gmail.com',95.40);
 insert into visitantes
  values ('Liliana Torres',40,default,'Sarmiento 876',default,default,default,85);
 insert into visitantes
  values ('Gabriela Duarte',21,null,null,'Rio Tercero',default,'gabrielaltorres@hotmail.com',321.50);

4- Queremos saber la cantidad de visitantes de cada ciudad utilizando la cláusula "group by" (4 filas devueltas)

5- Queremos la cantidad visitantes con teléfono no nulo, de cada ciudad (4 filas devueltas)

6- Necesitamos el total del monto de las compras agrupadas por sexo (3 filas)

7- Se necesita saber el máximo y mínimo valor de compra agrupados por sexo y ciudad (6 filas)

8- Calcule el promedio del valor de compra agrupados por ciudad (4 filas)

9- Cuente y agrupe por ciudad sin tener en cuenta los visitantes que no tienen mail (3 filas):

10- Realice la misma consulta anterior, pero use la palabra clave "all" para mostrar todos los 
valores de ciudad, incluyendo las que devuelven cero o "null" en la columna de agregado (4 filas)
Ver solución 

if object_id('visitantes') is not null
  drop table visitantes;

 create table visitantes(
  nombre varchar(30),
  edad tinyint,
  sexo char(1) default 'f',
  domicilio varchar(30),
  ciudad varchar(20) default 'Cordoba',
  telefono varchar(11),
  mail varchar(30) default 'no tiene',
  montocompra decimal (6,2)
 );

 insert into visitantes
  values ('Susana Molina',35,default,'Colon 123',default,null,null,59.80);
 insert into visitantes
  values ('Marcos Torres',29,'m',default,'Carlos Paz',default,'marcostorres@hotmail.com',150.50);
 insert into visitantes
  values ('Mariana Juarez',45,default,default,'Carlos Paz',null,default,23.90);
 insert into visitantes (nombre, edad,sexo,telefono, mail)
  values ('Fabian Perez',36,'m','4556677','fabianperez@xaxamail.com');
 insert into visitantes (nombre, ciudad, montocompra)
  values ('Alejandra Gonzalez','La Falda',280.50);
 insert into visitantes (nombre, edad,sexo, ciudad, mail,montocompra)
  values ('Gaston Perez',29,'m','Carlos Paz','gastonperez1@gmail.com',95.40);
 insert into visitantes
  values ('Liliana Torres',40,default,'Sarmiento 876',default,default,default,85);
 insert into visitantes
  values ('Gabriela Duarte',21,null,null,'Rio Tercero',default,'gabrielaltorres@hotmail.com',321.50);

 select ciudad, count(*)
  from visitantes
  group by ciudad;

 select ciudad, count(telefono)
  from visitantes
  group by ciudad;

 select sexo, sum(montocompra)
  from visitantes
  group by sexo;

 select sexo,ciudad,
  max(montocompra) as mayor,
  min(montocompra) as menor
  from visitantes
  group by sexo,ciudad;

 select ciudad,
  avg(montocompra) as 'promedio de compras'
  from visitantes
  group by ciudad;

 select ciudad,
  count(*) as 'cantidad con mail'
  from visitantes
  where mail is not null and
  mail<>'no tiene'
  group by ciudad;

 select ciudad,
  count(*) as 'cantidad con mail'
  from visitantes
  where mail is not null and
  mail<>'no tiene'
  group by all ciudad;


  ---------------

USE AdventureWorks2014
GO

SET NOCOUNT ON;

-- Create Sales Table   
CREATE TABLE dbo.SalesTransaction 
   (Id INT IDENTITY PRIMARY KEY
   ,CustomerName VARCHAR(65)
   ,TotalSalesAmount money
   ,SalesTypeDesc VARCHAR(200)
   ,SalesDateTime DATETIME
   ,StoreName VARCHAR(100));
GO
   
-- Add data to Sales Table
INSERT INTO dbo.SalesTransaction 
      VALUES ('John Smith', 124.23,'Software','09/2/2011 11:51:12 AM','The Software Outlet');
go
INSERT INTO dbo.SalesTransaction 
      VALUES ('Jack Thomas', 29.56,'Computer Supplies','09/2/2011 10:21:49 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sue Hunter', 89.45,'Computer Supplies','09/2/2011 2:51:56 AM','The Software Outlet');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Karla Johnson', 759.12,'Software','09/2/2011 2:54:37 PM','The Software Outlet');
      INSERT INTO dbo.SalesTransaction 
      VALUES ('Gary Clark', 81.51,'Software','09/2/2011 11:08:52 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Scott Crochet', 12345.78,'Computer Supplies','09/2/2011 3:12:37 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sheri Holtz', 12.34,'Software','09/2/2011 10:51:42 AM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Mary Lee', 101.34,'Software','09/2/2011 09:37:19 AM','Discount Software');
      INSERT INTO dbo.SalesTransaction 
      VALUES ('Sally Davisson', 871.12,'Software','09/3/2011 05:21:28 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Rod Kaplan', 2345.19,'Computer Supplies','09/3/2011 5:01:11 PM','Discount Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Sandy Roberts', 76.38,'Books','09/3/2011 4:51:57 PM','Computer Books and Software');
INSERT INTO dbo.SalesTransaction 
      VALUES ('Marc Trotter', 562.94,'Software','09/3/2011 6:51:43 PM','Computer Books and Software');
go


select getdate()
go

--(Sin nombre de columna)
--2013-03-18 20:05:00.810

Select * 
from SalesTransaction
GO
SELECT distinct StoreName
from SalesTransaction
GO

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS TotalVentasTienda
FROM dbo.SalesTransaction  
GROUP BY StoreName;

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS TotalVentasTienda
FROM dbo.SalesTransaction  
GROUP BY StoreName
ORDER BY SUM(TotalSalesAmount) DESC ;

SELECT StoreName, SalesTypeDesc
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction  
GROUP BY StoreName, SalesTypeDesc
ORDER BY SUM(TotalSalesAmount) DESC;



SELECT CONVERT(CHAR(10),SalesDateTime,101) AS FechaVentas   
     ,SUM(TotalSalesAmount) AS TotalVentas
FROM dbo.SalesTransaction
GROUP BY CONVERT(CHAR(10),SalesDateTime,101)
-- HAVING SUM(TotalSalesAmount)> 4000;


SELECT CONVERT(CHAR(10),SalesDateTime,101) AS FechaVentas   
     ,SUM(TotalSalesAmount) AS TotalVentas
FROM dbo.SalesTransaction
GROUP BY CONVERT(CHAR(10),SalesDateTime,101)
HAVING SUM(TotalSalesAmount)>3000;



SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName
HAVING SUM(TotalSalesAmount) < 1000.00;


SElect distinct storename
FROM dbo.SalesTransaction
GO

SELECT StoreName 
     ,SUM(TotalSalesAmount) AS StoreSalesAmount
FROM dbo.SalesTransaction 
GROUP BY StoreName 
HAVING StoreName LIKE '%Outlet%' 
    OR StoreName LIKE '%Books%';


























