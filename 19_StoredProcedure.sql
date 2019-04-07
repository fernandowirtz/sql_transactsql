http://elsasoft.com/samples.htm

-------------------------------------------------------------------------
--PROCEDIMIENTOS ALMACENADOS (o SNIPPET)
-------------------------------------------------------------------------

--Los procedimientos almacenados son a nivel de base de datos, es decir, se 
--les asigna un schema, se les pueden dar permisos, etc.

USE pubs;
GO

CREATE PROCEDURE uspGetAutor
AS
		SELECT TOP 1 au_id, au_fname, au_lname
		FROM dbo.authors
GO

--Con este procedimiento del sistema vemos la estructura del proced. en cuestión
sp_helptext "uspGetAutor"
GO

--Para ejecutar un proced. almacenado, se invoca con EXECUTE ó EXEC
EXEC uspGetAutor


--Para modificar un procedimiento
--Así saca los 10 primeros valores
ALTER PROCEDURE uspGetAutor 
AS
		SELECT TOP 10 au_id, au_fname, au_lname
		FROM dbo.authors;
GO

--EJEMPLO
USE AdventureWorks2014;
GO
IF OBJECT_ID ('HumanResources.uspGetAllEmployess', 'P') IS NOT NULL
	DROP PROCEDURE HumanResources.uspGetAllEmployess;
go

CREATE PROCEDURE HumanResources.uspGetAllEmployess
AS
	SET NOCOUNT ON;
	SELECT LastName, FirstName, Department
	FROM HumanResources.vEmployeeDepartmentHistory;
GO

EXECUTE HumanResources.uspGetAllEmployess;
GO
--Or
EXEC HumanResources.uspGetAllEmployess;
GO
--Or, if this procedure is the first statement whiting a batch:
HumanResources.uspGetAllEmployess;

 -- Probar [uspGetAllEmployess]



--Crear un procedimiento almacenado con dos select
USE AdventureWorks2014;
GO
CREATE PROCEDURE dbo.uspMultipleResult
AS
	SELECT TOP(10) BusinessEntityID, Lastname, Firstname
	FROM Person.Person;
	SELECT TOP(5) CustomerID, AccountNumber
	FROM Sales.Customer;
GO

EXEC uspMultipleResult;
GO

---------------------------------------------------------------------------
		--Procedimientos almacenados con PARÁMETROS DE ENTRADA
---------------------------------------------------------------------------
USE pubs;
GO
/* crear Procedimiento de 3 variables */
DROP PROC miproc
go 
create proc miproc
	@primero int=null,
	@segundo int = 2,
	@tercero int =3
as 
	select @primero, @segundo,@tercero
go
exec miproc
exec miproc 2,3,4
----------------
USE Pubs
GO
SELECT  au_id, au_fname, au_lname
		FROM dbo.authors
GO
ALTER PROCEDURE uspGetAutor
	@Lastname NVARCHAR(50)
AS
		SELECT TOP 1 au_id, au_fname, au_lname
		FROM dbo.authors
		WHERE au_lname = @Lastname;
GO

--Nos muestra el primer valor del select con apellido como 
-- parámetro de entrada

EXEC uspGetAutor 'Ringer'
EXEC uspGetAutor 'Dull'

--Resultado
--998-72-3567	Albert	Ringer

-- Con 2 parámetros

use pubs;
go
CREATE PROCEDURE uspApellidoNombreAutor
	@Lastname NVARCHAR(50),
	@Firstname NVARCHAR(50) --Importa el orden
AS
		SELECT TOP 1 au_id, au_fname, au_lname
		FROM dbo.authors
		WHERE au_lname = @Lastname AND au_fname = @Firstname;
GO
--Ejecutamos
EXEC dbo.uspApellidoNombreAutor 'Ringer','Anne';

--O también (de esta forma no es necesario respetar el orden de entrada
EXEC dbo.uspApellidoNombreAutor @Firstname='Anne', @Lastname='Ringer';


--Ejemplo de valores por defecto
use AdventureWorks2014;
Go
IF OBJECT_ID('HumanResources.uspGetEmployees2', 'P') IS NOT NULL
	DROP PROCEDURE HumanResources.uspGetEmployees2;
go

CREATE PROCEDURE HumanResources.uspGetEmployees2
	@Lastname NVARCHAR(50) = 'D%',
	@Firstname NVARCHAR(50) = '%'
AS
	SET NOCOUNT ON;
	SELECT Firstname, Lastname, Department
	from HumanResources.vEmployeeDepartmentHistory
	WHERE FirstName LIKE @Firstname AND LastName LIKE @Lastname;
GO
--Diferentes resultados dependiendo del parámetro de entrada utilizado
EXEC HumanResources.uspGetEmployees2;
EXEC HumanResources.uspGetEmployees2 'Wi%';
EXEC HumanResources.uspGetEmployees2 @Firstname= '%';
EXEC HumanResources.uspGetEmployees2 '[CK]ars[OE]n';
EXEC HumanResources.uspGetEmployees2 'Hesse', 'Stefen';
EXEC HumanResources.uspGetEmployees2 'H%', 'S%';

-------------------
-- CRUD

USE tempDb
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 6/8/2014 2:10:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SET IDENTITY_INSERT Customers ON
GO
DROP TABLE Customers
GO
DROP PROCEDURE [Customers_CRUD]
GO

GO
CREATE TABLE [dbo].[Customers](
	[CustomerId] int  PRIMARY KEY NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Country] [varchar](50) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

INSERT INTO Customers
 VALUES (1,'Pepe Arias', 'United States'),
        (2,'Ana Perez', 'India'),
        (3,'Luis Garcia', 'Francia'),
		(4,'Roberto Fernandez', 'Rusia')

GO
SELECT * FROM Customers
Go

ALTER PROCEDURE [dbo].[Customers_CRUD]
	@Action VARCHAR(10)
	,@CustomerId INT = NULL
	,@Name VARCHAR(100) = NULL
	,@Country VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT
    IF @Action = 'SELECT'
	BEGIN
		SELECT CustomerId, Name, Country 
		FROM Customers
	END

	--INSERT
    IF @Action = 'INSERT'
	BEGIN
		INSERT INTO Customers (CustomerId,Name, Country) 
		VALUES (@CustomerId,@Name, @Country)
	END

	--UPDATE
    IF @Action = 'UPDATE'
	BEGIN
		UPDATE Customers 
		SET Name = @Name, Country = @Country 
		WHERE CustomerId = @CustomerId
	END

	--DELETE
    IF @Action = 'DELETE'
	BEGIN
		DELETE FROM Customers 
		WHERE CustomerId = @CustomerId
	END
END
GO

EXEC Customers_CRUD 'SELECT'
Go
EXEC Customers_CRUD 'INSERT',5,'Pepa Lopez','Argentina'
Go
SELECT * FROM Customers
Go
EXEC Customers_CRUD 'DELETE',1
Go
EXEC Customers_CRUD 'UPDATE',2,'Juan Arias','China'
Go

----------------------------------

USE [AdventureWorks2014]
GO

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  PRINT 'You must provide a customer ID.';
SELECT FirstName, LastName, City, StateProvinceName
FROM Sales.vIndividualCustomer
WHERE BusinessEntityID = @CustID;
GO

EXEC GetCustomerInfo 1700
GO
--FirstName	LastName	City	StateProvinceName
--Rebecca	Robinson	Seaford	Victoria

EXEC GetCustomerInfo;
GO

-- Message
--You must provide a customer ID.

--(0 row(s) affected)

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  PRINT 'You must provide a customer ID.';
  PRINT 'Contact the sales rep for your region:';
  SELECT FirstName, LastName, TerritoryName, EmailAddress
  FROM Sales.vSalesPerson
  WHERE JobTitle = 'Sales Representative';
SELECT FirstName, LastName, City, StateProvinceName
FROM Sales.vIndividualCustomer
WHERE BusinessEntityID = @CustID;
GO

EXEC GetCustomerInfo;
GO

EXEC GetCustomerInfo 1700;
GO

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
  END
SELECT FirstName, LastName, City, StateProvinceName
FROM Sales.vIndividualCustomer
WHERE BusinessEntityID = @CustID;
GO

EXEC GetCustomerInfo 1700;
GO

--FirstName	LastName	City	StateProvinceName
--Rebecca	Robinson	Seaford	Victoria

EXEC GetCustomerInfo 
GO
-----
-- When should I include an ELSE clause within an IF statement?
IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
  END
ELSE
  SELECT FirstName, LastName, City, StateProvinceName
  FROM Sales.vIndividualCustomer
  WHERE BusinessEntityID = @CustID;
PRINT 'AdventureWorks Bicycles;  '
  + CONVERT(VARCHAR(30), GETDATE(), 109);
GO

--------------
-- How do I nest IF and IF…ELSE statements, if it’s even possible?

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
  END
ELSE
  BEGIN
    IF EXISTS(SELECT * FROM Sales.vIndividualCustomer
        WHERE BusinessEntityID = @CustID)
      SELECT FirstName, LastName, City, StateProvinceName
      FROM Sales.vIndividualCustomer
      WHERE BusinessEntityID = @CustID;
    ELSE
      PRINT 'No record matches the customer ID ' +
        CAST(@CustID AS VARCHAR(10)) + '.'
  END
GO
-----------------
-- Update

USE [AdventureWorks2014]
GO

ALTER PROCEDURE [dbo].[UpdateSales]
  @SalesPersonID INT,
  @SalesAmt MONEY = 0
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;
      UPDATE LastYearSales
      SET SalesLastYear = SalesLastYear + @SalesAmt
      WHERE SalesPersonID = @SalesPersonID;
    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();

    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));

    THROW;
  END CATCH
