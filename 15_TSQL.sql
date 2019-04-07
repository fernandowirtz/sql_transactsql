


--												T-SQL (Transact-SQL)

-- DECLARE SET SELECT PRINT     VARIABLES LOCALES @ - GLOBALES  @@ 

-- IF IIF CHOOSE CASE     WHILE - BREAK - CONTINUE    GOTO    WAITFOR
-- BEGIN - END  COMMIT - ROLLBACK - TRANSACTION 

-- RAISERROR			THROW				TRY - CATCH				

-- @@ERROR			@@TRANCOUNT			@@ROWCOUNT

--		  ERROR_NUMBER() AS ErrorNumber
--       ,ERROR_SEVERITY() AS ErrorSeverity
--        ,ERROR_STATE() AS ErrorState
--        ,ERROR_LINE () AS ErrorLine
--        ,ERROR_PROCEDURE() AS ErrorProcedure
--        ,ERROR_MESSAGE() AS ErrorMessage;

-- STORED PROCEDURE. FUNCTION. TRIGGER. CURSORS, ASSEMBLIES

-- CTE (Common Table Expression). TABLAS TEMPORALES #NombreTablaTemporal
--
--
-- http://www.sql-server-helper.com/tips/set-vs-select-assigning-variables.aspx
-- http://en.wikipedia.org/wiki/Transact-SQL
-- http://www.sql-server-helper.com/sql-server-2008/connection-error-1326.aspx


USE pubs
GO

DECLARE @nombre VARCHAR(30) ;
DECLARE @fecha DATETIME ;
DECLARE @contar INT ;

DECLARE @datevariable DATE,
	@spatialvar GEOGRAPHY,
	@levelvar HIERARCHYID ;

-- ASIGNAR VALORES

DECLARE @nom VARCHAR(30)='pepe';

SET @nombre = 'pepe' ;
SET @fecha = '30/04/2013' ;-- Formato americano MM/DD//yyyy

SELECT @contar = COUNT(*)
	FROM stores ;
--Mens. 137, Nivel 15, Estado 1, Línea 1
--Debe declarar la variable escalar "@contar".

DECLARE @cuenta INT;
SELECT @cuenta = COUNT(*)
	FROM stores ;
PRINT @cuenta ;
SELECT @cuenta ;



PRINT @nombre ;
PRINT @fecha ;
PRINT @contar ;


SELECT @fecha 
	

--
--
USE AdventureWorks2014
GO
-- Parámetros Reemplazables
DECLARE @find VARCHAR(30);
SET @find = 'Man%' ;
-- DECLARE @find VARCHAR(30) = 'Man%' ;

SELECT LastName, FirstName, Phone
	FROM Person.Contact
	WHERE LastName LIKE @find ;
GO

USE Pubs
GO
-- Parámetros Reemplazables

DECLARE @Apellido VARCHAR(30);
SET @Apellido = 'M%' ;
--SET @Apellido = 'B%'
--DECLARE @Apellido VARCHAR(30) = 'B%' ;

SELECT *
	FROM autores
	WHERE [au_lname] LIKE @Apellido ;--@Apellido Parametro reemplazable
GO


--
--
-- 2 Parámetros reemplazables

USE AdventureWorks2014
GO
DECLARE @Group NVARCHAR(50), @Sales MONEY ;
SET @Group = 'North America' ;
SET @Sales = 2000000 ;

SELECT FirstName, LastName, SalesYTD
	FROM Sales.vSalesPerson
	WHERE TerritoryGroup = @Group
		AND SalesYTD >= @Sales;
GO
--
-- Asignar con SELECT

USE Northwind
GO
DECLARE @filas INT ;
SET @filas = (SELECT COUNT(*) FROM Customers) ;
Print @filas ;
GO
-- 91

-- IF Estructura Alternativa Simple/Doble

-- Simple

USE AdventureWorks2014 ;
GO
IF OBJECT_ID ('Purchasing.PurchaseOrderReject', 'V') IS NOT NULL
    DROP VIEW Purchasing.PurchaseOrderReject ;
GO
PRINT 'Continuar ........'


IF OBJECT_ID ('Purchasing.PurchaseOrderReject', 'V') IS NOT NULL
	BEGIN
		DROP VIEW Purchasing.PurchaseOrderReject 
	END 
ELSE
	CREATE USER Anita
GO
PRINT 'Continuar ........'
-- Doble

DECLARE  @diminutivo VARCHAR(3)
SET @diminutivo = 'com' -- es
IF @diminutivo = 'com'
	BEGIN
		PRINT 'www.google.com'
	END
ELSE -- Doble
	--BEGIN
		PRINT 'www.yahoo.es'
	--END ;
GO
PRINT 'Continuar ........'
----
-- Similar If Doble
DECLARE @contar INTEGER = 0 
IF @contar = 0 
BEGIN 
PRINT 'La condicion se cumple' 
END 
ELSE 
BEGIN 
PRINT 'La condicion NO se cumple' 
END --La condicion se cumple -------------------------------------------------------------------------- 
--Cambiamos la expresión logica DECLARE @contar INTEGER = 0 IF @contar != 0 BEGIN PRINT 'La condicion se cumple' END ELSE BEGIN PRINT 'La condicion NO se cumple' END
--
-- Ejemplo alternativa Doble

-- https://msdn.microsoft.com/es-es/library/ms174420.aspx

-- dw weekday
-- Returns a number from 1 (Sunday) to 7 (Saturday)

IF DATEPART(dw, GETDATE()) = 7 OR DATEPART(dw, GETDATE()) = 1
   PRINT 'It is the weekend.'
ELSE
   PRINT 'It is a weekday.'
GO
-- Example Given
IF DATEPART(dw, GETDATE()) = 7 OR DATEPART(dw, GETDATE()) = 1
BEGIN
   PRINT 'It is the weekend.'
   PRINT 'Get some rest on the weekend!'
END
ELSE
BEGIN
   PRINT 'It is a weekday.'
   PRINT 'Get to work on a weekday!'
END
GO

-- Clase
IF DATEPART(dw, GETDATE()) = 7 OR DATEPART(dw, GETDATE()) = 1
	BEGIN
	   PRINT 'It is the weekend.'
	   PRINT 'Get some rest on the weekend!'
	END
ELSE
	BEGIN
	   PRINT 'It is a weekday.'
	   PRINT 'Get to work on a weekday!'
	END
Print DATEPART(dw, GETDATE())
Print  GETDATE()
GO
--It is a weekday.
--Get to work on a weekday!
--6
--May 13 2016  7:38AM

