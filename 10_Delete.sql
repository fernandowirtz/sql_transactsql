-- http://chancrovsky.blogspot.com.es/2015/01/delete-y-truncate.html
-- http://www.wilsonmar.com/sql_adventureworks.htm

-- Borrar tabla Completa (Definición y contenido)   DROP TABLE NombreTabla

-- Trabajando con Borrado de registros
--

USE AdventureWorks2014
GO
-- Creamos una tabla  para las pruebas de borrado
SELECT *
INTO Pruebas
FROM Sales.SalesPersonQuotaHistory ;
GO

-- Contamos el número de registros que hay en la tabla antes del borrado

SELECT COUNT(*) Registros
FROM dbo.Prueba ;
GO

-- Borramos todos los registros de la tabla
DELETE
FROM dbo.Pruebas;
GO
-- 
DELETE Pruebas
GO

DROP TABLE Pruebas
GO
-- Contamos el número de registros que hay en la tabla después del borrado
SELECT COUNT(*)
FROM dbo.Prueba ;
GO


--
USE AdventureWorks2014
GO

-- Creamos una tabla para las pruebas de borrado

SELECT *
INTO HistorialProductos
FROM Production.ProductCostHistory ;
GO
-- Contamos el número de registros que hay en la tabla antes del borrado
SELECT COUNT(*) as Productos
FROM dbo.HistorialProductos ;
GO
-- Borrar Todos los registros de la Tabla
DELETE FROM HistorialProductos
GO
SELECT*
FROM dbo.HistorialProductos ;
GO
DROP TABLE HistorialProductos
GO
DELETE HistorialProductos
GO


-- Borrado selectivo de registros

DELETE FROM HistorialProductos
WHERE standardCost > 1000.00 ;
GO



-- Contamos el número de registros que hay en la tabla después del borrado

SELECT COUNT(*)
FROM dbo.HistorialProductos ;
GO
--
--
USE pubs
GO
-- Creamos una tabla  para las pruebas de borrado
SELECT *
INTO TituloAutores
FROM titleauthor ;
GO
SELECT * FROM TituloAutores
GO

SELECT title_id
FROM titles
WHERE title LIKE '%computer%'
--title_id
--PS1372
--BU1111
--BU7832
--MC3026
--BU2075

-- Borrado selectivo de registros en base al resultado de una consulta

-- MAL
DELETE FROM TituloAutores
WHERE title_id = (SELECT title_id
		FROM titles
		WHERE title LIKE '%computer%' );
GO

--Msg 512, Level 16, State 1, Line 103
--Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
--The statement has been terminated.

DELETE FROM TituloAutores
WHERE title_id IN (SELECT title_id
		FROM titles
		WHERE title LIKE '%computer%' );
GO






-- Contamos el número de registros que hay en la tabla después del borrado

SELECT COUNT(*)
FROM TituloAutores ;
GO
--
--
USE Northwind
GO

-- Creamos una tabla  para las pruebas de borrado
SELECT *
INTO DetallesPedido
FROM [Order Details] ;
	
-- Contamos el número de registros que hay en la tabla antes del borrado
SELECT COUNT(*)
FROM DetallesPedido ;
GO

DELETE DetallesPedido
FROM orders JOIN DetallesPedido
ON orders.orderId = DetallesPedido.orderId
WHERE orderdate < '07-10-1996'
      AND shippedDate IS NOT NULL ;

-- Contamos el número de registros que hay en la tabla después del borrado
SELECT COUNT(*)
FROM DetallesPedido ;
GO

-- Usando Clausula Output
-- Histórico de Productos Borrados
-- Tablas : InventarioProducto y HistoricoBorrado

USE AdventureWorks2014
GO
-- Creamos una tabla InventarioProducto para las pruebas de borrado
-- Tabla InventarioProducto

-- DROP Tables

DROP TABLE HistoricoBorrado
GO
DROP TABLE InventarioProducto
GO

------
SELECT *
INTO InventarioProducto
FROM Production.ProductInventory ;
GO
-- 1069 Filas

SELECT * From InventarioProducto
GO

-- La creo con la misma estructura que tabla InventarioProducto 
-- pero vacia (WHERE 1=0) .Incumplimiento condición

SELECT *
INTO HistoricoBorrado
FROM Production.ProductInventory 
WHERE 1=0;
GO


SELECT * FROM HistoricoBorrado
GO

-- First DELETE
DELETE InventarioProducto
	OUTPUT DELETED.*
	INTO HistoricoBorrado
	WHERE LocationID= 50
GO
--DELETE InventarioProducto
--	OUTPUT DELETED.ProductID,deleted.LocationID
--	INTO HistoricoBorrado
--GO
SELECT * 
from HistoricoBorrado
order by LocationID

GO
-- Second DELETE
DELETE InventarioProducto
	OUTPUT DELETED.*
	INTO HistoricoBorrado
	WHERE LocationID= 6
