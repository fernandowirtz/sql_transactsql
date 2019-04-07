--  Checking the Database Server Version


-- @ AT 
-- @ Variable Local         @@  Variable Global

-- @@VERSION Variable Global del Sistema

SELECT @@VERSION;
GO
PRINT @@VERSION;
GO

-- Funciones del Sistema DB_NAME()
-- Checking the Active Database Name 

select DB_NAME();
GO
USE AdventureWorks2014
GO
Print DB_NAME();
Go

-- Checking Your Username .Funciones del Sistema

SELECT ORIGINAL_LOGIN(), CURRENT_USER, SYSTEM_USER;

PRINT ORIGINAL_LOGIN()
PRINT CURRENT_USER
PRINT SYSTEM_USER



--Listar todo el contenido de una tabla/vista

--Se pueden poner todos los campos separados por coma

USE AdventureWorks2014
GO
SELECT * 
FROM HumanResources.Employee;
GO
USE master
GO
SELECT * 
FROM AdventureWorks2014.HumanResources.Employee;
GO


---Listar solo unos campos determinados 

USE AdventureWorks2014
GO

SELECT NationalIDNumber, LoginID
FROM HumanResources.Employee;
GO


--Listar solo las filas que cumplan una determinada condicion

USE AdventureWorks2014
GO

----aqui listamos las mujeres que cumplen la condicion de que el title Ms. solamente

SELECT Title ,FirstName,LastName
FROM Person.Person
GO


SELECT Title ,FirstName,LastName
FROM Person.Person
GO

-- Concatenación  : Unir Cadenas

SELECT Title ,FirstName + LastName  NombrePersona
FROM Person.Person
GO


SELECT Title ,FirstName + ' '+LastName as 'Nombre Persona '
FROM Person.Person
GO

SELECT Title AS Titulo,LastName + ', '+ FirstName AS 'Apellidos Nombre'
FROM Person.Person
GO

-- WHERE Condición  Filtro Expresiones Lógicas : Simples y Compuestas

SELECT Title,FirstName,LastName
FROM Person.Person
go



SELECT Title
FROM Person.Person
WHERE Title is NOT NULL
GO

-- Evitar Duplicados

SELECT DISTINCT Title
FROM Person.Person
GO







SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title ='Ms.';
go


SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title <> 'Ms.';
go

SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title != 'Ms.';
go



SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title is not Null ;
go





SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title is not Null ;
go

--Preguntar si un campo es de contenido NULL o NOT NULL


SELECT ProductID, Name, Weight
		FROM Production.Product
		WHERE Weight IS NULL;
Go


SELECT ProductID, Name, Weight
		FROM Production.Product
		WHERE Weight IS NOT NULL;
Go


--Aqui seleccionamos la mujer que lleve el title Ms.
--  y que su apellido sea Antrim
--- este cumple dos condiciones por lo que es una 
--expresion logica compuesta
---Expresion logica compuesta con AND

SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title = 'Ms.' 
		-- AND LastName = 'Antrim';
		OR LastName = 'Antrim';
go



--Title	FirstName	LastName
---Ms.	Ramona	    Antrim



--Aqui la condicion seria que el title fuese Ms. o Antrim por lo que muestra tanto las 
--- personas con el title Ms. y las que cumplen la condicion de que su apellido sea Antrim
-- Expresion logica compuesta con OR

SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title = 'Ms.' 
		OR LastName = 'Antrim';
go


---Ahora negamos la condicion utilizando el operador NOT
--Aqui seleccionamos todas las filas donde el campo Title
-- no sea Ms. 


SELECT Title,FirstName,LastName
FROM Person.Person
WHERE NOT Title = 'Ms.';
go



---Aqui muestra tanto los que cumplen la condicion de que su title sea Ms. 
----como los que tiene de nombre Catherine o de apellido Adams 

SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title = 'Ms.'
			AND FirstName = 'Catherine'
			OR LastName ='Adams'
go