-- Another IF Doble
USE AdventureWorks2014
GO
DECLARE @QuerySelector INT
SET @QuerySelector = 3 -- Try Out 1
IF @QuerySelector = 3
	BEGIN
		SELECT TOP 1 ProductID, Name, Color
		FROM Production.Product
		WHERE Color = 'Silver'
		ORDER BY Name ;
	END
ELSE
	BEGIN
		SELECT TOP 3 ProductID, Name, Color
		FROM Production.Product
		WHERE Color = 'Black'
		ORDER BY Name ;
	END ;
GO

----------------

-- Can I use control-of-flow language to do an upsert in SQL Server

-- Upsert refers to code that includes logic to either update a row or insert a row, depending on whether that row exists. As with other data modification operations, you can use control-of-flow statement elements to do an upsert.

-- One of the most common ways to do this is to use an IF expression to check for the row’s existence and then execute your statements accordingly. Let’s start with a simple temporary table to demonstrate how this works:
-- # (Hash) Tabla Temporal se almacena en BD Tempdb y desaparece al desconectar la Instancia
-- ClassRoom
USE Tempdb
GO
CREATE TABLE #products   -- Temporal table
(ProdID INT, ListPrice MONEY);
GO
INSERT INTO #products VALUES
				(101, 199.99),
				(102, 299.99),
				(103, 399.99);
 
GO
SELECT * FROM #products
GO
-- Now let’s create our data modification statements, based on an IF…ELSE construction to control the execution flow:
-- DECLARE @ProdID INT = 103;
DECLARE @ProdID INT = 13;
DECLARE @ListPrice MONEY = 388.88
IF EXISTS(SELECT * FROM #products
		WHERE ProdID = @ProdID)
  BEGIN
    UPDATE #products
    SET ListPrice = @ListPrice
    WHERE ProdID = @ProdID
  END
ELSE
  BEGIN
    INSERT INTO #products
      VALUES(@ProdID, @ListPrice)
  END
GO
 -- Con 103 Update
 -- Con 13 INSERT
SELECT * FROM #products 
WHERE ProdID = @ProdID;
GO

-----------
use pubs
go
if (select avg(price) from titles where type = 'mod_cook')<$15
	begin
		print 'Libros de cocina'
		select substring (title,1,35) as titulo
		from titles
		where type ='mod_cook'
	end
else
	begin
		print 'Libros de cocina baratos'
		select substring (title,1,35) as titulo
		from titles
		where type ='mod_cook'
	end
go

--titulo
--Silicon Valley Gastronomic Treats
--The Gourmet Microwave

-----------
--CASE Estructura Alternativa Múltiple
-- http://www.dotnet-tricks.com/Tutorial/sqlserver/1MS1120313-Understanding-Case-Expression-in-SQL-Server-with-Example.html

--
DECLARE @diminutivo VARCHAR(3), @web varchar(30)
SET @diminutivo = 'com' -- probamos con es org
SET @Web = (CASE @diminutivo
		WHEN 'com' THEN 'www.google.com'
		WHEN 'es' THEN 'www.yahoo.es'
		ELSE 'www.bing.com'
	    END);
GO
PRINT @Web ;
GO

--
-- ClassRoom

-----
-- CASE
Use Northwind
go
SELECT UnitPrice from products
GO
Select Precio =
 CASE
	WHEN UnitPrice is null THEN 'Desconocido'
	WHEN UnitPrice < 10 THEN 'Precio Bajo'
	WHEN UnitPrice > 10 THEN 'Precio Alto'
	ELSE 'Cuesta Exactamente 10'
 END
from products
GO
---------
USE AdventureWorks2014
GO
SELECT TOP 10 *
FROM HumanResources.Department ;
GO
SELECT DepartmentID, Name, GroupName,
	CASE GroupName
		WHEN 'Research and Development' THEN 'Sala A'
		WHEN 'Sales and Marketing' THEN 'Sala B'
		WHEN 'Manufacturing' THEN 'Sala C'
		ELSE 'Sala D'
	END AS SalaConferencias -- Header
	FROM HumanResources.Department ;
GO


-----------------
-- http://www.sqlservercentral.com/articles/Stairway+Series/108723/

-- Example CASE
CREATE TABLE MyOrder (
ID int identity,
OrderDT date,
OrderAmt decimal(10,2),
Layaway char(1));
GO
INSERT into MyOrder VALUES
('12‐11‐2012', 10.59,NULL),
('10‐11‐2012', 200.45,'Y'),
('02‐17‐2014', 8.65,NULL),
('01‐01‐2014', 75.38,NULL),
('07‐10‐2013', 123.54,NULL),
('08‐23‐2009', 99.99,NULL),
('10‐08‐2013', 350.17,'N'),
('04‐05‐2010', 180.76,NULL),
('03‐27‐2011', 1.49, NULL);
GO
SELECT YEAR(OrderDT) AS OrderYear,
CASE YEAR(OrderDT)
	WHEN 2014 THEN 'Year 1'
	WHEN 2013 THEN 'Year 2'
	WHEN 2012 THEN 'Year 3'
ELSE 'Year 4 and beyond' END AS YearType
FROM MyOrder;
GO

SELECT YEAR(OrderDT) AS OrderYear,
CASE YEAR(OrderDT)
WHEN 2014 THEN 'Year 1'
WHEN 2013 THEN 'Year 2'
WHEN 2012 THEN 'Year 3' END AS YearType
FROM MyOrder;

SELECT YEAR(OrderDT) AS OrderYear,
CASE
WHEN YEAR(OrderDT) = 2014 THEN 'Year 1'
WHEN YEAR(OrderDT) = 2013 THEN 'Year 2'
WHEN YEAR(OrderDT) = 2012 THEN 'Year 3'
WHEN YEAR(OrderDT) < 2012 THEN 'Year 4 and beyond'
END AS YearType
FROM MyOrder;

SELECT OrderAmt,
CASE
WHEN OrderAmt < 300 THEN '200 Dollar Order'
WHEN OrderAmt < 200 THEN '100 Dollar Order'
WHEN OrderAmt < 100 THEN '< 100 Dollar Order'
ELSE '300 Dollar and above Order'
END AS OrderAmt_Category
FROM MyOrder;

SELECT OrderAmt,
CASE
WHEN OrderAmt < 100 THEN '< 100 Dollar Order'
WHEN OrderAmt < 200 THEN '100 Dollar Order'
WHEN OrderAmt < 300 THEN '200 Dollar Order'
ELSE '300 Dollar and above Order'
END AS OrderAmt_Category
FROM MyOrder;

