-- http://www.sql-server-helper.com/error-messages/msg-1-500.aspx

--

USE AdventureWorks2014
GO
-- Tables  Child Production.WorkOrderRouting  Parent Production.WorkOrder
SELECT TOP 10 *  FROM [Production].[WorkOrder]
SELECT TOP 10 *  FROM Production.WorkOrderRouting
GO
CREATE PROCEDURE Production.uspDeleteWorkOrder ( @WorkOrderID int )
AS
SET NOCOUNT ON;
BEGIN TRY
   BEGIN TRANSACTION 
   -- Delete rows from the child table, WorkOrderRouting, for the specified work order.
   DELETE FROM Production.WorkOrderRouting
   WHERE WorkOrderID = @WorkOrderID;

   -- Delete the rows from the parent table, WorkOrder, for the specified work order.
   DELETE FROM Production.WorkOrder
   WHERE WorkOrderID = @WorkOrderID;
  
   COMMIT

END TRY
BEGIN CATCH
  -- Determine if an error occurred.
  IF @@TRANCOUNT > 0
     ROLLBACK

  -- Return the error information.
  DECLARE @ErrorMessage nvarchar(4000),  @ErrorSeverity int;
  SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
  RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
END CATCH;
GO
EXEC Production.uspDeleteWorkOrder 13
GO



/* Intentionally generate an error by reversing the order in which rows are deleted from the
   parent and child tables. This change does not cause an error when the procedure
   definition is altered, but produces an error when the procedure is executed.
*/
CREATE PROCEDURE Production.uspDeleteWorkOrder_Error ( @WorkOrderID int )
AS

BEGIN TRY
   BEGIN TRANSACTION 
      -- Delete the rows from the parent table, WorkOrder, for the specified work order.
   DELETE FROM Production.WorkOrder
   WHERE WorkOrderID = @WorkOrderID;
  
   -- Delete rows from the child table, WorkOrderRouting, for the specified work order.
   DELETE FROM Production.WorkOrderRouting
   WHERE WorkOrderID = @WorkOrderID;
  
   COMMIT TRANSACTION

END TRY
BEGIN CATCH
  -- Determine if an error occurred.
  IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION

  -- Return the error information.
  DECLARE @ErrorMessage nvarchar(4000),  @ErrorSeverity int;
  SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY();
  RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
END CATCH;
GO
-- Execute the altered procedure.
EXEC Production.uspDeleteWorkOrder_Error 15;
GO

--(0 row(s) affected)
--Msg 50000, Level 16, State 1, Procedure uspDeleteWorkOrder_Error, Line 95
--The DELETE statement conflicted with the REFERENCE constraint "FK_WorkOrderRouting_WorkOrder_WorkOrderID". The conflict occurred in database "AdventureWorks2014", table "Production.WorkOrderRouting", column 'WorkOrderID'.

DROP PROCEDURE Production.uspDeleteWorkOrder;
GO
DROP PROCEDURE Production.uspDeleteWorkOrder_Error;
GO

-----------------------

-- Handling Errors in SQL Server 2014

USE tempdb
GO
if object_id('tempdb..#tres') is not null
		drop TABLE #tres
go
CREATE TABLE #tres(
ID INT PRIMARY KEY);
GO

BEGIN -- INICIO
PRINT 'Primera prueba : THROW'
BEGIN TRY
	INSERT #tres(ID) VALUES(1);
	-- Force error 2627, Violation of PRIMARY KEY constraint to be raised.
	INSERT #tres(ID) VALUES(1);
END TRY
BEGIN CATCH
	THROW 50001,'Test First Error',16; --raises error and exits immediately
END CATCH;
select 'First : I reached this point' --test with a SQL statement
print 'Final Primera prueba : THROW'
END -- FIN
GO

--Primera prueba : THROW

--(1 filas afectadas)

--(0 filas afectadas)
--Mens. 50001, Nivel 16, Estado 16, Línea 9
--Test First Error


BEGIN -- iNICIO
print 'Segunda prueba : RAISERROR'
BEGIN TRY
	INSERT #tres(ID) VALUES(2);
	-- Force error 2627, Violation of PRIMARY KEY constraint to be raised.
	INSERT #tres(ID) VALUES(2);