---Aqui solo me muestra las que tienen en la columna title Ms. y como primer nombre Catherine
--por lo que cumple ambas condiciones para la seleccion

SELECT Title,FirstName,LastName
FROM Person.Person
WHERE Title = 'Ms.'
			AND FirstName = 'Catherine'
go

--Title	FirstName	LastName
--Ms.	    Catherine	 Abel
--Ms.	    Catherine	Whitney



-- Prioridad Operadores : Uso de Paréntesis
-- Cuando en una instrucción se usa más de un operador lógico, 
-- primero se evalúa NOT, luego AND y, finalmente, OR. 


SELECT Title, FirstName,LastName
FROM Person.Person
WHERE Title = 'Ms.'
		AND FirstName ='Catherine'
		OR LastName = 'Adams';
go

-- (88 filas afectadas)

SELECT Title, FirstName,LastName
		FROM Person.Person
		WHERE Title = 'Ms.'
		OR LastName = 'Adams'
		AND FirstName ='Catherine';
go
-- (415 filas afectadas)

SELECT Title, FirstName,LastName
		FROM Person.Person
		WHERE Title = 'Ms.'
		OR FirstName ='Catherine'
		AND LastName = 'Adams';
go
-- (415 filas afectadas)

SELECT ProductID, ProductModelID
FROM AdventureWorks2014.Production.Product
WHERE ProductModelID = 20 OR ProductModelID = 21
  AND Color = 'Red'


  -- PARENTHESIS

-- Se ejecuta primero la Expresión entre Paréntesis

SELECT Title, FirstName,LastName
		FROM Person.Person
		WHERE (Title ='Ms.' AND FirstName ='Catherine')
				OR LastName = 'Adams';
go

-- (88 filas afectadas)

SELECT Title, FirstName,LastName
		FROM Person.Person
		WHERE Title ='Ms.' AND (FirstName ='Catherine'
				OR LastName = 'Adams');
go
-- (4 filas afectadas)

---Cambiamos las cabeceras de los campos resultantes
-- asi identificamos mejor los campos

SELECT BusinessEntityID AS "Employee ID",
	   VacationHours AS "Vacation",
	   SickLeaveHours AS "Sick Time"
FROM HumanResources.Employee;
GO

SELECT BusinessEntityID AS Employee_ID,
	   VacationHours AS Vacation,
	   SickLeaveHours AS Sick_Time
FROM HumanResources.Employee;
GO

SELECT BusinessEntityID  Employee_ID,
	   VacationHours  Vacation,
	   SickLeaveHours  Sick_Time
FROM HumanResources.Employee;
GO
--- Cabeceras

SELECT Producto=ProductID,Name Nombre, StandardCost AS CostesStandard
FROM Production.Product
WHERE StandardCost < 100.000;
GO

-- CAMPO CALCULADO

SELECT BusinessEntityID,
  VacationHours,SickLeaveHours 
  FROM HumanResources.Employee;
GO


-- Campos Calculado
-- Cambiamos el nombre de la columna para reconocerlo mejor


SELECT BusinessEntityID, 
       VacationHours + SickLeaveHours AS AvaibleTimeOFF
  FROM HumanResources.Employee;
GO



-- ALIAS : Providing shorthand name for schemas/tables 
-- Alias E para HumanResources.Employee

SELECT E.BusinessEntityID AS "EmployeeID",
	   E.VacationHours AS "Vacation",
	   E.SickLeaveHours AS "Sick Time"
FROM   HumanResources.Employee AS E;




--TOP

SELECT JobTitle ,HireDate
FROM HumanResources.Employee
GO
-- (290 row(s) affected)


SELECT TOP 5 JobTitle ,HireDate
FROM HumanResources.Employee
GO
SELECT TOP (5)  JobTitle ,HireDate
FROM HumanResources.Employee
GO       

SELECT TOP (5) PERCENT JobTitle ,HireDate
FROM HumanResources.Employee
       