SELECT OrderAmt,
CASE
WHEN OrderAmt < 100 THEN '< 100 Dollar Order'
WHEN OrderAmt < 200 THEN '100 Dollar Order'
WHEN OrderAmt < 300 THEN
CASE
WHEN Layaway = 'N'
THEN '200 Dollar Order without Layaway'
ELSE '200 Dollar Order with Layaway' END
ELSE
CASE
WHEN Layaway = 'N'
THEN '300 Dollar Order without Layaway'
ELSE '300 Dollar Order with Layaway' END
END AS OrderAmt_Category
FROM MyOrder;

SELECT *
FROM MyOrder
WHERE CASE YEAR(OrderDT)
WHEN 2014 THEN 'Year 1'
WHEN 2013 THEN 'Year 2'
WHEN 2012 THEN 'Year 3'
ELSE 'Year 4 and beyond' END = 'Year 1';


-- IIF
SELECT OrderAmt,
CASE
WHEN OrderAmt > 200 THEN 'High $ Order'
ELSE 'Low $ Order' END AS OrderType
FROM MyOrder;

SELECT OrderAmt,
IIF(OrderAmt > 200,
'High $ Order',
'Low $ Order') AS OrderType
FROM MyOrder;

--------------------------
-- Which is better to use, a CASE expression or an IF (or IF…ELSE) statement?
-- IF Nested (Anidada)
DECLARE @a VARCHAR(30) = 'one'
IF @a = 'one'
  BEGIN
    PRINT 'The variable value is 1.';
    RETURN;
  END
IF @a = 'two'
  BEGIN
    PRINT 'The variable value is 2.';
    RETURN;
  END
IF @a = 'three'
  BEGIN
    PRINT 'The variable value is 3.';
    RETURN;
  END
IF @a = 'four'
  BEGIN
    PRINT 'The variable value is 4.';
    RETURN;
  END
IF @a NOT IN ('one', 'two', 'three', 'four')
  BEGIN
    PRINT 'The variable value is not 1-4.';
    RETURN;
  END
GO
-- CASE
DECLARE @b VARCHAR(30) = 'two'
 
SELECT @b =
  CASE
    WHEN @b = 'one' THEN 'The variable value is 1.'
    WHEN @b = 'two' THEN 'The variable value is 2.'
    WHEN @b = 'three' THEN 'The variable value is 3.'
    WHEN @b = 'four' THEN 'The variable value is 4.'
  ELSE 'The variable value is not 1-4.'
  END;
PRINT @b;
--------------------

-- http://www.sql-server-helper.com/sql-server-2012/sql-server-2012-new-iif-choose-logical-functions.aspx

-- Can I use control-of-flow language to do an upsert in SQL Server

-- Upsert refers to code that includes logic to either update a row or insert a row, depending on whether that row exists. As with other data modification operations, you can use control-of-flow statement elements to do an upsert.
----------------
-- ClassRoom

-- CHOOSE
USE AdventureWorks2014
GO
SELECT ModifiedDate
FROM [Person].[Person]
Go 
SELECT 
		DISTINCT(FirstName + ' ' + LastName) AS Name
		 ,DATEPART(DD, ModifiedDate) AS [Dia],
		 DATEPART(MM, ModifiedDate) AS [Número Mes] -- Indice para Choose
		 -- CHOOSE devuelve un indice (posición)
		 ,CHOOSE(DATEPART(MM,ModifiedDate),'January','February','March','April','May','June',
		  'July','August','September','October','November','December')[Nombre Mes]
		 ,DATEPART(YYYY, ModifiedDate) AS [Year]
FROM [Person].[Person] 
ORDER BY Name ASC
GO
------------------
-- IIF (IF Lógico)

--Ejemplo
DECLARE @PAIS NVARCHAR(20)
SELECT @PAIS =
CASE 'Fr'
 WHEN 'Fr' THEN 'Francia'
 WHEN 'Ru' THEN 'Rusia'
 WHEN 'In' THEN 'Inglaterra'
 ElSE 'Pais desconocido'
END
PRINT @PAIS


-- Funciones de Conversión CAST / CONVERT . Concatenación

DECLARE @dinero money
SET @dinero = $193.57 -- + No es Suma es Concatenación
--print 'Dinero? ' + @dinero    -- ERROR!!!
--GO
PRINT 'Dinero? ' +  CAST(@dinero AS varchar(20))+'----' /* Convierte money en varchar */
GO
--

DECLARE @FirstArgument INT = 10
DECLARE @SecondArgument INT = 20
SELECT IIF ( @FirstArgument > @SecondArgument , 'TRUE', 'FALSE' ) 
 AS [Output Using IIF Logical Function]
GO

-- TRY_PARSE
-- Devuelve el resultado de una expresión, traducido al tipo de datos solicitado, o NULL si se produce un error 
-- en la conversión en SQL Server. 
-- Use TRY_PARSE solo para convertir de tipos de cadena a tipos de fecha y hora y de número.
SELECT 
   StateProvinceCode
  ,CountryRegionCode
  ,IIF(TRY_PARSE(StateProvinceCode AS INT) Between 0 AND 95,'France','Canada') AS Pais
FROM Person.StateProvince 
  WHERE StateProvinceCode IN ('95','AB')
GO
----------------
-- Funciones Anidadas (= Nested)

PRINT 'IMPRESO EN '+ RTRIM(CONVERT(varchar(30),getdate()))+'.'
GO
-- IMPRESO EN May 10 2016  8:31AM.


/* Muestra el dia que se imprimio un archivo, además convierte un getdate a varchar */


-- http://www.sql-server-helper.com/tips/determine-missing-identity-values.aspx

-- Determine Missing Identity Values
USE Tempdb
GO
-- Step #1: Create Table and Populate with Values
CREATE TABLE #CarType (
    [ID] INT IDENTITY, 
    [Name] VARCHAR(20) )
GO

INSERT INTO #CarType ( [Name] ) VALUES ( 'Bentley' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'BMW' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Ferrari' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Lamborghini' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Hummer' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Jaguar' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Lexus' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Mercedes Benz' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Porsche' )
INSERT INTO #CarType ( [Name] ) VALUES ( 'Volvo' )
GO
SELECT * FROM #CarType
GO

-- Step #2: Delete IDs
DELETE FROM #CarType WHERE [ID] IN (3, 4, 9)

SELECT * FROM #CarType

-- Step #3 (Option #1): Identify Missing IDENTITY Values
DECLARE @ID INT
DECLARE @MaxID INT
DECLARE @MissingCarTypeIDs TABLE ( [ID] INT )

SELECT @MaxID = [ID] FROM #CarType

