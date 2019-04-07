-- http://www.sql-server-helper.com/faq/views-p01.aspx

-- https://www.simple-talk.com/sql/learn-sql-server/sql-server-system-views-the-basics/

-- VIEW (=VISTA)
-- Es una Tabla Virtual (depende de la/s tabla/s Base).

-- Nota : Tabla o TablaS (la vista puede ser el resultado de una consulta multitabla)

-- Uso: 

--			Seguridad (sólo presenta a los usuarios los datos que quieres que vean)
				-- Ejemplo: Tabla Nomina 
						-- Vistas: Administrativos(no ven algunas columnas)
									  -- Departamento Contabilidad (no ven algunas filas)
									  -- Jefe de Contabilidad (ve toda la información)

--			Mejorar Gestión de la Información (Por ejemplo,en lugar de una subconsualta compleja
						-- generanos una vista y, sobre la vista, hacemos consulta más simple)


-- Primero: Creación de VISTAS desde SSMS (GUI = Graphical User Interface)


-- Desde Transact-SQL
USE pubs
GO
-- Hint:
-- Do not use * to create Views

CREATE VIEW todos
AS
	SELECT *
	FROM dbo.authors
GO

SELECT * 
FROM todos
GO
----------
IF OBJECTPROPERTY( OBJECT_ID( 'todos' ), 'IsView' ) = 1
    PRINT 'Object is a view'
-- In this script, the OBJECTPROPERY metadata function will return a value 
-- of 1 if the object is a view.  
-- Otherwise, it will return a value of 0.  If the object passed to the 
-- function is not a valid object in the current database, 
-- the function will return a value of NULL.
GO

SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('[HumanResources].[vEmployeeDepartment]'); 
GO
USE Pubs
USE AdventureWorks2014
GO
SELECT OBJECT_DEFINITION (OBJECT_ID('[HumanResources].[vEmployeeDepartment]')) 
	AS ObjectDefinition; 
GO

EXEC sp_helptext '[HumanResources].[vEmployeeDepartment]';
GO

sp_depends '[HumanResources].[vEmployeeDepartment]'
GO
--------------------
ALTER VIEW todos (id_autor,id_apellidos,id_telefono)
AS
	SELECT au_id,au_lname,phone
	FROM dbo.authors
	WHERE state ='CA'
GO
SELECT * 
FROM todos
GO
DROP VIEW Todos
GO

-- View 2 Tables
USE AdventureWorks2014 ; 
GO
CREATE VIEW HumanResources.EmployeeHireDate
AS
	SELECT p.FirstName, p.LAStName, e.HireDate
	FROM HumanResources.Employee AS e JOIN Person.Person AS  p
	ON e.BusinessEntityID = p.BusinessEntityID ; 
GO
-- Query the view
SELECT FirstName, lastName, HireDate
FROM HumanResources.EmployeeHireDate
ORDER BY lastName;

-------------------
 
-- Try Out Insert in Table

SELECT [au_lname],[au_fname]
INTO Nombres_Autores
FROM Authors
GO
-- (23 filas afectadas)
SELECT * 
FROM Nombres_Autores 
ORDER BY [au_lname]
GO
sp_depends 'vNombres_Autores'
GO
IF OBJECT_ID('vNombres_Autores','V') is Not Null
	DROP VIEW vNombres_Autores
GO
CREATE VIEW vNombres_Autores ([au_lname],[au_fname])
AS
	SELECT [au_lname],[au_fname]
	FROM Nombres_Autores
GO

SELECT * 
FROM vNombres_Autores 
ORDER BY [au_lname]
GO

-- Try Out Insert . First OK - Second Fail     in Nombres_Autores
INSERT INTO vNombres_Autores
VALUES ('Arias','Luis')
GO
-- INSERT afecto a la TABLA BASE Nombres_Autores
SELECT * 
FROM Nombres_Autores 
ORDER BY [au_lname]
GO
INSERT INTO vNombres_Autores
VALUES ('Garcia')
GO
--Mens. 213, Nivel 16, Estado 1, Línea 1
--El nombre de columna o los valores especificados no corresponden a la definición de la tabla.

-- WITHOUT CHECK OPTION
CREATE VIEW vNombres_Autores1 
AS
	SELECT [au_lname],[au_fname]
	FROM Nombres_Autores
	WHERE [au_fname] LIKE 'A%'
GO
-- (5 filAS afectadAS)
SELECT * 
FROM vNombres_Autores1 
ORDER BY [au_lname]
GO
-- Problema : Inserta en la Tabla usando la Vista sin cumplir su definición 
-- WHERE [au_fname] LIKE 'A%'

INSERT INTO vNombres_Autores1
VALUES ('Zapata','Pepe')
GO
SELECT * 
FROM Nombres_Autores  
-- where au_lname = 'Zapata'
GO
SELECT * FROM vNombres_Autores1 ORDER BY [au_lname]
GO
-- En la Vista no aparece

DELETE vNombres_Autores1
WHERE [au_lname] = 'Zapata'
GO
-- (0 row(s) affected)
UPDATE vNombres_Autores1
SET au_lname = 'Zapa'
WHERE [au_lname] = 'Zapata'
GO
-- (0 row(s) affected)
SELECT * 
FROM Nombres_Autores 
ORDER BY [au_lname] DESC
GO
-- WITH CHECK OPTION
IF OBJECT_ID('vNombres_Autores2','V') is Not Null
	DROP VIEW vNombres_Autores2
GO
CREATE VIEW vNombres_Autores2 
AS
	SELECT [au_lname],[au_fname]
	FROM Nombres_Autores
	WHERE [au_fname] LIKE 'A%'
	WITH CHECK OPTION
GO
SELECT * FROM vNombres_Autores2 
GO
-- Insert OK
 INSERT INTO vNombres_Autores2
 VALUES ('Zapata','Ana')
GO
-- (1 row(s) affected)
SELECT * FROM vNombres_Autores2 
GO
-- Insert Fail
INSERT INTO vNombres_Autores2
 VALUES ('Zapata','Emiliano')
GO
--Msg 550, Level 16, State 1, Line 137
--The attempted insert or update failed because the target view either specifies 
-- WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
--The statement has been terminated.



-- Source Code Plain Text

sp_helptext 'vNombres_Autores2'
GO

-- WITH ENCRYPTION

ALTER VIEW vNombres_Autores2 
WITH ENCRYPTION
AS
	SELECT [au_lname],[au_fname]
	FROM Nombres_Autores
	WHERE [au_lname] LIKE 'A%'
GO
sp_helptext 'vNombres_Autores2'
GO
-- The text for object 'vNombres_Autores2' is encrypted.

-- SCHEMABINDING
-- WITHOUT SCHEMABINDING

IF OBJECT_ID('Algunos_Autores','U') is Not Null
	DROP TABLE Algunos_Autores
GO
SELECT [au_lname],[au_fname]
INTO Algunos_Autores
FROM Authors
GO
IF OBJECT_ID('vAlgunos_Autores','V') is Not Null
	DROP VIEW vAlgunos_Autores
GO
CREATE VIEW vAlgunos_Autores ([au_lname],[au_fname])
AS
	SELECT [au_lname],[au_fname]
	FROM Algunos_Autores
GO
-- DROP TABLE
DROP TABLE Algunos_Autores
GO
INSERT INTO vAlgunos_Autores
VALUES ('Lopez','Pedro')
GO

--Msg 208, Level 16, State 1, Procedure vAlgunos_Autores, Line 188
--Invalid object name 'Algunos_Autores'.
--Msg 4413, Level 16, State 1, Line 185
--Could not use view or function 'vAlgunos_Autores' because of binding errors.


--  WITH SCHEMABINDING

IF OBJECT_ID('Algunos_Autores','U') is Not Null
	DROP TABLE Algunos_Autores
GO
SELECT [au_lname],[au_fname]
INTO Algunos_Autores
FROM Authors
GO
IF OBJECT_ID('vAlgunos_Autores','V') is Not Null
	DROP VIEW vAlgunos_Autores
GO
CREATE VIEW vAlgunos_Autores ([au_lname],[au_fname])
WITH SCHEMABINDING
AS
	SELECT [au_lname],[au_fname]
	FROM Algunos_Autores
GO
-- HINT
--Msg 4512, Level 16, State 3, Procedure vAlgunos_Autores, Line 210
--Cannot schema bind view 'vAlgunos_Autores' because name 'Algunos_Autores' is invalid for schema binding. Names must be in two-part format and an object cannot reference itself.
-- Add dbo.
CREATE VIEW vAlgunos_Autores ([au_lname],[au_fname])
WITH SCHEMABINDING
AS
	SELECT [au_lname],[au_fname]
	FROM dbo.Algunos_Autores        -- Hay que poner el nombre de esquema
GO
-- Try Out DROP TABLE 
DROP TABLE Algunos_Autores
GO

--Msg 3729, Level 16, State 1, Line 224
--Cannot DROP TABLE 'Algunos_Autores' because it is being referenced 
-- by object 'vAlgunos_Autores'.

-- Funciones de Agregado. Group by, TOP y otras

CREATE VIEW vTitulosMedia (categoria, precio_medio)
AS
	SELECT type, avg(price)
	FROM titles
	group by type
GO

SELECT * 
FROM vTitulosMedia
GO
-- Using built-in functions within a view
--The following example shows a view definition that includes a built-in function. When you USE functions, you must specify a column name for the derived column.
USE AdventureWorks2014;
GO
IF OBJECT_ID ('Sales.SalesPersonPerform', 'V') IS NOT NULL
    DROP VIEW Sales.SalesPersonPerform ;
GO
CREATE VIEW Sales.SalesPersonPerform
AS
	SELECT TOP 100 SalesPersonID, SUM(TotalDue) AS 	TotalSales
	FROM Sales.SalesOrderHeader
	WHERE OrderDate > CONVERT(DATETIME,'20001231',101)
	GROUP BY SalesPersonID;
GO
SELECT * 
FROM Sales.SalesPersonPerform
GO

-----------------
-- Fin Clase
------------------------
-- http://www.sql-server-helper.com/faq/views-p01.aspx

-- 4.  How can I create a view that combines the records from 2 tables where the tables have different number of columns?
-- To create a view that combines the records from 2 tables, you will be using the UNION ALL operator.

CREATE VIEW [dbo].[AllEmployees]
AS
SELECT [EmployeeID], [Name]
FROM [dbo].[OldEmployees]
UNION ALL
SELECT [EmployeeID], [Name]
FROM [dbo].[Employees]
GO
-- Just make sure that the output of both SELECT statements involved in the UNION ALL operator have the same number of columns.  If they don't have the same number of columns, you will get the following error message:

CREATE VIEW [dbo].[AllEmployees]
AS
SELECT [EmployeeID], [Name], [LastEmploymentDate]
FROM [dbo].[OldEmployees]
UNION ALL
SELECT [EmployeeID], [Name]
FROM [dbo].[Employees]
GO

--Server: Msg 8157, Level 16, State 1, Procedure AllEmployees, Line 4
--All the queries in a query expression containing a UNION operator 
--must have the same number of expressions in their select lists.
--If the tables you are trying to combine doesn't have the same number of columns just like the example above, what you can do is to put in fillers in place of those extra columns from the other table.  In the example above, since the [dbo].[Employees] table only contain active employees and therefore don't have a column for the [LastEmploymentDate], you can simply return a NULL value for that column as the filler:

CREATE VIEW [dbo].[AllEmployees]
AS
SELECT [EmployeeID], [Name], [LastEmploymentDate]
FROM [dbo].[OldEmployees]
UNION ALL
SELECT [EmployeeID], [Name], NULL AS [LastEmploymentDate]
FROM [dbo].[Employees]
GO
-- Do this for each column that does not exist in the other table.  You can also do it for both tables if a column in the second table does not exist in the first table.

----------------
CREATE VIEW vVentAS
AS
	SELECT * 
	FROM Sales
GO

UPDATE vVentAS 
SET qty = 13
WHERE stor_id = 6380
GO

SELECT * 
FROM Sales 
WHERE stor_id = 6380 

.. Actualizados 2 registros en la TABLA BASE Sales

-- Modificar VistAS

ALTER VIEW vVentAS
AS
	SELECT * 
	FROM Sales
	WHERE stor_id = 6380
GO
SP_HELPTEXT vVentAS
-----

- Filtrando columnAS y filAS
CREATE VIEW vAutoresParcial
AS
	SELECT [au_lname],[au_fname]
	FROM authors
	where state = 'UT'
GO
SELECT * 
FROM vAutoresParcial
GO
sp_HELPTEXT vAutoresParcial
GO

-- Borrar variAS vistAS con una única sentencia

DROP VIEW vVentAS,vAutoresParcial,todos 





------
sp_help "todos"
GO
sp_helptext 'todos'
GO
sp_depends 'todos'
GO

-- cREAR vISTA CON ALGUNOS CAMPOS Y CON where

CREATE VIEW todos_los_autores 
AS 
	SELECT * 
	FROM dbo.authors;
GO

-- Borramos lAS 2 VistAS

drop view todos_los_autores , todos
------------------
-- Vista con variAS tablAS

USE northwind;
GO
CREATE VIEW customer_orders
AS
	SELECT o.orderid, c.companyname, c.contactname 
	FROM orders o join customers c 
	on o.customerid = c.customerid;
GO

-- Compruebo la Vista
SELECT *  
FROM customer_orders
GO

-- Uso Procedimientos Almacenados del Sistema

sp_help "customer_orders"
GO
sp_helptext 'customer_orders'
GO
sp_depends 'customer_orders'
GO


drop view customer_orders


-- Borrar variAS vistAS al mismo tiempo

drop view todos_los_autores , todos



----------------



-- With [HumanResources].[vEmployeeDepartment]

CREATE VIEW [HumanResources].[vEmployeeDepartment] 
AS 
SELECT 
    e.[BusinessEntityID] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,e.[JobTitle]
    ,d.[Name] AS [Department] 
    ,d.[GroupName] 
    ,edh.[StartDate] 
