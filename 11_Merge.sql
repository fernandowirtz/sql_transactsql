-- Ejemplos MERGE
-- http://chancrovsky.blogspot.com.es/2015/01/merge-into.html

--------------------------------------------------------------
--MERGE (Fusión)
--------------------------------------------------------------
--Reemplazar grupos de datos de una tabla 'Target' desde los datos de 
-- otra tabla 'Source'

--USE Tempdb
--GO

CREATE DATABASE Fusionar
GO
USE Fusionar
GO

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
ORDER BY Nombre;
GO
	--Leche		2,40
	--Manzanas	3,99
	--Miel		4,99
	--Pan		2,45
	--Uvas		4,00
	
SELECT *
FROM Frutas
ORDER BY Nombre;
GO
	--Bananas		4,95
	--Mandarinas	3,95
	--Manzanas		6,00
	--Naranjas		2,50
	--Uvas			4,00


MERGE INTO Productos --Target
USING Frutas --Source
ON (Productos.Nombre = Frutas.Nombre)
	WHEN MATCHED THEN
			UPDATE SET Precio = Frutas.Precio
	WHEN NOT MATCHED BY TARGET THEN
			INSERT (Nombre, Precio)
			VALUES (Frutas.Nombre, Frutas.Precio)
	WHEN NOT MATCHED BY SOURCE THEN
			DELETE;
GO
-- Antigua Tabla Productos
	--Leche		2,40
	--Manzanas	3,99
	--Miel		4,99
	--Pan		2,45
	--Uvas		4,00

	--Actualiza Manzanas. Uvas tiene el mismo precio en las 2 Tablas
	--Inserta Bananas, Mandarinas, Naranjas que existe en Source y no en Target
	--Borra Leche, Miel, Pan que no existen en Source

SELECT * FROM Productos order by nombre
--	Nombre	Precio
--Bananas	4,95						Insertada
--Mandarinas	3,95					Insertada
--Manzanas	6,00						Actualizada
--Naranjas	2,50						Insertada
--Uvas	4,00
	
	DECLARE @MergeOutput TABLE 
	( ActionType NVARCHAR(10), DelNombre NVARCHAR(60), 
	InsNombre NVARCHAR(60), DelPrecio varchar(12),
	 InsPrecio varchar(12));
	MERGE INTO Productos --Target
	USING Frutas --Source
	ON (Productos.Nombre = Frutas.Nombre)
	WHEN MATCHED THEN
			UPDATE SET Precio = Frutas.Precio
	WHEN NOT MATCHED BY TARGET THEN
			INSERT (Nombre, Precio)
			VALUES (Frutas.Nombre, Frutas.Precio)
	WHEN NOT MATCHED BY SOURCE THEN
			DELETE
	OUTPUT $action, DELETED.*, INSERTED.* INTO @MergeOutput; 
   SELECT * FROM @MergeOutput ;
GO
-----------------
-- Example Given:

DROP TABLE ProductosSalida
GO
CREATE TABLE ProductosSalida(
ActionType NVARCHAR(10), DelNombre NVARCHAR(60), 
	InsNombre NVARCHAR(60), DelPrecio varchar(12),
	 InsPrecio varchar(12)
)
GO
MERGE INTO Productos --Target
USING Frutas --Source
ON (Productos.Nombre = Frutas.Nombre)
	WHEN MATCHED THEN
			UPDATE SET Precio = Frutas.Precio
	WHEN NOT MATCHED BY TARGET THEN
			INSERT (Nombre, Precio)
			VALUES (Frutas.Nombre, Frutas.Precio)
	WHEN NOT MATCHED BY SOURCE THEN
			DELETE
	OUTPUT $action, DELETED.*, INSERTED.* INTO ProductosSalida;
GO  
SELECT * FROM ProductosSalida


-------------------
-- Otro Ejemplo

 -- Example MERGE
 USE Tempdb
 GO