SET @ID = 1
WHILE @ID <= @MaxID
BEGIN
    IF NOT EXISTS (SELECT 'X' FROM #CarType
                   WHERE [ID] = @ID)
        INSERT INTO @MissingCarTypeIDs ( [ID] )
        VALUES ( @ID )

    SET @ID = @ID + 1
END

SELECT * FROM @MissingCarTypeIDs

-- Another way of determining the missing identity values is the use of a temporary table that contains just one column which will hold all possible values of an identity column from a value of 1 to the maximum identity value of the table being searched.

-- Step #3 (Option #2): Identify Missing IDENTITY Values
DECLARE @IntegerTable TABLE ( [ID] INT )
DECLARE @ID INT
DECLARE @MaxID INT

SELECT @MaxID = [ID] FROM #CarType

SET @ID = 1
WHILE @ID <= @MaxID
BEGIN
    INSERT INTO @IntegerTable ( [ID] )
    VALUES ( @ID )

    SET @ID = @ID + 1
END

SELECT A.*
FROM @IntegerTable A LEFT OUTER JOIN #CarType B
  ON A.[ID] = B.[ID]
WHERE B.[ID] IS NULL

---------

-- http://www.sql-server-helper.com/tips/generate-random-records.aspx
-- http://www.sql-server-helper.com/tips/sort-ip-address.aspx

-- WHILE			BREAK		CONTINUE
-- Estructura Repetitiva (Iterativa). Bucle(=Loop)

DECLARE @i INT = 0
-- SET @i = 0
WHILE @i < 5
BEGIN
			   PRINT 'Hola Mundo'
			   SET @i = @i + 1
			   PRINT CAST(@i AS varchar(1))
END


--Hola Mundo
--1
--Hola Mundo
--2
--Hola Mundo
--3
--Hola Mundo
--4
--Hola Mundo
--5

-- Decrementando

DECLARE @i INT
SET @i = 5
WHILE @i > 0
BEGIN
   PRINT 'Hola Mundo'
   SET @i = @i - 1
   -- PRINT CAST(@i AS Char(1))
   PRINT convert(varchar(1),@i)
END

--Hola Mundo
--4
--Hola Mundo
--3
--Hola Mundo
--2
--Hola Mundo
--1
--Hola Mundo
--0
-------------

-- Determine Missing Identity Values
USE Tempdb
GO
-- Step #1: Create Table and Populate with Values
CREATE TABLE Coches (
    [ID] INT IDENTITY, 
    [Name] VARCHAR(20) )
GO

INSERT INTO Coches ( [Name] ) VALUES ( 'Bentley' )
INSERT INTO Coches ( [Name] ) VALUES ( 'BMW' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Ferrari' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Lamborghini' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Hummer' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Jaguar' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Lexus' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Mercedes Benz' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Porsche' )
INSERT INTO Coches ( [Name] ) VALUES ( 'Volvo' )
GO
SELECT * FROM Coches
GO

-- Step #2: Delete IDs
DELETE Coches 
WHERE [ID] IN (3, 4, 9)
GO

SELECT * FROM Coches

-- Step #3 (Option #1): Identify Missing IDENTITY Values
DECLARE @ID INT
DECLARE @MaxID INT
DECLARE @MissingCarTypeIDs TABLE ( ID INT )

SELECT @MaxID = [ID] FROM Coches
PRINT convert(varchar(2),@MaxID)
SET @ID = 1
WHILE @ID <= @MaxID
BEGIN
    IF NOT EXISTS (SELECT 'X' FROM Coches
                   WHERE ID = @ID)
        INSERT INTO @MissingCarTypeIDs ( ID )
        VALUES ( @ID )

    SET @ID = @ID + 1
END

SELECT * FROM @MissingCarTypeIDs

--------------------------


Declare @Contador int
set @Contador = 10
while (@Contador > 0)
 begin
 print '@Contador = ' + CONVERT(NVARCHAR,@Contador)
 set @Contador = @Contador -1
 end
 --------------
 -- Simple Example of WHILE Loop With CONTINUE and BREAK Keywords

--  1) Example of WHILE Loop
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=5)
		BEGIN
		PRINT @intFlag
		SET @intFlag = @intFlag + 1
END
GO

--ResultSet:
--1
--2
--3
--4
--5

-- 2) Example of WHILE Loop with BREAK keyword
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=5)
			BEGIN
			PRINT @intFlag
			SET @intFlag = @intFlag + 1
			IF @intFlag = 4
			BREAK;
END
GO

--ResultSet:
--1
--2
--3

-- 3) Example of WHILE Loop with CONTINUE and BREAK keywords
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=5)
		BEGIN
					PRINT @intFlag
					SET @intFlag = @intFlag + 1
					CONTINUE;
					IF @intFlag = 4 -- This will never executed
					BREAK;
END
GO

--ResultSet:
--1
--2
--3
--4
--5


-----------
-- Ejemplo parecido

-- Now run the preceding examples in SQL Server Management Studio.

-- While statement
print 'While statement'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
END
 go
 
-- While Statement with Beak
print 'While Statement with break'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
if(@countnumber=22)
break
END
go
-- While Statement with continue
print 'While Statement with continue'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
CONTINUE;
if(@countnumber=4)  -- This will never execute.
break
END
-----------------------
-- I don’t get how a WHILE loop works. Can you help make sense of what’s going on here?

--The WHILE loop provides a structure for repeatedly executing a set of statements as long as the loop’s condition evaluates to TRUE. The WHILE loop lets you add the logic necessary to limit the number of executions when you don’t know that number in advance. Let’s look at a few examples to get a sense of how these loops work.

--We’ll start simply by first demonstrating the logic behind the execution flow when using a WHILE loop. The following T-SQL declares a variable and then executes a loop based on the variable’s value:

DECLARE @c INT = 100;
 
WHILE @c <= 104
  BEGIN
    PRINT @c;
    SET @c = @c + 1;
  END;
 
--The loop begins with the WHILE keyword, followed by the condition that is evaluated each time the loop runs. If the condition evaluates to TRUE, the query engine executes the T-SQL in the statement block that follows the condition. If the condition evaluates to FALSE, the query engine exits the loop and continues on to any code after the statement block.

--In this case, the condition will evaluate to TRUE five times, which means the loop will run five times. When the variable value exceeds 104, the loop ends. The following statement shows the results that the statements return:

100
101
102
103
104
-- You can further control the logic within your loop by adding a BREAK statement in any place where the query engine should exit the loop:

DECLARE @d INT = 100;
 
WHILE @d <= 104
  BEGIN
    PRINT @d;
    SET @d = @d + 1;
    IF @d = 103
      BREAK;
  END;
 
