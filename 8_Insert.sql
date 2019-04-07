-- OUTPUT
-- http://chancrovsky.blogspot.com.es/2014/05/clausula-output-inserted-deleted-sin.html


-- Adding Records to a table using INSERT Statement
-- https://www.simple-talk.com/sql/learn-sql-server/working-with-the-insert-statement-in-sql-server/
USE tempdb;
GO
CREATE TABLE Fruit (
   Id int NOT NULL,
   Name varchar(100) NOT NULL,
   Color varchar(100) NULL,
   Quantity int DEFAULT 1);
GO
Select * from Fruit
GO
INSERT INTO Fruit (Id, Name, Color, Quantity) 
   VALUES (1, 'Banana', 'Yellow', 1);
Go
INSERT INTO Fruit   
   VALUES (2, 'Grapes', 'Red', 15);
Go
INSERT INTO Fruit (Id, Name)
   VALUES (3, 'Apples');
GO
INSERT INTO Fruit(Id, Name, Color, Quantity)
   VALUES (4, 'Apples', 'Red', 10),
          (5, 'Peaches', 'Green', 7),
          (6, 'Pineapples','Yellow', 5);
GO
-- Inserting Data into a Table using a SELECT statement
INSERT INTO Fruit(Id, Name, Color, Quantity)
     SELECT 7+(6-Id),Name, 'White', Quantity 
	 FROM Fruit 
	 WHERE Id > 3
     ORDER BY Id DESC;
GO
SELECT * from Fruit
GO
-- Inserting Data into a Table using a Stored Procedure
CREATE PROC HybridFruit 
AS 
   SELECT b.Id + 9, a.Name + b.name 
   FROM Fruit a INNER JOIN Fruit b
   ON a.Id = 9 - b.Id;
GO   
INSERT INTO Fruit (Id, Name) EXECUTE HybridFruit;
GO
-- Using the OUTPUT Clause
INSERT INTO Fruit(Id, Name)
   OUTPUT INSERTED.*
   VALUES (18,'Pie Cherries');
GO
--Id	Name	Color	Quantity
--18	Pie Cherries	NULL	1

INSERT INTO Fruit(Id, Name)
   OUTPUT INSERTED.*
   VALUES (19,'Platanos'),
		  (20,'Sandias')
  GO

--  Id	Name	Color	Quantity
--19	Platanos	NULL	1
--20	Sandias	NULL	1

-- Using OUTPUT clause to return inserted values to calling application

-- Alter table so Id column is now an identity   
ALTER TABLE Fruit
  DROP Column Id;
ALTER TABLE Fruit
 ADD Id int identity;

-- Create table variable to hold output from insert
DECLARE @INSERTED as TABLE (
   Id int,
   Name varchar(100));

--INSERT with OUTPUT clause
INSERT INTO Fruit (Name, Color) 
   OUTPUT INSERTED.Id, 
          INSERTED.Name 
   INTO @INSERTED  
   VALUES ('Bing Cherries','Purple'),
          ('Oranges','Orange');
          -- view rows that where inserted
SELECT * FROM @INSERTED;
GO

--Id	Name
--26	Bing Cherries
--27	Oranges



-- (2 filas afectadas)

----------------------------------------

--
-- Trabajando con inserciones
--

USE PruebasDB
GO

CREATE TABLE fyi_links (
	id INTEGER PRIMARY KEY,
	url VARCHAR(80) NOT NULL,
	notes VARCHAR(1024),
	counts INT,
	created DATETIME NOT NULL DEFAULT(GETDATE()) );
GO

SELECT c.column_id AS seq, c.name, x.name AS TYPE, c.max_length, c.is_nullable
	FROM sys.columns c, sys.tables t, sys.systypes x
	WHERE c.object_id = t.object_id
		AND c.system_type_id = x.xtype
		AND t.name = 'fyi_links'
	ORDER BY c.column_id ;


--
--

-- INSERT / SELECT
USE AdventureWorks2014
GO

IF OBJECT_ID ( 'HumanResources.NewEmployee', 'U' ) IS NOT NULL
	DROP TABLE HumanResources.NewEmployee ;
GO

CREATE TABLE HumanResources.NewEmployee (
	EmployeeID INT NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	Phone Phone NULL,
	AddressLine1 NVARCHAR(60) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	State NCHAR(3) NOT NULL, 
	PostalCode NVARCHAR(15) NOT NULL,
	CurrentFlag FLAG );