END TRY
BEGIN CATCH
	RAISERROR(50001,16,1,'Test Segunda prueba ') --just raises the error
END CATCH;
select 'Second: I reached this point' --test with a SQL statement
print 'Segunda prueba : RAISERROR End'
END -- FIN
GO

--Mens. 18054, Nivel 16, Estado 1, Línea 9
--Se detectó el error 50001, gravedad 16, estado 1, pero no se encontró ningún mensaje con ese número de error en sys.messages. Si el error es superior a 50000, asegúrese de que se agrega el mensaje definido por el usuario mediante sp_addmessage.

--(1 filas afectadas)
--Segunda prueba : RAISERROR End

--Second: I reached this point

-------------------
-- https://www.simple-talk.com/sql/database-administration/handling-errors-in-sql-server-2012/

-- Creating the LastYearSales table

USE AdventureWorks2014;
GO

IF OBJECT_ID('LastYearSales', 'U') IS NOT NULL
			DROP TABLE LastYearSales;
GO
SELECT
  BusinessEntityID AS SalesPersonID,
  FirstName + ' ' + LastName AS FullName,
  SalesLastYear
INTO
  LastYearSales
FROM
  Sales.vSalesPerson
WHERE
  SalesLastYear > 0;
GO
-- 
SELECT * FROM LastYearSales
GO
-- Adding a check constraint to the LastYearSales table

ALTER TABLE LastYearSales
ADD CONSTRAINT ckSalesTotal CHECK (SalesLastYear >= 0);
GO

--The constraint makes it easy to generate an error when updating the table. All I have to do is try to add a negative amount to the SalesLastYear column, an amount large enough to cause SQL Server to throw an error.

-- Working with the TRY…CATCH Block

-- Once we’ve set up our table, the next step is to create a stored procedure that demonstrates how to handle errors. The procedure, UpdateSales, modifies the value in the SalesLastYear column in the LastYearSales table for a specified salesperson. It works by adding or subtracting an amount from the current value in that column. Listing 3 shows the script I used to create the procedure. Notice that I include two input parameters—@SalesPersonID and @SalesAmt—which coincide with the table’s SalesPersonID and SalesLastYear columns.

-- Creating a stored procedure that contains a Try…Catch block

IF OBJECT_ID('UpdateSales', 'P') IS NOT NULL
	DROP PROCEDURE UpdateSales;
GO

CREATE PROCEDURE UpdateSales
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
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO

-- Retrieving date from the LastYearSales table

SELECT FullName, SalesLastYear
FROM LastYearSales
WHERE SalesPersonID = 288
GO

--FullName	SalesLastYear
--Rachel Valdez	1307949,7917

--  Running the UpdateSales stored procedure

EXEC UpdateSales 288, 2000000;
GO

-- (1 filas afectadas)

-- Comprobar

SELECT FullName, SalesLastYear
FROM LastYearSales
WHERE SalesPersonID = 288
GO

--FullName	SalesLastYear
--Rachel Valdez	3307949,7917

-- Causing the UpdateSales stored procedure to throw an error

-- Now let’s look what happens if we subtract enough from her account to bring her totals to below zero. In listing 8, I run the procedure once again, but this time specify -4000000 for the amount.

EXEC UpdateSales 288, -4000000;
GO

--(0 filas afectadas)
--Actual error number: 547
--Actual line number: 9
--Mens 50000, Nivel 16, Estado 0, Procedimiento UpdateSales, Línea 27
--Instrucción UPDATE en conflicto con la restricción CHECK "ckSalesTotal". El conflicto ha aparecido en la base de datos "AdventureWorks2014", tabla "dbo.LastYearSales", column 'SalesLastYear'.

-- As expected, the information we included in the CATCH block has been returned.
-- But notice that the actual error number (547) is different from the RAISERROR message 
-- number (50000) and that the actual line number (9) is different from the RAISERROR 
-- line number (27). In theory, these values should coincide. But as I mentioned earlier, 
-- the rules that govern RAISERROR are a bit quirky.

-- Working with the THROW Statement

-- To demonstrate the THROW statement, I defined an ALTER PROCEDURE statement that modifies the UpdateSales procedure, specifically the CATCH block,