-- This time around, we’ve added an IF statement that specifies that the query engine should break out of the loop if the variable value equals 103. Because we’ve added the IF and BREAK conditions, our loop now returns only the following results;

100
101
102
-- As you can see, query execution stopped when the variable value hit 103.

-- You can also add a CONTINUE statement to your WHILE loop to further control the execution. The CONTINUE statement causes the query engine to restart the loop from wherever you’ve added CONTINUE:

DECLARE @e INT = 100;
 
WHILE @e <= 104
  BEGIN
    PRINT @e;
    SET @e = @e + 1;
    CONTINUE;
  IF @e = 103
    BREAK;
  END;
 
Because I’ve included the CONTINUE statement where I did, the statement will never reach the final IF block. Instead, each time the WHILE condition evaluates to TRUE, the statement block will be executed up to CONTINUE and then start over, giving us the following results:

100
101
102
103
104


-------------------
-- ClassRoom

------------
-- WARNING: WHILE (and cursor) loop does not scale well for large datasets
-- Use set-based operations for large datasets 
------------
-- T-SQL create stored procedure - no parameter
-- MSSQL while loop - insert select - table variable
USE Northwind 
GO
SELECT TOP 10 * FROM [dbo].[Suppliers]
GO
IF OBJECT_ID('Suministradores','U') is not null
	DROP TABLE Suministradores
GO
SELECT [SupplierID],[ContactName],[CompanyName]
INTO Suministradores
FROM [dbo].[Suppliers]
WHERE 1=0
GO
SELECT * FROM Suministradores
GO
IF OBJECT_ID('SupplierStats','P') is not null
	DROP TABLE SupplierStats
GO
CREATE PROC SupplierStats 
-- ALTER PROC SupplierStats 
AS 
  BEGIN 
  SET nocount  ON
    DECLARE  @imax INT, 
             @i    INT 
    DECLARE  @Contact VARCHAR(100), 
             @Company VARCHAR(50) 
-- The RowID identity column will be used for loop control
-- MSSQL declare table variable 
    DECLARE  @CompanyInfo  TABLE( 
                                 RowID       INT    IDENTITY ( 1 , 1 ), 
                                 CompanyName VARCHAR(100), 
                                 ContactName VARCHAR(50) 
                                 ) 
    INSERT @CompanyInfo 
    SELECT   CompanyName, 
             ContactName 
    FROM     Suppliers 
    WHERE    ContactName LIKE '[a-k]%' 
    ORDER BY CompanyName 
     
    SET @imax = @@ROWCOUNT 
    SET @i = 1 
     
    WHILE (@i <= @imax) 
      BEGIN 
        SELECT @Contact = ContactName, 
               @Company = CompanyName 
        FROM   @CompanyInfo 
        WHERE  RowID = @i 
         
        ------------------------------------------------------

        -- INSERT PROCESSING HERE
		INSERT Suministradores
		VALUES (@Contact,@Company)
        ------------------------------------------------------
 
        PRINT CONVERT(varchar,@i)+' Contact: ' + @Contact + ' at ' + @Company 
         
        SET @i = @i + 1 
      END -- WHILE
  END -- SPROC
GO
-- Stored procedure execution - test stored procedure
EXEC SupplierStats
GO
 
/* Partial results
 
1 Contact: Guylène Nodier at Aux joyeux ecclésiastiques
2 Contact: Cheryl Saylor at Bigfoot Breweries
3 Contact: Antonio del Valle Saavedra at Cooperativa de Quesos 'Las Cabras'
4 Contact: Charlotte Cooper at Exotic Liquids
5 Contact: Chantal Goulet at Forêts d'érables
6 Contact: Elio Rossi at Formaggi Fortini s.r.l.
7 Contact: Eliane Noz at Gai pâturage
8 Contact: Anne Heikkonen at Karkki Oy
*/
 ------------
 SELECT * FROM Suministradores
GO
--------------------------------------------------------------

-- Of course, all we’ve done is go full circle, receiving the same results we received without using CONTINUE and BREAK, but these simple examples should help demonstrate the basic concepts of a WHILE loop.

-- But now suppose we want to do something a little more involved. 
-- Let’s start by creating a small temporary table based on data from the Product table in the AdventureWorks2014 
-- database:

SELECT ProductID,
  Name AS ProductName,
  StandardCost AS Wholesale,
  ListPrice As Retail
INTO #PriceyProducts
FROM Production.Product
WHERE ListPrice > 2999.99;
GO
 
SELECT * FROM #PriceyProducts
GO
-- Now suppose we want to increase the retail prices in 10% percent increments, but only as long as the average 
-- net price remains under $2500. At the same time, the retail price must always remain under $4999.99. We can create a WHILE loop that increments the price while ensuring we stay within our parameters:

DECLARE @count INT = 0
WHILE (SELECT AVG(Retail - Wholesale) FROM #PriceyProducts) < 2500
  BEGIN
    UPDATE #PriceyProducts SET Retail = Retail * 1.1
    SET @count = @count + 1;
    IF (SELECT MAX(Retail) FROM #PriceyProducts) < 4999.99
      CONTINUE;
    ELSE
      BREAK;
  END;
PRINT 'The WHILE loop ran ' + CAST(@count AS VARCHAR(10)) + ' times.'
GO
-- The WHILE condition checks whether the average net price is under $2500. If the condition evaluates to TRUE, the statement block runs and increases the retail prices by 10%. The statement block also includes an IF statement, which checks whether the highest retail price is under $4999.00. If it is, the loop starts over. Should the IF condition evaluate to FALSE, the query engine breaks out of the loop and jumps to the final PRINT statement.

--I included the @count variable only to count the number of times the WHILE loop runs, which in this case, is three times, as the following results show:

--The WHILE loop ran 3 times.

--If we were now to view the data in the #PriceyProducts table, we would see the following results:

--We can verify our results by running the following SELECT statement to determine the current average net price:

SELECT AVG(Retail - Wholesale) 
FROM #PriceyProducts 
GO
-- 2598.9164

-- The statement returns the value 2598.9164, which exceeds the $2500. It was at this point that the query engine exited the WHILE loop. In addition, as we can see in the results, the maximum Retail value is 4762.6774, which is below the 4999.99 limit.

-------------------
--Utilizar BREAK y CONTINUE con IF…ELSE y WHILE anidados
--En el ejemplo siguiente, si el precio de venta promedio de un producto es inferior a $300, 
--el bucle WHILE dobla los precios y, a continuación, selecciona el precio máximo. 
-- Si el precio máximo es menor o igual que $500, el bucle WHILE se reinicia y vuelve a doblar los precios. 
--Este bucle continúa doblando los precios hasta que el precio máximo es mayor que $500, 
--después de lo cual sale del bucle WHILE e imprime un mensaje.

USE AdventureWorks2014;
GO
WHILE (SELECT AVG(ListPrice) FROM Production.Product) < $300
BEGIN
   UPDATE Production.Product
      SET ListPrice = ListPrice * 2
   SELECT MAX(ListPrice) FROM Production.Product
   IF (SELECT MAX(ListPrice) FROM Production.Product) > $500
      BREAK
   ELSE
      CONTINUE
END
PRINT 'Too much for the market to bear';

 ---------------
 USE Pubs
 GO
 -- Declaramos una tabla temporal
CREATE TABLE #Temp1 (
    ID INT Identity(1,1),
    campo1 VARCHAR(50),
    campo2 VARCHAR(50)
)
 
-- Pasamos todo a nuestra tabla temporal de nuestra tabla en cuestion
INSERT INTO #Temp1
(
    campo1,
    campo2
)
SELECT[au_lname],[au_fname]
FROM [dbo].[autores]
 
DECLARE @Contador INT           -- Variable contador
SET @Contador = 1   
DECLARE @Regs INT               -- Variable para el Numero de Registros a procesar
SET @Regs = (SELECT COUNT(*) FROM [dbo].[autores])
 
DECLARE @campo VARCHAR(50)
 
-- Hacemos el Loop
WHILE @Contador = @Regs
BEGIN
    SELECT @campo= t.campo1
    FROM #Temp1 t
    WHERE t.ID = @Contador
 
    -- Imprimimos el valor
    Print  @campo
    SET @Contador = @Contador + 1
 
END
----------------

-- RETURN

DECLARE @CONTADOR INT
SET @CONTADOR = 10
WHILE (@CONTADOR >0)
 BEGIN
 PRINT '@CONTADOR = ' + CONVERT(NVARCHAR,@CONTADOR)
 SET @CONTADOR = @CONTADOR -1
 IF (@CONTADOR = 5)
 RETURN -- No ejecuta el PRINT 'FIN'        BREAK -- Ejecuta el PRINT 'FIN'
PRINT 'FIN'


----------------------
--Ejemplo : Utilizar BREAK y CONTINUE con IF…ELSE y WHILE anidados

--Si el precio de venta promedio de un producto es inferior a $300, 
--el bucle WHILE dobla los precios y, a continuación, selecciona el precio máximo. 

--Si el precio máximo es menor o igual que $500, el bucle WHILE se reinicia con CONTINUE
--  y vuelve a doblar los precios.
 
--Este bucle continúa doblando los precios hasta que el precio máximo es mayor que $500, 
--después de lo cual sale del bucle WHILE con BREAK e imprime un mensaje.


USE AdventureWorks2014;
GO
DROP TABLE Producto
GO

SELECT *
	into Producto
	FROM Production.Product
GO
SELECT AVG(ListPrice) 
FROM Producto 
GO

-- 443,8249
WHILE (SELECT AVG(ListPrice) FROM Producto) < $300
BEGIN
	declare @Precio as money
   UPDATE Producto
      SET ListPrice = ListPrice * 2
	SET @Precio = (select top 1 Listprice from Producto)
	PRINT convert(varchar(20),@Precio)
	WAITFOR DELAY '00:00:05'
   SELECT MAX(ListPrice) FROM Producto
   IF (SELECT MAX(ListPrice) FROM Producto) > $500
      BREAK
   ELSE
      CONTINUE
END
PRINT 'Precio demasiado alto';
GO
--------------------

-- How do I add a pause or wait time to my T-SQL in order to delay execution?

SELECT ProductID AS ProdID,
  Name AS ProductName,
  StandardCost AS Wholesale,
  ListPrice As Retail
INTO ##awproducts
FROM Production.Product
WHERE FinishedGoodsFlag = 1;
GO
BEGIN TRANSACTION;
 
UPDATE ##awproducts
SET Retail = Retail * 1.2
WHERE ProdID = 680;
 
WAITFOR DELAY '00:00:05' 
 
ROLLBACK TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
SELECT Retail FROM ##awproducts
WHERE ProdID = 680;

DECLARE @time DATETIME = DATEADD(S, 5, GETDATE());
WAITFOR TIME @time;
PRINT 'The waiting is over.';

---------------

-- “Is it possible to skip from one section of your T-SQL code to another?

-- In T-SQL you can use a GOTO statement to jump to another part of the code, as long as you’ve assigned a label to the destination. A label is merely an identifier that provides a heading for the targeted section of code. For example, the following T-SQL includes several labeled blocks of code with several references to them:

DECLARE @count INT = 1;
 
IF @count = 1
  GOTO goto_one;
ELSE IF @count = 2
  GOTO goto_two;
ELSE IF @count = 3
  GOTO goto_three;
ELSE
  GOTO goto_four;
 
goto_one:
PRINT 'This is goto_one.'
GOTO goto_four;
 
goto_two:
PRINT 'This is goto_two.'
GOTO goto_four;
 
goto_three:
PRINT 'This is goto_three.'
GOTO goto_four;
 
goto_four:
RETURN
 
--When you reference a label, you provide only the label name along with the GOTO keyword. However, when you assign a label to a bock of code, you must also include a colon. When the query engine encounters a GOTO statement, it jumps to the label identified in the statement. For example, the initial IF statement includes a GOTO statement that points to the goto_one label. As a result, if the @count variable has a value of 1, the query engine will jump to the goto_one label, execute the PRINT statement associated with that label, and return the following results.

--This is goto_one.

-- Of course, you’re likely to want to use the GOTO statement for more practical purposes than in the example above. For example, suppose your T-SQL includes a number of IF statements that take different steps. Regardless of which condition evaluates to TRUE, you want to run a final INSERT statement that logs the event. You can do something similar to the following:

CREATE TABLE #UsageLog
(LogID INT IDENTITY, Usage VARCHAR(20),
  LogTime DATETIME DEFAULT GETDATE());
 
DECLARE @CustID INT = 170, @usage VARCHAR(20) = '';
 
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
    SET @usage = 'ID null';
    GOTO log_usage;
  END
ELSE IF EXISTS(SELECT * FROM Sales.vIndividualCustomer
    WHERE BusinessEntityID = @CustID)
  BEGIN
    SELECT FirstName, LastName, City, StateProvinceName
    FROM Sales.vIndividualCustomer
    WHERE BusinessEntityID = @CustID;
    SET @usage = 'ID valid';
    GOTO log_usage;
  END
ELSE
  BEGIN
    PRINT 'No record matches the customer ID ' +
      CAST(@CustID AS VARCHAR(10)) + '.'
    SET @usage = 'ID invalid';
    GOTO log_usage;
  END
 
log_usage:
INSERT INTO #UsageLog (Usage) VALUES(@usage);
GO
-- For each possible condition, the statement block ends with a GOTO statement that points to the log_usage label, so no matter what happens elsewhere, the last statement here will run. Although we’ve included only a simple INSERT statement with out label, you can use this strategy to avoid having to recode more complex logic in multiple places.

--SQL Server – Implementing a DO-WHILE Loop in Transact-SQL


--Last day there was a T-SQL Session going on with a bunch of folks attending the session and most of them were familiar with T-SQL. During the session, the topic of Transact-SQL WHILE Loop Construct came up and we started discussing about it. Suddenly I asked everyone, How to Implement DO-WHILE Loop in T-SQL. To my surprise, many folks were not able to answer this question. So just thought that this can be good learning for folks who are not familiar with the implementation of DO-WHILE in T-SQL and also this tip is worth adding to the T-SQL Interview Questions and Answers List.

--A DO-WHILE Loop is a Looping Construct, similar to WHILE Loop. The difference between WHILE Loop and DO-WHILE Loop is that, statements inside a WHILE Loop are executed only if the condition specified in the WHILE Loop is satisfied, whereas the statements inside a DO-WHILE Loop are executed at least once irrespective of whether the condition specified in the DO-WHILE Loop is satisfied or not.

--As most of you, who are reading this article might already be aware and those of you who are new to this, there is no DO-WHILE Looping Construct available in T-SQL Language. However, we can achieve the DO-WHILE Looping functionality in T-SQL by combining a couple of T-SQL Control Flow Clauses/Constructs/Statements.

--Let us say that you want to achieve a DO-WHILE Loop functionality and the statements inside the loop should execute specified number of times based on the condition but should execute at least once. Below is an example of the same.


DECLARE @LoopCounter TINYINT = 1
DECLARE @LoopMaxCount TINYINT

SET @LoopMaxCount = 0    /* Intentionally set to zero */

WHILE (1 = 1)    /* Give an expression, outcome of which is always true */
BEGIN
    PRINT 'Loop Counter Value: ' + CAST(@LoopCounter AS VARCHAR(3))
    /*
    Your list of statements to be executed here.
    */

    SET @LoopCounter = @LoopCounter + 1 ;

    IF (@LoopCounter > @LoopMaxCount)
        BREAK ;

END
GO
---

1) Example of WHILE Loop
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=5)
BEGIN
PRINT @intFlag
SET @intFlag = @intFlag + 1
END
GO