---DISTINCT : Evita el duplicado de contenidos 
       
-- Seleccionamos todo el contenido de la columna JobTitle 	

SELECT JobTitle
FROM HumanResources.Employee
GO
 -- Nos muestra el contenido sin duplicados 

SELECT DISTINCT JobTitle
FROM HumanResources.Employee
GO


-- TOP N

SELECT TOP 3  JobTitle
FROM HumanResources.Employee
GO

SELECT TOP (3)  JobTitle
FROM HumanResources.Employee
GO

SELECT TOP 10 PERCENT  JobTitle
FROM HumanResources.Employee
GO

-- TABLESAMPLE Resultados aleatorios (Random)

USE AdventureWorks2014
GO
select *
from [Sales] .[SalesOrderDetail]
GO
-- (121317 row(s) affected)

select top 1000 *
from [Sales] .[SalesOrderDetail]
GO
-- 1,000 Rows Returned
--  First 7 Rows still in the order the table was loaded

-- Instead of selecting the first 1000 rows we can use 
--the TABLESAMPLE keyword to get a random sample returned 
--from the query.  
--Adding TABLESAMPLE (1000 ROWS) tells SQL Server to 
--find random records and return approximately this number 
--of rows.  Using this example, it returned 1,183 rows.

select *
from [Sales] .[SalesOrderDetail]
TABLESAMPLE (1000 ROWS)
GO
-- (1015 row(s) affected)

--SalesOrderID	SalesOrderDetailID	CarrierTrackingNumber	OrderQty	ProductID	SpecialOfferID	UnitPrice	UnitPriceDiscount	
--LineTotal	rowguid	ModifiedDate
--43678	169	FBD8-4CE4-8B	1	765	1	419,4589	0,00	419.458900	FF26342B-D08E-4597-B38A-8BAD5E6FD8F4	2011-05-31 
--00:00:00.000
--43678	170	FBD8-4CE4-8B	2	732	1	356,898	0,00	713.796000	3F3663AD-9896-4F7C-A894-66B88A814FB8	2011-05-31 00:00:00.000
--43678	171	FBD8-4CE4-8B	3	762	1	419,4589	0,00	1258.376700	EB3B01CF-3994-47F6-9CC6-1C1E5A108713	2011-05-31 
--00:00:00.000
--43678	172	FBD8-4CE4-8B	2	761	1	419,4589	0,00	838.917800	0CF44A8C-4FD3-42E5-8A33-5C0F277E6F3D	2011-05-31 
--00:00:00.000
--43678	173	FBD8-4CE4-8B	3	712	1	5,1865	0,00	15.559500	83D229DC-F929-4EDE-A995-18BC2EE28837	2011-05-31 00:00:00.000

-- You can also limit the rows returned by the percentage of records as shown here:
select *
from [Sales] .[SalesOrderDetail]
TABLESAMPLE (10 Percent)
GO
-- 11,819 Rows Returned
--Using the TABLESAMPLE keyword is a great way to quickly look at a set of data for profiling.  This can be very helpful when beginning work on a business 
-- intelligence or data warehousing project.

--For complete information on TABLESAMPLE see MSDN: http://technet.microsoft.com/en-us/library/ms189108%28v=sql.105%29.aspx

-- Another way to get a random set of exactly 1000 thousand rows would be:
SELECT TOP 1000 *
FROM [Sales] .[SalesOrderDetail]
ORDER BY NEWID()
GO


-- Predicados 

----BETWEEN -  IN

-- BETWEEN Entre

SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '2014-07-04' 
	   AND '2014-07-05';
GO

SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '2014-07-04' 
	   AND '2014-07-05';
GO
-- BETWEEN = Entre
---Es muy utilizado para crear consultas con rango de fechas

--Sin BETWEEN con AND creando dos expresiones logicas

SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '2014-07-04' AND '2014-07-05';
GO


SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE (ShipDate >='2014-07-04') AND (ShipDate <='2014-07-05');
GO
 

 -- Números en lugar de Fechas

SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43659  AND 43662;
GO  

SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE (SalesOrderID >= 43659)  AND (SalesOrderID <= 43662)
GO 
    

 --IN Pertenencia a conjunto

 -- Preguntamos por varios colores
 
 SELECT ProductID,Name,Color
		FROM Production.Product
		WHERE Color IN ('Silver', 'Black', 'Red');
GO

-- Sustituyendo IN por OR

SELECT ProductID,Name,Color
		FROM Production.Product
		WHERE Color = 'Silver' OR Color= 'Black' OR Color = 'Red'
GO

---Aqui usamos NOT IN para que aparezcan en la consulta todos menos estos tres colores

 SELECT ProductID,Name,Color
		FROM Production.Product
		WHERE Color NOT IN ('Silver', 'Black', 'Red');
GO




---Aqui sin IN con OR se muestra o el color silver o el red o el black
--Cualquiera de las filas que cumplan con este criterio


SELECT ProductID,Name,Color
		FROM Production.Product
		WHERE (Color ='Silver')
		   OR (Color ='Black')
		   OR (Color ='Red');
GO

-- --Paging Through A Result Set 

USE [Northwind]
GO
SELECT  [LastName]+ ' ' + [FirstName] AS Nombre_Empleado
FROM Employees 
ORDER BY  [LastName] 
GO
-- 9 Rows

--Nombre_Empleado
--Buchanan Steven
--Callahan Laura
--Davolio Nancy
--Dodsworth Anne
--Fuller Andrew
--King Robert
--Leverling Janet
--Peacock Margaret
--Suyama Michael

SELECT  [LastName]+ ' ' + [FirstName] AS Nombre_Empleado
FROM Employees 
ORDER BY  [LastName] 
OFFSET 3 ROWS
GO

--Nombre_Empleado
--Callahan Laura
--Peacock Margaret
--Suyama Michael
--Davolio Nancy
--King Robert
--Buchanan Steven

SELECT  [LastName]+ ' ' + [FirstName] AS Nombre_Empleado
FROM Employees 
ORDER BY  [LastName] 
OFFSET 12 ROWS
GO
-- No Results


SELECT  [LastName]+ ' ' + [FirstName] AS Nombre_Empleado
FROM Employees 
ORDER BY  [LastName] 
OFFSET 2 ROWS FETCH NEXT 5 ROWS ONLY
GO


--Leverling Janet
--Callahan Laura
--Peacock Margaret
--Suyama Michael
--Davolio Nancy


-- Otro Ejemplo
http://dbadiaries.com/new-t-sql-features-in-sql-server-2012-offset-and-fetch
----
USE AdventureWorks2014
GO
SELECT
TransactionID
, ProductID
, TransactionDate
, Quantity
, ActualCost
FROM Production.TransactionHistory
ORDER BY TransactionDate DESC
OFFSET 5 ROWS FETCH NEXT 20 ROWS ONLY
GO
-- (20 row(s) affected)
DECLARE @OffsetRows tinyint = 7, @FetchRows tinyint = 13;
SELECT
TransactionID
, ProductID
, TransactionDate
, Quantity
, ActualCost
FROM
Production.TransactionHistory
ORDER BY TransactionDate DESC
OFFSET @OffsetRows ROWS
FETCH NEXT @FetchRows ROWS ONLY;
GO

DECLARE @OffsetRows tinyint = 0, @FetchRows tinyint = 20;
SELECT
TransactionID
, ProductID
, TransactionDate
, Quantity
, ActualCost
FROM
Production.TransactionHistory
ORDER BY TransactionDate DESC
OFFSET @OffsetRows - 0 ROWS
FETCH NEXT @FetchRows - @OffsetRows + 1 ROWS ONLY;
GO