--Create a target table
CREATE TABLE Products
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Rate MONEY
) 
GO
--Insert records into target table
INSERT INTO Products
VALUES
(1, 'Tea', 10.00),
(2, 'Coffee', 20.00),
(3, 'Muffin', 30.00),
(4, 'Biscuit', 40.00)
GO
--Create source table
CREATE TABLE UpdatedProducts
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Rate MONEY
) 
GO
--Insert records into source table
INSERT INTO UpdatedProducts
VALUES
(1, 'Tea', 10.00),
(2, 'Coffee', 25.00),
(3, 'Muffin', 35.00),
(5, 'Pizza', 60.00)
GO
SELECT * FROM Products
SELECT * FROM UpdatedProducts
GO

----

--Synchronize the target table with
--refreshed data from source table
MERGE Products AS TARGET
USING UpdatedProducts AS SOURCE 
ON (TARGET.ProductID = SOURCE.ProductID) 
--When records are matched, update 
--the records if there is any change
WHEN MATCHED AND TARGET.ProductName <> SOURCE.ProductName 
OR TARGET.Rate <> SOURCE.Rate THEN 
UPDATE SET TARGET.ProductName = SOURCE.ProductName, 
TARGET.Rate = SOURCE.Rate 
--When no records are matched, insert
--the incoming records from source
--table to target table
WHEN NOT MATCHED BY TARGET THEN 
INSERT (ProductID, ProductName, Rate) 
VALUES (SOURCE.ProductID, SOURCE.ProductName, SOURCE.Rate)
--When there is a row that exists in target table and
--same record does not exist in source table
--then delete this record from target table
WHEN NOT MATCHED BY SOURCE THEN 
DELETE
--$action specifies a column of type nvarchar(10) 
--in the OUTPUT clause that returns one of three 
--values for each row: 'INSERT', 'UPDATE', or 'DELETE', 
--according to the action that was performed on that row
OUTPUT $action, 
DELETED.ProductID AS TargetProductID, 
DELETED.ProductName AS TargetProductName, 
DELETED.Rate AS TargetRate, 
INSERTED.ProductID AS SourceProductID, 
INSERTED.ProductName AS SourceProductName, 
INSERTED.Rate AS SourceRate; 
SELECT @@ROWCOUNT;
GO

----------------------
-- Otro Ejemplo

Example: 
--Let’s create Student Details and StudentTotalMarks and inserted some records.

USE AdventureWorks2014
GO
CREATE TABLE StudentDetails
(
StudentID INTEGER PRIMARY KEY,
StudentName VARCHAR(15)
)
GO
INSERT INTO StudentDetails
VALUES(1,'SMITH')
INSERT INTO StudentDetails
VALUES(2,'ALLEN')
INSERT INTO StudentDetails
VALUES(3,'JONES')
INSERT INTO StudentDetails
VALUES(4,'MARTIN')
INSERT INTO StudentDetails
VALUES(5,'JAMES')
GO 

-- create StudentTotalMarks:

CREATE TABLE StudentTotalMarks
(
StudentID INTEGER REFERENCES StudentDetails,
StudentMarks INTEGER
)
GO
INSERT INTO StudentTotalMarks
VALUES(1,230)
INSERT INTO StudentTotalMarks
VALUES(2,255)
INSERT INTO StudentTotalMarks
VALUES(3,200)
GO 

select * from StudentDetails

select * from StudentTotalMarks

--In our example we will consider three main conditions while we merge this two tables.

--Delete the records whose marks are more than 250. 
--Update marks and add 25 to each as internals if records exist. 
--Insert the records if record does not exists. 

MERGE StudentTotalMarks AS stm
USING (SELECT StudentID,StudentName FROM StudentDetails) AS sd ON stm.StudentID = sd.StudentID
WHEN MATCHED AND stm.StudentMarks > 250 THEN DELETE
WHEN MATCHED THEN UPDATE SET stm.StudentMarks = stm.StudentMarks + 25
WHEN NOT MATCHED THEN
INSERT(StudentID,StudentMarks)VALUES(sd.StudentID,25);
GO 
-- Outcome

select * from StudentTotalMarks order by StudentID

--AS we can see there are 5 rows updated. StudentID 2 is deleted as it is more than 250, 
--25 marks have been added to all records that exists i.e StudentID 1,3 and the records 
--that did not exists i.e. 4 and 5 are now inserted in StudentTotalMarks .