END;
---------------
-- insert

USE AdventureWorks2014;
GO
DROP Table Contactos
GO
SELECT BusinessEntityID,PersonID,ContactTypeID
INTO Contactos
FROM Person.BusinessEntityContact
GO
INSERT INTO	Contactos -- Person.BusinessEntityContact
           (BusinessEntityID
           ,PersonID
           ,ContactTypeID)
     VALUES(0,0,1);
GO
SELECT BusinessEntityID,PersonID,ContactTypeID
FROM Contactos
GO
CREATE PROC spInsertValidatedBusinessEntityContact
    @BusinessEntityID int,
    @PersonID int,
    @ContactTypeID int
AS
BEGIN

    DECLARE @Error int;

    INSERT INTO Contactos
           (BusinessEntityID
           ,PersonID
           ,ContactTypeID)
    VALUES
        (@BusinessEntityID, @PersonID, @ContactTypeID);

    SET @Error = @@ERROR;

    IF @Error = 0
        PRINT 'New Record Inserted';
    ELSE
    BEGIN
        IF @Error = 547 -- Foreign Key violation. Tell them about it.
            PRINT 'At least one provided parameter was not found. Correct and retry';
        ELSE -- something unknown
            PRINT 'Unknown error occurred. Please contact your system admin';
    END
END
GO
EXEC spInsertValidatedBusinessEntityContact 1, 1, 11;
EXEC spInsertValidatedBusinessEntityContact 1806, 1, 11;

-------------------

-- Is it possible to terminate a procedure's execution from within an IF statement?

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
  END
SELECT FirstName, LastName, City, StateProvinceName
FROM Sales.vIndividualCustomer
WHERE BusinessEntityID = @CustID;
GO
-- Even if the IF expression evaluates to TRUE, the final SELECT statement runs and with it comes an empty result set. One way to avoid this, as we saw earlier, is to add an ELSE clause. However, we can also terminate the stored procedure after the IF statement block runs by adding the RETURN statement:

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
    RETURN;
  END
SELECT FirstName, LastName, City, StateProvinceName
FROM Sales.vIndividualCustomer
WHERE BusinessEntityID = @CustID;
GO
--If the IF expression evaluates to TRUE all the statements within the BEGIN…END block will run, just like before; however, when the query engine hits RETURN, it will immediately stop processing the stored procedure and exit. No other statements will be executed.

--Although this might not always be the strategy you want to employ for controlling your code’s logical flow, when it is, the RETURN statement is easy to implement and can be used anywhere in your code that makes sense. For example, the following procedure definition also includes RETURN in the nested IF statement:

IF OBJECT_ID('dbo.GetCustomerInfo', 'p') IS NOT NULL
DROP PROCEDURE dbo.GetCustomerInfo;
GO
 
CREATE PROCEDURE dbo.GetCustomerInfo
  (@CustID INT = NULL)
AS
IF @CustID IS NULL
  BEGIN
    PRINT 'You must provide a customer ID.';
    PRINT 'Contact the sales rep for your region:';
    SELECT FirstName, LastName, TerritoryName, EmailAddress
    FROM Sales.vSalesPerson
    WHERE JobTitle = 'Sales Representative';
    RETURN;
  END
ELSE
  BEGIN
    IF EXISTS(SELECT * FROM Sales.vIndividualCustomer
        WHERE BusinessEntityID = @CustID)
      BEGIN
        SELECT FirstName, LastName, City, StateProvinceName
        FROM Sales.vIndividualCustomer
        WHERE BusinessEntityID = @CustID;
        RETURN;
      END
    ELSE
      PRINT 'No record matches the customer ID ' +
        CAST(@CustID AS VARCHAR(10)) + '.'
  END
GO

-----------------
-- https://www.mssqltips.com/sqlservertip/2112/table-value-parameters-in-sql-server-2008-and-net-c/



-- VALUE table

USE TempDB
GO
CREATE TABLE Department
(
DepartmentID INT PRIMARY KEY,
DepartmentName VARCHAR(30)
)
GO
CREATE TYPE DeptType AS TABLE
(
DeptId INT, DeptName VARCHAR(30)
);
GO
CREATE PROCEDURE InsertDepartment
@InsertDept_TVP DeptType READONLY
AS
INSERT INTO Department(DepartmentID,DepartmentName)
SELECT * FROM @InsertDept_TVP;
GO

DECLARE @DepartmentTVP AS DeptType;
INSERT INTO @DepartmentTVP(DeptId,DeptName)
VALUES (1,'Accounts'),
(2,'Purchase'),
(3,'Software'),
(4,'Stores'),
(5,'Maarketing');
EXEC InsertDepartment @DepartmentTVP;
GO
SELECT * FROM Department
GO
-------
-------------------------------------
-- http://www.sql-server-helper.com/error-messages/msg-352.aspx
--  Msg 352 - The table-valued parameter <Parameter Name> must be declared with the READONLY option.
USE tempdb
GO
CREATE TYPE [Product] AS TABLE (
    [ProductID]      INT,
    [ProductName]    NVARCHAR(100),
    [UnitPrice]      MONEY,
    [Quantity]       INT
)
GO

CREATE TABLE [dbo].[Product] (
    [ProductID]    INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    [ProductName]  NVARCHAR(100),
    [UnitPrice]    MONEY,
    [Quantity]    INT
)
GO

-- Error
CREATE PROCEDURE [dbo].[usp_ProcessNewProducts]
    @NewProducts          Product READONLY,
    @NewProductsWithID    Product OUTPUT
AS

    INSERT INTO [dbo].[Product] ( [ProductName], [UnitPrice], [Quantity] )
    OUTPUT [inserted].[ProductID], [inserted].[ProductName],
           [inserted].[UnitPrice], [inserted].[Quantity]
    INTO @NewProductsWithID
    SELECT [ProductName], [UnitPrice], [Quantity]
    FROM @NewProducts
GO

--Msg 352, Level 15, State 1, Procedure usp_ProcessNewProducts, Line 3
--The table-valued parameter "@NewProductsWithID" must be declared with the READONLY option.

-- End Error

-- Adding the READONLY property to the OUTPUT parameter in the stored procedure above will not solve the problem 
-- as a different error message will be encountered:

--Msg 102, Level 15, State 1, Procedure usp_ProcessNewProducts, Line 3
--Incorrect syntax near 'READONLY'.

CREATE PROCEDURE [dbo].[usp_ProcessNewProducts]
    @NewProducts          Product READONLY,
    @NewProductsWithID    Product READONLY OUTPUT
AS

    INSERT INTO [dbo].[Product] ( [ProductName], [UnitPrice], [Quantity] )
    OUTPUT [inserted].[ProductID], [inserted].[ProductName],
           [inserted].[UnitPrice], [inserted].[Quantity]
    INTO @NewProductsWithID
    SELECT [ProductName], [UnitPrice], [Quantity]
    FROM @NewProducts

GO

--Msg 102, Level 15, State 1, Procedure usp_ProcessNewProducts, Line 3
--Incorrect syntax near 'READONLY'.

--In addition to having the table-valued parameter defined as READONLY in the stored procedure, DML operations such as UPDATE, DELETE or INSERT on the table-valued parameter in the body of the stored procedure is not allowed.
--To work around this restriction with table-valued parameter and still be able to accomplish the task of retrieving the system generated Product ID for each new product pass as a table-valued parameter, the stored procedure needs to be modified to remove the second table-valued parameter and instead have this variable populated outside the stored procedure:

CREATE PROCEDURE [dbo].[usp_ProcessNewProducts]
    @NewProducts    Product READONLY
AS

    INSERT INTO [dbo].[Product] ( [ProductName], [UnitPrice], [Quantity] )
    OUTPUT [inserted].[ProductID], [inserted].[ProductName],
           [inserted].[UnitPrice], [inserted].[Quantity]
    SELECT [ProductName], [UnitPrice], [Quantity]
    FROM @NewProducts

GO

DECLARE @NewProductsWithID    Product
DECLARE @NewProducts          Product

INSERT INTO @NewProductsWithID ( [ProductID], [ProductName], [UnitPrice], [Quantity] )
EXECUTE [dbo].[usp_ProcessNewProducts] @NewProducts
GO

-- As can be seen from the updated stored procedure, it now returns, as a result set, the newly inserted products together with the system-generated Product ID. The stored procedure uses the OUTPUT clause, introduced in SQL Server 2005, within the INSERT statement to accomplish this task. The newly inserted products together with the Product ID are then inserted into the table-valued variable.

---------------------------------------------------
--------------------------------------
-- http://www.kodyaz.com/t-sql/pass-table-valued-parameters-to-sql-stored-procedure.aspx

USE AdventureWorks2014
GO
CREATE TYPE tabletype_ProductIdList AS TABLE (
 ProductID int NOT NULL PRIMARY KEY
)
GO
SELECT * FROM sys.table_types
GO
DROP TYPE tabletype_ProductIdList
GO
CREATE PROCEDURE sp_ListProductSalesQuantity (
 @ProductIdList tabletype_ProductIdList READONLY
)
AS
BEGIN
SELECT
 p.ProductID, p.Name, q.OrderQuantity