GO
SELECT * FROM HumanResources.NewEmployee
GO
INSERT TOP (10) INTO HumanResources.NewEmployee 
	SELECT e.EmployeeID, c.LastName, c.FirstName, c.Phone,
			a.AddressLine1, a.City, sp.StateProvinceCode, 
			a.PostalCode, e.CurrentFlag
    FROM HumanResources.Employee e
		INNER JOIN HumanResources.EmployeeAddress AS ea
		ON e.EmployeeID = ea.EmployeeID
		INNER JOIN Person.Address AS a
		ON ea.AddressID = a.AddressID
		INNER JOIN Person.StateProvince AS sp
		ON a.StateProvinceID = sp.StateProvinceID
		INNER JOIN Person.Contact AS c
		ON e.ContactID = c.ContactID ;
GO
INSERT TOP (10) INTO HumanResources.NewEmployee 
	SELECT *
    FROM HumanResources.Employee 
GO
SELECT  EmployeeID, LastName, FirstName, Phone,
	AddressLine1, City, State, PostalCode, CurrentFlag
	FROM HumanResources.NewEmployee ;
GO


---------------
-- INSERT

-- Insertamos registros sin necesidad de especificar los campos
--	por ir en la misma secuencia que los campos en la estructura de la tabla
USE pubs
GO
SELECT *
 FROM publishers
GO
SELECT *
INTO Editoriales
FROM Publishers
GO
-- Los datos se dan en el mismo orden en el que están en la tabla
INSERT INTO Editoriales
	VALUES ( '9956', 'Nueva Editorial', 'Coruña', 'ca', 'usa' );
GO
-------
USE AdventureWorks2014
GO
DROP TABLE Ventas
GO
-- Tabla Ventas
SELECT *
INTO Ventas
FROM Sales.SalesReason
GO
SELECT * FROM Ventas
-- Los datos se dan en el mismo orden en el que están en la tabla
--	 y usamos una función para dar valor a un campo


-- SalesReasonID Identity    función GETDATE() 
--INSERT INTO Sales.SalesReason
--	VALUES ( 'Item closeout', 'other', GETDATE() );
--GO

INSERT INTO Ventas
	VALUES ( 'Item closeout', 'other', GETDATE() );
GO
-- ModifiedDate por defecto GETDATE()


-- Si uno de los campos admite valores por defecto, podemos emplear 'DEFAULT'
--INSERT INTO Sales.SalesReason
--	VALUES ( 'Item closeout', 'other 2', DEFAULT );
--GO

-- No funciona . Modificar
INSERT INTO Ventas
	VALUES ( 'Item closeout', 'other 2', DEFAULT );
GO

-- Insertar múltiples registros en una unica sentencia 

IF OBJECT_ID ( 'dbo.departments', 'U' ) IS NOT NULL
	DROP TABLE dbo.departments ;

CREATE TABLE dbo.departments (
	DeptID TINYINT NOT NULL PRIMARY KEY,
	DeptName NVARCHAR(30),
	Manager NVARCHAR(50) );

-- Varios Registros con un INSERT

INSERT INTO dbo.departments
	VALUES ( 1, 'human resources', 'Pepe' ),
			( 2, 'sales', 'Ana' ),
			( 3, 'finance', 'Luisa' ),
			( 4, 'purchasing', 'Juan' ),
			( 5, 'manufacturing', 'Ramón' )
GO





SELECT count(*) as [Número Departamentos] 
from departments
GO




-- Insertamos los valores de los campos desordenados, por lo que hay que
--	especificar los nombres de los campos en el orden en el que los vamos
--	a introducir

Select *
 from Production.UnitMeasure
GO

INSERT INTO Production.UnitMeasure ( Name, UnitMeasureCode, ModifiedDate )
	VALUES ( 'Square yards', 'Y2', GETDATE() );
GO


--
-- 
-- -- Ejemplo INSERT / SELECT
USE pubs
GO
Select * from Titles
GO
-- Cargamos el contenido de una tabla en otra filtrando por un campo
SELECT title_id, title, type
	INTO MisLibros
	FROM titles
   WHERE ( title_id = 'BU1032' );
GO
Select * from MisLibros
GO
-- Cargamos el contenido de una tabla en otra filtrando por un campo
INSERT INTO MisLibros
	SELECT title_id, title, type
	FROM titles
	WHERE type = 'mod_cook' ;
GO
SELECT * FROM MisLibros
GO
--
SELECT au_lname, Address, city, state
	INTO Autores
	FROM authors
	WHERE city = 'paris' ;
GO

--
INSERT INTO autores
	SELECT au_lname + ',' + au_fname, Address, city, State
	FROM authors ;
GO
SELECT * FROM autores
GO
-----------------------
USE AdventureWorks2014
GO
IF OBJECT_ID ( 'HumanResources.NewEmployee', 'U' ) IS NOT NULL
	DROP TABLE HumanResources.NewEmployee ;
GO

CREATE TABLE HumanResources.NewEmployee (
	EmployeeID INT NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	AddressLine1 NVARCHAR(60) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	State NCHAR(3) NOT NULL, 
	PostalCode NVARCHAR(15) NOT NULL,
	CurrentFlag varChar(5) );