-----------------

-- https://www.simple-talk.com/sql/learn-sql-server/the-merge-statement-in-sql-server-2008/

--Otro ejemplo con MERGE

--Primero crea las tablas

-- USE AdventureWorks2014
USE Fusionar
GO
IF OBJECT_ID ('BookInventory', 'U') IS NOT NULL
DROP TABLE dbo.BookInventory;

CREATE TABLE dbo.BookInventory  -- target
	(
		TitleID INT NOT NULL PRIMARY KEY,
		Title NVARCHAR(100) NOT NULL,
		Quantity INT NOT NULL
		CONSTRAINT Quantity_Default_1 DEFAULT 0
	);
	
IF OBJECT_ID ('BookOrder', 'U') IS NOT NULL
DROP TABLE dbo.BookOrder;

CREATE TABLE dbo.BookOrder  -- source
	(
		TitleID INT NOT NULL PRIMARY KEY,
		Title NVARCHAR(100) NOT NULL,
		Quantity INT NOT NULL
		CONSTRAINT Quantity_Default_2 DEFAULT 0
	);
	
INSERT BookInventory VALUES
	(1, 'The Catcher in the Rye', 6),
	(2, 'Pride and Prejudice', 3),
	(3, 'The Great Gatsby', 0),
	(5, 'Jane Eyre', 0),
	(6, 'Catch 22', 0),
	(8, 'Slaughterhouse Five', 4);
	
INSERT BookOrder VALUES
	(1, 'The Catcher in the Rye', 3),
	(3, 'The Great Gatsby', 0),
	(4, 'Gone with the Wind', 4),
	(5, 'Jane Eyre', 5),
	(7, 'Age of Innocence', 8);
	
--Antes de hacer nada, comprobamos el contenido
SELECT * FROM BookInventory;

		--1	The Catcher in the Rye	6
		--2	Pride and Prejudice		3
		--3	The Great Gatsby		0
		--5	Jane Eyre				0
		--6	Catch 22				0
		--8	Slaughterhouse Five		4

--Ahora hace el merge para actualizar los datos
-- Hacemos Pedido

MERGE BookInventory bi
USING BookOrder bo
ON bi.TitleID = bo.TitleID
WHEN MATCHED THEN
	UPDATE
	SET bi.Quantity = bi.Quantity + bo.Quantity;
	
--Ahora comprueba
SELECT * FROM BookInventory;

--Los resultados de la query son los siguientes
			--1	The Catcher in the Rye	9
			--2	Pride and Prejudice		3
			--3	The Great Gatsby		0
			--5	Jane Eyre				5
			--6	Catch 22				0
			--8	Slaughterhouse Five		4



--Cuando el la cantidad de un libro no esté en ninguna de las dos tablas
--ni en inventario ni en pedido, eliminarlo.
--cuando esté pedido, actualizar la cantidad del pedido al inventario			
MERGE BookInventory bi
USING BookOrder bo
ON bi.TitleID = bo.TitleID
WHEN MATCHED AND
	bi.Quantity + bo.Quantity = 0 THEN
	DELETE
WHEN MATCHED THEN
	UPDATE
	SET bi.Quantity = bi.Quantity + bo.Quantity;
	
SELECT * FROM BookInventory;

--Cuando no se encuentre en el target, insertar los valores...
MERGE BookInventory bi
USING BookOrder bo
ON bi.TitleID = bo.TitleID
WHEN MATCHED AND
	bi.Quantity + bo.Quantity = 0 THEN
	DELETE
WHEN MATCHED THEN
	UPDATE
	SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
	INSERT (TitleID, Title, Quantity)
	VALUES (bo.TitleID, bo.Title,bo.Quantity);
	
SELECT * FROM BookInventory;

--Cuando no se encuentra en el Source y en el inventario esté a cero,
-- borrar
MERGE BookInventory bi
USING BookOrder bo
ON bi.TitleID = bo.TitleID
WHEN MATCHED AND
	bi.Quantity + bo.Quantity = 0 THEN
	DELETE
WHEN MATCHED THEN
	UPDATE
	SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
	INSERT (TitleID, Title, Quantity)
	VALUES (bo.TitleID, bo.Title,bo.Quantity)