DECLARE @OffsetRows tinyint = 0, @FetchRows tinyint = 20;
SELECT
TransactionID
, ProductID
, TransactionDate
, Quantity
, ActualCost
FROM
Production.TransactionHistory
ORDER BY TransactionDate DESC
OFFSET @OffsetRows ROWS
FETCH NEXT (SELECT 20) ROWS ONLY;
GO


--------
http://dbadiaries.com/using-select-top-with-ties-in-sql-server


-- With TIES Enlaces



USE Tempdb
GO
CREATE TABLE FamousTransformers
(ID SMALLINT PRIMARY KEY IDENTITY(1,1),
FirstName VARCHAR(100) NOT NULL,
LastName VARCHAR(100) NOT NULL,
FavouriteColour VARCHAR(50) NOT NULL);
GO
--populate with some data (6 rows to demonstrate this working)
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Clark','Kent','Blue');
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Bruce','Wayne','Black');
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Peter','Parker','Red');
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Optimus','Prime','Red');
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('David','Banner','Green');
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Rodimus','Prime','Orange');
GO

-- Añadir
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Manuel','Arias','Red');
Go
--select using normal TOP(x)

SELECT TOP (5) FirstName, LastName, FavouriteColour
FROM FamousTransformers
ORDER BY FavouriteColour
--FirstName	LastName	FavouriteColour
--Bruce	Wayne	Black
--Clark	Kent	Blue
--David	Banner	Green
--Rodimus	Prime	Orange
--Optimus	Prime	Red

-- Now we execute using WITH TIES

SELECT TOP (5) WITH TIES FirstName, LastName, FavouriteColour
FROM FamousTransformers
ORDER BY FavouriteColour
--FirstName	LastName	FavouriteColour
--Bruce	Wayne	Black
--Clark	Kent	Blue
--David	Banner	Green
--Rodimus	Prime	Orange
--Peter	Parker	Red ******************************************
--Optimus	Prime	Red

-- You must use ORDER BY and TOP clauses together if you want to use WITH TIES.
-- So you can see the extra row appearing there where “Optimus Prime” 
-- is displayed because he has the same favourite colour as “Peter Parker”.
-- The FavouriteColour column is the key here as defined in the ORDER BY 
-- statement. -

-- Con otro Registro
-- 
INSERT INTO FamousTransformers(FirstName, LastName, FavouriteColour)
VALUES('Manuel','Arias','Red');

SELECT TOP (5) WITH TIES FirstName, LastName, FavouriteColour
FROM FamousTransformers
ORDER BY FavouriteColour


--FirstName	LastName	FavouriteColour
--Bruce	Wayne		Black
--Clark	Kent	Blue
--David	Banner	Green
--Rodimus	Prime	Orange
--Manuel	Arias				Red
--Peter	Parker					Red
--Optimus	Prime				Red
-- Otro ejemplo con TIES


-- (7 row(s) affected)






-- TOP WITH TIES   SQL Server 2014

USE tempdb
GO
CREATE TABLE AggregatedClientRequests
(
    Id INT IDENTITY PRIMARY KEY,
    ClientIp VARCHAR(200) NOT NULL,
    NumOfRequests INT NOT NULL
)
GO

INSERT INTO AggregatedClientRequests (ClientIp, NumOfRequests)
VALUES
    ('1.1.1.1', 5100),
    ('2.2.2.2', 10000),
    ('3.3.3.3', 200),
    ('3.3.3.3', 44000),
    ('4.4.4.4', 2200),
    ('5.5.5.5', 10000),
    ('6.6.6.6', 31000),
    ('7.7.7.7', 100),
    ('8.8.8.8', 300),
    ('9.9.9.9', 10000)
GO

SELECT TOP (3) *
FROM AggregatedClientRequests
ORDER BY NumOfRequests DESC
GO

Id	ClientIp	NumOfRequests
4	3.3.3.3	44000
7	6.6.6.6	31000
2	2.2.2.2	10000


SELECT TOP (3) WITH TIES *
FROM AggregatedClientRequests
ORDER BY NumOfRequests DESC