GO
SELECT * 
from HistoricoBorrado
order by LocationID

-----------------------------------


-- Contamos el número de registros que hay en la tabla antes del borrado

SELECT COUNT(*)
FROM InventarioProducto ;
	
-- Borramos el 2.5% de los registros de la tabla

DELETE TOP (2.5) PERCENT
FROM InventarioProducto ;
	
-- Contamos el número de registros que hay en la tabla después del borrado

SELECT COUNT(*)
FROM InventarioProducto ;
	
---DELETE con clausula OUTPUT DELETED
DELETE InventarioProducto
	OUTPUT DELETED.* 
GO



-- Mostraría los registros que son borrados, en este caso no se impide su borrado
DELETE Sales.ShoppingCartItem
	OUTPUT DELETED.* 
	;
DELETE Sales.ShoppingCartItem
	OUTPUT DELETED.* 
	INTO HistoricoBorrado
	GO
	;


-- Verificamos que se han borrado los registros
SELECT COUNT(*) AS 'Filas en la tabla'
	FROM Sales.ShoppingCartItem ;

--
--


-- DELETE con clausula OUTPUT DELETED


drop table Produc
go
select *
into Produc
from Productos
go

Select * 
from Produc
go

drop table Produc_History
go
select *
into Produc_History
from Productos
go

delete Produc_History
go
select * from Produc_History

Delete Produc
OUTPUT deleted.* 
into Produc_History
go

select * from Produc_History


-------------
--TRUNCATE

--Escribe en Archivo de LOG (Transaction Log) menos.
--Por esto : Ventaja : Más rápida
--			Inconveniente : No ROLLBACK (Falso) . No WHERE

-- NOTE: 
--  TRUNCATE TABLE statement also removes all rows from a table. 
--  TRUNCATE TABLE has several advantages over DELETE, when used to remove all rows from a table.
--  TRUNCATE TABLE uses less transaction log space, requires fewer locks, and leaves zero pages 
--   for the table.

-- SINTAXIS

TRUNCATE TABLE 
    [ { database_name .[ schema_name ] . | schema_name . } ]
    table_name
[ ; ]

USE AdventureWorks2014
GO

SELECT *
INTO Candidatos
FROM HumanResources.JobCandidate ;

-- Contamos el número de registros que hay en la tabla antes del borrado

SELECT COUNT(*) AS BeforeTruncateCount
FROM Candidatos ;

-- Eliminamos el contenido de la tabla

TRUNCATE TABLE Candidatos ;

-- Contamos el número de registros que hay en la tabla después del borrado

SELECT COUNT(*) AS AfterTruncateCount
FROM Candidatos ;

-- https://www.mssqltips.com/sqlservertip/4248/differences-between-delete-and-truncate-in-sql-server/

-- DELETE / TRUNCATE with ROLLBACK


USE tempdb
GO
CREATE TABLE Employee
(
Empid int IDENTITY NOT NULL,
Name nchar(10) NULL,
City nchar(10) NULL
) ON [PRIMARY]
GO
--Command(s) completed successfully.
insert into Employee values ('Pepe','Lugo') ,
							('Luis','Coruña')
GO 
-- (2 row(s) affected)
select * from Employee
GO
-- Now we have a table with dummy records. Now let’s do a DELETE inside a TRANSACTION and see if we can rollback
BEGIN TRANSACTION
--select * from employee
DELETE from Employee where Empid=1
SELECT * from Employee
GO
-- We deleted the record where the Empid equals 1 and now we have only one record:

-- Let’s try to rollback and see if we can recover the deleted record:
ROLLBACK TRANSACTION
SELECT * from employee

-- As you can see below, we have the record back.

-- Let’s try the same for TRUNCATE:

begin transaction
truncate table Employee 
select * from Employee

-- Now we have truncated the table and have no records, the table is empty:

-- Let’s try to rollback and see if we can get the records back. Run the below command and see what you get:

ROLLBACK TRANSACTION
select * from Employee
-- As you can see below, we got the records back.

--So we can rollback DELETE as well TRUNCATE if the commands are started inside a transaction and there is no difference between DELETE and TRUNCATE if we are talking about rollback. Try on your own and let me know if you experience any issues.

--Differences between the SQL Server DELETE and TRUNCATE Commands

--Truncate reseeds identity values, whereas delete doesn't.
--Truncate removes all records and doesn't fire triggers.
--Truncate is faster compared to delete as it makes less use of the transaction log.
--Truncate is not possible when a table is referenced by a Foreign Key or tables are used in replication or with indexed views.


----------------------------------

-- https://www.simple-talk.com/sql/learn-sql-server/the-delete-statement-in-sql-server/

USE AdventureWorks2014;
 
EXEC sp_rename '[Sales].[Sales.SalesTerritory]', 'Sales.SalesTerritory'
GO