--ResultSet:
--1
--2
--3
--4
--5

2) Example of WHILE Loop with BREAK keyword
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=5)
BEGIN
PRINT @intFlag
SET @intFlag = @intFlag + 1
IF @intFlag = 4
BREAK;
END
GO

ResultSet:
1
2
3

3) Example of WHILE Loop with CONTINUE and BREAK keywords
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=5)
BEGIN
PRINT @intFlag
SET @intFlag = @intFlag + 1
CONTINUE;
IF @intFlag = 4 -- This will never executed
BREAK;
END
GO

ResultSet:
1
2
3
4
5

http://www.sqlusa.com/bestpractices/whilelooptablevariable/
Execute the following T-SQL example scripts in Microsoft SQL Server Management Studio Query Editor to demonstrate cursor-like WHILE loop construction.

------------
-- WARNING: WHILE (and cursor) loop does not scale well for large datasets
-- Use set-based operations for large datasets 
------------
-- T-SQL create stored procedure - no parameter
-- MSSQL while loop - insert select - table variable
USE Northwind 
GO
CREATE PROC SupplierStats 
-- ALTER PROC SupplierStats 
AS 
  BEGIN 
  SET nocount  ON
    DECLARE  @imax INT, 
             @i    INT 
    DECLARE  @Contact VARCHAR(100), 
             @Company VARCHAR(50) 
-- The RowID identity column will be used for loop control
-- MSSQL declare table variable 
    DECLARE  @CompanyInfo  TABLE( 
                                 RowID       INT    IDENTITY ( 1 , 1 ), 
                                 CompanyName VARCHAR(100), 
                                 ContactName VARCHAR(50) 
                                 ) 
    INSERT @CompanyInfo 
    SELECT   CompanyName, 
             ContactName 
    FROM     Suppliers 
    WHERE    ContactName LIKE '[a-k]%' 
    ORDER BY CompanyName 
     
    SET @imax = @@ROWCOUNT 
    SET @i = 1 
     
    WHILE (@i <= @imax) 
      BEGIN 
        SELECT @Contact = ContactName, 
               @Company = CompanyName 
        FROM   @CompanyInfo 
        WHERE  RowID = @i 
         
        ------------------------------------------------------

        -- INSERT PROCESSING HERE
        ------------------------------------------------------
 
        PRINT CONVERT(varchar,@i)+' Contact: ' + @Contact + ' at ' + @Company 
         
        SET @i = @i + 1 
      END -- WHILE
  END -- SPROC
GO
-- Stored procedure execution - test stored procedure
EXEC SupplierStats
GO
 
/* Partial results
 
1 Contact: Guylène Nodier at Aux joyeux ecclésiastiques
2 Contact: Cheryl Saylor at Bigfoot Breweries
3 Contact: Antonio del Valle Saavedra at Cooperativa de Quesos 'Las Cabras'
4 Contact: Charlotte Cooper at Exotic Liquids
5 Contact: Chantal Goulet at Forêts d'érables
6 Contact: Elio Rossi at Formaggi Fortini s.r.l.
7 Contact: Eliane Noz at Gai pâturage
8 Contact: Anne Heikkonen at Karkki Oy
*/



-- http://sqlserverpedia.com/wiki/WHILE_Loops

-- http://www.c-sharpcorner.com/UploadFile/rohatash/if-and-while-statement-in-sql-server-2012/
-- Example

-- While statement
print 'While statement'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
END
-- The execution of statements in the WHILE loop can be controlled from inside the loop with the break and continue keywords.

BREAK  Keyword

-- Break forces a loop to exit immediately. Suppose we repeat a number from 1 to 20. The loop will go through all the numbers. We want to exit when we get to the number 11 in the loop. That can be done simply by using the break keyword with a while loop.

-- Example

-- While Statement with Beak
print 'While Statement with break'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
if(@countnumber=22)
break
END
 
--Continue Keyword
 
--This does the opposite of break. Instead of terminating the loop, it immediately loops again, skipping the rest of the code. The continue statement skips the value and jumps to the while loop without terminating the loop.

--Example