ALTER PROCEDURE UpdateSales
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
GO

-- Notice that I retain the @ErrorNumber and @ErrorLine variable declarations 
-- and their related PRINT statements. I do so only to demonstrate the THROW 
-- statement’s accuracy. In actually, I need only to roll back the transaction and 
--specify the THROW statement, without any parameters.

-- Now let’s execute the stored procedure again, once more trying to deduct 
-- $4 million from the sales amount

--  Causing the UpdateSales stored procedure to throw an error

EXEC UpdateSales 288, -4000000;
GO


--(0 filas afectadas)
--Actual error number: 547
--Actual line number: 8
--Mens 547, Nivel 16, Estado 0, Procedimiento UpdateSales, Línea 8
--Instrucción UPDATE en conflicto con la restricción CHECK "ckSalesTotal". El conflicto ha aparecido en la base de datos "AdventureWorks2014", tabla "dbo.LastYearSales", column 'SalesLastYear'.

------------------------------

-- http://sqlhints.com/2013/06/30/differences-between-raiserror-and-throw-in-sql-server/

-------------------------
USE AdventureWorks2014;
GO
DROP TABLE HumanResources.Candidatos
GO
SELECT * 
INTO HumanResources.Candidatos 
FROM HumanResources.JobCandidate
GO
SELECT * FROM HumanResources.Candidatos 
GO
DECLARE @ErrorVar INT;
DECLARE @RowCountVar INT;
 DELETE FROM HumanResources.Candidatos
WHERE JobCandidateID = 35; -- No existe 35
--DELETE FROM HumanResources.Candidatos
-- WHERE JobCandidateID = 3; -- Existe 2
-- Save @@ERROR and @@ROWCOUNT while they are both
-- still valid.
SELECT @ErrorVar = @@ERROR, @RowCountVar = @@ROWCOUNT;
IF (@ErrorVar <> 0 or @RowCountVar= 0)
    PRINT 'Candidato no existente ' + CAST(@ErrorVar AS NVARCHAR(8)) +'   '  +
	 CAST(@RowCountVar AS NVARCHAR(8))
ELSE
  PRINT 'Candidato Borrado = ' + CAST(@RowCountVar AS NVARCHAR(8));
GO

-- Versión SP
ALTER PROC Borrar_Candidato
	@candidato INT
	AS
BEGIN
DECLARE @ErrorVar INT;
DECLARE @RowCountVar INT;
DECLARE @Candi INT;
 DELETE FROM HumanResources.Candidatos
WHERE JobCandidateID = @candidato; -- No existe 35
--DELETE FROM HumanResources.Candidatos
-- WHERE JobCandidateID = @candidato; -- Existe 2
-- Save @@ERROR and @@ROWCOUNT while they are both
-- still valid.
SELECT @ErrorVar = @@ERROR, @RowCountVar = @@ROWCOUNT, @candi=@candidato;
IF (@ErrorVar <> 0 or @RowCountVar= 0)
    PRINT 'Candidato no existente ' + CAST(@ErrorVar AS NVARCHAR(8)) +'   '  +
	 CAST(@RowCountVar AS NVARCHAR(8))
ELSE
  PRINT 'Candidato Borrado = ' + CAST(@candi AS NVARCHAR(8));
END
EXEC Borrar_Candidato 35
GO
EXEC Borrar_Candidato  6
GO
-----
USE AdventureWorks2014;
GO
DROP TABLE HumanResources.Candidatos 
GO
select *
 into HumanResources.Candidatos 
 from HumanResources.JobCandidate
go
SELECT * FROM HumanResources.Candidatos
GO
-- Drop the procedure if it already exists.
IF OBJECT_ID('HumanResources.usp_DeleteCandidate', 'P') IS NOT NULL
    DROP PROCEDURE HumanResources.usp_DeleteCandidate;
GO
-- Create the procedure.
CREATE  PROCEDURE HumanResources.usp_DeleteCandidate 
      @CandidateID INT  
AS
SELECT * FROM Candidatos
WHERE   JobCandidateID = @CandidateID
-- Execute the DELETE statement.
DELETE  HumanResources.Candidatos
    WHERE JobCandidateID = @CandidateID