WHEN NOT MATCHED BY SOURCE
	AND bi.Quantity = 0 THEN
	DELETE;

SELECT * FROM BookInventory;


--Merge con OUTPUT
--Declaramos una variable tabla a la que irán los valores extraidos
DECLARE @MergeOutput TABLE
	(
		ActionType NVARCHAR(10),
		DelTitleID INT,
		InsTitleID INT,
		DelTitle NVARCHAR(50),
		InsTitle NVARCHAR(50),
		DelQuantity INT,
		InsQuantity INT
	);
MERGE BookInventory bi
USING BookOrder bo
ON bi.TitleID = bo.TitleID
WHEN MATCHED AND
	bi.Quantity + bo.Quantity = 0 THEN
	DELETE
WHEN MATCHED THEN
	UPDATE
	SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
	INSERT (TitleID, Title, Quantity)
	VALUES (bo.TitleID, bo.Title,bo.Quantity)
WHEN NOT MATCHED BY SOURCE
	AND bi.Quantity = 0 THEN
	DELETE
OUTPUT
		$action,
		DELETED.TitleID,
		INSERTED.TitleID,
		DELETED.Title,
		INSERTED.Title,
		DELETED.Quantity,
		INSERTED.Quantity
	INTO @MergeOutput
;
SELECT * FROM BookInventory;
SELECT * FROM @MergeOutput;

-- Release 2.0
-- -- Storage in Table
CREATE TABLE MergeOutput 
	(
		ActionType NVARCHAR(10),
		DelTitleID INT,
		InsTitleID INT,
		DelTitle NVARCHAR(50),
		InsTitle NVARCHAR(50),
		DelQuantity INT,
		InsQuantity INT
	)
GO
MERGE BookInventory bi
USING BookOrder bo
ON bi.TitleID = bo.TitleID
WHEN MATCHED AND
	bi.Quantity + bo.Quantity = 0 THEN
	DELETE
WHEN MATCHED THEN
	UPDATE
	SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
	INSERT (TitleID, Title, Quantity)
	VALUES (bo.TitleID, bo.Title,bo.Quantity)
WHEN NOT MATCHED BY SOURCE
	AND bi.Quantity = 0 THEN
	DELETE
OUTPUT
		$action,
		DELETED.TitleID,
		INSERTED.TitleID,
		DELETED.Title,
		INSERTED.Title,
		DELETED.Quantity,
		INSERTED.Quantity
	INTO MergeOutput;
GO

-- Hint:
--Msg 10713, Level 15, State 1, Line 497
--A MERGE statement must be terminated by a semi-colon (;).

SELECT * FROM BookInventory;
GO
SELECT * FROM MergeOutput
GO

--ActionType	DelTitleID	InsTitleID	DelTitle	InsTitle	DelQuantity	InsQuantity
--UPDATE	1	1	The Catcher in the Rye	The Catcher in the Rye	6	9
--DELETE	3	NULL	The Great Gatsby	NULL	0	NULL
--INSERT	NULL	4	NULL	Gone with the Wind	NULL	4
--UPDATE	5	5	Jane Eyre	Jane Eyre	0	5
--DELETE	6	NULL	Catch 22	NULL	0	NULL
--INSERT	NULL	7	NULL	Age of Innocence	NULL	8
-----------------------------------------------------



--Otro ejemplo
USE tempdb

IF OBJECT_ID ('dbo.Departments', 'U') IS NOT NULL
DROP TABLE dbo.Departments;
GO

CREATE TABLE dbo.Departments  -- target
	(DeptID TINYINT NOT NULL PRIMARY KEY,
	DeptName NVARCHAR(30),
	Manager NVARCHAR(50));
GO

INSERT INTO dbo.Departments
	VALUES (1, 'Human Resources', 'Margheim'),
			(2, 'Sales', 'Byham'),
			(3, 'Finance', 'Gill'),
			(4, 'Purchasing', 'Barber'),
			(5, 'Manufacturing', 'Brewer');
GO