-- While Statement with continue
print 'While Statement with continue'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
CONTINUE;
if(@countnumber=4)  -- This will never execute.
break
END

--Output of the preceding examples in SQL Server Management Studio

--Now run the preceding examples in SQL Server Management Studio.

-- While statement
print 'While statement'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
END
 go
 
-- While Statement with Break
print 'While Statement with break'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
if(@countnumber=22)
break
END
go
-- While Statement with continue
print 'While Statement with continue'
 
DECLARE @countnumber varchar(50)
SET @countnumber  = 1
WHILE (@countnumber<=30)
BEGIN
PRINT 'Number=' +  @countnumber
SET @countnumber = @countnumber  + 3
CONTINUE;
if(@countnumber=4)  -- This will never execute.
break
END




------------------------

Transact-SQL

/* asignar valores */
declare @nombre varchar(10)
declare @fecha datetime
declare @contar int
	set @nombre='pepe'
	set @fecha='01/01/2003'

	select @nombre='pepe', @fecha= '01/01/2003'
	select @contar=count (*) from stores
print @nombre
print @fecha
print @contar

------------
use pubs
go
if (select avg(price) from titles where type = 'mod_cook')<$15
	begin
		print 'libros de cocina'
		select substring (title,1,35) as titulo
		from titles
		where type ='mod_cook'
	end
else
	begin
		print 'libros de cocina baratos'
		select substring (title,1,35) as titulo
		from titles
		where type ='mod_cook'
	end
go

-- Silicon Valley Gastronomic Treats
-----------------

use pubs 
set nocount on
go
declare @pub_id char(4),@hire_date datetime
set @pub_id ='0877'
set @hire_date='1/10/90'
select fname,lname
from employee
where pub_id=@pub_id and hire_date >=@hire_date

/* Muestra Nombre y Apellidos de los empleados que tengan
el pub id y fecha especificada. */ 


-------
USE Pubs
GO
SELECT * FROM Sales
GO
DROP TABLE Ventas
GO
SELECT * 
INTO Ventas
FROM Sales
GO
begin TRANSACTION
	delete ventas
	where title_id ='BU1032'
	if @@error = 0
		BEGIN
			commit tran
			Print 'Sin Error  '+ cast(@@error as varchar(10))
		END
	else
		BEGIN
			rollback tran
			Print 'Error     '+ cast(@@error as varchar(10))
		END
		
GO

-------------------------

-- ClassRoom 

-- Stored Procedure Backup DataBases

-- Script Backup BD 


USE master
GO
CREATE PROC BACKUP_ALL_DB_PARENTRADA
	@path VARCHAR(256)
AS
DECLARE @name VARCHAR(50), -- database name
-- @path VARCHAR(256), -- path for backup files
	@fileName VARCHAR(256), -- filename for backup
	@fileDate VARCHAR(20), -- used for file name
	@backupCount INT

CREATE TABLE [dbo].#tempBackup
 (intID INT IDENTITY (1, 1), 
 name VARCHAR(200))

-- Crear la Carpeta Backup
-- SET @path = 'C:\Backup\'

-- Includes the date in the filename
SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112)

-- Includes the date and time in the filename
--SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '')

INSERT INTO [dbo].#tempBackup (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ( 'AdventureWorks2014','Northwind','pubs')
	-- WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')

SELECT TOP 1 @backupCount = intID 
FROM [dbo].#tempBackup 
ORDER BY intID DESC

-- Utilidad: Solo Comprobación Nº Backups a realizar
PRINT @backupCount

IF ((@backupCount IS NOT NULL) AND (@backupCount > 0))
BEGIN
	DECLARE @currentBackup INT

	SET @currentBackup = 1
		WHILE (@currentBackup <= @backupCount)
			BEGIN
			SELECT
					@name = name,
					@fileName = @path + name + '_' + @fileDate + '.BAK' -- Unique FileName
			--@fileName = @path + @name + '.BAK' -- Non-Unique Filename
			FROM [dbo].#tempBackup
			WHERE intID = @currentBackup

		-- Utilidad: Solo Comprobación Nombre Backup
		print @fileName

		-- does not overwrite the existing file
		BACKUP DATABASE @name TO DISK = @fileName
		-- overwrites the existing file (Note: remove @fileDate from the fileName so they are no longer unique
		--BACKUP DATABASE @name TO DISK = @fileName WITH INIT

		SET @currentBackup = @currentBackup + 1
	END
END
-- Utilidad: Solo Comprobación Mirar panel de Resulatados Autonumerico y Nombre BD
SELECT * FROM  [dbo].#tempBackup

DROP TABLE [dbo].#tempBackup

-- End SP_
GO

-- Ejecutar Procedimiento

EXEC BACKUP_ALL_DB_PARENTRADA 'C:\Backup\'

-- Results

--intID	name
--1	AdventureWorks2014
--2	Northwind
--3	pubs

-- Messages

--(3 row(s) affected)
--3
--C:\Backup\AdventureWorks2014_20160125.BAK
--Processed 24768 pages for database 'AdventureWorks2014', file 'AdventureWorks2014_Data' on file 1.
--Processed 2 pages for database 'AdventureWorks2014', file 'AdventureWorks2014_Log' on file 1.
--BACKUP DATABASE successfully processed 24770 pages in 6.106 seconds (31.691 MB/sec).
--C:\Backup\Northwind_20160125.BAK
--Processed 536 pages for database 'Northwind', file 'Northwind' on file 1.
--Processed 2 pages for database 'Northwind', file 'Northwind_log' on file 1.
--BACKUP DATABASE successfully processed 538 pages in 0.231 seconds (18.167 MB/sec).
--C:\Backup\pubs_20160125.BAK
--Processed 392 pages for database 'pubs', file 'pubs' on file 1.
--Processed 2 pages for database 'pubs', file 'pubs_log' on file 1.
--BACKUP DATABASE successfully processed 394 pages in 0.145 seconds (21.177 MB/sec).

--(3 row(s) affected)


-----------------------

SELECT GETDATE()

DECLARE @counter INT = 0
DECLARE @date DATETIME = '2018-04-19 17:52:22.407'

CREATE TABLE #dateFormats (dateFormatOption int, dateOutput varchar(40))

WHILE (@counter <= 150 )
BEGIN
   BEGIN TRY
      INSERT INTO #dateFormats
      SELECT CONVERT(varchar, @counter), CONVERT(varchar,@date, @counter) 
      SET @counter = @counter + 1
   END TRY
   BEGIN CATCH;
      SET @counter = @counter + 1
      IF @counter >= 150
      BEGIN
         BREAK
      END
   END CATCH
END

SELECT * FROM #dateFormats