FROM (
 SELECT p.ProductID, SUM(ISNULL(d.OrderQty,0)) OrderQuantity
 FROM @ProductIdList p
 LEFT OUTER JOIN Sales.SalesOrderDetail d ON d.ProductID = p.ProductID
 GROUP BY p.ProductID
) q
INNER JOIN Production.Product p ON p.ProductID = q.ProductID
ORDER BY p.ProductID
END
GO

DECLARE @RandomProducts tabletype_ProductIdList
INSERT INTO @RandomProducts (ProductID)
	SELECT TOP 10 ProductID FROM Production.Product ORDER BY NEWID()
EXEC sp_ListProductSalesQuantity @RandomProducts

----------------------------------------
-- Variable Table

USE AdventureWorks2014; 
GO 
/* Create a table type. */ 
CREATE TYPE LocationTableType AS TABLE ( LocationName VARCHAR(50) , CostRate INT ); 
GO 
/* Create a procedure to receive data for the table-valued parameter. */ 
CREATE PROCEDURE dbo. usp_InsertProductionLocation 
@TVP LocationTableType READONLY 
AS 
SET NOCOUNT ON 
INSERT 
INTO AdventureWorks2014.Production.Location (Name ,CostRate ,Availability ,ModifiedDate) 
SELECT *, 0, GETDATE() FROM  @TVP; 
GO 
/* Declare a variable that references the type. */ 
DECLARE @LocationTVP AS LocationTableType; 
/* Add data to the table variable. */ 
INSERT INTO @LocationTVP (LocationName, CostRate) 
SELECT Name, 0.00 FROM AdventureWorks2014.Person.StateProvince; 
/* Pass the table variable data to a stored procedure. */ 
EXEC usp_InsertProductionLocation @LocationTVP; 
GO
-- (181 row(s) affected)


---------------
---------------------------------------------------------------------------
		--Procedimientos almacenados con PARÁMETROS DE SALIDA
---------------------------------------------------------------------------
--Nos devuelven un contenido para emplearlo después de la ejecución 
--del procedimiento
--Los parámetros de salida hay que declararlos 3 veces 
-- (antes, durante y después del procedimiento)
-- Con Parámetro de Salida
USE Pubs
GO
CREATE PROC uspparametrosalida
	@contador INT OUTPUT --OUTPUT o OUT es una palabra reservada para declarar un parámetro de salida
AS
	SET NOCOUNT ON	--No presentar nº de filas	
	SELECT * FROM authors
	SET @contador = @@ROWCOUNT;  --Asignación del valor de la Variable global que devuelve el nº de filas afectadas por la operación
GO
--no se ponen ; en la declaración

--Declaración. Ejecución
DECLARE @contador INT
EXEC uspparametrosalida @contador OUTPUT
PRINT 'Resultado '+ CAST(@contador AS VARCHAR(3));

--------

-- Ejemplo



-- Ejemplo con Parámetro de Entrada y de Salida
CREATE PROC uspSumarTitulos 
	@titulo VARCHAR(40)= '%',
	@suma money OUTPUT 
AS
	SELECT @suma = SUM(price)
	FROM titles
	WHERE title LIKE @titulo
GO
DECLARE @coste money
EXEC uspSumarTitulos 'the%', @coste output
IF @coste < 200
		BEGIN
			print @coste
			print 'titulos < 200'
		END
ELSE
		print 'total del coste es ' + rtrim(cast(@coste as varchar(20)))
GO
----------------

-- Parametros de salida

USE AdventureWorks2014
GO
SELECT * FROM HumanResources.Department
GO
IF OBJECT_ID('dbo.usp_seleccionDepartamentos', 'P') IS NOT NULL
DROP PROCEDURE dbo.usp_seleccionDepartamentos
GO
create procedure dbo.usp_seleccionDepartamentos
		@Groupname nvarchar(50),
		@Contador int out
as
			select Name
			from HumanResources.Department
			where GroupName = @Groupname
			order by Name
			select @Contador = @@ROWCOUNT -- contar numero de filas; = que count(*)
GO

-- Ejecutar

declare @contador int
--execute dbo.usp_seleccionDepartamentos 'Executive general and administration',
--@contador output
execute dbo.usp_seleccionDepartamentos 'Sales and Marketing',@contador output
--print 'el numero de filas es: '  + cast(@contador as char)
print 'el numero de filas es: '  + convert(char, @contador)
GO
-------------
USE [AdventureWorks2014]
GO
 
--// Create Stored Prcedure with OUTPUT parameter
ALTER PROCEDURE getContactName
    @ContactID INT,
    @FirstName VARCHAR(50) OUTPUT,
    @LastName  VARCHAR(50) OUTPUT
AS
BEGIN
    SELECT @FirstName = FirstName, @LastName = LastName
    FROM [Person].[Person]
    WHERE [BusinessEntityID] = @ContactID
end
GO
 
--// Test the Procedure
DECLARE @CID INT, @FName VARCHAR(50), @LName VARCHAR(50)
 
--/ Test# 1
SET @CID = 100
EXEC getContactName @ContactID=@CID,
                    @FirstName=@FName OUTPUT,
                    @LastName=@LName OUTPUT
 
SELECT @FName as 'First Name', @LName as 'Last Name'
--/ Output
--First Name	Last Name
--Lolan				Song

GO

--/ Test# 2
DECLARE @CID INT, @FName VARCHAR(50), @LName VARCHAR(50)
SET @CID = 200
EXEC getContactName @ContactID=@CID,
                    @FirstName=@FName OUTPUT,
                    @LastName=@LName OUTPUT
 
SELECT @FName as 'First Name', @LName as 'Last Name'
--/ Output
--First Name	Last Name
--Frank			  Lee
GO
 
--// Final Cleanup
DROP PROCEDURE getContactName
GO
----------------
-- Crear Sp en el cual dada una ciudad obtener mensaje si existe una editorial en esa ciudad
-- que obtenga 'Ciudad es San Francisco el estado es California' o  
-- 'ERROR:No hay Editorial en esa ciudad no existe.'


USE Pubs
GO
SELECT * FROM dbo.publishers
GO
IF OBJECT_ID('usp_CiudadEditorial', 'P') IS NOT NULL
DROP PROCEDURE usp_CiudadEditorial;
GO
Create PROCEDURE usp_CiudadEditorial
	@ciudad varchar(20) = NULL,
	@ciud  varchar(20) output,
	@estado char(2)  output
AS  
   		SELECT  @ciud=city,@estado=state 
		FROM dbo.publishers
		WHERE city = @ciudad;
		If @estado is null
			return 2
		else 
			return 1

GO

DECLARE  @ret_code INT,@ciud varchar(20),@estado char(2) 
-- EXECUTE @ret_code = usp_CiudadEditorial 'Boston',@ciud output,@estado output
-- EXECUTE @ret_code = usp_CiudadEditorial 'Vigo',@ciud output,@estado output
EXECUTE @ret_code = usp_CiudadEditorial 'Dallas',@ciud output,@estado output
IF @ret_code = 1
		PRINT 'Ciudad es '+ @ciud + ' el estado es '+ @estado  
ELSE 
	BEGIN
		PRINT 'ERROR No hay Editorial en esa ciudad ' 
	END
GO

-- Ciudad es Boston el estado es MA
----------------------------------------
--------------------------
-- Ejemplo
ALTER PROCEDURE [HumanResources].[uspUpdateEmployeeLogin]
    @BusinessEntityID [int], 
    @OrganizationNode [hierarchyid],
    @LoginID [nvarchar](256),
    @JobTitle [nvarchar](50),
    @HireDate [datetime],
    @CurrentFlag [dbo].[Flag]
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [HumanResources].[Employee] 
        SET [OrganizationNode] = @OrganizationNode 
            ,[LoginID] = @LoginID 
            ,[JobTitle] = @JobTitle 
            ,[HireDate] = @HireDate 
            ,[CurrentFlag] = @CurrentFlag 
        WHERE [BusinessEntityID] = @BusinessEntityID;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
-------------
-- C.Usar parámetros OUTPUT
-- En el ejemplo siguiente se crea el procedimiento uspGetList. 
--Este procedimiento devuelve una lista de productos cuyos precios no superan una cantidad especificada. 
-- El ejemplo se muestra con varias instrucciones SELECT y varios parámetros OUTPUT. 
--Los parámetros OUTPUT permiten a un procedimiento externo, un lote o más de una instrucción Transact-SQL 
-- tener acceso a un conjunto de valores durante la ejecución del procedimiento.

USE AdventureWorks2014
GO
IF OBJECT_ID ( 'Production.uspGetList', 'P' ) IS NOT NULL 
    DROP PROCEDURE Production.uspGetList;
GO
CREATE PROCEDURE Production.uspGetList 
	@Product varchar(40) 
    , @MaxPrice money 
    , @ComparePrice money OUTPUT
    , @ListPrice money OUT
AS
    SET NOCOUNT ON;
    SELECT p.[Name] AS Product, p.ListPrice AS 'List Price'
    FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS s 
      ON p.ProductSubcategoryID = s.ProductSubcategoryID
    WHERE s.[Name] LIKE @Product AND p.ListPrice < @MaxPrice;
-- Populate the output variable @ListPprice.
SET @ListPrice = (SELECT MAX(p.ListPrice)
        FROM Production.Product AS p
        JOIN  Production.ProductSubcategory AS s 
          ON p.ProductSubcategoryID = s.ProductSubcategoryID
        WHERE s.[Name] LIKE @Product AND p.ListPrice < @MaxPrice);