Id	ClientIp	NumOfRequests
4	3.3.3.3	44000
7	6.6.6.6	31000
6	5.5.5.5	10000
2	2.2.2.2	10000
10	9.9.9.9	10000

That looks right… or does it? What about the ClientIps ‘5.5.5.5’ and ‘9.9.9.9’ ? They also generated 10.000 requests, so they are actually equally to the 
‘2.2.2.2’ ip. So which one of the three with 10.000 request should I return?. If I want those returned as well (think of a use case where the top three are 
sales persons that should have a bonus), how could I do that? That’s actually pretty simple by using the TOP WITH TIES clause like this:

Notice that I actually get 5 rows returned, even though my TOP clause stated that I only wanted three! The WITH TIES clause looks at the last row of the TOP 
(3) rows, and add all other rows with identical values.



-- See more at: http://dbadiaries.com/using-select-top-with-ties-in-sql-server#sthash.dYa2Mwup.dpuf

-----------------

-- Funciones de Conversion CONVERT - CAST
-- Funciones de Fecha Year Month Day
-- Variante CONVERT


SELECT SalesOrderID,year(ShipDate)+ ' - '+ month(ShipDate)+' - '+ day(ShipDate) 
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '2014-07-04 00:00:00.000'  AND '2014-07-05 00:00:00.000';
GO

--75053        2026
--75054        2026
--75055        2026
--75056        2026
--75057        2026
--75058        2026
--75059        2026
--75060        2026

-- -- Variante CONVERT

SELECT SalesOrderID,convert(varchar(30),year(ShipDate))+ ' - '
+ convert(varchar(30),month(ShipDate))+' - '+ 
convert(varchar(30), day(ShipDate)) AS Fecha
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '2014-07-04'  AND '2014-07-05';
GO

-- Variante CAST

SELECT SalesOrderID,cast(year(ShipDate)as varchar(30))+ ' - '+ 
cast(month(ShipDate) as varchar(30) )+' - '+ 
cast(day(ShipDate) as varchar(30)) AS Fecha
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '2014-07-04'  AND '2014-07-05';
GO

SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
go
SELECT SalesOrderID,ShipDate
FROM Sales.SalesOrderHeader
WHERE ShipDate BETWEEN '04/07/2014' AND '05/07/2014';
GO


-- En los ejemplos siguientes se usa CAST en la primera instrucción SELECT y CONVERT en la segunda instrucción SELECT para convertir la columna Title en una columna nvarchar(20) y reducir así la longitud de los títulos.

USE AdventureWorks2014;
GO
SELECT CAST(Title AS nvarchar(20)) AS Title, Revision
FROM Production.Document
GO
SELECT CAST(Title AS nvarchar(20)) AS Title, Revision
FROM Production.Document
WHERE Revision < 2 ;
GO

-- O bien-

USE AdventureWorks2014;
GO
SELECT CONVERT(nvarchar(20), Title) AS Title, Revision
FROM Production.Document
WHERE Revision < 2 ;
GO

SELECT 
   GETDATE() AS UnconvertedDateTime,
   CAST(GETDATE() AS nvarchar(30)) AS UsingCast,
   CONVERT(nvarchar(30), GETDATE(), 126) AS UsingConvertTo_ISO8601  ;
GO


-- Use CAST
USE AdventureWorks2014;
GO
SELECT SUBSTRING(Name, 1, 30) AS ProductName, ListPrice
FROM Production.Product
WHERE CAST(ListPrice AS int) LIKE '3%';
GO

-- Use CONVERT.
USE AdventureWorks2014;
GO
SELECT SUBSTRING(Name, 1, 30) AS ProductName, ListPrice
FROM Production.Product
WHERE CONVERT(int, ListPrice) LIKE '3%';
GO

USE AdventureWorks2014;
GO
SELECT 'The list price is ' + CAST(ListPrice AS varchar(12)) AS ListPrice
FROM Production.Product
WHERE ListPrice BETWEEN 350.00 AND 400.00;
GO