GO
SELECT * FROM HumanResources.NewEmployee
GO
INSERT TOP (10) INTO HumanResources.NewEmployee 
	SELECT e.[NationalIDNumber], c.LastName, c.FirstName,
			a.AddressLine1, a.City, sp.StateProvinceCode, 
			a.PostalCode, e.CurrentFlag
    FROM HumanResources.Employee e
        INNER JOIN Person.BusinessEntityAddress AS bea
        ON e.BusinessEntityID = bea.BusinessEntityID
        INNER JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
        INNER JOIN Person.PersonPhone AS pp
        ON e.BusinessEntityID = pp.BusinessEntityID
        INNER JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
        INNER JOIN Person.Person as c
        ON e.BusinessEntityID = c.BusinessEntityID
GO


--INSERT TOP (10) INTO HumanResources.NewEmployee 
--	SELECT *
--    FROM HumanResources.Employee 
--GO
--SELECT  EmployeeID, LastName, FirstName,
--	AddressLine1, City, State, PostalCode, CurrentFlag
--	FROM HumanResources.NewEmployee ;
--GO

---------------------------------
-- INSERT     OUTPUT
-- Variable Tabla

-- http://chancrovsky.blogspot.com.es/2014/05/clausula-output-inserted-deleted-sin.html


--Utilizar Clausula OUTPUT INTO con una instrucción INSERT simple
-- Variable Tabla

--En el siguiente ejemplo se inserta una fila en la tabla ScrapReason
-- y se utiliza la cláusula OUTPUT para devolver los resultados de la 
-- instrucción a la variable table @MyTableVar. 
-- Como la columna ScrapReasonID se ha definido con una propiedad IDENTITY, 
-- no se especifica ningún valor en la instrucción INSERT de esa columna. 
-- No obstante, tenga en cuenta que el valor generado por el Motor de base de datos 
-- para esa columna se devuelve en la cláusula OUTPUT de la columna inserted.
-- ScrapReasonID.

USE AdventureWorks2014;
GO
sp_help 'Production.ScrapReason'
GO
-- Nota: Ejecutar hasta la última linea, para no perder el valor de la variable

DECLARE @MyTableVar table( NewScrapReasonID smallint,
                           Name varchar(50),
                           ModifiedDate date);
INSERT Production.ScrapReason
    OUTPUT INSERTED.ScrapReasonID, INSERTED.Name, INSERTED.ModifiedDate
        INTO @MyTableVar
VALUES ('Prueba Insert con Output 5', GETDATE());

--Display the result set of the table variable.
SELECT NewScrapReasonID, Name, ModifiedDate 
FROM @MyTableVar;
--Display the result set of the table.
SELECT ScrapReasonID, Name, ModifiedDate 
FROM Production.ScrapReason;
GO
delete Production.ScrapReason
where ScrapReasonID = 17
GO
-- Ejecutando otra vez

--Mens. 2601, Nivel 14, Estado 1, Línea 4
--No se puede insertar una fila de clave duplicada en el objeto 'Production.ScrapReason' 
--con índice único 'AK_ScrapReason_Name'. 
--El valor de la clave duplicada es (Prueba Insert con Output 4).
--Se terminó la instrucción.

sp_help 'Production.ScrapReason'
GO
-----------------
-- http://www.sqlserver.info/syntax/how-to-use-the-output-clause/

USE tempdb
GO
DROP TABLE Animal
GO
CREATE TABLE Animal
		(AnimalID	INT IDENTITY,
		 AnimalName	VARCHAR(50))
GO
-- Inicio
DECLARE	@OutputData	TABLE
		(AnimalID	INT,
		 AnimalName	VARCHAR(50))
-- Insert into the table and stick the resulting animal
--   name and identity column in to a temp variable
INSERT
INTO	Animal
		(AnimalName)
OUTPUT	inserted.AnimalID, inserted.AnimalName
INTO	@OutputData
		(AnimalID, AnimalName)
VALUES	('Pig'),
		('Dog'),
		('Chinchilla')
-- View the inserted data
SELECT	*
FROM	@OutputData
GO
-- Fin
-- 
CREATE PROC INSERT_OTPUT_TABLE
AS
BEGIN
DECLARE	@OutputData	TABLE
		(AnimalID	INT,
		 AnimalName	VARCHAR(50));
-- Insert into the table and stick the resulting animal
--   name and identity column in to a temp variable
INSERT
INTO	Animal(AnimalName)
OUTPUT	inserted.AnimalID, inserted.AnimalName
INTO	@OutputData
		(AnimalID, AnimalName)
VALUES	('Pig'),
		('Dog'),
		('Chinchilla');
-- View Table Animal
SELECT	*
FROM	Animal
-- View the inserted data
SELECT	*
FROM	@OutputData
END
GO

EXEC INSERT_OTPUT_TABLE
GO