-- Populate the output variable @compareprice.
SET @ComparePrice = @MaxPrice;
GO
-- End SP
--Ejecute uspGetList para obtener una lista de los productos de Adventure Works (bicicletas) que cuestan menos de $700. Los parámetros OUTPUT, @Cost y @ComparePrices se utilizan con el lenguaje de control de flujo para devolver un mensaje en la ventana Mensajes.
--Nota
--La variable OUTPUT debe definirse al crear el procedimiento y también al utilizar la variable. Los nombres de parámetro y de variable no tienen por qué coincidir; sin embargo, el tipo de datos y la posición de los parámetros deben coincidir, a menos que se use @ListPrice = variable.
DECLARE @ComparePrice money, @Cost money ;
EXECUTE Production.uspGetList '%Bikes%', 700, 
    @ComparePrice OUT, 
    @Cost OUTPUT
IF @Cost <= @ComparePrice 
BEGIN
    PRINT 'These products can be purchased for less than 
    $'+RTRIM(CAST(@ComparePrice AS varchar(20)))+'.'
END
ELSE
    PRINT 'The prices for all products in this category exceed 
    $'+ RTRIM(CAST(@ComparePrice AS varchar(20)))+'.';


-----------------------------



ALTER PROCEDURE [HumanResources].[uspUpdateEmployeePersonalInfo]
    @BusinessEntityID [int], 
    @NationalIDNumber [nvarchar](15), 
    @BirthDate [datetime], 
    @MaritalStatus [nchar](1), 
    @Gender [nchar](1)
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [HumanResources].[Employee] 
        SET [NationalIDNumber] = @NationalIDNumber 
            ,[BirthDate] = @BirthDate 
            ,[MaritalStatus] = @MaritalStatus 
            ,[Gender] = @Gender 
        WHERE [BusinessEntityID] = @BusinessEntityID;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
-------------------
-- Procedimiento [dbo].[uspLogError]
ALTER PROCEDURE [dbo].[uspLogError] 
    @ErrorLogID [int] = 0 OUTPUT -- contains the ErrorLogID of the row inserted
AS                               -- by uspLogError in the ErrorLog table
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
            );

        -- Pass back the ErrorLogID of the row inserted
        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [dbo].[uspPrintError];
        RETURN -1;
    END CATCH
END;

----------------------
-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
ALTER PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;



http://elsasoft.com/samples/ReportServer_adventureworks/SqlServer.SPRING.KATMAI.AdventureWorks2008/sp_HumanResourcesuspUpdateEmployeeHireInfo.htm

USE [AdventureWorks2014]
GO
ALTER PROCEDURE [HumanResources].[uspUpdateEmployeeHireInfo]
    @BusinessEntityID [int], 
    @JobTitle [nvarchar](50), 
    @HireDate [datetime], 
    @RateChangeDate [datetime], 
    @Rate [money], 
    @PayFrequency [tinyint], 
    @CurrentFlag [dbo].[Flag] 
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [HumanResources].[Employee] 
        SET [JobTitle] = @JobTitle 
            ,[HireDate] = @HireDate 
            ,[CurrentFlag] = @CurrentFlag 
        WHERE [BusinessEntityID] = @BusinessEntityID;

        INSERT INTO [HumanResources].[EmployeePayHistory] 
            ([BusinessEntityID]
            ,[RateChangeDate]
            ,[Rate]
            ,[PayFrequency]) 
        VALUES (@BusinessEntityID, @RateChangeDate, @Rate, @PayFrequency);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;

--------------


--Otro con parámetro de entrada (@titulo) y parámetro de salida (@suma)
--Y una estructura condicional según sea el valor del parámetro de salida

---------------
--Parámetro de salida con Return valor entero
use Pubs
Go
SELECT state FROM authors
GO
CREATE PROC uspverificar
	@parametro varchar(11)
as
	IF exists (SELECT state
		FROM authors
		WHERE au_id=@parametro)       --'CA' California
					RETURN 1
	ELSE
					RETURN 2
GO
------------------
--Declaración en la ejecución
--La primera da otro estado, y la segunda California
--DECLARE @estado INT
--exec @estado = verificar '648-92-1872'
--if @estado=1
--	print 'California'
--else
--	print 'Otro Estado'
--GO
--Resultado: Otro Estado
 --'172-32-1176'
DECLARE @estado INT
exec @estado = uspverificar  '648-92-1872'
if @estado=1
	print 'California'
else
	print 'Otro Estado' + convert(char(2),@estado)
GO
--Resultado: California

-----------------------------------
--Parámetro de Salida con Códigos de Retorno

--Procedimiento almacenado con un parámetro de entrada (ciudad), 2 de salida (Ciudad - Estado)
-- Si en esa ciudad hay una editorial, obtener
--'Ciudad es ........ el estado es .........'
--Si en esa ciudad no hay editorial: 'ERROR: No hay Editorial en esa ciudad'
USE pubs
GO

CREATE PROC spCiudadEditorial
	@ciudad varchar(20) = NULL,
	@ciud varchar(20) output,
	@estado char(2) output
AS
		SELECT @ciud=city, @estado=state
		FROM dbo.publishers
		WHERE city=@ciudad;
		IF @@rowcount<>0
					return 1
		ELSE
					return 2
GO

--Ejecución
DECLARE @ret_code int, @ciud varchar(20), @estado char(2)
--EXEC @ret_code= spCiudadEditorial 'Chicago', @ciud output, @estado output
--EXEC @ret_code= spCiudadEditorial 'Boston', @ciud output, @estado output
EXEC @ret_code= spCiudadEditorial 'Paris', @ciud output, @estado output
PRINT @ret_code
IF @ret_code = 1
		PRINT 'Ciudad es ' + @ciud + ' el estado es '+ @estado
ELSE
		PRINT 'ERROR: No hay Editorial en esa ciudad o la ciudad no existe'
GO

-------------------
--Obtener las ventas anuales de un título dado
--@titulo es parámetro de entrada
--@ytd_sales (ventas anuales) es el parámetro de salida
--Añadiremos tb control de errores: no existe el título, ó con @@ERROR
--Si el contenido de @@error es distinto de cero, no hay errores

USE pubs
GO

CREATE PROC usp_get_sales_for_title
	@title varchar(80),
	@ytd_sales int output
AS
	--Validar parámetro @tilte
	IF @title is null
		BEGIN
			print 'ERROR: Tienes que introducir un título.'
			return (1)
		END
	ELSE
	BEGIN
		--Asegurar que @title es válido
		IF (SELECT COUNT(*) FROM titles
			WHERE title=@title) = 0
			return (2)
	END
--Obtener sales para un título y asignarlo a parámetro de salida
SELECT @ytd_sales=ytd_sales
FROM titles
WHERE title=@title

--Buscar errores
IF @@ERROR<>0
	BEGIN
		return (3)
	END
ELSE
	--Mirar si ytd_sales es nulo
	IF @ytd_sales IS NULL
		return (4)
	ELSE
		return (0)
GO

--Declarar las varialbes de salida y return al código del procedimiento
DECLARE @ytd_sales_for_title int, @ret_code int

--ejecución del procedimiento con title_id
--y salvar el valor de salida y volver al código en las variables.
exec @ret_code = dbo.usp_get_sales_for_title 'The Gourmet Microwave', @ytd_sales_for_title output

--Buscar códigos de retorno
IF @ret_code=0
	BEGIN
		print 'Ejecución Correcta Ventas '+ CONVERT(VARCHAR(6),@ytd_sales_for_title)
	END
ELSE IF @ret_code=1
		print 'ERROR: title_id no estaba especificado.'
ELSE IF @ret_code=2
		print 'ERROR: Título incorrecto.'
ELSE IF @ret_code=3
		print 'ERROR: ur error ocurrido con ytd_sales.'
ELSE IF @ret_code=4
		print 'ERROR: Ventas anuales no especificadas.'
GO



------------------------------------------------------------------------------
-- Procedimiento para LANZAR SENTENCIAS ENTRE DISTINTAS BBDD
------------------------------------------------------------------------------
--Con esta sentencia se crean objetos (tablas, vistas, etc) en una bd desde otra
DECLARE @s nvarchar(1000)
SET @s = 'CREATE VIEW vAutores AS SELECT * FROM Pubs.dbo.authors'
EXEC Northwind.dbo.sp_executesql @s
GO
USE Northwind
GO
DROP VIEW vAutores
GO
---------------------------------------------------

-- PROCEDIMIENTOS ALMACENADOS

use AdventureWorks2014
go

select * 
into HumanResources.Empleado 
from HumanResources.Employee

ALTER procedure Humanresources.usp_ActualizaEmpleados
	@BusinesEntityID int,
	@JobTitle nvarchar(50),
	@HireDate datetime,
	@RateChangeDate datetime,
	@Rate money,
	@Payfrequency tinyint -- menos memoria de almacenamiento
with execute as caller -- directivas de seguridad del usuario que crea el procedimiento
as
begin
	set nocount on;
	begin try
		begin transaction;
			update HumanResources.Empleado
			set JobTitle = @JobTitle,HireDate = @HireDate
			where BusinessEntityID = @BusinesEntityID;
			PRINT @BusinesEntityID
			PRINT @@error
			print @@TRANCOUNT
			print 'exito';
			commit transaction; -- confirmar transaccion
	end try
	bEGIN catch
		-- rollback any active or uncommittable (no confirmada) transactions
		-- @@TRANCOUNT returns the number of active transactions for the 
		--current connection
		if @@ERROR <> 0
			print 'error';
		if @@TRancount > 0
		begin
		 rollback tran;
		end
	END catch