IF OBJECT_ID ('dbo.Departments_delta', 'U') IS NOT NULL
DROP TABLE dbo.Departments_delta;
GO

CREATE TABLE dbo.Departments_delta  -- source
	(DeptID TINYINT NOT NULL PRIMARY KEY,
	DeptName NVARCHAR(30),
	Manager NVARCHAR(50));
GO

INSERT INTO dbo.Departments_delta
	VALUES (1, 'Human Resources', 'Margheim'),
			(2, 'Sales', 'Erickson'),
			(3, 'Accounting', 'Varkey'),
			(4, 'Purchasing', 'Barber'),
			(6, 'Production', 'Jones'),
			(7, 'Customer Relations', 'Smith');
GO

--Actualizar los campos con Merge y mostrar una tabla comparativa
--con la clausula output en la que se vean los cambios

MERGE INTO Departments d --Target
USING Departments_delta dd--Source
ON (d.DeptID = dd.DeptID)
	WHEN MATCHED AND (d.Manager <> dd.Manager OR d.DeptName <> dd.DeptName) THEN
			UPDATE SET DeptName = dd.DeptName, Manager = dd.Manager
	WHEN NOT MATCHED BY TARGET THEN --no existe destino
			INSERT (DeptID, DeptName, Manager)
			VALUES (dd.DeptID, dd.DeptName, dd.Manager)
	WHEN NOT MATCHED BY SOURCE THEN --no existe la fuente
			DELETE
OUTPUT $action,
		inserted.DeptID AS SourceDeptID, inserted.DeptName AS SourceName,
		inserted.Manager AS SourceManager, deleted.DeptID AS TargetDeptID,
		deleted.DeptName AS TargetDeptName, deleted.Manager AS TargetManager;

SELECT * FROM dbo.Departments
SELECT * FROM dbo.Departments_delta

--2 cambia manager
--3 cambia nombre
--5 desaparece
--6 se inserta

--------------------------

-- http://www.made2mentor.com/2013/06/using-the-output-clause-with-t-sql-merge/

-- Using the Output Clause with T-SQL Merge
-- 
USE TempDb;
GO
 
IF OBJECT_ID ('tempdb..#Customer_Orig') IS NOT NULL DROP TABLE #Customer_Orig;
IF OBJECT_ID ('tempdb..#Customer_New')  IS NOT NULL DROP TABLE #Customer_New;
 
 
CREATE TABLE #Customer_Orig
(  CustomerNum    TINYINT NOT NULL
  ,CustomerName   VARCHAR (25) NULL
  ,Planet         VARCHAR (25) NULL);
 
CREATE TABLE #Customer_New
(  CustomerNum    TINYINT NOT NULL
  ,CustomerName   VARCHAR (25) NULL
  ,Planet         VARCHAR (25) NULL);
 
INSERT INTO #Customer_New (CustomerNum, CustomerName, Planet)
   VALUES (1, 'Anakin Skywalker', 'Tatooine')
         ,(2, 'Yoda', 'Coruscant')
         ,(3, 'Obi-Wan Kenobi', 'Coruscant');  
 
INSERT INTO #Customer_Orig (CustomerNum, CustomerName, Planet)
   VALUES (2, 'Master Yoda', 'Coruscant')
         ,(3, 'Obi-Wan Kenobi', 'Coruscant')
         ,(4, 'Darth Vader', 'Death Star');
 
SELECT * FROM #Customer_Orig Order by CustomerNum;
SELECT * FROM #Customer_New Order by CustomerNum;

MERGE  #Customer_New AS Target
 USING #Customer_Orig AS Source
    ON Target.CustomerNum = Source.CustomerNum
WHEN MATCHED AND EXISTS
                    (SELECT Source.CustomerName, Source.Planet
                     EXCEPT
                     SELECT Target.CustomerName, Target.Planet)
THEN
   UPDATE SET
      Target.CustomerName = Source.CustomerName
     ,Target.Planet = Source.Planet
WHEN NOT MATCHED BY TARGET
THEN
   INSERT (CustomerNum, CustomerName, Planet)
   VALUES (CustomerNum, Source.CustomerName, Source.Planet)