DECLARE @RowCountVar INT
SELECT  @RowCountVar = @@ROWCOUNT
IF @RowCountVar > 0
    BEGIN
         -- Return 0 to the calling program to indicate success.
       RETURN (0)
	       END
ELSE
    BEGIN
		RETURN (1)
     END
GO
-- Command(s) completed successfully.

declare @vr int
-- exec @vr=HumanResources.usp_DeleteCandidate 99 ---- Sin Borrar
 exec @vr=HumanResources.usp_DeleteCandidate  7 ---- -- Borrando
PRINT @vr
If @vr = 0
		PRINT 'The job candidate has been deleted. Borrado';
ELSE
	PRINT 'An error occurred deleting the candidate information.';
GO




---------------------------

USE pubs


SELECT * INTO Authors_Prueba FROM authors
go
BEGIN TRAN
DECLARE @intErrorCode INT
    UPDATE  Authors_Prueba
    SET Phone = '415 354-9866'
    WHERE au_id = '724-80-9391'

    SELECT @intErrorCode = @@ERROR
    IF (@intErrorCode <> 0) GOTO PROBLEM

    UPDATE Publishers
    SET city = 'Calcutta', country = 'India'
    WHERE pub_id = '9999'

    SELECT @intErrorCode = @@ERROR
    IF (@intErrorCode <> 0) GOTO PROBLEM
COMMIT TRAN

PROBLEM:
IF (@intErrorCode <> 0) BEGIN
PRINT 'Unexpected error occurred!'
    ROLLBACK TRAN
END

----------------------------------------------------------------------------
						--MANEJO DE ERRORES Y EXCEPCIONES
----------------------------------------------------------------------------
--TRY/CATCH/THROW(RAISERROR)

USE tempdb;
GO

CREATE TABLE dbo.TestRethrow
	(ID INT PRIMARY KEY);
BEGIN TRY
	INSERT dbo.TestRethrow(ID) VALUES(1);
	--Force error 2627, Violation of Primary key constraint to be raised.
	INSERT dbo.TestRethrow(ID) VALUES(1);
END TRY
BEGIN CATCH
	PRINT 'In catch block.';
	--THROW;							
	RAISERROR ('Violation of PRIMARY KEY CONSTARINT ERROR',12,12)
END CATCH;

--Resultado
----------------(1 row(s) affected)
----------------In catch block.
----------------Msg 50000, Level 12, State 12, Line 12
----------------Violation of PRIMARY KEY CONSTARINT ERROR



------------------------------------------------------------------------------
--TRANSACCIONES
------------------------------------------------------------------------------
--Instrucciones que se ejecutan de forma conjunta
--O se ejecutan las 2 o no se ejecuta ninguna

--ESTRUCTURA:
--	BEGIN TRANSACTION
--		INSERT.....
--		UPDATE.....
--	END TRAN

--OPCIONES:
--	COMMIT TRAN (Confirma operaciones contra BD)
--	ROLLBACK TRAN (No ejecuta la Transacción)	

USE AdventureWorks2014;

BEGIN TRANSACTION;
BEGIN TRY
	--Generamos una violación de restricción
	DELETE FROM Production.Product
	WHERE ProductID=980;
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	IF @@TRANCOUNT >0
		ROLLBACK TRANSACTION;
END CATCH;
Print @@Trancount;
IF @@TRANCOUNT > 0
	COMMIT TRANSACTION;
GO
----547	16	0	NULL	6	The DELETE statement conflicted with the REFERENCE constraint "FK_BillOfMaterials_Product_ProductAssemblyID". The conflict occurred in database "AdventureWorks2014", table "Production.BillOfMaterials", column 'ProductAssemblyID'.


BEGIN TRANSACTION;
BEGIN TRY
	--Generamos una violación de restricción
	DELETE FROM Production.Producto
	WHERE ProductID=943;
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	IF @@TRANCOUNT >0
		ROLLBACK TRANSACTION;
END CATCH;
Print @@Trancount;
IF @@TRANCOUNT > 0
	COMMIT TRANSACTION;
GO