end;


-- Command(s) completed successfully


exec HumanResources.usp_ActualizaEmpleados 111, 'Tecnico mantenimiento', '2001-01-18', '1999-01-18 00:00:00.000',
5, 2

exec HumanResources.usp_ActualizaEmpleados 111, 'DBA', '2001-01-18', '1999-01-18 00:00:00.000',
5, 2

exec HumanResources.usp_ActualizaEmpleados 111111, 'DBA', '2001-01-18', '1999-01-18 00:00:00.000',
5, 2


select [BusinessEntityID],[JobTitle] from [HumanResources].[Empleado]
where [BusinessEntityID] = 111111
GO
----------------------------------



-- Parametros de salida

USE AdventureWorks2014
GO
SELECT * FROM HumanResources.Department
GO
IF OBJECT_ID('dbo.usp_seleccionDepartamentos', 'P') IS NOT NULL
		DROP PROCEDURE dbo.usp_seleccionDepartamentos
GO
create procedure dbo.usp_seleccionDepartamentos
		@Groupname nvarchar(50),
		@Contador int out
as
			select Name
			from HumanResources.Department
			where GroupName = @Groupname
			order by Name
			select @Contador = @@ROWCOUNT -- contar numero de filas; = que count(*)
GO
-- Ejecutar
declare @contador int
--execute dbo.usp_seleccionDepartamentos 'Executive general and administration',
--@contador output
execute dbo.usp_seleccionDepartamentos 'Sales and Marketing',@contador output
--print 'el numero de filas es: '  + cast(@contador as char)
print 'el numero de filas es: '  + convert(char, @contador)
GO

----------------

--Parámetro de Salida con Códigos de Retorno

-- Crear Sp en el cual dada una ciudad obtener mensaje si existe una editorial en esa ciudad
-- que obtenga 'Ciudad es San Francisco el estado es California' o  
-- 'ERROR:No hay Editorial en esa ciudad no existe.'
USE Pubs
GO
SELECT * FROM dbo.publishers
GO
IF OBJECT_ID('usp_CiudadEditorial', 'P') IS NOT NULL
			DROP PROCEDURE usp_CiudadEditorial;
GO
Create PROCEDURE usp_CiudadEditorial
	@ciudad varchar(20) = NULL,
	@ciud  varchar(20) output,
	@estado char(2)  output
AS  
   		SELECT  @ciud=city,@estado=state 
		FROM dbo.publishers
		WHERE city = @ciudad;
		If @estado is null
			return 2
		else 
			return 1
GO
DECLARE  @ret_code INT,@ciud varchar(20),@estado char(2) 
-- EXECUTE @ret_code = usp_CiudadEditorial 'Boston',@ciud output,@estado output
-- EXECUTE @ret_code = usp_CiudadEditorial 'Vigo',@ciud output,@estado output
EXECUTE @ret_code = usp_CiudadEditorial 'Dallas',@ciud output,@estado output
IF @ret_code = 1
		PRINT 'Ciudad es '+ @ciud + ' el estado es '+ @estado  
ELSE 
	BEGIN
		PRINT 'ERROR No hay Editorial en esa ciudad ' 
	END
GO

-- Ciudad es Boston el estado es MA
----------------------------------------
use pubs;
go

create procedure VentasPorTitulo
	@Titulo varchar(80),
	@YtdVentas int out,
	@TextoTitulo varchar(80) output
as
	select @YtdVentas = ytd_sales, @TextoTitulo = title
	from titles
	where title like @Titulo
go
-- declare variables for receive output vañues from procedure.
declare @A_YtdVentas int, @A_TextoTitulo varchar(80)

execute VentasPorTitulo

@YtdVentas =  @A_YtdVentas output, @TextoTitulo = @A_TextoTitulo output,

@titulo = '%garlic%'

select "title" = @A_TextoTitulo, "Number of sales" = @A_YtdVentas
go


use pubs;
go

-- output with return (integer values)
create procedure verificar
	@parametro varchar(11)
as
	if (select state from authors
		where au_id = @parametro) = 'ca'
			return (1)
	else
			return (2)
go


declare @VR int
exec @VR = verificar '648-92-1872'
if @VR = 1
	print 'estado ca'
else
	print 'estado no ca'
go

create  procedure ups_ventas
	@titulo varchar(80) = null,
	@VentasAnuales int output
as
	-- validar parametro de netrada
	if @titulo is null
		begin
			print 'ERROR: ESPECIFICAR TÍTULO'
			return(1)
		end
	else
		begin -- titulo valido
			if (select COUNT(*) from titles
				where title = @titulo) = 0
					return(2)
		end
		
	-- venta para título y asignar a parametro de salida
		select @VentasAnuales = ytd_sales
		from titles
		where title = @titulo
		
		-- errores sql server
		if @@ERROR <> 0
			begin
				return(3)
			end
		else
			--ventasAnuales es nulo (ytd_sales)
			if @VentasAnuales is null
				return (4)
			else
				return(0)
go
	
	
declare @Ventas_por_titulo int, @ValorDevuelto int

execute @ValorDevuelto = ups_Ventas  'AAA',
@VentasAnuales = @Ventas_por_titulo output

if @ValorDevuelto = 0
	begin
		print 'Ejecucion correcta'
		-- valor devuelto
		print 'valor....' + convert (varchar(6), @ventas_por_titulo)
	end
else
	if @ValorDevuelto = 1
		print 'Error: titulo sin especificar'
	else
		if @ValorDevuelto = 2
			print 'Error: titulo incorrecto'
		else
			if @ValorDevuelto = 3
				print 'error con ventas anuales'
			else 
				print 'Ventas nulas'
go

-- encrypting a stored procedure
use AdventureWorks2014
go
create procedure usp_ProcedimientoSinEncriptar
as
select EmployeeID, RateChangeDate, Rate, PayFrequency, ModifiedDate
from HumanResources.EmployeePayHistory
go
-- view the procedure's text
exec sp_helptext usp_ProcedimientoSinEncriptar

create procedure usp_ProcedimientoEncriptado
with encryption
as
select EmployeeID, RateChangeDate, Rate, PayFrequency, ModifiedDate
from HumanResources.EmployeePayHistory
go
-- view the procedure's text
exec sp_helptext usp_ProcedimientoEncriptado


-- Script Backup BD 


USE tempdb
GO
IF OBJECT_ID('BACKUP_ALL_DB_PARENTRADA', 'P') IS NOT NULL
	DROP PROCEDURE BACKUP_ALL_DB_PARENTRADA
GO
CREATE PROC BACKUP_ALL_DB_PARENTRADA
	@path VARCHAR(256)
AS
DECLARE @name VARCHAR(50), -- database name
		-- @path VARCHAR(256), -- path for backup files
		@fileName VARCHAR(256), -- filename for backup
		@fileDate VARCHAR(20), -- used for file name
		@backupCount INT

CREATE TABLE [dbo].#tempBackup (intID INT IDENTITY (1, 1), name VARCHAR(200))