WHEN NOT MATCHED BY SOURCE THEN DELETE
-------------------------------------
OUTPUT $action, inserted.*, deleted.*
-------------------------------------
;
GO

--
IF OBJECT_ID( 'tempdb..#CustomerChanges') IS NOT NULL DROP TABLE #CustomerChanges;
 
CREATE TABLE #CustomerChanges(
  ChangeType         NVARCHAR(10)
 ,CustomerNum        TINYINT NOT NULL
 ,NewCustomerName    VARCHAR(25) NULL
 ,PrevCustomerName   VARCHAR(25) NULL
 ,NewPlanet          VARCHAR(25) NULL
 ,PrevPlanet         VARCHAR(25) NULL
 ,UserName           NVARCHAR(100) NOT NULL
 ,DateTimeChanged    DateTime NOT NULL);
 
MERGE  #Customer_New AS Target
 USING #Customer_Orig AS Source
    ON Target.CustomerNum = Source.CustomerNum
WHEN MATCHED AND EXISTS
                    (SELECT Source.CustomerName, Source.Planet
                     EXCEPT
                     SELECT Target.CustomerName, Target.Planet)
THEN
   UPDATE SET
      Target.CustomerName = Source.CustomerName,
      Target.Planet = Source.Planet
WHEN NOT MATCHED BY TARGET
THEN
   INSERT (CustomerNum, CustomerName, Planet)
   VALUES (Source.CustomerNum, Source.CustomerName, Source.Planet)
WHEN NOT MATCHED BY SOURCE THEN DELETE
-------------------------------------
OUTPUT
   $ACTION ChangeType,
   coalesce (inserted.CustomerNum, deleted.CustomerNum) CustomerNum,
   inserted.CustomerName NewCustomerName,
   deleted.CustomerName PrevCustomerName,
   inserted.Planet NewPlanet,
   deleted.Planet PrevPlanet,
   SUSER_SNAME() UserName,
   Getdate () DateTimeChanged
    INTO #CustomerChanges
GO
------------------------------

-- http://www.sqlservercentral.com/blogs/sqlservernotesfromthefield/2012/02/21/merge-with-output-clause/

-- MERGE with OUTPUT clause

--The challange was to keep track of changes on a table that we had only a readonly access to, and keep a history of the changes. 
--Furthermore the table didn’t have a column to track the last modified date, but a primary key was available though.
--We didn’t need to track the changes realtime, but once or twice a day was preferable. I came up with a solution using the MERGE stament, and applying the OUTPUT clause. Let me show a simple demo setup:
USE tempdb
GO
CREATE TABLE ReadOnlyTable (
    Id INT PRIMARY KEY,
    Col1 INT,
    Col2 INT,
    Timestamp DATETIME
)
GO
CREATE TABLE HistoryTable (
    Id INT PRIMARY KEY,
    Col1 INT,
    Col2 INT,
    Timestamp DATETIME
)
GO

INSERT INTO ReadOnlyTable (Id, Col1, Col2, Timestamp)
VALUES
    (1, 1, 1, GETDATE()),
    (2, 2, 2, GETDATE()),
    (3, 3, 3, GETDATE())
GO

--The ReadOnlyTable represents the table from a third party system, that we only have read access to.
--The HistoryTable is a table to hold a copy of the snapshot at the scheduled compare times (once or twice a day).
--I came up with this MERGE statement, which compares the entire content of the tables for changes – so it is not lightweight in any way.

MERGE INTO HistoryTable Dst
USING ReadOnlyTable Src 
ON Dst.id = Src.id
WHEN MATCHED AND (Dst.col1 <> Src.col1 OR Dst.col2 <> Src.col2 OR Dst.Timestamp <> Src.Timestamp) THEN
    UPDATE
    SET Dst.col1 = Src.col1, Dst.col2 = Src.col2, Dst.Timestamp = src.Timestamp