-- No Funciona sp_rename

-- Cambiar [Sales].[vSalesPerson] por Sales.TerritorioVentas
-- Problem
CREATE ViEW Sales.TerritorioVentas
AS
SELECT        s.BusinessEntityID, p.Title, p.FirstName, p.MiddleName, p.LastName, p.Suffix, e.JobTitle, pp.PhoneNumber, pnt.Name AS PhoneNumberType, ea.EmailAddress, p.EmailPromotion, a.AddressLine1, 
                         a.AddressLine2, a.City, sp.Name AS StateProvinceName, a.PostalCode, cr.Name AS CountryRegionName, st.Name AS TerritoryName, st.[Group] AS TerritoryGroup, s.SalesQuota, s.SalesYTD, 
                         s.SalesLastYear
FROM            Sales.SalesPerson AS s INNER JOIN
                         HumanResources.Employee AS e ON e.BusinessEntityID = s.BusinessEntityID INNER JOIN
                         Person.Person AS p ON p.BusinessEntityID = s.BusinessEntityID INNER JOIN
                         Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = s.BusinessEntityID INNER JOIN
                         Person.Address AS a ON a.AddressID = bea.AddressID INNER JOIN
                         Person.StateProvince AS sp ON sp.StateProvinceID = a.StateProvinceID INNER JOIN
                         Person.CountryRegion AS cr ON cr.CountryRegionCode = sp.CountryRegionCode LEFT OUTER JOIN
                         Sales.[Sales.SalesTerritory] AS st ON st.TerritoryID = s.TerritoryID LEFT OUTER JOIN
                         Person.EmailAddress AS ea ON ea.BusinessEntityID = p.BusinessEntityID LEFT OUTER JOIN
                         Person.PersonPhone AS pp ON pp.BusinessEntityID = p.BusinessEntityID LEFT OUTER JOIN
                         Person.PhoneNumberType AS pnt ON pnt.PhoneNumberTypeID = pp.PhoneNumberTypeID
GO


USE AdventureWorks2014;
 
IF OBJECT_ID ('SalesStaff', 'U') IS NOT NULL
DROP TABLE SalesStaff;
 
CREATE TABLE SalesStaff
(
  StaffID INT NOT NULL PRIMARY KEY,
  FirstName NVARCHAR(50) NOT NULL,
  LastName NVARCHAR(50) NOT NULL,
  CountryRegion NVARCHAR(50) NOT NULL
);
 
INSERT INTO SalesStaff
SELECT BusinessEntityID, FirstName,
  LastName, CountryRegionName
FROM [Sales].[TerritorioVentas];
GO

DELETE SalesStaff;

DELETE FROM SalesStaff;

-- NOTE: TRUNCATE TABLE statement also removes all rows from a table. 
-- TRUNCATE TABLE has several advantages over DELETE, when used to remove all rows from a table.
--  TRUNCATE TABLE uses less transaction log space, requires fewer locks, and leaves zero pages 
-- for the table.

DELETE TOP (20) PERCENT
FROM SalesStaff;

DELETE FROM SalesStaff
WHERE [LastName] LIKE 'Cath*'
GO

DELETE SalesStaff
WHERE StaffID IN
  (
    SELECT BusinessEntityID
    FROM [Sales].[TerritorioVentas]
    WHERE SalesLastYear = 0
  );

  DELETE SalesStaff
FROM Sales.vSalesPerson sp
  INNER JOIN dbo.SalesStaff ss
  ON sp.BusinessEntityID = ss.StaffID
WHERE sp.SalesLastYear = 0;

DELETE ss
FROM Sales.vSalesPerson sp
  INNER JOIN dbo.SalesStaff ss
  ON sp.BusinessEntityID = ss.StaffID
WHERE sp.SalesLastYear = 0;


WITH cteSalesPerson
  AS
  (
    SELECT BusinessEntityID
    FROM Sales.vSalesPerson
    WHERE SalesLastYear = 0
  )
DELETE SalesStaff
FROM cteSalesPerson sp
  INNER JOIN dbo.SalesStaff ss
  ON sp.BusinessEntityID = ss.StaffID;


  WITH cteSalesPerson
  AS
  (
    SELECT BusinessEntityID
    FROM Sales.vSalesPerson
    WHERE SalesLastYear = 0
  )
DELETE SalesStaff
WHERE StaffID IN
  (SELECT* FROM cteSalesPerson);

DECLARE @Output table
(
  StaffID INT,
  FirstName NVARCHAR(50),
  LastName NVARCHAR(50),
  CountryRegion NVARCHAR(50)
);
DELETE SalesStaff
OUTPUT DELETED.* INTO @Output
FROM Sales.vSalesPerson sp
  INNER JOIN dbo.SalesStaff ss
  ON sp.BusinessEntityID = ss.StaffID
WHERE sp.SalesLastYear = 0;
SELECT * FROM @output;