-- Crear la Carpeta Backup
-- SET @path = 'C:\BackupSP\'

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
print @backupCount

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
			-- BACKUP DATABASE @name TO DISK = @fileName
			-- overwrites the existing file (Note: remove @fileDate from the fileName so they are no longer unique
			BACKUP DATABASE @name TO DISK = @fileName WITH INIT

			SET @currentBackup = @currentBackup + 1
END
END
-- Utilidad: Solo Comprobación.  Mirar panel de Resultados Autonumerico y Nombre BD
		select * from #tempBackup
GO
EXECUTE BACKUP_ALL_DB_PARENTRADA 'C:\BackupSP\'
-- Mirar panel de Resultados : Resultados - Mensajes
GO

-------------------------------

USE tempdb
GO
--
 CREATE TABLE Employee
(
 EmpID int primary key, 
 Name varchar(50),
 Salary int,
 Address varchar(100)
) 
GO
Insert into Employee(EmpID,Name,Salary,Address) Values(1,'Mohan',16000,'Delhi')
Insert into Employee(EmpID,Name,Salary,Address) Values(2,'Asif',15000,'Delhi')
Insert into Employee(EmpID,Name,Salary,Address) Values(3,'Bhuvnesh',19000,'Noida')
GO
--See table
SELECT * FROM Employee 

-- Inicio sp
CREATE PROCEDURE usp_InsertEmployee
		@flag bit output,-- return 0 for fail,1 for success
		@EmpID int,
		@Name varchar(50),
		@Salary int,
		@Address varchar(100)
AS
BEGIN
 BEGIN TRANSACTION 
				 BEGIN TRY 
							Insert into Employee(EmpID,Name,Salary,Address)
							 Values(@EmpID,@Name,@Salary,@Address)
							 set @flag=1;
							IF @@TRANCOUNT > 0
							 BEGIN 
									 commit TRANSACTION;
							 END
				 END TRY 
				 BEGIN CATCH
							IF @@TRANCOUNT > 0
									 BEGIN 
											 rollback TRANSACTION;
									 END
									 set @flag=0;
				 END CATCH
END 
GO
-- Fin sp
 --Execute above created procedure to insert rows into table . Falla por el 1
Declare @flag bit
EXEC usp_InsertEmployee @flag output,1,'Luis',14000,'A Coruña'
if @flag=1
		print 'Successfully inserted'
else
		print 'There is some error'
GO
--(0 row(s) affected)
--There is some error


--Execute above created procedure to insert rows into table
Declare @flag bit
EXEC usp_InsertEmployee @flag output,4,'Luis',14000,'A Coruña'
if @flag=1
			print 'Successfully inserted'
else
			print 'There is some error' 
GO

--(1 row(s) affected)
--Successfully inserted

 --now see modified table
Select * from Employee 

-- Retrieve Operation

- first we Insert data in the table
Insert into Employee(EmpID,Name,Salary,Address) Values(1,'Mohan',16000,'Delhi')
Insert into Employee(EmpID,Name,Salary,Address) Values(2,'Asif',15000,'Delhi')
Insert into Employee(EmpID,Name,Salary,Address) Values(3,'Bhuvnesh',19000,'Noida')
go
--Now we create a procedure to fetch data
CREATE PROCEDURE usp_SelectEmployee
As
Select * from Employee ORDER By EmpID

--Execute above created procedure to fetch data
exec usp_SelectEmployee 

-- Update Operation

 CREATE PROCEDURE usp_UpdateEmployee
			@flag bit output,-- return 0 for fail,1 for success
			@EmpID int,
			@Salary int,
			@Address varchar(100)
AS
BEGIN
 BEGIN TRANSACTION 
 BEGIN TRY
 Update Employee set Salary=@Salary, Address=@Address
 Where EmpID=@EmpID 
 set @flag=1; 
IF @@TRANCOUNT > 0
 BEGIN commit TRANSACTION;
 END
 END TRY
 BEGIN CATCH
IF @@TRANCOUNT > 0
BEGIN rollback TRANSACTION; 
 END
 set @flag=0;
 END CATCH
 END 

--Execute above created procedure to update table
Declare @flag bit
EXEC usp_UpdateEmployee @flag output,1,22000,'Noida'
if @flag=1 print 'Successfully updated'
else
 print 'There is some error' 

-now see updated table
Select * from Employee

-- Delete Operation

CREATE PROCEDURE usp_DeleteEmployee
@flag bit output,-- return 0 for fail,1 for success
@EmpID int
AS
BEGIN
 BEGIN TRANSACTION 
 BEGIN TRY
 Delete from Employee Where EmpID=@EmpID set @flag=1; 
IF @@TRANCOUNT > 0
 BEGIN commit TRANSACTION;
 END
 END TRY
 BEGIN CATCH
IF @@TRANCOUNT > 0
 BEGIN rollback TRANSACTION; 
 END
set @flag=0; 
END CATCH 
END 

--Execute above created procedure to delete rows from table
Declare @flag bit
EXEC usp_DeleteEmployee @flag output, 4
if @flag=1
 print 'Successfully deleted'
else
 print 'There is some error' 

--now see modified table
Select * from Employee

-----------------------------------------
-- https://technet.microsoft.com/es-es/library/ms190778%28v=sql.105%29.aspx

--------------------

USE AdventureWorks2014;
GO
IF OBJECT_ID('Sales.usp_GetSalesYTD', 'P') IS NOT NULL
    DROP PROCEDURE Sales.usp_GetSalesYTD;
GO
CREATE PROCEDURE Sales.usp_GetSalesYTD
@SalesPerson nvarchar(50) = NULL,  -- NULL default value
@SalesYTD money = NULL OUTPUT
AS  

-- Validate the @SalesPerson parameter.
IF @SalesPerson IS NULL
   BEGIN
       PRINT 'ERROR: You must specify a last name for the sales person.'
       RETURN(1)
   END
ELSE
   BEGIN
   -- Make sure the value is valid.
   IF (SELECT COUNT(*) FROM HumanResources.vEmployee
          WHERE LastName = @SalesPerson) = 0
      RETURN(2)
   END
-- Get the sales for the specified name and 
-- assign it to the output parameter.
SELECT @SalesYTD = SalesYTD 
FROM Sales.SalesPerson AS sp
JOIN HumanResources.vEmployee AS e ON e.BusinessEntityID = sp.BusinessEntityID
WHERE LastName = @SalesPerson;
-- Check for SQL Server errors.
IF @@ERROR <> 0 
   BEGIN
      RETURN(3)
   END
ELSE
   BEGIN
   -- Check to see if the ytd_sales value is NULL.
     IF @SalesYTD IS NULL
       RETURN(4) 
     ELSE
      -- SUCCESS!!
        RETURN(0)
   END
-- Run the stored procedure without specifying an input value.
EXEC Sales.usp_GetSalesYTD;
GO
-- Run the stored procedure with an input value.
DECLARE @SalesYTDForSalesPerson money, @ret_code int;
-- Execute the procedure specifying a last name for the input parameter
-- and saving the output value in the variable @SalesYTD
EXECUTE Sales.usp_GetSalesYTD
    N'Blythe', @SalesYTD = @SalesYTDForSalesPerson OUTPUT;
PRINT N'Year-to-date sales for this employee is ' +
    CONVERT(varchar(10), @SalesYTDForSalesPerson);

-- 

-- Declare the variables to receive the output value and return code 
-- of the procedure.
DECLARE @SalesYTDForSalesPerson money, @ret_code int;

-- Execute the procedure with a title_id value
-- and save the output value and return code in variables.
EXECUTE @ret_code = Sales.usp_GetSalesYTD
    N'Blythe', @SalesYTD = @SalesYTDForSalesPerson OUTPUT;
--  Check the return codes.
IF @ret_code = 0
BEGIN
   PRINT 'Procedure executed successfully'
   -- Display the value returned by the procedure.
   PRINT 'Year-to-date sales for this employee is ' + CONVERT(varchar(10),@SalesYTDForSalesPerson)
END
ELSE IF @ret_code = 1
   PRINT 'ERROR: You must specify a last name for the sales person.'
ELSE IF @ret_code = 2 
   PRINT 'EERROR: You must enter a valid last name for the sales person.'
ELSE IF @ret_code = 3
   PRINT 'ERROR: An error occurred getting sales value.'
ELSE IF @ret_code = 4
   PRINT 'ERROR: No sales recorded for this employee.'   
GO

-- Salida

--Procedure executed successfully
--Year-to-date sales for this employee is 3763178.18

-- Declare the variables to receive the output value and return code 
-- of the procedure.
DECLARE @SalesYTDForSalesPerson money, @ret_code int;

-- Execute the procedure with a title_id value
-- and save the output value and return code in variables.
EXECUTE @ret_code = Sales.usp_GetSalesYTD
     'Pepe', @SalesYTD = @SalesYTDForSalesPerson OUTPUT;
EXECUTE @ret_code = Sales.usp_GetSalesYTD
     @SalesYTD = @SalesYTDForSalesPerson OUTPUT;
--  Check the return codes.
IF @ret_code = 0
BEGIN
   PRINT 'Procedure executed successfully'
   -- Display the value returned by the procedure.
   PRINT 'Year-to-date sales for this employee is ' + CONVERT(varchar(10),@SalesYTDForSalesPerson)
END
ELSE IF @ret_code = 1
   PRINT 'ERROR: You must specify a last name for the sales person.'
ELSE IF @ret_code = 2 
   PRINT 'ERROR: You must enter a valid last name for the sales person.'
ELSE IF @ret_code = 3
   PRINT 'ERROR: An error occurred getting sales value.'
ELSE IF @ret_code = 4
   PRINT 'ERROR: No sales recorded for this employee.'   
GO
-- ERROR: You must enter a valid last name for the sales person.

DECLARE @SalesYTDForSalesPerson money, @ret_code int;

-- Execute the procedure with a title_id value
-- and save the output value and return code in variables.
EXECUTE @ret_code = Sales.usp_GetSalesYTD
     @SalesYTD = @SalesYTDForSalesPerson OUTPUT;
--  Check the return codes.
IF @ret_code = 0
BEGIN
   PRINT 'Procedure executed successfully'
   -- Display the value returned by the procedure.
   PRINT 'Year-to-date sales for this employee is ' + CONVERT(varchar(10),@SalesYTDForSalesPerson)
END
ELSE IF @ret_code = 1
   PRINT 'ERROR: You must specify a last name for the sales person.'
ELSE IF @ret_code = 2 
   PRINT 'ERROR: You must enter a valid last name for the sales person.'
ELSE IF @ret_code = 3
   PRINT 'ERROR: An error occurred getting sales value.'
ELSE IF @ret_code = 4
   PRINT 'ERROR: No sales recorded for this employee.'   
GO

-- Salida

--ERROR: You must specify a last name for the sales person.
--ERROR: You must specify a last name for the sales person.	

------------------------

-- CRUD

/****** Object:  Table [dbo].[Customers]    Script Date: 6/8/2014 2:10:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SET IDENTITY_INSERT Customers ON
GO
DROP TABLE Customers
GO
DROP PROCEDURE [Customers_CRUD]
GO

GO
CREATE TABLE [dbo].[Customers](
	[CustomerId] int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Country] [varchar](50) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

INSERT INTO Customers
 VALUES ('Pepe Arias', 'United States'),
        ('Ana Perez', 'India'),
        ('Luis Garcia', 'Francia'),
		('Roberto Fernandez', 'Rusia')

GO

USE Pubs
GO

CREATE PROCEDURE [dbo].[Customers_CRUD]
	@Action VARCHAR(10)
	,@CustomerId INT = NULL
	,@Name VARCHAR(100) = NULL
	,@Country VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT
    IF @Action = 'SELECT'
	BEGIN
		SELECT CustomerId, Name, Country 
		FROM Customers
	END

	--INSERT
    IF @Action = 'INSERT'
	BEGIN
		INSERT INTO Customers (Name, Country) 
		VALUES (@Name, @Country)
	END

	--UPDATE
    IF @Action = 'UPDATE'
	BEGIN
		UPDATE Customers 
		SET Name = @Name, Country = @Country 
		WHERE CustomerId = @CustomerId
	END

	--DELETE
    IF @Action = 'DELETE'
	BEGIN
		DELETE FROM Customers 
		WHERE CustomerId = @CustomerId
	END
END
GO



------
-- http://elsasoft.com/samples/sqlserver_adventureworks/sqlserver.spring.katmai.adventureworks/default.htm


-- https://technet.microsoft.com/en-us/library/ms124456%28v=sql.100%29.aspx


USE [AdventureWorks2014]
GO
/****** Object:  StoredProcedure [HumanResources].[uspUpdateEmployeeHireInfo]    Script Date: 26/05/2015 17:15:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [HumanResources].[uspUpdateEmployeeHireInfo]
    @BusinessEntityID [int], 
    @JobTitle [nvarchar](50), 
    @HireDate [datetime], 
    @RateChangeDate [datetime], 
    @Rate [money], 
    @PayFrequency [tinyint], 
    @CurrentFlag [dbo].[Flag] 
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [HumanResources].[Employee] 
        SET [JobTitle] = @JobTitle 
            ,[HireDate] = @HireDate 
            ,[CurrentFlag] = @CurrentFlag 
        WHERE [BusinessEntityID] = @BusinessEntityID;

        INSERT INTO [HumanResources].[EmployeePayHistory] 
            ([BusinessEntityID]
            ,[RateChangeDate]
            ,[Rate]
            ,[PayFrequency]) 
        VALUES (@BusinessEntityID, @RateChangeDate, @Rate, @PayFrequency);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;



[dbo].[uspLogError]

USE [AdventureWorks2014]
GO
/****** Object:  StoredProcedure [dbo].[uspLogError]    Script Date: 26/05/2015 17:16:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- uspLogError logs error information in the ErrorLog table about the 
-- error that caused execution to jump to the CATCH block of a 
-- TRY...CATCH construct. This should be executed from within the scope 
-- of a CATCH block otherwise it will return without inserting error 
-- information. 
ALTER PROCEDURE [dbo].[uspLogError] 
    @ErrorLogID [int] = 0 OUTPUT -- contains the ErrorLogID of the row inserted
AS                               -- by uspLogError in the ErrorLog table
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
            );

        -- Pass back the ErrorLogID of the row inserted
        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [dbo].[uspPrintError];
        RETURN -1;
    END CATCH
END;



USE [AdventureWorks2014]
GO
/****** Object:  StoredProcedure [dbo].[uspPrintError]    Script Date: 26/05/2015 17:16:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
ALTER PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;




-- [dbo].[uspPrintError]

USE [AdventureWorks2014]
GO
/****** Object:  StoredProcedure [dbo].[uspPrintError]    Script Date: 26/05/2015 17:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
ALTER PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;
GO

------------------------------








-- Create tool table.
CREATE TABLE dbo.Tool(
   ID INT IDENTITY NOT NULL PRIMARY KEY, 
   Name VARCHAR(40) NOT NULL
);
GO
-- Inserting values into products table.
INSERT INTO dbo.Tool(Name) 
VALUES ('Screwdriver')
        , ('Hammer')
        , ('Saw')
        , ('Shovel');
GO

-- Create a gap in the identity values.
DELETE dbo.Tool
WHERE Name = 'Saw';
GO

SELECT * 
FROM dbo.Tool;
GO

-- Try to insert an explicit ID value of 3;
-- should return a warning.
INSERT INTO dbo.Tool (ID, Name) VALUES (3, 'Garden shovel');
GO
-- SET IDENTITY_INSERT to ON.
SET IDENTITY_INSERT dbo.Tool ON;
GO

-- Try to insert an explicit ID value of 3.
INSERT INTO dbo.Tool (ID, Name) VALUES (3, 'Garden shovel');
GO

SELECT * 
FROM dbo.Tool;
GO
-- Drop products table.
DROP TABLE dbo.Tool;
GO
-----------------------------

-- https://www.mssqltips.com/sqlservertip/4261/sql-server-stored-procedure-to-safely-delete-data/

-- Ennsuring you are deleting the number of records you are expecting to be deleted.

--When it comes to best practices I am always in favor all DML changes being made through an application and not being done directly against the database using T-SQL commands. When done this way we can ensure that the code has been tested to validate that it is going to do what it is intended to do. That said, there are always cases that come up, whether it be from a bug in an application adding/updating records incorrectly or someone running a script against the database that was not fully tested or even providing the incorrect file to a data loader service/application when we are tasked with removing this unwanted data from the database manually using T-SQL.

CREATE DATABASE ControlBorrado
GO
USE ControlBorrado
GO
DROP DATABASE ControlBorrado

-- table setup
CREATE TABLE Main 
(col1 INT primary key,
 col2 INT);
GO

DECLARE @val INT
SELECT @val=1
WHILE @val < 50000
BEGIN  
   INSERT INTO Main VALUES (@val,round(rand()*100000,0));
   SELECT @val=@val+1;
END;

SELECT * FROM Main
GO
-- (49999 row(s) affected)

-- create procedure

CREATE PROCEDURE sp_delete_from_table (@table sysname, 
                                       @whereclause varchar(7000),  
                                       @delcnt bigint, 
                                       @actcnt bigint output) AS
BEGIN
  declare @sql varchar(8000)
    begin transaction
  select @sql='delete from ' + @table + ' ' + @whereclause
  execute(@sql)
  select @actcnt=@@rowcount
  if @actcnt=@delcnt
    begin
      print cast(@actcnt as varchar) + ' rows have been deleted.'
      commit transaction
    end
  else
    begin
      print 'Statement would have deleted ' + cast(@actcnt as varchar) + 
            ' rows so the transaction has been rolled back.'
      rollback transaction
      select @actcnt=0
    end
END
GO

--The code for the procedure is pretty straightforward. The parameters required are the table you want to delete from, the where clause which identifies which records will be deleted and the count of records you expect to be deleted.
--The first step of the procedure begins a new transaction which will allow us to rollback later if needed. It then builds and executes the delete statement based on the parameters passed to the stored procedure. It uses @@rowcount after the delete executes to determine if the expected number of records were deleted. If these match then a message is printed and the transaction is committed. If the record counts don't match, then a message is printed to tell you how many rows would have been deleted and the transaction is rolled back.
--One thing to note with the stored procedure is that you can pass in anything for the where clause. It is not checked so you could set this parameter to something like 'WHERE 1=1' if you wanted to delete the entire table and as long as you pass in the correct expected delete count the records will be deleted.

-- The first stored procedure call below shows what would be output if the incorrect expected record count is passed to the stored procedure.
-- rollback example
declare @actcnt bigint
exec sp_delete_from_table 'Main','where col2=85942',1,@actcnt output
-- And here is the output from the above example.
-- rollback output
-- Statement would have deleted 6 rows so the transaction has been rolled back.

-- The second call shows what is output when the correct expected count is passed and the stored procedure successfully deletes the data from the table.
-- success example
declare @actcnt bigint
exec sp_delete_from_table 'Main','where col2=85942',6,@actcnt output

-- And here is the output from the above example
-- success output
-- 6 rows have been deleted.

--------------------

CREATE PROCEDURE TimesheetIndexSearch (@Start DATETIME, @End DATETIME)
AS
SELECT Timesheets.Hours AS Hours
       , Timesheets.DateWorked AS DateWorked
       , Timesheets.Description AS Description
       , Timesheets.Id AS Id
       , Users.Name AS UserName
       , Projects.Name AS ProjectName
FROM   Timesheets
       INNER JOIN Users ON Timesheets.UserId = Users.Id
       INNER JOIN Projects ON Timesheets.ProjectId = Projects.Id
WHERE  Timesheets.DateWorked >= @Start
       AND Timesheets.DateWorked <= @End;

You can also use the keyword between as follows:

WHERE Timesheets.DateWorked BETWEEN @Start AND @End
Just be careful with between, as it is inclusive of the dates in the variables, the first approach is cleaner, and easier to read by all.

-- To run the proc you'd use

EXEC TimesheetIndexSearch '2015-01-01','2015-01-10'


CREATE FRUN TimesheetIndexSearch (
    @Start date,
    @End date
)
RETURNS table
AS
    RETURN (SELECT ts.Hours AS Hours, ts.DateWorked AS DateWorked,              
                   ts.Description AS Description,
                   ts.Id AS Id, u.Name AS UserName, p.Name AS ProjectName
            FROM Timesheets ts INNER JOIN
                 Users u
                 ON ts.UserId = u.Id INNER JOIN
                 Projects p
                 ON ts.ProjectId = p.Id
            WHERE ts.DateWorked >= @Start AND ts.DateWorked <= @End
           );
select f.*
from dbo.frun('2015-01-01', '2015-02-01');

-- Also, note how the use of table aliases makes the query easier to write and to read.

----------

-- http://www.sql-server-helper.com/sql-server-2008/table-valued-parameters.aspx

CREATE TABLE [dbo].[Contact] (
    [Email]         VARCHAR(100),
    [FirstName]     VARCHAR(50),
    [LastName]      VARCHAR(50)
)
GO

CREATE PROCEDURE [dbo].[usp_ProcessContact]
    @Email      VARCHAR(100),
    @FirstName  VARCHAR(50),
    @LastName   VARCHAR(50)
AS

IF NOT EXISTS (SELECT 'X' FROM [dbo].[Contact]
               WHERE [Email] = @Email)
    INSERT INTO [dbo].[Contact] ( [Email], [FirstName], [LastName] )
    VALUES ( @Email, @FirstName, @LastName )
ELSE
    UPDATE [dbo].[Contact]
    SET [FirstName] = @FirstName,
        [LastName]  = @LastName
    WHERE [Email] = @Email
GO


EXECUTE [dbo].[usp_ProcessContact] 'mickey@mouse.com', 'Mickey', 'Mouse'
EXECUTE [dbo].[usp_ProcessContact] 'minnie@mouse.com', 'Minnie', 'Mouse'

SELECT * FROM [dbo].[Contact]

--Email               FirstName    LastName
--------------------  -----------  -----------
--mickey@mouse.com    Mickey       Mouse
--minnie@mouse.com    Minnie       Mouse

-- The Table-Valued Parameter Way

CREATE TYPE [ContactTemplate] AS TABLE (
    [Email]             VARCHAR(100),
    [FirstName]         VARCHAR(50),
    [LastName]          VARCHAR(50)
)
GO

-- Before
CREATE PROCEDURE [dbo].[usp_ProcessContact]
    @Email      VARCHAR(100),
    @FirstName  VARCHAR(50),
    @LastName   VARCHAR(50)
-- Now

CREATE PROCEDURE [dbo].[usp_ProcessContact]
    @Contact    ContactTemplate READONLY


One thing to note in this parameter is the READONLY attribute.  Table-valued parameters must be passed as input READONLY parameters to stored procedures or functions.  If you forget to include the READONLY attribute, you will get the following error message:

Msg 352, Level 15, State 1, Procedure usp_ProcessContact, Line 1
The table-valued parameter "@Contact" must be declared with the READONLY option.
One thing to remember also is that DML operations such as DELETE, INSERT or UPDATE on a table-valued parameter in the body of a stored procedure or function are not allowed.  If you try to issue a DELETE, INSERT or UPDATE statement into a table-valued parameter, you will get the following error message:

Msg 10700, Level 16, State 1, Procedure usp_ProcessContact, Line 6
The table-valued parameter "@Contact" is READONLY and cannot be modified.
The body of the stored procedure will also change since we are now processing multiple rows of contacts instead of one contact at a time.  The updated stored procedure, which now uses a table-valued parameter, will now look something like the following:


CREATE PROCEDURE [dbo].[usp_ProcessContact]
    @Contact    ContactTemplate READONLY
AS
-- Update First Name and Last Name for Existing Emails
UPDATE A
SET [FirstName] = B.[FirstName],
    [LastName]  = B.[LastName]
FROM [dbo].[Contact] A INNER JOIN @Contact B
  ON A.[Email] = B.[Email]

-- Add New Email Addresses
INSERT INTO [dbo].[Contact] ( [Email], [FirstName], [LastName] )
SELECT [Email], [FirstName], [LastName]
FROM @Contact A
WHERE NOT EXISTS (SELECT 'X' FROM [dbo].[Contact] B
                  WHERE A.[Email] = B.[Email])
GO

DECLARE @Contacts ContactTemplate

INSERT INTO @Contacts
VALUES ( 'mickey@mouse.com', 'Mickey', 'Mouse' ),
       ( 'minnie@mouse.com', 'Minnie', 'Mouse' )

EXECUTE [dbo].[usp_ProcessContact] @Contacts
SELECT * FROM [dbo].[Contact]

--Email               FirstName    LastName
--------------------  -----------  -----------
--mickey@mouse.com    Mickey       Mouse
--minnie@mouse.com    Minnie       Mouse

--------------------

-- http://www.sql-server-helper.com/sql-server-2008/merge-statement-with-table-valued-parameters.aspx

CREATE TYPE [ContactTemplate] AS TABLE (
    [Email]             VARCHAR(100),
    [FirstName]         VARCHAR(50),
    [LastName]          VARCHAR(50)
)
GO

CREATE PROCEDURE [dbo].[usp_ProcessContact]
    @Contact    ContactTemplate READONLY
AS

-- Update First Name and Last Name for Existing Emails
UPDATE A
SET [FirstName] = B.[FirstName],
    [LastName]  = B.[LastName]
FROM [dbo].[Contact] A INNER JOIN @Contact B
  ON A.[Email] = B.[Email]

-- Add New Email Addresses
INSERT INTO [dbo].[Contact] ( [Email], [FirstName], [LastName] )
SELECT [Email], [FirstName], [LastName]
FROM @Contact A
WHERE NOT EXISTS (SELECT 'X' FROM [dbo].[Contact] B
                  WHERE A.[Email] = B.[Email])
GO

-- Converting the UPDATE and INSERT statements into a single MERGE sstatement, the stored procedure will now look like this:

CREATE PROCEDURE [dbo].[usp_ProcessContact]
    @Contact        ContactTemplate READONLY
AS

MERGE [dbo].[Contact] AS [Target]
USING @Contact AS [Source]
ON [Target].[Email] = [Source].[Email]
WHEN MATCHED THEN
    UPDATE SET [FirstName] = [Source].[FirstName],
               [LastName]  = [Source].[LastName]
WHEN NOT MATCHED THEN
    INSERT ( [Email], [FirstName], [LastName] )
    VALUES ( [Source].[Email], [Source].[FirstName], [Source].[LastName] );
GO

DECLARE @Contacts ContactTemplate

INSERT INTO @Contacts
VALUES ( 'mickey@mouse.com', 'Mickey', 'Mouse' ),
       ( 'minnie@mouse.com', 'Minnie', 'Mouse' )

EXECUTE [dbo].[usp_ProcessContact] @Contacts
SELECT * FROM [dbo].[Contact]

--Email               FirstName    LastName
--------------------  -----------  -----------
--mickey@mouse.com    Mickey       Mouse
--minnie@mouse.com    Minnie       Mouse
-------------
-- http://www.sql-server-helper.com/sql-server-2008/merge-statement.aspx

-- To illustrate how the MERGE statement is used, let's look at the process of maintaining a table using a stored procedure that performs either an INSERT statement if the record does not exist or an UPDATE statement if the record already exists in the target table. 
CREATE TABLE [dbo].[Employee] (
    [EmployeeNumber]        VARCHAR(10),
    [FirstName]             VARCHAR(50),
    [LastName]              VARCHAR(50),
    [Position]              VARCHAR(50)
)
GO

CREATE PROCEDURE [dbo].[usp_ProcessEmployee]
    @EmployeeNumber         VARCHAR(10),
    @FirstName              VARCHAR(50),
    @LastName               VARCHAR(50),
    @Position               VARCHAR(50)
AS

IF NOT EXISTS (SELECT 'X' FROM [dbo].[Employee]
               WHERE [EmployeeNumber] = @EmployeeNumber)
    INSERT INTO [dbo].[Employee] ( [EmployeeNumber], [FirstName], [LastName], [Position] )
    VALUES ( @EmployeeNumber, @FirstName, @LastName, @Position )
ELSE
    UPDATE [dbo].[Employee]
    SET [FirstName] = @FirstName,
        [LastName]  = @LastName,
        [Position]  = @Position
    WHERE [EmployeeNumber] = @EmployeeNumber
GO

EXECUTE [dbo].[usp_ProcessEmployee] 'ABC123', 'John', 'Smith', 'Vice President'

SELECT * FROM [dbo].[Employee]
GO

--EmployeeNumber   FirstName    LastName    Position
-----------------  -----------  ----------  ------------
--ABC123           John         Smith       Vice President

-- With the new MERGE statement, the stored procedure above will now look as follows:

CREATE PROCEDURE [dbo].[usp_MergeEmployee]
    @EmployeeNumber         VARCHAR(10),
    @FirstName              VARCHAR(50),
    @LastName               VARCHAR(50),
    @Position               VARCHAR(50)
AS

MERGE [dbo].[Employee] AS [Target]
USING (SELECT @EmployeeNumber, @FirstName, @LastName, @Position)
   AS [Source] ( [EmployeeNumber], [FirstName], [LastName], [Position] )
ON [Target].[EmployeeNumber] = [Source].[EmployeeNumber]
WHEN MATCHED THEN
    UPDATE SET [FirstName] = [Source][FirstName],
               [LastName]  = [Source].[LastName],
               [Position]  = [Source].[Position]
WHEN NOT MATCHED THEN
    INSERT ( [EmployeeNumber], [FirstName], [LastName], [Position] )
    VALUES ( [Source].[EmployeeNumber], [Source].[FirstName], 
             [Source].[LastName], [Source].[Position] );
GO

-- Here are the results when calling the stored procedure containing the MERGE statement:

DELETE FROM [dbo].[Employee]

EXECUTE [dbo].[usp_MergeEmployee] 'ABC123', 'John', 'Smith', 'Vice President'
SELECT * FROM [dbo].[Employee]
GO

--EmployeeNumber   FirstName    LastName    Position
-----------------  -----------  ----------  ------------
--ABC123           John         Smith       Vice President



EXECUTE [dbo].[usp_MergeEmployee] 'ABC123', 'John', 'Smith', 'President'
SELECT * FROM [dbo].[Employee]
GO

--EmployeeNumber   FirstName    LastName    Position
-----------------  -----------  ----------  ------------
--ABC123           John         Smith       President