WHEN NOT MATCHED BY TARGET THEN
    INSERT (id, col1, col2, Timestamp)
    VALUES (Src.id, Src.col1, Src.col2, Src.Timestamp)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT
    GETDATE() AS ChangeDate,
    COALESCE(Inserted.Id, Deleted.Id) AS Id,
    CASE
        WHEN Deleted.Id IS NULL AND Inserted.Id IS NOT NULL THEN 'i'
        WHEN Deleted.Id IS NOT NULL AND Inserted.Id IS NOT NULL THEN 'u'
        WHEN Deleted.Id IS NOT NULL AND Inserted.Id IS NULL THEN 'd'
    END AS ChangeType,
    deleted.col1 AS col1_before,
    deleted.col2 AS col2_before,
    deleted.Timestamp AS Timestamp_before,
    inserted.col1 AS col1_after,
    inserted.col2 AS col2_after,
    inserted.Timestamp AS Timestamp_after;
GO

--The basic MERGE statement just joins the source and destination on the Id column. If the Id exists in the destination table (HistoryTable) and if at least one of the other columns have changed, then we update. Rows that do not exist will be inserted. Deleted rows will simply be removed from the HistoryTable.
--Given the three rows in ReadOnlyTable and no rows in HistoryTable, the execution of the MERGE statement will return this:

-- Because the rows are all new, there are no content in the *_before columns. To illustrate changes performed in the third party database, I will now update a few rows, and run the MERGE statement again:

UPDATE ReadOnlyTable SET Col1 = 42
WHERE Id = 1
GO
DELETE FROM ReadOnlyTable
WHERE Id = 2
GO
INSERT INTO ReadOnlyTable (Id, Col1, Col2, Timestamp)
VALUES (4, 4, 4, GETDATE())
GO

-- The MERGE now returns this:


--Now we have a way to asynchronously track changes performed in the readonly table. All we need now, is to create a table to store the output data, and add the INTO <table name>. The final table and MERGE statement looks like this:

CREATE TABLE ReadOnlyTableChanges
(
    ChangeId INT IDENTITY PRIMARY KEY,
    ChangeDate DATETIME,
    Id INT,
    ChangeType CHAR(1),
    Col1_before INT,
    Col2_before INT,
    Timestamp_before DATETIME,
    Col1_after INT,
    Col2_after INT,
    Timestamp_after DATETIME
)
GO

MERGE INTO HistoryTable Dst
USING ReadOnlyTable Src 
ON Dst.id = Src.id
WHEN MATCHED AND (Dst.col1 <> Src.col1 OR Dst.col2 <> Src.col2 OR Dst.Timestamp <> Src.Timestamp) THEN
    UPDATE
    SET Dst.col1 = Src.col1, Dst.col2 = Src.col2, Dst.Timestamp = src.Timestamp
WHEN NOT MATCHED BY TARGET THEN
    INSERT (id, col1, col2, Timestamp)
    VALUES (Src.id, Src.col1, Src.col2, Src.Timestamp)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT
    GETDATE() AS ChangeDate,
    COALESCE(Inserted.Id, Deleted.Id) AS Id,
    CASE
        WHEN Deleted.Id IS NULL AND Inserted.Id IS NOT NULL THEN 'i'
        WHEN Deleted.Id IS NOT NULL AND Inserted.Id IS NOT NULL THEN 'u'
        WHEN Deleted.Id IS NOT NULL AND Inserted.Id IS NULL THEN 'd'
    END AS ChangeType,
    deleted.col1 AS col1_before,
    deleted.col2 AS col2_before,
    deleted.Timestamp AS Timestamp_before,
    inserted.col1 AS col1_after,
    inserted.col2 AS col2_after,
    inserted.Timestamp AS Timestamp_after
INTO ReadOnlyTableChanges; --This is added
GO

SELECT * FROM ReadOnlyTableChanges
GO

--ChangeId	ChangeDate	Id	ChangeType	Col1_before	Col2_before	Timestamp_before	Col1_after	Col2_after	Timestamp_after
--1	2016-05-09 09:06:19.093	1	u	1	1	2016-05-09 09:03:48.603	42	1	2016-05-09 09:03:48.603
--2	2016-05-09 09:06:19.093	2	d	2	2	2016-05-09 09:03:48.603	NULL	NULL	NULL
--3	2016-05-09 09:06:19.093	4	i	NULL	NULL	NULL	4	4	2016-05-09 09:05:27.313
--------------------------