--@@ERROR no es muy fialble
--Ejemplo Sin @variable:
USE tempdb
go
CREATE TABLE notnull (a int not null)
declare @value int
insert notnull values(@value)
if @@error<>0
	print '@@error is ' + ltrim(str(@@error)) + '.';
	--La salida sería:
--------------Msg 515, Level 16, State 2, Line 3
--------------Cannot insert the value NULL into column 'a', table 'tempdb.dbo.notnull'; column does not allow nulls. INSERT fails.
--------------The statement has been terminated.
--------------@@error is 0.

	--Ejemplo. La otra forma, cargando @@ERROR en una @variable, sería:
if OBJECT_ID('notnull', 'u') is not null
	drop table notnull
go
CREATE TABLE notnull (a int not null)
declare @err int, @value int
insert notnull values(@value)
select @err= @@ERROR
if @err<>0
	print '@err is ' + ltrim(str(@err)) + '.';
	
	--La salida sería:	
------------Msg 515, Level 16, State 2, Line 3
------------Cannot insert the value NULL into column 'a', table 'tempdb.dbo.notnull'; column does not allow nulls. INSERT fails.
------------The statement has been terminated.
------------@err is 515.





--------------------------------------------------------------
--Ejemplo complejo de gestión de errores
--------------------------------------------------------------
use AdventureWorks2014;
--Crea la tabla LastyearSales
if OBJECT_ID('LastYearSales', 'u') is not null
	drop table LastYearSales
go
SELECT BusinessEntityID AS SalespersonID,
		FirstName + ' ' + Lastname AS Fullname,
		SalesLastYear
INTO LastyearSales
FROM Sales.vSalesPerson
WHERE
	SalesLastYear>0;
GO
--Le añade un check
ALTER TABLE LastYearSales
ADD CONSTRAINT ckSalesTotal CHECK (SalesLastYear >=0);
GO

------

--Crea un procedimiento almacenado 'UpdateSales'
USE AdventureWorks2014;
GO

IF OBJECT_ID('UpdateSales', 'P') IS NOT NULL
DROP PROC UpdateSales;
GO

CREATE PROC UpdateSales
@SalesPersonID INT,
@SalesAmt MONEY = 0
AS
BEGIN
BEGIN TRY
		BEGIN TRANSACTION;
					UPDATE LastYearSales
					SET SalesLastYear = SalesLastYear + @SalesAmt
					WHERE SalespersonID = @SalesPersonID;
		COMMIT TRANSACTION;
END TRY
BEGIN CATCH
			IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
					DECLARE @ErrorNumber INT = ERROR_NUMBER();
					DECLARE	@ErrorSeverity INT = ERROR_SEVERITY();
					DECLARE	@ErrorState INT = ERROR_STATE();
					DECLARE	@ErrorLine INT = ERROR_LINE();
					DECLARE @ErrorMessage INT = ERROR_MESSAGE();
					PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
					PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
					RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
END;

--Comprobamos que existe el id 288
SELECT FullName, SalesLastYear
FROM LastyearSales
WHERE SalespersonID = 288

------------Rachel Valdez	1307949,7917

EXEC UpdateSales 288, 2000000;
--------(1 row(s) affected)

EXEC UpdateSales 288, -2000000;
--------(0 row(s) affected)
--------Msg 245, Level 16, State 1, Procedure UpdateSales, Line 20
--------Conversion failed when converting the nvarchar value 'UpdateSales' to data type int.





--OTRO EJEMPLO
create PROC Deletesales
@salespersonid	int
AS
BEGIN
BEGIN TRY
		BEGIN TRAN;
				DELETE LastyearSales
				WHERE SalespersonID = @salespersonid;
		COMMIT TRAN;
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				DECLARE @ErrorNumber INT = error_number();
				DECLARE @ErrorLine INT = ERROR_LINE();
				PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
				PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
				--THROW; (Sólo en SQL server 2012)
				RAISERROR('Registro ya borrado', 16,3);
END CATCH
END;
GO







--OTRO EJEMPLO
sp_help "[Sales].[salesperson]"
go
CREATE PROC DeleteSalesPerson
@TerritoryID INT
AS
BEGIN
BEGIN TRY
		BEGIN TRAN;
			DELETE Sales.SalesPerson
			WHERE TerritoryID=@TerritoryID;
		COMMIT TRAN;
GO