FROM [HumanResources].[Employee] e
	INNER JOIN [Person].[Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh 
    ON e.[BusinessEntityID] = edh.[BusinessEntityID] 
    INNER JOIN [HumanResources].[Department] d 
    ON edh.[DepartmentID] = d.[DepartmentID] 
WHERE edh.EndDate IS NULL
GO



USE adventureworks2014;
GO
CREATE VIEW v_product_costs
AS
SELECT productid, name, standardcost
FROM production.product
GO

SELECT * FROM v_product_costs
GO

alter view v_product_costs
AS
SELECT productid, productsubcateGOryid, name, productnumber, standardcost
FROM production.product

drop view v_product_costs

--esta é unha vista sobre unha vista e faGO esquema binding conexión
CREATE VIEW v_product_costs_2
AS
SELECT name, standardcost 
FROM v_product_costs

SELECT * FROM v_product_costs_2

drop view v_product_costs

SELECT * FROM v_product_costs_2

drop view v_product_costs_2

------------
--SCHEMABINDING 
--Binds the view to the schema of the underlying table or tables. When SCHEMABINDING is specified, the bASe table or tables cannot be modified in a way that would affect the view definition. The view definition itself must first be modified or dropped to remove dependencies on the table that is to be modified. When you USE SCHEMABINDING, the SELECT_statement must include the two-part names (schema.object) of tables, views, or USEr-defined functions that are referenced. All referenced objects must be in the same databASe.

--Views or tables that participate in a view created with the SCHEMABINDING claUSE
---- cannot be dropped unless that view is dropped or changed so that it no longer hAS 
----schema binding. Otherwise, the Microsoft SQL Server DatabASe Engine raises an error. Also, executing ALTER TABLE statements on tables that participate in views that have schema binding fail when these statements affect the view definition.

--SCHEMABINDING cannot be specified if the view contains aliAS data type columns.

--What does this mean?

--To put it simply, once you create a view with schemabinding, you cannot change the underlying tables in a way that would break the view.  
--Examples of this would be removing columns or dropping tables that are specified in the view
-----------------
USE Pubs
GO
-- Ejemplo SchemaBinding
DROP Table Autor
GO
SELECT * 
INTO AUTOR
FROM Authors

DROP VIEW VpruebAS
GO
CREATE VIEW VpruebAS
	AS
	SELECT *
	FROM Autor ;
	
DROP TABLE Autor ;

SELECT *
	FROM VpruebAS ;


--Mens. 4413, Nivel 16, Estado 1, Línea 2
--No se pudo usar la vista o función 'VpruebAS' debido a errores de enlace.


CREATE VIEW VpruebAS2
	WITH SCHEMABINDING
	AS
	SELECT [au_id],[au_lname],[au_fname]
	FROM dbo.Autor ;
	
DROP TABLE dbo.Autor ;


--Mens. 3729, Nivel 16, Estado 1, Línea 1
--No se puede DROP TABLE 'dbo.Autor' porque se le hace referencia en el objeto 'VpruebAS2'.

SELECT *
	FROM VpruebAS2 ;

--

------------------------
-- WITH SCHEMABINDING


-- Creamos Tabla EmployeeAddresses

USE adventureworks2014
GO

-- SELECT / INTO

SELECT c.FirstName, c.LAStName, e.JobTitle, a.AddressLine1, a.City, 
    sp.Name AS [State/Province], a.PostalCode
INTO dbo.EmployeeAddresses
FROM Person.Person AS c
    JOIN HumanResources.Employee AS e 
    ON e.BusinessEntityID = c.BusinessEntityID
    JOIN Person.BusinessEntityAddress AS bea
    ON e.BusinessEntityID = bea.BusinessEntityID
    JOIN Person.Address AS a
    ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp 
    ON sp.StateProvinceID = a.StateProvinceID;
GO

SELECT Top 20 * 
FROM EmployeeAddresses
GO
-- 


CREATE VIEW vistaesquema
AS
	SELECT * 
	FROM EmployeeAddresses
GO
drop table  EmployeeAddresses
GO
SELECT *
 FROM vistaesquema
GO

--Msg 208, Level 16, State 1, Procedure vistaesquema, Line 4
--Invalid object name 'EmployeeAddresses'.
--Msg 4413, Level 16, State 1, Line 2
--Could not USE view or function 'vistaesquema' becaUSE of binding errors.

CREATE VIEW vistaesquema
 with schemabinding
AS
SELECT * 
FROM EmployeeAddresses
GO

--Msg 1054, Level 15, State 6, Procedure vistaesquema, Line 3
--Syntax '*' is not allowed in schema-bound objects.

drop view vistaesquema
GO
CREATE VIEW vistaesquema with schemabinding
AS
SELECT FirstName, LAStName
FROM EmployeeAddresses
GO

--Msg 4512, Level 16, State 3, Procedure vistaesquema, Line 3
--Cannot schema bind view 'vistaesquema' becaUSE name 'EmployeeAddresses' 
----is invalid for schema binding. Names must be in two-part format 
-- and an object cannot reference itself.


-- Sin with schemabinding

DROP VIEW vistaesquema 
GO
CREATE VIEW vistaesquema 
AS
	SELECT FirstName, LAStName
	FROM dbo.EmployeeAddresses
GO

sp_helptext 'vistaesquema'
GO
drop table dbo.EmployeeAddresses
 

-- Command(s) completed successfully.
 
SELECT * FROM vistaesquema;
GO

--Msg 208, Level 16, State 1, Procedure vistaesquema, Line 4
--Invalid object name 'dbo.EmployeeAddresses'.
--Msg 4413, Level 16, State 1, Line 1
--Could not USE view or function 'vistaesquema' becaUSE of binding errors.

 
-- Con with schemabinding

DROP VIEW vistaesquema

-- SELECT / INTO

SELECT c.FirstName, c.LAStName, e.JobTitle, a.AddressLine1, a.City, 
    sp.Name AS [State/Province], a.PostalCode
INTO dbo.EmployeeAddresses
FROM Person.Person AS c
    JOIN HumanResources.Employee AS e 
    ON e.BusinessEntityID = c.BusinessEntityID
    JOIN Person.BusinessEntityAddress AS bea
    ON e.BusinessEntityID = bea.BusinessEntityID
    JOIN Person.Address AS a
    ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp 
    ON sp.StateProvinceID = a.StateProvinceID;
GO

CREATE VIEW vistaesquema 
with schemabinding
AS
	SELECT FirstName, LAStName  -- NO SE PUEDE PONER *
	FROM dbo.EmployeeAddresses
GO

sp_helptext 'vistaesquema'
GO
drop table dbo.EmployeeAddresses
GO

--Msg 3729, Level 16, State 1, Line 1
--Cannot DROP TABLE 'dbo.EmployeeAddresses' becaUSE it is being referenced 
--by object 'vistaesquema'.

--Probar con ALTER VIEW
alter  view vistaesquema 
AS
SELECT FirstName, LAStName
FROM dbo.EmployeeAddresses
GO
drop table dbo.EmployeeAddresses
GO
-- Command(s) completed successfully.

SELECT * FROM vistaesquema
GO


--Msg 208, Level 16, State 1, Procedure vistaesquema, Line 4
--Invalid object name 'dbo.EmployeeAddresses'.
--Msg 4413, Level 16, State 1, Line 1
--Could not USE view or function 'vistaesquema' becaUSE of binding errors.

CREATE VIEW dbo.v_product_costs with schemabinding
AS
SELECT productid, productsubcateGOryid, name, productnumber, standardcost
FROM production.product

CREATE VIEW v_product_costs_2  with schemabinding
AS
SELECT name, standardcost 
FROM dbo.v_product_costs
GO


----------------------

-- A.Usar una instrucción CREATE VIEW sencilla

-- En el ejemplo siguiente se crea una vista mediante una instrucción SELECT sencilla. Una vista sencilla resulta útil cuando se consulta con frecuencia una combinación de columnAS. Los datos de esta vista provienen de lAS tablAS HumanResources.Employee y Person.Person de la bASe de datos AdventureWorks2014. Los datos proporcionan el nombre e información sobre la fecha de contratación de los empleados de Adventure Works Cycles. Esta vista puede crearse para la persona responsable del seguimiento de los aniversarios de trabajo pero sin concederle acceso a todos los datos de estAS tablAS.

USE adventureworks2014 ;
GO
IF OBJECT_ID ('hiredate_view', 'V') IS NOT NULL
DROP VIEW hiredate_view ;
GO
CREATE VIEW hiredate_view
AS 
SELECT p.FirstName, p.LAStName, e.BusinessEntityID, e.HireDate
FROM HumanResources.Employee e 
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID ;
GO
sp_helptext 'hiredate_view'
GO
sp_depends 'hiredate_view'
GO
USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('Sales.SalesPersonPerform', 'V') IS NOT NULL
    DROP VIEW Sales.SalesPersonPerform ;
GO
CREATE VIEW Sales.SalesPersonPerform
AS
SELECT TOP (100) SalesPersonID, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE OrderDate > CONVERT(DATETIME,'20001231',101)
GROUP BY SalesPersonID;
GO

--with ENCRYPTION, SCHEMABINDING, CHECK OPTION


-- Using WITH ENCRYPTION

USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('PurchASing.PurchASeOrderReject', 'V') IS NOT NULL
    DROP VIEW PurchASing.PurchASeOrderReject ;
GO

-- Using WITH ENCRYPTION


CREATE VIEW PurchASing.PurchASeOrderReject
WITH ENCRYPTION
AS
	SELECT PurchASeOrderID, ReceivedQty, RejectedQty, 
    			RejectedQty / ReceivedQty AS RejectRatio, DueDate
	FROM PurchASing.PurchASeOrderDetail
	WHERE RejectedQty / ReceivedQty > 0
		AND DueDate > CONVERT(DATETIME,'20010630',101) ;
GO
sp_helptext 'PurchASing.PurchASeOrderReject'

-- The text for object 'PurchASing.PurchASeOrderReject' is encrypted.


-- Using WITH CHECK OPTION

-- C.Usar WITH CHECK OPTION

-- En el siguiente ejemplo se muestra una vista denominada SeattleOnly que hace referencia a cinco tablAS y permite modificar datos aplicados únicamente a los empleados que viven en Seattle.

USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('dbo.SeattleOnly', 'V') IS NOT NULL
    DROP VIEW dbo.SeattleOnly ;
GO
CREATE VIEW dbo.SeattleOnly
AS
SELECT p.LAStName, p.FirstName, e.JobTitle, a.City, sp.StateProvinceCode
FROM HumanResources.Employee e
INNER JOIN Person.Person p
ON p.BusinessEntityID = e.BusinessEntityID
    INNER JOIN Person.BusinessEntityAddress bea 
    ON bea.BusinessEntityID = e.BusinessEntityID 
    INNER JOIN Person.Address a 
    ON a.AddressID = bea.AddressID
    INNER JOIN Person.StateProvince sp 
    ON sp.StateProvinceID = a.StateProvinceID
WHERE a.City = 'Seattle'
WITH CHECK OPTION ;
GO



--Example: Create a view on databASe pubs for table authors, 
--that shows the name, phone number and state FROM all authors FROM California.
USE Pubs
GO
drop table authors
GO
SELECT *
INTO autores1
FROM autores
GO
drop table autores
GO
SELECT *
INTO autores
FROM autores1
GO
SELECT * FROM autores
GO
drop view dbo.AuthorsCA
GO
CREATE VIEW dbo.AuthorsUT
AS
	SELECT au_id, au_fname, au_lname, phone, state, contract
	FROM dbo.autores
	WHERE state = 'UT' 
GO
SELECT * FROM dbo.AuthorsUT
GO
--This is an updatable view and a USEr can change any column, even the state column:

UPDATE AuthorsUT
SET state='NY'
-- (2 filAS afectadAS)
SELECT state
 FROM autores
GO


--(15 filAS afectadAS)
--After this UPDATE there will be no authors FROM California. This might not be the desired behavior.

--Example: Same AS above but the state column cannot be changed.
drop view dbo.AuthorsCA2
GO
CREATE VIEW dbo.AuthorsUT2
AS
	SELECT au_id, au_fname, au_lname, phone, state, contract
	FROM dbo.autores
	WHERE state = 'UT'
	With Check Option -- Hay que ponerlo aqui no arriba
GO
-- The view is still updatable, except for the state column:

UPDATE AuthorsUT2
SET state='NY'

--Mens. 550, Nivel 16, Estado 1, Línea 1
--Error en la inserción o actualización debido a que la vista de destino especifica WITH CHECK OPTION o alcanza una vista con esta opción, y una o más filAS resultantes de la operación no se califican con la restricción CHECK OPTION.
--Se terminó la instrucción.



----
-- WITH CHECK OPTION
USE pubs
GO

CREATE VIEW dbo.AuthorsCA
	AS
	SELECT au_id, au_fname, au_lname, phone, state, contract
	FROM dbo.authors
	WHERE state = 'ca' ;
GO

UPDATE AuthorsCA 
SET state = 'NY'
WHERE ...... 

ALTER VIEW dbo.AuthorsCA2
	AS
	SELECT au_id, au_fname, au_lname, phone, state, contract
	FROM dbo.authors
	WHERE state = 'ca'
	WITH CHECK OPTION 

SELECT *
	FROM dbo.AuthorsCA2 ;
GO

UPDATE AuthorsCA2 
SET state = 'NY'
WHERE ...... 
GO


ERROR !!!!!

---
---
CREATE VIEW dbo.CheckPerson
AS
SELECT person_id, person_name, country
FROM dbo.Person
WHERE country= ‘Italy’

This is an updatable view, we can change even the country:

 

UPDATE CheckPerson SET country=’Russia’

After this UPDATE, there will be no persons FROM Italy.

But if we write the view like this:

CREATE VIEW dbo.CheckPerson
AS
SELECT person_id, person_name, country
FROM dbo.Person
WHERE country= ‘Italy’ 
 With Check Option

If we try to UPDATE the view(same UPDATE) we’ll get an error.

Error message:
Server: Msg 550, Level 16, State 1, Line 1
The attempted insert or UPDATE failed becaUSE the target view either
specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK
OPTION and one or more rows resulting FROM the operation did not qualify
under the CHECK OPTION constraint.
The statement hAS been terminated.

----------------------------

The following example shows a view named SeattleOnly that references five tables and allows for data modifications to apply only to employees who live in Seattle


 USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('dbo.SeattleOnly', 'V') IS NOT NULL
    DROP VIEW dbo.SeattleOnly ;
GO
CREATE VIEW dbo.SeattleOnly
AS
SELECT p.LAStName, p.FirstName, e.JobTitle, a.City, sp.StateProvinceCode
FROM HumanResources.Employee e
	INNER JOIN Person.Person p
	ON p.BusinessEntityID = e.BusinessEntityID
    INNER JOIN Person.BusinessEntityAddress bea 
    ON bea.BusinessEntityID = e.BusinessEntityID 
    INNER JOIN Person.Address a 
    ON a.AddressID = bea.AddressID
    INNER JOIN Person.StateProvince sp 
    ON sp.StateProvinceID = a.StateProvinceID
WHERE a.City = 'Seattle'
WITH CHECK OPTION ;
GO





---------------

--Es posible obligar a todAS lAS instrucciones de modificación de datos que se ejecutan en una vista a cumplir ciertos criterios.

--Por ejemplo, creamos la siguiente vista:

 CREATE VIEW vista_empleados
 AS
  SELECT apellido, e.nombre, sexo, s.nombre AS seccion
  FROM empleados AS e
  join secciones AS s
  on seccion=codiGO
  where s.nombre='Administracion'
  with check option;

--La vista definida anteriormente muestra solamente algunos de los datos de los empleados de la sección "Administracion". 
--Además, solamente se permiten modificaciones a los empleados de esa sección.

--Podemos actualizar el nombre, apellido y sexo a través de la vista, pero no el campo "seccion" porque está restringuido.

--Problema:

--Una empresa almacena la información de sus empleados en dos tablAS llamadAS "empleados" y "secciones".
--Eliminamos lAS tablAS, si existen:

 if object_id('empleados') is not null
  drop table empleados;
 if object_id('secciones') is not null
  drop table secciones;


 create table secciones(
  codiGO tinyint identity,
  nombre varchar(20),
  sueldo decimal(5,2)
   constraint CK_secciones_sueldo check (sueldo>=0),
  constraint PK_secciones primary key (codiGO)
 );

 create table empleados(
  legajo int identity,
  documento char(8)
   constraint CK_empleados_documento check (documento like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  sexo char(1)
   constraint CK_empleados_sexo check (sexo in ('f','m')),
  apellido varchar(20),
  nombre varchar(20),
  domicilio varchar(30),
  seccion tinyint not null,
  cantidadhijos tinyint
   constraint CK_empleados_hijos check (cantidadhijos>=0),
  estadocivil char(10)
   constraint CK_empleados_estadocivil check (estadocivil in ('cASado','divorciado','soltero','viudo')),
  fechaingreso datetime,
   constraint PK_empleados primary key (legajo),
  constraint FK_empleados_seccion
   foreign key (seccion)
   references secciones(codiGO)
   on UPDATE cAScade,
  constraint UQ_empleados_documento
   unique(documento)
 );

 insert INTO secciones values('Administracion',300);
 insert INTO secciones values('Contaduría',400);
 insert INTO secciones values('SistemAS',500);

 insert INTO empleados values('22222222','f','Lopez','Ana','Colon 123',1,2,'cASado','1990-10-10');
 insert INTO empleados values('23333333','m','Lopez','Luis','Sucre 235',1,0,'soltero','1990-02-10');
 insert INTO empleados values('24444444','m','Garcia','Marcos','Sarmiento 1234',2,3,'divorciado','1998-07-12');
 insert INTO empleados values('25555555','m','GOmez','Pablo','Bulnes 321',3,2,'cASado','1998-10-09');
 insert INTO empleados values('26666666','f','Perez','Laura','Peru 1254',3,3,'cASado','2000-05-09');

-- Eliminamos la vista "vista_empleados" si existe:

 if object_id('vista_empleados') is not null
  drop view vista_empleados;
 

--Creamos la vista "vista_empleados", que es resultado de una combinación:

--Es posible obligar a todAS lAS instrucciones de modificación de datos que se ejecutan en una vista a cumplir ciertos criterios.
--Por ejemplo, creamos la siguiente vista:

 CREATE VIEW vista_empleados
 AS
  SELECT apellido, e.nombre, sexo, s.nombre AS seccion
  FROM empleados AS e
  join secciones AS s
  on seccion=codiGO
  where s.nombre='Administracion'
  with check option;

Consultamos la vista:

 SELECT *FROM vista_empleados;

Actualizamos el nombre de un empleado a través de la vista:

 UPDATE vista_empleados set nombre='Beatriz' where nombre='Ana';

Veamos si la modificación se realizó en la tabla:

 SELECT *FROM empleados;

if object_id('empleados') is not null
  drop table empleados;
 if object_id('secciones') is not null
  drop table secciones;

 create table secciones(
  codiGO tinyint identity,
  nombre varchar(20),
  sueldo decimal(5,2)
   constraint CK_secciones_sueldo check (sueldo>=0),
  constraint PK_secciones primary key (codiGO)
 );

 create table empleados(
  legajo int identity,
  documento char(8)
   constraint CK_empleados_documento check (documento like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  sexo char(1)
   constraint CK_empleados_sexo check (sexo in ('f','m')),
  apellido varchar(20),
  nombre varchar(20),
  domicilio varchar(30),
  seccion tinyint not null,
  cantidadhijos tinyint
   constraint CK_empleados_hijos check (cantidadhijos>=0),
  estadocivil char(10)
   constraint CK_empleados_estadocivil check (estadocivil in ('cASado','divorciado','soltero','viudo')),
  fechaingreso datetime,
   constraint PK_empleados primary key (legajo),
  constraint FK_empleados_seccion
   foreign key (seccion)
   references secciones(codiGO)
   on UPDATE cAScade,
  constraint UQ_empleados_documento
   unique(documento)
 );

 insert INTO secciones values('Administracion',300);
 insert INTO secciones values('Contaduría',400);
 insert INTO secciones values('SistemAS',500);

 insert INTO empleados values('22222222','f','Lopez','Ana','Colon 123',1,2,'cASado','1990-10-10');
 insert INTO empleados values('23333333','m','Lopez','Luis','Sucre 235',1,0,'soltero','1990-02-10');
 insert INTO empleados values('24444444','m','Garcia','Marcos','Sarmiento 1234',2,3,'divorciado','1998-07-12');
 insert INTO empleados values('25555555','m','GOmez','Pablo','Bulnes 321',3,2,'cASado','1998-10-09');
 insert INTO empleados values('26666666','f','Perez','Laura','Peru 1254',3,3,'cASado','2000-05-09');

 if object_id('vista_empleados') is not null
  drop view vista_empleados;

 CREATE VIEW vista_empleados
 AS
  SELECT apellido, e.nombre, sexo, s.nombre AS seccion
  FROM empleados AS e
  join secciones AS s
  on seccion=codiGO
  where s.nombre='Administracion'
  with check option;

 SELECT *FROM vista_empleados;

 UPDATE vista_empleados set nombre='Beatriz' where nombre='Ana';

 SELECT *FROM empleados;

------------------

Primer problema:

Una empresa almacena la información de sus clientes en dos tablAS llamadAS "clientes" y "ciudades".
1- Elimine lAS tablAS, si existen:
 if object_id('clientes') is not null
  drop table clientes;
 if object_id('ciudades') is not null
  drop table ciudades;

2- Cree lAS tablAS:
 create table ciudades(
  codiGO tinyint identity,
  nombre varchar(20),
  constraint PK_ciudades
   primary key (codiGO)
 );

 create table clientes(
  nombre varchar(20),
  apellido varchar(20),
  documento char(8),
  domicilio varchar(30),
  codiGOciudad tinyint
   constraint FK_clientes_ciudad
    foreign key (codiGOciudad)
   references ciudades(codiGO)
   on UPDATE cAScade
 );

3- Ingrese algunos registros:
 insert INTO ciudades values('Cordoba');
 insert INTO ciudades values('Carlos Paz');
 insert INTO ciudades values('Cruz del Eje');
 insert INTO ciudades values('La Falda');

 insert INTO clientes values('Juan','Perez','22222222','Colon 1123',1);
 insert INTO clientes values('Karina','Lopez','23333333','San Martin 254',2);
 insert INTO clientes values('Luis','Garcia','24444444','CASeros 345',1);
 insert INTO clientes values('Marcos','GOnzalez','25555555','Sucre 458',3);
 insert INTO clientes values('Nora','Torres','26666666','Bulnes 567',1);
 insert INTO clientes values('Oscar','Luque','27777777','San Martin 786',4);

4- Elimine la vista "vista_clientes" si existe:
 if object_id('vista_clientes') is not null
  drop view vista_clientes;

5- Cree la vista "vista_clientes" para que recupere el nombre, apellido, documento, domicilio, el 
códiGO y nombre de la ciudad a la cual pertenece, de la ciudad de "LuGO" empleando "with check 
option".

6- Consulte la vista:
 SELECT *FROM vista_clientes;

7- Actualice el apellido de un cliente a través de la vista.

8- Verifique que la modificación se realizó en la tabla:
 SELECT *FROM clientes;

9- Intente cambiar la ciudad de algún registro.
Mensaje de error.

USE tempo
GO
if object_id('clientes') is not null
  drop table clientes;
 if object_id('ciudades') is not null
  drop table ciudades;

 create table ciudades(
  codiGO tinyint identity,
  nombre varchar(20),
  constraint PK_ciudades
   primary key (codiGO)
 );

 create table clientes(
  nombre varchar(20),
  apellido varchar(20),
  documento char(8),
  domicilio varchar(30),
  codiGOciudad tinyint
   constraint FK_clientes_ciudad
    foreign key (codiGOciudad)
   references ciudades(codiGO)
   on UPDATE cAScade
 );

 insert INTO ciudades values('LuGO');
 insert INTO ciudades values('Coruña');
 insert INTO ciudades values('Oviedo');
 insert INTO ciudades values('Pontevedra');

 insert INTO clientes values('Juan','Perez','22222222','Colon 1123',1);
 insert INTO clientes values('Karina','Lopez','23333333','San Martin 254',2);
 insert INTO clientes values('Luis','Garcia','24444444','CASeros 345',1);
 insert INTO clientes values('Marcos','GOnzalez','25555555','Sucre 458',3);
 insert INTO clientes values('Nora','Torres','26666666','Bulnes 567',1);
 insert INTO clientes values('Oscar','Luque','27777777','San Martin 786',4);

 if object_id('vista_clientes') is not null
  drop view vista_clientes;

CREATE VIEW vista_clientes
 AS
  SELECT apellido, cl.nombre, documento, domicilio, cl.codiGOciudad,ci.nombre AS ciudad
  FROM clientes AS cl
  join ciudades AS ci
  on codiGOciudad=codiGO
  where ci.nombre='LuGO'
  with check option;

 SELECT *
 FROM vista_clientes;

 UPDATE vista_clientes
  set apellido='Pereyra' 
  where documento='22222222';

 SELECT *FROM clientes;

 UPDATE vista_clientes 
 set codiGOciudad=2 
 where documento='22222222';

Msg 550, Level 16, State 1, Line 1
The attempted insert or UPDATE failed becaUSE the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting FROM the operation did not qualify under the CHECK OPTION constraint.
The statement hAS been terminated.

-----------------

Example: Create a view on databASe pubs for table authors, that shows the name, phone number and state FROM all authors FROM California. This is very simple:

CREATE VIEW dbo.AuthorsCA
AS
SELECT au_id, au_fname, au_lname, phone, state, contract
FROM dbo.authors
WHERE state = 'ca'

This is an updatable view and a USEr can change any column, even the state column:

UPDATE AuthorsCA SET state='NY'

After this UPDATE there will be no authors FROM California. This might not be the desired behavior.

Example: Same AS above but the state column cannot be changed.

CREATE VIEW dbo.AuthorsCA2
AS
SELECT au_id, au_fname, au_lname, phone, state, contract
FROM dbo.authors
WHERE state = 'ca'
With Check Option

The view is still updatable, except for the state column:

UPDATE AuthorsCA2 SET state='NY'

This will caUSE an error and the state will not be changed.

-------------------

Si se modifican los datos de una vista, se modifica la tabla bASe.

Se puede insertar, actualizar o eliminar datos de una tabla a través de una vista, teniendo en cuenta lo siguiente, lAS modificaciones que se realizan a lAS vistAS:

- no pueden afectar a más de una tabla consultada. Pueden modificarse datos de una vista que combina variAS tablAS pero la modificación solamente debe afectar a una sola tabla.

- no se pueden cambiar los campos resultado de un cálculo.

- pueden generar errores si afectan a campos a lAS que la vista no hace referencia. Por ejemplo, si se ingresa un registro en una vista que consulta una tabla que tiene campos not null que no están incluidos en la vista.

- la opción "with check option" obliga a todAS lAS instrucciones de modificación que se ejecutan en la vista a cumplir ciertos criterios que se especifican al definir la vista.

- para eliminar datos de una vista solamente UNA tabla puede ser listada en el "FROM" de la definicion de la misma.

Problema:

Una empresa almacena la información de sus empleados en dos tablAS llamadAS "empleados" y "secciones".
Eliminamos lAS tablAS, si existen:

 if object_id('empleados') is not null
  drop table empleados;
 if object_id('secciones') is not null
  drop table secciones;

Creamos lAS tablAS:

 create table secciones(
  codiGO tinyint identity,
  nombre varchar(20),
  sueldo decimal(5,2)
   constraint CK_secciones_sueldo check (sueldo>=0),
  constraint PK_secciones primary key (codiGO)
 );

 create table empleados(
  legajo int identity,
  documento char(8)
   constraint CK_empleados_documento check (documento like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  sexo char(1)
   constraint CK_empleados_sexo check (sexo in ('f','m')),
  apellido varchar(20),
  nombre varchar(20),
  domicilio varchar(30),
  seccion tinyint not null,
  cantidadhijos tinyint
   constraint CK_empleados_hijos check (cantidadhijos>=0),
  estadocivil char(10)
   constraint CK_empleados_estadocivil check (estadocivil in ('cASado','divorciado','soltero','viudo')),
  fechaingreso datetime,
   constraint PK_empleados primary key (legajo),
  sueldo decimal(6,2),
  constraint FK_empleados_seccion
   foreign key (seccion)
   references secciones(codiGO)
   on UPDATE cAScade,
  constraint UQ_empleados_documento
   unique(documento)
);

Ingresamos algunos registros:

 insert INTO secciones values('Administracion',300);
 insert INTO secciones values('Contaduría',400);
 insert INTO secciones values('SistemAS',500);

 insert INTO empleados values('22222222','f','Lopez','Ana','Colon 123',1,2,'cASado','1990-10-10',600);
 insert INTO empleados values('23333333','m','Lopez','Luis','Sucre 235',1,0,'soltero','1990-02-10',650);
 insert INTO empleados values('24444444', 'm', 'Garcia', 'Marcos', 'Sarmiento 1234', 2, 3, 'divorciado', '1998-07-12',800);
 insert INTO empleados values('25555555','m','GOmez','Pablo','Bulnes 321',3,2,'cASado','1998-10-09',900);
 insert INTO empleados values('26666666','f','Perez','Laura','Peru 1254',3,3,'cASado','2000-05-09',700);

Eliminamos la vista "vista_empleados" si existe:

 if object_id('vista_empleados') is not null
  drop view vista_empleados;
 

Creamos la vista "vista_empleados", que es resultado de una combinación en la cual se muestran 5 campos:

 CREATE VIEW vista_empleados AS
  SELECT (apellido+' '+e.nombre) AS nombre,sexo,
   s.nombre AS seccion, cantidadhijos
   FROM empleados AS e
   join secciones AS s
   on codiGO=seccion;

Vemos la información contenida en la vista:

 SELECT *FROM vista_empleados;

Eliminamos la vista "vista_empleados2" si existe:

 if object_id('vista_empleados2') is not null
  drop view vista_empleados2;

Creamos otra vista de "empleados" denominada "vista_empleados2" que consulta solamente la tabla "empleados" con "with check option":

 CREATE VIEW vista_empleados2
  AS
  SELECT nombre, apellido,fechaingreso,seccion,estadocivil,sueldo
   FROM empleados
  where sueldo>=600
  with check option;

Consultamos la vista:

 SELECT *FROM vista_empleados2;

Ingresamos un registro en la vista "vista_empleados2":

 insert INTO vista_empleados2 values('Pedro','Perez','2000-10-10',1,'cASado',800);

No es posible insertar un registro en la vista "vista_empleados" porque el campo de la vista "nombre" es un campo calculado.

Actualizamos la sección de un registro de la vista "vista_empleados":

 UPDATE vista_empleados set seccion='SistemAS' where nombre='Lopez Ana';

Si intentamos actualizar el nombre de un empleado no lo permite porque es una columna calculada.

Actualizamos el nombre de un registro de la vista "vista_empleados2":

 UPDATE vista_empleados2 set nombre='Beatriz' where nombre='Ana';

Verifique que se actualizó la tabla:

 SELECT *FROM empleados;

Eliminamos un registro de la vista "vista_empleados2":

 delete FROM vista_empleados2 where apellido='Lopez';

Si podemos eliminar registros de la vista "vista_empleados2" dicha vista solamente consulta una tabla. No podemos eliminar registros de la vista "vista_empleados" porque hay variAS tablAS en su definición.

if object_id('empleados') is not null
  drop table empleados;
 if object_id('secciones') is not null
  drop table secciones;

 create table secciones(
  codiGO tinyint identity,
  nombre varchar(20),
  sueldo decimal(5,2)
   constraint CK_secciones_sueldo check (sueldo>=0),
  constraint PK_secciones primary key (codiGO)
 );

 create table empleados(
  legajo int identity,
  documento char(8)
   constraint CK_empleados_documento check (documento like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  sexo char(1)
   constraint CK_empleados_sexo check (sexo in ('f','m')),
  apellido varchar(20),
  nombre varchar(20),
  domicilio varchar(30),
  seccion tinyint not null,
  cantidadhijos tinyint
   constraint CK_empleados_hijos check (cantidadhijos>=0),
  estadocivil char(10)
   constraint CK_empleados_estadocivil check (estadocivil in ('cASado','divorciado','soltero','viudo')),
  fechaingreso datetime,
   constraint PK_empleados primary key (legajo),
  sueldo decimal(6,2),
  constraint FK_empleados_seccion
   foreign key (seccion)
   references secciones(codiGO)
   on UPDATE cAScade,
  constraint UQ_empleados_documento
   unique(documento)
 );

 insert INTO secciones values('Administracion',300);
 insert INTO secciones values('Contaduría',400);
 insert INTO secciones values('SistemAS',500);

 insert INTO empleados values('22222222','f','Lopez','Ana','Colon 123',1,2,'cASado','1990-10-10',600);
 insert INTO empleados values('23333333','m','Lopez','Luis','Sucre 235',1,0,'soltero','1990-02-10',650);
 insert INTO empleados values('24444444', 'm', 'Garcia', 'Marcos', 'Sarmiento 1234', 2, 3, 'divorciado', '1998-07-12',800);
 insert INTO empleados values('25555555','m','GOmez','Pablo','Bulnes 321',3,2,'cASado','1998-10-09',900);
 insert INTO empleados values('26666666','f','Perez','Laura','Peru 1254',3,3,'cASado','2000-05-09',700);

 if object_id('vista_empleados') is not null
  drop view vista_empleados;

 CREATE VIEW vista_empleados AS
  SELECT (apellido+' '+e.nombre) AS nombre,sexo,
   s.nombre AS seccion, cantidadhijos
   FROM empleados AS e
   join secciones AS s
   on codiGO=seccion;

 SELECT *FROM vista_empleados;

 if object_id('vista_empleados2') is not null
  drop view vista_empleados2;

 CREATE VIEW vista_empleados2
  AS
  SELECT nombre, apellido,fechaingreso,seccion,estadocivil,sueldo
   FROM empleados
  where sueldo>=600
  with check option;

 SELECT *FROM vista_empleados2;

 insert INTO vista_empleados2 values('Pedro','Perez','2000-10-10',1,'cASado',800);

 UPDATE vista_empleados set seccion='SistemAS' where nombre='Lopez Ana';

 UPDATE vista_empleados2 set nombre='Beatriz' where nombre='Ana';

 SELECT *FROM empleados;

 delete FROM vista_empleados2 where apellido='Lopez';

--------------

Primer problema:

Un club dicta cursos de distINTOs deportes. Almacena la información en variAS tablAS.
1- Elimine lAS tabla "inscriptos", "socios" y "cursos", si existen:
 if object_id('inscriptos') is not null  
  drop table inscriptos;
 if object_id('socios') is not null  
  drop table socios;
 if object_id('cursos') is not null  
  drop table cursos;

2- Cree lAS tablAS:
 create table socios(
  documento char(8) not null,
  nombre varchar(40),
  domicilio varchar(30),
  constraint PK_socios_documento
   primary key (documento)
 );

 create table cursos(
  numero tinyint identity,
  deporte varchar(20),
  dia varchar(15),
   constraint CK_inscriptos_dia check (dia in('lunes','martes','miercoles','jueves','viernes','sabado')),
  profesor varchar(20),
  constraint PK_cursos_numero
   primary key (numero),
 );

 create table inscriptos(
  documentosocio char(8) not null,
  numero tinyint not null,
  matricula char(1),
  constraint PK_inscriptos_documento_numero
   primary key (documentosocio,numero),
  constraint FK_inscriptos_documento
   foreign key (documentosocio)
   references socios(documento)
   on UPDATE cAScade,
  constraint FK_inscriptos_numero
   foreign key (numero)
   references cursos(numero)
   on UPDATE cAScade
  );

3- Ingrese algunos registros para todAS lAS tablAS:
 insert INTO socios values('30000000','Fabian Fuentes','CASeros 987');
 insert INTO socios values('31111111','GASton Garcia','Guemes 65');
 insert INTO socios values('32222222','Hector Huerta','Sucre 534');
 insert INTO socios values('33333333','Ines Irala','Bulnes 345');

 insert INTO cursos values('tenis','lunes','Ana Acosta');
 insert INTO cursos values('tenis','martes','Ana Acosta');
 insert INTO cursos values('natacion','miercoles','Ana Acosta');
 insert INTO cursos values('natacion','jueves','Carlos CASeres');
 insert INTO cursos values('futbol','sabado','Pedro Perez');
 insert INTO cursos values('futbol','lunes','Pedro Perez');
 insert INTO cursos values('bASquet','viernes','Pedro Perez');

 insert INTO inscriptos values('30000000',1,'s');
 insert INTO inscriptos values('30000000',3,'n');
 insert INTO inscriptos values('30000000',6,null);
 insert INTO inscriptos values('31111111',1,'s');
 insert INTO inscriptos values('31111111',4,'s');
 insert INTO inscriptos values('32222222',1,'s');
 insert INTO inscriptos values('32222222',7,'s');

4- Realice un join para mostrar todos los datos de todAS lAS tablAS, sin repetirlos:
 SELECT documento,nombre,domicilio,c.numero,deporte,dia, profesor,matricula
  FROM socios AS s
  join inscriptos AS i
  on s.documento=documentosocio
  join cursos AS c
  on c.numero=i.numero;

5- Elimine, si existe, la vista "vista_cursos":
 if object_id('vista_cursos') is not null
  drop view vista_cursos;

6- Cree la vista "vista_cursos" que muestre el número, deporte y día de todos los cursos.

7- Consulte la vista ordenada por deporte.

8- Ingrese un registro en la vista "vista_cursos" y vea si afectó a "cursos".
Puede realizarse el ingreso porque solamente afecta a una tabla bASe.

9- Actualice un registro sobre la vista y vea si afectó a la tabla "cursos".
Puede realizarse la actualización porque solamente afecta a una tabla bASe.

10- Elimine un registro de la vista para el cual no haya inscriptos y vea si afectó a "cursos".
Puede realizarse la eliminación porque solamente afecta a una tabla bASe.

11- Intente eliminar un registro de la vista para el cual haya inscriptos.
No lo permite por la restricción "foreign key".

12- Elimine la vista "vista_inscriptos" si existe y créela para que muestre el documento y nombre 
del socio, el numero de curso, el deporte y día de los cursos en los cuales está inscripto.

13- Intente ingresar un registro en la vista.
No lo permite porque la modificación afecta a más de una tabla bASe. 

14- Actualice un registro de la vista.
Lo permite porque la modificación afecta a una sola tabla bASe.

15- Vea si afectó a la tabla "socios":
 SELECT *FROM socios;

16- Intente actualizar el documento de un socio.
No lo permite por la restricción.

17- Intente eliminar un registro de la vista.
No lo permite porque la vista incluye variAS tablAS.


 if object_id('inscriptos') is not null  
  drop table inscriptos;
 if object_id('socios') is not null  
  drop table socios;
 if object_id('cursos') is not null  
  drop table cursos;

 create table socios(
  documento char(8) not null,
  nombre varchar(40),
  domicilio varchar(30),
  constraint PK_socios_documento
   primary key (documento)
 );

 create table cursos(
  numero tinyint identity,
  deporte varchar(20),
  dia varchar(15),
   constraint CK_inscriptos_dia check (dia in('lunes','martes','miercoles','jueves','viernes','sabado')),
  profesor varchar(20),
  constraint PK_cursos_numero
   primary key (numero),
 );

 create table inscriptos(
  documentosocio char(8) not null,
  numero tinyint not null,
  matricula char(1),
  constraint PK_inscriptos_documento_numero
   primary key (documentosocio,numero),
  constraint FK_inscriptos_documento
   foreign key (documentosocio)
   references socios(documento)
   on UPDATE cAScade,
  constraint FK_inscriptos_numero
   foreign key (numero)
   references cursos(numero)
   on UPDATE cAScade
  );

 insert INTO socios values('30000000','Fabian Fuentes','CASeros 987');
 insert INTO socios values('31111111','GASton Garcia','Guemes 65');
 insert INTO socios values('32222222','Hector Huerta','Sucre 534');
 insert INTO socios values('33333333','Ines Irala','Bulnes 345');

 insert INTO cursos values('tenis','lunes','Ana Acosta');
 insert INTO cursos values('tenis','martes','Ana Acosta');
 insert INTO cursos values('natacion','miercoles','Ana Acosta');
 insert INTO cursos values('natacion','jueves','Carlos CASeres');
 insert INTO cursos values('futbol','sabado','Pedro Perez');
 insert INTO cursos values('futbol','lunes','Pedro Perez');
 insert INTO cursos values('bASquet','viernes','Pedro Perez');

 insert INTO inscriptos values('30000000',1,'s');
 insert INTO inscriptos values('30000000',3,'n');
 insert INTO inscriptos values('30000000',6,null);
 insert INTO inscriptos values('31111111',1,'s');
 insert INTO inscriptos values('31111111',4,'s');
 insert INTO inscriptos values('32222222',1,'s');
 insert INTO inscriptos values('32222222',7,'s');

 SELECT documento,nombre,domicilio,c.numero,deporte,dia, profesor,matricula
  FROM socios AS s
  join inscriptos AS i
  on s.documento=documentosocio
  join cursos AS c
  on c.numero=i.numero;

 if object_id('vista_cursos') is not null
  drop view vista_cursos;

 CREATE VIEW vista_cursos
  AS
  SELECT numero,deporte,dia
   FROM cursos;

 SELECT *FROM vista_cursos order by deporte;

 insert INTO vista_cursos values('futbol','martes');
 SELECT *FROM cursos;

 UPDATE vista_cursos set dia='miercoles' where numero=8;
 SELECT *FROM cursos;

 delete FROM vista_cursos where numero=8;
 SELECT *FROM cursos;

 delete FROM vista_cursos where numero=1;

 if object_id('vista_inscriptos') is not null
  drop view vista_inscriptos;
 CREATE VIEW vista_inscriptos
  AS
  SELECT i.documentosocio,s.nombre,i.numero,c.deporte,dia
  FROM inscriptos AS i
  join socios AS s
  on s.documento=documentosocio
  join cursos AS c
  on c.numero=i.numero;

 insert INTO vista_inscriptos values('32222222','Hector Huerta',6,'futbol','lunes');

 UPDATE vista_inscriptos set nombre='Fabio Fuentes' where nombre='Fabian Fuentes';

 SELECT *FROM socios;

 UPDATE vista_inscriptos set documentosocio='30000111' where documentosocio='30000000';

 delete FROM vista_inscriptos where documentosocio='30000111' and deporte='tenis'; 

----------------------

Primer problema:

Un club oferta cursos de distINTOs deportes. Almacena la información en variAS tablAS.
1- Elimine lAS tabla "inscriptos", "socios" y "cursos", si existen:
 if object_id('inscriptos') is not null  
  drop table inscriptos;
 if object_id('socios') is not null  
  drop table socios;
 if object_id('cursos') is not null  
  drop table cursos;

2- Cree lAS tablAS:
 create table socios(
  documento char(8) not null,
  nombre varchar(40),
  domicilio varchar(30),
  constraint PK_socios_documento
   primary key (documento)
 );

 create table cursos(
  numero tinyint identity,
  deporte varchar(20),
  dia varchar(15),
   constraint CK_inscriptos_dia check (dia in('lunes','martes','miercoles','jueves','viernes','sabado')),
  profesor varchar(20),
  constraint PK_cursos_numero
   primary key (numero),
 );

 create table inscriptos(
  documentosocio char(8) not null,
  numero tinyint not null,
  matricula char(1),
  constraint PK_inscriptos_documento_numero
   primary key (documentosocio,numero),
  constraint FK_inscriptos_documento
   foreign key (documentosocio)
   references socios(documento)
   on UPDATE cAScade,
  constraint FK_inscriptos_numero
   foreign key (numero)
   references cursos(numero)
   on UPDATE cAScade
  );

3- Ingrese algunos registros para todAS lAS tablAS:
 insert INTO socios values('30000000','Fabian Fuentes','CASeros 987');
 insert INTO socios values('31111111','GASton Garcia','Guemes 65');
 insert INTO socios values('32222222','Hector Huerta','Sucre 534');
 insert INTO socios values('33333333','Ines Irala','Bulnes 345');

 insert INTO cursos values('tenis','lunes','Ana Acosta');
 insert INTO cursos values('tenis','martes','Ana Acosta');
 insert INTO cursos values('natacion','miercoles','Ana Acosta');
 insert INTO cursos values('natacion','jueves','Carlos CASeres');
 insert INTO cursos values('futbol','sabado','Pedro Perez');
 insert INTO cursos values('futbol','lunes','Pedro Perez');
 insert INTO cursos values('bASquet','viernes','Pedro Perez');

 insert INTO inscriptos values('30000000',1,'s');
 insert INTO inscriptos values('30000000',3,'s');
 insert INTO inscriptos values('30000000',6,null);
 insert INTO inscriptos values('31111111',1,'n');
 insert INTO inscriptos values('31111111',4,'s');
 insert INTO inscriptos values('32222222',1,'n');
 insert INTO inscriptos values('32222222',7,'n');

4- Elimine la vista "vista_deudores" si existe:
 if object_id('vista_deudores') is not null
  drop view vista_deudores;

5- Cree la vista "vista_deudores" que muestre el documento y nombre del socio, el deporte, el día y 
la matrícula, de todAS lAS inscripciones no pagAS colocando "with check option".

6- Consulte la vista:
 SELECT *FROM vista_deudores;

7- Veamos el texto de la vista.

8- Intente actualizar a "s" la matrícula de una inscripción desde la vista.
No lo permite por la opción "with check option".

9- Modifique el documento de un socio mediante la vista.

10- Vea si se alteraron lAS tablAS referenciadAS en la vista:
 SELECT *FROM socios;
 SELECT *FROM inscriptos;

11- Modifique la vista para que muestre el domicilio, coloque la opción de encriptación y omita 
"with check option".

12- Consulte la vista para ver si se modificó:
 SELECT *FROM vista_deudores;
Aparece el nuevo campo.

13- Vea el texto de la vista.
No lo permite porque está encriptada.

14- Actualice la matrícula de un inscripto.
Si se permite porque la opción "with check option" se quitó de la vista.

15- Consulte la vista:
 SELECT *FROM vista_empleados;
Note que el registro modificado ya no aparece porque la matrícula está paga.

16- Elimine la vista "vista_socios" si existe:
 if object_id('vista_socios') is not null
  drop view vista_socios;

17- Cree la vista "vista_socios" que muestre todos los campos de la tabla "socios".

18- Consulte la vista.

19- Agregue un campo a la tabla "socios".

20- Consulte la vista "vista_socios".
El nuevo campo agregado a "socios" no aparece, pese a que la vista indica que muestre todos los 
campos de dicha tabla.

21- Altere la vista para que aparezcan todos los campos.

22- Consulte la vista.

if object_id('inscriptos') is not null  
  drop table inscriptos;
 if object_id('socios') is not null  
  drop table socios;
 if object_id('cursos') is not null  
  drop table cursos;

 create table socios(
  documento char(8) not null,
  nombre varchar(40),
  domicilio varchar(30),
  constraint PK_socios_documento
   primary key (documento)
 );

 create table cursos(
  numero tinyint identity,
  deporte varchar(20),
  dia varchar(15),
   constraint CK_inscriptos_dia check (dia in('lunes','martes','miercoles','jueves','viernes','sabado')),
  profesor varchar(20),
  constraint PK_cursos_numero
   primary key (numero),
 );

 create table inscriptos(
  documentosocio char(8) not null,
  numero tinyint not null,
  matricula char(1),
  constraint PK_inscriptos_documento_numero
   primary key (documentosocio,numero),
  constraint FK_inscriptos_documento
   foreign key (documentosocio)
   references socios(documento)
   on UPDATE cAScade,
  constraint FK_inscriptos_numero
   foreign key (numero)
   references cursos(numero)
   on UPDATE cAScade
  );

 insert INTO socios values('30000000','Fabian Fuentes','CASeros 987');
 insert INTO socios values('31111111','GASton Garcia','Guemes 65');
 insert INTO socios values('32222222','Hector Huerta','Sucre 534');
 insert INTO socios values('33333333','Ines Irala','Bulnes 345');

 insert INTO cursos values('tenis','lunes','Ana Acosta');
 insert INTO cursos values('tenis','martes','Ana Acosta');
 insert INTO cursos values('natacion','miercoles','Ana Acosta');
 insert INTO cursos values('natacion','jueves','Carlos CASeres');
 insert INTO cursos values('futbol','sabado','Pedro Perez');
 insert INTO cursos values('futbol','lunes','Pedro Perez');
 insert INTO cursos values('bASquet','viernes','Pedro Perez');

 insert INTO inscriptos values('30000000',1,'s');
 insert INTO inscriptos values('30000000',3,'s');
 insert INTO inscriptos values('30000000',6,null);
 insert INTO inscriptos values('31111111',1,'n');
 insert INTO inscriptos values('31111111',4,'s');
 insert INTO inscriptos values('32222222',1,'n');
 insert INTO inscriptos values('32222222',7,'n');

 if object_id('vista_deudores') is not null
  drop view vista_deudores;

 CREATE VIEW vista_deudores
 AS
  SELECT documento,nombre,c.deporte,c.dia,matricula
  FROM socios AS s
  join inscriptos AS i
  on documento=documentosocio
  join cursos AS c
  on c.numero=i.numero
  where matricula='n'
  with check option;

 SELECT *FROM vista_deudores;

 sp_helptext vista_deudores;

 UPDATE vista_deudores set matricula='s' where documento='31111111';

 UPDATE vista_deudores set documento='31111113' where documento='31111111';

 SELECT *FROM socios;
 SELECT *FROM inscriptos;

 alter view vista_deudores
  with encryption
 AS
  SELECT documento,nombre,domicilio,c.deporte,c.dia,matricula
  FROM socios AS s
  join inscriptos AS i
  on documento=documentosocio
  join cursos AS c
  on c.numero=i.numero
  where matricula='n';

 SELECT *FROM vista_deudores;

 sp_helptext vista_deudores;

 UPDATE vista_deudores set matricula='s' where documento='31111113';

 SELECT *FROM vista_empleados;

 if object_id('vista_socios') is not null
  drop view vista_socios;

 CREATE VIEW vista_socios
 AS
  SELECT *FROM socios;

 SELECT *FROM vista_socios;

 alter table socios
 add telefono char(10);

 SELECT *FROM vista_socios;

 alter view vista_socios
 AS
  SELECT *FROM socios;

 SELECT *FROM vista_socios; 


-----------------------

CREATE VIEW vProductCosts
AS
SELECT ProductID, Name, StandardCost
FROM Production.Product
GO
SELECT * FROM vProductCosts
GO

ALTER VIEW vProductCosts
AS
SELECT ProductID, ProductSubcateGOryID, Name, ProductNumber, StandardCost
FROM Production.Product

DROP VIEW vProductCosts2

-- Dependencies on a View

CREATE VIEW vProductCosts2
AS
SELECT Name, StandardCost FROM vProductCosts

SELECT * FROM vProductCosts2
DROP VIEW vProductCosts
SELECT * FROM vProductCosts2

--Msg 208, Level 16, State 1, Procedure vProductCosts2, Line 3
--Invalid object name 'vProductCosts'.
--Msg 4413, Level 16, State 1, Line 1
--Could not USE view or function 'vProductCosts2' becaUSE of binding errors.

CREATE VIEW vProductCosts WITH SCHEMABINDING
AS
SELECT ProductID, ProductSubcateGOryID, Name, ProductNumber, StandardCost
FROM Production.Product
GO

CREATE VIEW vProductCosts2 WITH SCHEMABINDING
AS
SELECT Name, StandardCost
FROM dbo.vProductCosts

DROP VIEW vProductCosts

--Msg 3729, Level 16, State 1, Line 1
--Cannot DROP VIEW 'vProductCosts' becaUSE it is being referenced by object 'vProductCosts2'.


-- Order Top
CREATE VIEW vOrderedProductCostes
AS
SELECT  ProductID, Name, ProductNumber, StandardCost
FROM Production.Product
ORDER BY Name

--Msg 1033, Level 15, State 1, Procedure vOrderedProductCostes, Line 5
--The ORDER BY claUSE is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP or FOR XML is also specified.


CREATE VIEW vOrderedProductCostes
AS
SELECT TOP 100 PERCENT ProductID, Name, ProductNumber, StandardCost
FROM Production.Product
ORDER BY Name

--A. Using a simple CREATE VIEW
--The following example creates a view by using a simple SELECT statement. A simple view is helpful when a combination of columns is queried frequently. The data FROM this view comes FROM the HumanResources.Employee and Person.Contact tables of the AdventureWorks2014 databASe. The data provides name and hire date information for the employees of Adventure Works Cycles. The view could be created for the person in charge of tracking work anniversaries but without giving this person access to all the data in these tables.

USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('hiredate_view', 'V') IS NOT NULL
DROP VIEW hiredate_view ;
GO
CREATE VIEW hiredate_view
AS 
SELECT c.FirstName, c.LAStName, e.EmployeeID, e.HireDate
FROM HumanResources.Employee e JOIN Person.Contact c on e.ContactID = c.ContactID ;
GO
SELECT * FROM hiredate_view
GO

--B. Using WITH ENCRYPTION
--The following example USEs the WITH ENCRYPTION option and shows computed columns, renamed columns, and multiple columns.

USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('PurchASing.PurchASeOrderReject', 'V') IS NOT NULL
    DROP VIEW PurchASing.PurchASeOrderReject ;
GO
CREATE VIEW PurchASing.PurchASeOrderReject
WITH ENCRYPTION
AS
SELECT PurchASeOrderID, ReceivedQty, RejectedQty, 
    RejectedQty / ReceivedQty AS RejectRatio, DueDate
FROM PurchASing.PurchASeOrderDetail
WHERE RejectedQty / ReceivedQty > 0
AND DueDate > CONVERT(DATETIME,'20010630',101) ;
GO
SELECT * FROM PurchASing.PurchASeOrderReject

-- Querying the View Definition

SELECT definition FROM sys.sql_modules
WHERE object_id = OBJECT_ID('PurchASing.PurchASeOrderReject')


--D. Using built-in functions within a view
--The following example shows a view definition that includes a built-in function. When you USE functions, you must specify a column name for the derived column.


USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('Sales.SalesPersonPerform', 'V') IS NOT NULL
    DROP VIEW Sales.SalesPersonPerform ;
GO
CREATE VIEW Sales.SalesPersonPerform
AS
SELECT TOP 100 SalesPersonID, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE OrderDate > CONVERT(DATETIME,'20001231',101)
GROUP BY SalesPersonID;
GO
SELECT * FROM Sales.SalesPersonPerform
 
 
 -- ALTER VEW
-- creates a view that contains all employees and their hire dates called EmployeeHireDate. Permissions are granted to the view, but requirements are changed to SELECT employees whose hire dates fall before a certain date. Then, ALTER VIEW is USEd to replace the view.

USE AdventureWorks2014 ;
GO
CREATE VIEW HumanResources.EmployeeHireDate
AS
SELECT c.FirstName, c.LAStName, e.HireDate
FROM HumanResources.Employee AS e JOIN Person.Contact AS c
ON e.ContactID = c.ContactID ;
GO

 
-- The view must be changed to include only the employees that were hired before 1997. If ALTER VIEW is not USEd, but instead the view is dropped and re-created, the previously USEd GRANT statement and any other statements that deal with permissions pertaining to this view must be re-entered.
ALTER VIEW HumanResources.EmployeeHireDate
AS
SELECT c.FirstName, c.LAStName, e.HireDate
FROM HumanResources.Employee AS e JOIN Person.Contact AS c
ON e.ContactID = c.ContactID
WHERE HireDate < CONVERT(DATETIME,'19980101',101) ;
GO











-- Creating a BASic View

USE AdventureWorks2014
GO

CREATE VIEW dbo.v_Product_TransactionHistory
AS
SELECT p.Name ProductName,
p.ProductNumber,
c.Name ProductCateGOry,
s.Name ProductSubCateGOry,
m.Name ProductModel,
t.TransactionID,
t.ReferenceOrderID,
t.ReferenceOrderLineID,
t.TransactionDate,
t.TransactionType,
t.Quantity,
t.ActualCost
FROM Production.TransactionHistory t
INNER JOIN Production.Product p ON
t.ProductID = p.ProductID
INNER JOIN Production.ProductModel m ON
m.ProductModelID = p.ProductModelID
INNER JOIN Production.ProductSubcateGOry s ON
s.ProductSubcateGOryID = p.ProductSubcateGOryID
INNER JOIN Production.ProductCateGOry c ON
c.ProductCateGOryID = s.ProductCateGOryID
WHERE c.Name = 'Bikes'
GO

SELECT ProductName, ProductModel, ReferenceOrderID, ActualCost
FROM dbo.v_Product_TransactionHistory
ORDER BY ProductName

-- Querying the View Definition

SELECT definition FROM sys.sql_modules
WHERE object_id = OBJECT_ID('v_Product_TransactionHistory')

EXEC sp_helptext v_Product_TransactionHistory

--C. Using WITH CHECK OPTION
--The following example shows a view named SeattleOnly that references five tables and allows for data modifications to apply only to employees who live in Seattle.

USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('dbo.SeattleOnly', 'V') IS NOT NULL
    DROP VIEW dbo.SeattleOnly ;
GO
CREATE VIEW dbo.SeattleOnly
AS
SELECT c.LAStName, c.FirstName, a.City, s.StateProvinceCode
FROM Person.Contact AS c 
JOIN HumanResources.Employee AS e ON c.ContactID = e.ContactID
JOIN HumanResources.EmployeeAddress AS ea ON e.EmployeeID = ea.EmployeeID
JOIN Person.Address AS a ON ea.AddressID = a.AddressID
JOIN Person.StateProvince AS s ON a.StateProvinceID = s.StateProvinceID
WHERE a.City = 'Seattle'
WITH CHECK OPTION ;
GO
-- 
CREATE VIEW PortlandAreaAddresses_vw
AS
SELECT AddressID, AddressLine1, City,  StateProvinceID,PostalCode,ModifiedDate
FROM Person.Address
WHERE PostalCode LIKE '970%'
   OR PostalCode LIKE '971%'
   OR PostalCode LIKE '972%'
   OR PostalCode LIKE '986[6-9]%'
WITH CHECK OPTION;
GO


UPDATE PortlandAreaAddresses_vw
SET PostalCode = '33333'  -- it wAS 97205
WHERE AddressID = 22;

UPDATE Person.Address
SET PostalCode = '33333'  -- it wAS 97205
WHERE AddressID = 22;

 


-- Displaying Views and Their Structures

SELECT s.name SchemaName,
v.name ViewName
FROM sys.views v
INNER JOIN sys.schemAS s ON
v.schema_id = s.schema_id
ORDER BY s.name,
v.name

SELECT v.name ViewName,
c.name ColumnName
FROM sys.columns c
INNER JOIN sys.views v ON
c.object_id = v.object_id
ORDER BY v.name,
c.name


-- Refreshing a View’s Definition

EXEC sp_refreshview 'dbo.v_Product_TransactionHistory'

EXEC sys.sp_refreshsqlmodule @name = 'dbo.v_Product_TransactionHistory'

-- Modifying a View

-- Add a WHERE claUSE and remove
-- the ReferenceOrderID and ReferenceOrderLineID columns
ALTER VIEW dbo.v_Product_TransactionHistory
AS
SELECT p.Name,
p.ProductNumber,
t.TransactionID,
t.TransactionDate,
t.TransactionType,
t.Quantity,
t.ActualCost
FROM Production.TransactionHistory t
INNER JOIN Production.Product p ON
t.ProductID = p.ProductID
WHERE Quantity > 10
GO

-- Dropping a View

DROP VIEW dbo.v_Product_TransactionHistory

-- Modifying Data Through aView

CREATE VIEW Production.vw_Location
AS
SELECT LocationID,
Name LocationName,
CostRate,
Availability,
CostRate/Availability CostToAvailabilityRatio
FROM Production.Location
GO

INSERT Production.vw_Location
(LocationName, CostRate, Availability, CostToAvailabilityRatio)
VALUES ('Finishing Cabinet', 1.22, 75.00, 0.01626 )

INSERT Production.vw_Location
(LocationName, CostRate, Availability)
VALUES ('Finishing Cabinet', 1.22, 75.00)

-- Encrypting aView

CREATE VIEW dbo.v_Product_TopTenListPrice
WITH ENCRYPTION
AS
SELECT TOP 10
p.Name,
p.ProductNumber,
p.ListPrice
FROM Production.Product p
ORDER BY p.ListPrice DESC
GO

SELECT definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('v_Product_TopTenListPrice')

-- Creating an Indexed View

CREATE VIEW dbo.v_Product_Sales_By_LineTotal
WITH SCHEMABINDING
AS
SELECT p.ProductID, p.Name ProductName,
SUM(LineTotal) LineTotalByProduct,
COUNT_BIG(*) LineItems
FROM Sales.SalesOrderDetail s
INNER JOIN Production.Product p ON
s.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
GO

SET STATISTICS IO ON
GO

SELECT TOP 5 ProductName, LineTotalByProduct
FROM v_Product_Sales_By_LineTotal
ORDER BY LineTotalByProduct DESC

CREATE UNIQUE CLUSTERED INDEX UCI_v_Product_Sales_By_LineTotal
ON dbo.v_Product_Sales_By_LineTotal (ProductID)
GO

CREATE NONCLUSTERED INDEX NI_v_Product_Sales_By_LineTotal
ON dbo.v_Product_Sales_By_LineTotal (ProductName)
GO

SELECT TOP 5 ProductName, LineTotalByProduct
FROM v_Product_Sales_By_LineTotal
ORDER BY LineTotalByProduct DESC

-- Forcing the Optimizer to USE an Index for an IndexedView

SELECT ProductID
FROM dbo.v_Product_Sales_By_LineTotal
WITH (NOEXPAND)
WHERE ProductName = 'Short-Sleeve ClASsic Jersey, L'

SELECT ProductID
FROM dbo.v_Product_Sales_By_LineTotal
WITH (NOEXPAND, INDEX(NI_v_Product_Sales_By_LineTotal))
WHERE ProductName = 'Short-Sleeve ClASsic Jersey, L'

-- Creating a Distributed-Partitioned View

USE mASter
GO
EXEC sp_addlinkedserver
'JOEPROD',
N'SQL Server'
GO

-- skip schema checking of remote tables
EXEC sp_serveroption 'JOEPROD', 'lazy schema validation', 'true'
GO

USE mASter
GO
EXEC sp_addlinkedserver
'JOEPROD\SQL2008',
N'SQL Server'
GO

-- skip schema checking of remote tables
EXEC sp_serveroption 'JOEPROD\SQL2008', 'lazy schema validation', 'true'
GO

IF NOT EXISTS (SELECT name
FROM sys.databASes
WHERE name = 'TSQLRecipeTest')
BEGIN
CREATE DATABASE TSQLRecipeTest
END
GO

USE TSQLRecipeTest
GO

CREATE TABLE dbo.WebHits_MegaCorp
(WebHitID uniqueidentifier NOT NULL,
WebSite varchar(20) NOT NULL ,
HitDT datetime NOT NULL,
CHECK (WebSite = 'MegaCorp'),
CONSTRAINT PK_WebHits PRIMARY KEY (WebHitID, WebSite))

IF NOT EXISTS (SELECT name
FROM sys.databASes
WHERE name = 'TSQLRecipeTest')
BEGIN
CREATE DATABASE TSQLRecipeTest
END
GO

USE TSQLRecipeTest
GO

CREATE TABLE dbo.WebHits_MiniCorp
(WebHitID uniqueidentifier NOT NULL ,
WebSite varchar(20) NOT NULL ,
HitDT datetime NOT NULL,
CHECK (WebSite = 'MiniCorp') ,
CONSTRAINT PK_WebHits PRIMARY KEY (WebHitID, WebSite))

CREATE VIEW dbo.v_WebHits AS
SELECT WebHitID,
WebSite,
HitDT
FROM TSQLRecipeTest.dbo.WebHits_MegaCorp
UNION ALL
SELECT WebHitID,
WebSite,
HitDT
FROM JOEPROD.TSQLRecipeTest.dbo.WebHits_MiniCorp
GO

CREATE VIEW dbo.v_WebHits AS
SELECT WebHitID,
WebSite,
HitDT
FROM TSQLRecipeTest.dbo.WebHits_MiniCorp
UNION ALL
SELECT WebHitID,
WebSite,
HitDT
FROM [JOEPROD\SQL2008].TSQLRecipeTest.dbo.WebHits_MegaCorp
GO

SET XACT_ABORT ON

INSERT dbo.v_WebHits
(WebHitID, WebSite, HitDT)
VALUES(NEWID(), 'MegaCorp', GETDATE())

INSERT dbo.v_WebHits
(WebHitID, WebSite, HitDT)
VALUES(NEWID(), 'MiniCorp', GETDATE())

SET XACT_ABORT ON

SELECT WebHitID, WebSite, HitDT
FROM dbo.v_WebHits

SELECT WebHitID, WebSite, HitDT
FROM JOEPROD.AdventureWorks2014.dbo.WebHits_MiniCorp

SELECT WebHitID, WebSite, HitDT
FROM [JOEPROD\SQL2008].AdventureWorks2014.dbo.WebHits_MegaCorp





-----------------------------------
-- VistAS entre TablAS

DECLARE @s nvarchar(1000)
SET @s = 'CREATE VIEW dbo.test AS SELECT * FROM sys.objects'
EXEC tempdb.dbo.sp_executesql @s
SELECT * FROM tempdb.dbo.test
SET @s = 'DROP VIEW dbo.test'
EXEC tempdb.dbo.sp_executesql @s


USE Northwind
DECLARE @s nvarchar(1000)
SET @s = 'CREATE VIEW vAutores AS SELECT * FROM Pubs.dbo.authors'
EXEC Northwind.dbo.sp_executesql @s


-- dynamically too

DECLARE @s nvarchar(1000), @p nvarchar(1000)
SET @s = 'CREATE VIEW dbo.test AS SELECT * FROM sys.objects'
SET @p = 'tempdb.dbo.sp_executesql'
EXEC @p @s
SELECT * FROM tempdb.dbo.test
SET @s = 'DROP VIEW dbo.test'
EXEC @p @s

-------------------------------------------------
-- https://msdn.microsoft.com/en-us/library/ms190174.aspx

--A view is a virtual table whose contents are defined by a query. Like a table, a view consists of a set of named columns and rows of data. Unless indexed, a view does not exist as a stored set of data values in a database. The rows and columns of data come from tables referenced in the query defining the view and are produced dynamically when the view is referenced.
--A view acts as a filter on the underlying tables referenced in the view. The query that defines the view can be from one or more tables or from other views in the current or other databases. Distributed queries can also be used to define views that use data from multiple heterogeneous sources. This is useful, for example, if you want to combine similarly structured data from different servers, each of which stores data for a different region of your organization.
--Views are generally used to focus, simplify, and customize the perception each user has of the database. Views can be used as security mechanisms by letting users access data through the view, without granting the users permissions to directly access the underlying base tables of the view. Views can be used to provide a backward compatible interface to emulate a table that used to exist but whose schema has changed. Views can also be used when you copy data to and from SQL Server to improve performance and to partition data.


-- Besides the standard role of basic user-defined views, SQL Server provides the following types of views that serve special purposes in a database.
--Indexed Views
--An indexed view is a view that has been materialized. This means the view definition has been computed and the resulting data stored just like a table. You index a view by creating a unique clustered index on it. Indexed views can dramatically improve the performance of some types of queries. Indexed views work best for queries that aggregate many rows. They are not well-suited for underlying data sets that are frequently updated.
--Partitioned Views
--A partitioned view joins horizontally partitioned data from a set of member tables across one or more servers. This makes the data appear as if from one table. A view that joins member tables on the same instance of SQL Server is a local partitioned view.
--System Views
--System views expose catalog metadata. You can use system views to return information about the instance of SQL Server or the objects defined in the instance. For example, you can query the sys.databases catalog view to return information about the user-defined databases available in the instance.


--You can create views in SQL Server 2016 by using SQL Server Management Studio or Transact-SQL. A view can be used for the following purposes:
--To focus, simplify, and customize the perception each user has of the database.
--As a security mechanism by allowing users to access data through the view, without granting the users permissions to directly access the underlying base tables.
--To provide a backward compatible interface to emulate a table whose schema has changed.



USE AdventureWorks2014 ; 
GO

IF OBJECT_ID ('hiredate_view', 'V') IS NOT NULL
DROP VIEW hiredate_view ;
GO
CREATE VIEW hiredate_view
AS 
SELECT p.FirstName, p.LastName, e.BusinessEntityID, e.HireDate
FROM HumanResources.Employee e 
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID ;
GO

CREATE VIEW HumanResources.EmployeeHireDate
AS
SELECT p.FirstName, p.LastName, e.HireDate
FROM HumanResources.Employee AS e JOIN Person.Person AS  p
ON e.BusinessEntityID = p.BusinessEntityID ; 
GO
-- Query the view
SELECT FirstName, LastName, HireDate
FROM HumanResources.EmployeeHireDate
ORDER BY LastName;



IF OBJECT_ID ('Purchasing.PurchaseOrderReject', 'V') IS NOT NULL
    DROP VIEW Purchasing.PurchaseOrderReject ;
GO
CREATE VIEW Purchasing.PurchaseOrderReject
WITH ENCRYPTION
AS
SELECT PurchaseOrderID, ReceivedQty, RejectedQty, 
    RejectedQty / ReceivedQty AS RejectRatio, DueDate
FROM Purchasing.PurchaseOrderDetail
WHERE RejectedQty / ReceivedQty > 0
AND DueDate > CONVERT(DATETIME,'20010630',101) ;
GO

IF OBJECT_ID ('Sales.SalesPersonPerform', 'V') IS NOT NULL
    DROP VIEW Sales.SalesPersonPerform ;
GO
CREATE VIEW Sales.SalesPersonPerform
AS
SELECT TOP (100) SalesPersonID, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE OrderDate > CONVERT(DATETIME,'20001231',101)
GROUP BY SalesPersonID;
GO

-- creates a view and an index on that view. Two queries are included that use the indexed view.

--Set the options to support indexed views.
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
    QUOTED_IDENTIFIER, ANSI_NULLS ON;
GO
--Create view with schemabinding.
IF OBJECT_ID ('Sales.vOrders', 'view') IS NOT NULL
DROP VIEW Sales.vOrders ;
GO
CREATE VIEW Sales.vOrders
WITH SCHEMABINDING
AS
    SELECT SUM(UnitPrice*OrderQty*(1.00-UnitPriceDiscount)) AS Revenue,
        OrderDate, ProductID, COUNT_BIG(*) AS COUNT
    FROM Sales.SalesOrderDetail AS od, Sales.SalesOrderHeader AS o
    WHERE od.SalesOrderID = o.SalesOrderID
    GROUP BY OrderDate, ProductID;
GO
--Create an index on the view.
CREATE UNIQUE CLUSTERED INDEX IDX_V1 
    ON Sales.vOrders (OrderDate, ProductID);
GO
--This query can use the indexed view even though the view is 
--not specified in the FROM clause.
SELECT SUM(UnitPrice*OrderQty*(1.00-UnitPriceDiscount)) AS Rev, 
    OrderDate, ProductID
FROM Sales.SalesOrderDetail AS od
    JOIN Sales.SalesOrderHeader AS o ON od.SalesOrderID=o.SalesOrderID
        AND ProductID BETWEEN 700 and 800
        AND OrderDate >= CONVERT(datetime,'05/01/2002',101)
GROUP BY OrderDate, ProductID
ORDER BY Rev DESC;
GO
--This query can use the above indexed view.
SELECT  OrderDate, SUM(UnitPrice*OrderQty*(1.00-UnitPriceDiscount)) AS Rev
FROM Sales.SalesOrderDetail AS od
    JOIN Sales.SalesOrderHeader AS o ON od.SalesOrderID=o.SalesOrderID
        AND DATEPART(mm,OrderDate)= 3
        AND DATEPART(yy,OrderDate) = 2002
GROUP BY OrderDate
ORDER BY OrderDate ASC;
GO


-- Create a view.
CREATE VIEW HumanResources.EmployeeHireDate
AS
SELECT p.FirstName, p.LastName, e.HireDate
FROM HumanResources.Employee AS e JOIN Person.Person AS  p
ON e.BusinessEntityID = p.BusinessEntityID ; 

-- Modify the view by adding a WHERE clause to limit the rows returned.
ALTER VIEW HumanResources.EmployeeHireDate
AS
SELECT p.FirstName, p.LastName, e.HireDate
FROM HumanResources.Employee AS e JOIN Person.Person AS  p
ON e.BusinessEntityID = p.BusinessEntityID
WHERE HireDate < CONVERT(DATETIME,'20020101',101) ; 
GO

-- Modify Contents

--This example changes the value in the StartDate and EndDate columns for a specific employee by referencing columns 
--in the view HumanResources.vEmployeeDepartmentHistory. 
--This view returns values from two tables. This statement succeeds because the columns being modified are from only one 
-- of the base tables.

USE AdventureWorks2014 ; 
GO
UPDATE HumanResources.vEmployeeDepartmentHistory
SET StartDate = '20110203', EndDate = GETDATE() 
WHERE LastName = N'Smith' AND FirstName = 'Samantha'; 
GO

-- The example inserts a new row into the base table HumanResouces.Department by specifying the relevant columns from the view HumanResources.vEmployeeDepartmentHistory. 
-- The statement succeeds because only columns from a single base table are specified and the other columns in the base table
--  have default values.

INSERT INTO HumanResources.vEmployeeDepartmentHistory (Department, GroupName) 
VALUES ('MyDepartment', 'MyGroup'); 
GO

-- Get Information

SELECT definition, uses_ansi_nulls, uses_quoted_identifier, is_schema_bound
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('HumanResources.vEmployee'); 
GO

SELECT OBJECT_DEFINITION (OBJECT_ID('HumanResources.vEmployee')) AS ObjectDefinition; 
GO

EXEC sp_helptext 'HumanResources.vEmployee';


-- To get the dependencies of a view
SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name, 
    o.type_desc AS referencing_desciption, 
    COALESCE(COL_NAME(referencing_id, referencing_minor_id), '(n/a)') AS referencing_minor_id, 
    referencing_class_desc, referenced_class_desc,
    referenced_server_name, referenced_database_name, referenced_schema_name,
    referenced_entity_name, 
    COALESCE(COL_NAME(referenced_id, referenced_minor_id), '(n/a)') AS referenced_column_name,
    is_caller_dependent, is_ambiguous
FROM sys.sql_expression_dependencies AS sed
INNER JOIN sys.objects AS o ON sed.referencing_id = o.object_id
WHERE referencing_id = OBJECT_ID(N'Production.vProductAndDescription');
GO

