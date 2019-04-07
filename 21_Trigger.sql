-- http://www.aspsnippets.com/Articles/Simple-Insert-Update-and-Delete-Triggers-in-SQL-Server-with-example.aspx
-- http://www.aspsnippets.com/Articles/SQL-Server-Instead-Of-Insert-Trigger-Example.aspx

------------------------------------------------------------------------
								--TRIGGERS
------------------------------------------------------------------------
--Es un tipo de procedimiento almacenado que se ejecuta automáticamente
--cuando se producen unas acciones determinadas

--Tipos de Trigger:

-- Level
-- Pueden crearse Triggers a distintos niveles: Servidor, Base de Datos, Tabla o Vista
--		Server
--		DataBase
--		Table - View

-- According Statements
	--	DDL(Lenguaje de Definición de Datos): Create Schemas, Alter Synonym, etc.
	--	DML (Lenguaje de Manipulación de Datos): INSERT, UPDATE, DELETE,etc.	
	


-- Notación : Microsoft nombra los trigger con el prefijo 'TRG_'

--A nivel de Tabla / Vista 2 tipos de trigger:

	--AFTER/FOR  se dispara cuando se detecta la acción y después hace algo
				--pero no trunca nada
	--INSTEAD OF, se dispara cuando se da una condición y en vez de hacer la orden, ejecuta el contenido del trigger

--Los trigger pueden habilitarse o deshabilitarse, según nos convenga, mediante ENABLE/DISABLE	

-- https://msdn.microsoft.com/es-es/library/ms179309.aspx

USE AdventureWorks2014
GO
-- Mostrar los desencadenadores de la BD
SELECT OBJECT_NAME(parent_id) Table_or_ViewNM,
name TriggerNM, is_instead_of_trigger, is_disabled
FROM sys.triggers
WHERE parent_class_desc = 'OBJECT_OR_COLUMN'
ORDER BY OBJECT_NAME(parent_id), name
GO

-- mostrar codigo desencadenador

SELECT o.name, m.definition
FROM sys.sql_modules m
INNER JOIN sys.objects o ON
m.object_id = o.object_id
WHERE o.type = 'TR'
GO

-- http://elsasoft.com/samples/sqlserver_AdventureWorks20142014/sqlserver.spring.katmai.AdventureWorks20142014/allTriggers.htm

-- dEmployee
sp_helptext "HumanResources.dEmployee"
GO

-- nivel server
SELECT name, s.type_desc SQL_or_CLR,
is_disabled, e.type_desc FiringEvents
FROM sys.server_triggers s
INNER JOIN sys.server_trigger_events e ON
s.object_id = e.object_id
GO
-- nivel BD

SELECT t.name, m.Definition
FROM sys.triggers AS t
INNER JOIN sys.sql_modules m ON
t.object_id = m.object_id
WHERE t.parent_class_desc = 'DATABASE'
GO
-- Nivel tabla
-- Table  [Purchasing].[Vendor]      Trigger [dVendor]

-- Events de un Trigger

SELECT TE.*
FROM sys.trigger_events AS TE
JOIN sys.triggers AS T ON T.object_id = TE.object_id
WHERE T.parent_class = 0 AND T.name = 'safety';
GO
----------------------
-- Deshabilitar un desencadenador DML en una tabla

USE AdventureWorks2014;
GO
DISABLE TRIGGER Person.uAddress ON Person.Address;
GO
ENABLE Trigger Person.uAddress ON Person.Address;
GO
-- Deshabilitar un desencadenador DDL

-- En el ejemplo siguiente se crea un desencadenador DDL safety, con ámbito en la base de datos, 
-- y después se deshabilita.

IF EXISTS (SELECT * FROM sys.triggers
    WHERE parent_class = 0 AND name = 'safety')
DROP TRIGGER safety ON DATABASE;
GO
CREATE TRIGGER safety 
ON DATABASE 
FOR DROP_TABLE, ALTER_TABLE 
AS 
   PRINT 'You must disable Trigger "safety" to drop or alter tables!' 
   ROLLBACK;
GO
DISABLE TRIGGER safety ON DATABASE;
GO
ENABLE TRIGGER safety ON DATABASE;
GO
-- Deshabilitar todos los desencadenadores que se definieron con el mismo ámbito
-- En el ejemplo siguiente se deshabilitan todos los desencadenadores DDL creados en el ámbito de servidor.

USE AdventureWorks2014;
GO
DISABLE Trigger ALL ON ALL SERVER;
GO
ENABLE Trigger ALL ON ALL SERVER;
GO
-----------------------------------------------------------------------
--			A NIVEL DE SERVIDOR (DDL)
-----------------------------------------------------------------------
--Este tipo de trigger se almacenan en 'Server Objects'

USE master
GO


--Deshabilitar nuevos Logins en una instancia SQL
CREATE TRIGGER trg_NoNuevoLogin
ON ALL SERVER
FOR CREATE_LOGIN --Sentencia a controlar (puede haber más de una)
AS
	PRINT 'No login creations without DBA involvement'
	ROLLBACK TRAN
GO

--Intentamos crear un login y nos va a dar el error
CREATE LOGIN Joe WITH PASSWORD='A2359'
GO
--------No login creations without DBA involvement
--------Msg 3609, Level 16, State 2, Line 1
--------The transaction ended in the trigger. The batch has been aborted.

--Vemos que no nos deja
--En vez de print podríamos hacer lo mismo con un RAISERROR

--El Trigger está activado. Si queremos borrarlo: DROP
DROP TRIGGER trg_NoNuevoLogin
ON ALL SERVER

-----------------------------------------------------------------------------------
									--LOG ON
----------------------------------------------------------------------------------
--Triggers especiales para controlar inicios de sesión, logins, etc.

USE master;
GO
--Crea un login con una contraseña
CREATE LOGIN login_test WITH PASSWORD='1234',
CHECK_EXPIRATION = ON;
GO

--Le damos permiso de lectura
GRANT VIEW SERVER STATE TO login_test;

--Borra el logon (trigger de servidor) que vamos a crear si ya existe
IF EXISTS (SELECT * FROM sys.server_triggers
			WHERE name='connection_limit_trigger')
				DROP TRIGGER connection_limit_trigger
				ON ALL SERVER;
GO

--Crea un trigger de servidor que se dispara cuando el usuario 'login_test'
CREATE TRIGGER connection_limit_trigger
ON ALL SERVER
WITH EXECUTE AS 'login_test'
FOR LOGON
AS 
	BEGIN
		IF ORIGINAL_LOGIN()= 'login_test' AND 
				(SELECT COUNT(*) FROM sys.dm_exec_sessions
					WHERE is_user_process=1 AND
							original_login_name='login_test') >3
				ROLLBACK;
	END;
GO
													
-------------------------------------------------------------------------------------------------
								--TRIGGER a nivel de BD (DML)
-------------------------------------------------------------------------------------------------
--En el entorno gráfico este tipo de trigger aparece dentro de 'Programmability' en su respectiva BD

USE pubs
GO
--Primero creamos una tabla con select into
IF OBJECT_ID('Autores', 'U') IS NOT NULL
	DROP TABLE Autores;
GO
select *
	into autores
	from authors
go	

--Creamos el Trigger (el FOR AFTER, no es necesario, llega con poner FOR)
IF OBJECT_ID('trg_PrevenirBorrado', 'TR') IS NOT NULL
	DROP TRIGGER trg_PrevenirBorrado;
GO
CREATE TRIGGER trg_PrevenirBorrado
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE
AS
		RAISERROR('No se puede borrar o modificar tablas', 16,3)
		ROLLBACK TRAN;
GO

--Probamos a borrar la tabla recién creada
DROP TABLE Autores;
GO
--Vemos que no nos deja y nos devuelve el siguiente mensaje:
------------Msg 50000, Level 16, State 3, Procedure trg_PrevenirBorrado, Line 5
------------No se puede borrar o modificar tablas
------------Msg 3609, Level 16, State 2, Line 1
------------The transaction ended in the trigger. The batch has been aborted.

--Para Borrar
DROP TRIGGER trg_PrevenirBorrado
GO
-- Si da Error de Borrado borrarlo desde GUI

-------------------------------------------------------------------------
--TRIGGER A NIVEL DE TABLA O VISTA
-------------------------------------------------------------------------
--Estos triggers se almacenan en la tabla a la que restringen

USE pubs
GO
IF OBJECT_ID ('Autores', 'U') IS NOT NULL
   DROP TABLE Autores;
GO
SELECT *
INTO Autores
FROM Authors
GO
IF OBJECT_ID ('trg_DarAutor', 'TR') IS NOT NULL
   DROP TRIGGER trg_DarAutor;
GO
--Creamos un Trigger que nos ejecute un raiserror y un procedimiento almacenado
--Después de una inserción o un update en la tabla autores
CREATE TRIGGER trg_DarAutor
ON Autores
FOR INSERT, UPDATE --Si ponemos 'FOR' es un 'After'
AS
			RAISERROR (50009,16,10)
			EXEC sp_helpdb pubs
GO

--Comprobamos el contenido de la tabla
select * from Autores;
GO
--Lo probamos
UPDATE Autores
	SET au_lname ='Black'
	WHERE au_fname = 'Johnson';
GO
	
--Nos devuelve un error, pero ejecuta la operación
----------------Msg 18054, Level 16, State 1, Procedure trg_DarAutor, Line 5
----------------Error 50009, severity 16, state 10 was raised, but no message with that error number was found in sys.messages. If error is larger than 50000, make sure the user-defined message is added using sp_addmessage.

----------------(1 row(s) affected)

--Creamos otro Trigger de tipo AFTER
USE pubs;

IF EXISTS (select name from sysobjects
			where name='trg_borra' and type='tr')
			DROP TRIGGER trg_borra
GO

--Creamos un trigger para la tabla autores
CREATE TRIGGER trg_borra
ON Autores
FOR DELETE, UPDATE
AS
		RAISERROR('%d filas modificadas en la tabla Autores',16,1,@@rowcount)
GO

-- Try out
DELETE Autores
WHERE au_fname='Johnson';
GO

--Sigue siendo un trigger AFTER, por lo que lanza lo que le especifiquemos después de ejecutar
--la sentencia que lo dispara, por lo que devuelve:
----------------Msg 50000, Level 16, State 1, Procedure trg_borra, Line 5
----------------1 filas modificadas en la tabal

----------------(1 row(s) affected)


--Trigger sobre una vista.
--Va a ser un trigger de tipo INSTEAD OF, ejecutará el contenido del trigger en vez de la sentencia que
--lo dispara

--Creamos la vista
CREATE VIEW vAutores
AS
	SELECT * FROM Autores
GO

--Creamos un trigger para la vista (de tipo INSTEAD OF)
CREATE TRIGGER trg_BorrarVista
ON vAutores
INSTEAD OF DELETE
AS
		PRINT 'No puedes borrar la vista'
GO

--Lo probamos
DELETE vAutores;
GO
--Nos devuelve:
------------No puedes borrar la vista

------------(23 row(s) affected)

--Aunque pone que hay 23 filas afectadas, al hacer un select
select * from vAutores;
--vemos que está todo igual, es decir, el trigger evitó el DELETE
--y en su lugar nos mostró el mensaje 'No puedes borrar la vista'



---------------------------------------------------------------------------------
--Trigger con tablas temporales INSERTED DELETED 
---------------------------------------------------------------------------------
USE pubs
GO
IF OBJECT_ID ('trg_TablasTemporales', 'TR') IS NOT NULL
   DROP TRIGGER trg_TablasTemporales;
GO
CREATE TRIGGER trg_TablasTemporales
ON Autores
FOR UPDATE
AS
		PRINT 'Tabla inserted'
		SELECT * FROM inserted
		PRINT 'Tabla deleted'
		SELECT * FROM deleted
GO
select * from Autores
go
-- Try Out
UPDATE Autores
SET au_lname= 'VERDE'
WHERE au_fname='Marjorie'
GO
--Vemos los cambios en las tablas temporales, antes y después del update

--au_id	au_lname	au_fname	phone	address	city	state	zip	contract
--213-46-8915	VERDE	Marjorie	415 986-7020	309 63rd St. #411	Oakland	CA	94618	1

--au_id	au_lname	au_fname	phone	address	city	state	zip	contract
--213-46-8915	Green	Marjorie	415 986-7020	309 63rd St. #411	Oakland	CA	94618	1

--NOS Da un error porque había otro trigger, podemos borrarlo DROP o desactivarlo con DISABLE


-------------------------
--Otro ejemplo, pero actualizando varios registros a la vez

--Usamos el mismo trigger anterior

UPDATE Autores
SET city= 'A Coruña'
WHERE contract= 0 ;
GO


---------------------------------------
--Trigger con estructura condicional sobre un campo
---------------------------------------
USE pubs
GO
--select * from authors into autores3
--drop trigger trg_actualizar_ciudad;
IF OBJECT_ID ('trg_actualizar_ciudad', 'TR') IS NOT NULL
   DROP TRIGGER trg_actualizar_ciudad;
GO
CREATE TRIGGER trg_actualizar_ciudad
ON autores
FOR UPDATE
AS
	IF UPDATE (city)
			BEGIN 
					RAISERROR('No puedes cambiar la ciudad', 15,1)
					ROLLBACK TRAN
			END
	ELSE
			PRINT 'Operación Correcta'
GO

update Autores2
set city='AC' where state='CA'
go	

------

-----------------------------------------------------------------------------------------------
				--Trigger que nos impide actualizar un campo determinado
-----------------------------------------------------------------------------------------------
create trigger HumanResources.trg_U_Department
on HumanResources.Department
after update --after y for se pueden emplear indistintamente
as
	if UPDATE(groupname)
		BEGIN
			PRINT 'Updates to Groupname requires DBA involvement.';
			ROLLBACK TRAN;
		END
GO
	
--Intentamos actualizar groupname
UPDATE HumanResources.Department
SET GroupName='Research an Development'
WHERE DepartmentID=10;
--------------Updates to Groupname requires DBA involvement.
--------------Msg 3609, Level 16, State 1, Line 1
--------------The transaction ended in the trigger. The batch has been aborted.


--Probamos a actualizar otro campo
select * from HumanResources.Department WHERE DepartmentID=10;
----10		Finance		Executive General and Administration		2002-06-01 00:00:00.000
UPDATE HumanResources.Department
SET Name='Finanzas'
WHERE DepartmentID=10;
--10	Finanzas	Executive General and Administration	2002-06-01 00:00:00.000
--Volvemos al estado inicial
UPDATE HumanResources.Department
SET Name='Finance'
WHERE DepartmentID=10;

-------------------------
-- Example Trigger AdventureWorks
ALTER TRIGGER [HumanResources].[dEmployee] 
ON [HumanResources].[Employee] 
INSTEAD OF DELETE 
 AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN
        RAISERROR
            (N'Employees cannot be deleted. They can only be marked as not current.', -- Message
            10, -- Severity.
            1); -- State.

        -- Rollback any active or uncommittable transactions
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END;
END;

-------------------------------------------------------------------------------------
--Crear un trigger que no permita borrar más de un registro con una sentencia delete
--Tabla Employees de Northwind
USE Northwind
GO
IF OBJECT_ID('Empleados','U')is not null
DROP TABLE Empleados
GO
SELECT EmployeeID, LastName 
INTO Empleados 
FROM Employees ;
GO
SELECT * FROM Empleados ORDER BY EmployeeID
GO
IF OBJECT_ID ('trg_delete_individual', 'TR') IS NOT NULL
   DROP TRIGGER trg_delete_individual;
GO
CREATE TRIGGER trg_delete_individual
ON Empleados
FOR DELETE
AS
	IF (SELECT COUNT(*) FROM deleted) > 1
			BEGIN 
				RAISERROR('Borra sólo un empleado',16,3);
				ROLLBACK
				RETURN
			END
	ELSE
			PRINT 'Empleado Borrado'
GO

delete Empleados 
where EmployeeID >5;
go	
--Devuelve:
------------Msg 50000, Level 16, State 3, Procedure trg_delete_individual, Line 7
------------Borra sólo un empleado
------------Msg 3609, Level 16, State 1, Line 1
------------The transaction ended in the trigger. The batch has been aborted.

-- Borra 5 , Trigger no lo impide
delete Empleados 
where EmployeeID =5;
go

--Empleado Borrado
--(1 row(s) affected)
-- 
SELECT * FROM  Empleados 
where EmployeeID =5;
go


--drop table Empleados;
--drop trigger trg_delete_individual;

---------------------
----------------------------------------------------------------
--- Crear Tabla ejemplos 

USE Tempdb
GO
CREATE TABLE [dbo].[Customers](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Country] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[CustomerLogs](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NOT NULL,
	[ACTION] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CustomerLogs] PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

INSERT INTO Customers
SELECT 'Ana', 'A Coruña'
UNION ALL
SELECT 'Luis', 'Pontevedra'
UNION ALL
SELECT 'Pablo', 'Ourense'
UNION ALL
SELECT 'Veronica', 'Lugo'
GO
SELECT * FROM [Customers]
GO

-- Simple Insert Update and Delete Triggers in SQL Server with example

-- Insert en la Tabla base y en la de Log

CREATE TRIGGER [dbo].[Customer_INSERT]
       ON [dbo].[Customers]
AFTER INSERT
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
 
       SELECT @CustomerId = INSERTED.CustomerId       
       FROM INSERTED
 
       INSERT INTO CustomerLogs
       VALUES(@CustomerId, 'Inserted')
END

-- try Out

INSERT Customers
Values ('Pepe','Rusia')
GO
SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO

-- Delete

CREATE TRIGGER [dbo].[Customer_DELETE]
       ON [dbo].[Customers]
AFTER DELETE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
 
       SELECT @CustomerId = DELETED.CustomerId       
       FROM DELETED
 
       INSERT INTO CustomerLogs
       VALUES(@CustomerId, 'Deleted')
END
GO

--
DELETE Customers
WHERE CustomerId = 5
GO
SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO


-- Update
-- Error con lo que aparece
CREATE TRIGGER [dbo].[Customer_UPDATE]
       ON [dbo].[Customers]
AFTER UPDATE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
       DECLARE @Action VARCHAR(50)
 
       SELECT @CustomerId = INSERTED.CustomerId       
       FROM INSERTED
 
       IF UPDATE(Name)
       BEGIN
              SET @Action = 'Updated Name'
       END
 
       IF UPDATE(Country)
       BEGIN
              SET @Action = 'Updated Country'
       END
 
       INSERT INTO CustomerLogs
       VALUES(@CustomerId, @Action)
END
GO

UPDATE Customers
SET Name ='rodolfo', Country='Alemania'
WHERE Name='Veronica' and Country='Lugo'
GO
SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO


--Instead Of Delete Triggers

--Instead Of triggers are executed instead of any of the Insert, Update or Delete operations.
--For example consider an Instead of Trigger for Delete operation, whenever a Delete is performed the Trigger will be executed first and if the Trigger deletes record then only the record will be deleted.
--Below is an example of an Instead Of Delete Trigger.
-- Whenever anyone tries to delete a row from the Customers table the following trigger is executed.

-- Inside the Trigger, I have added a condition that if record has CustomerId value 2 then such a record 
-- must not be deleted and an error must be raised. Also a record is inserted in the CustomerLogs table.

--If the CustomerId value is not 2 then a delete query is executed which deletes the record permanently and a record is inserted in the CustomerLogs table.


CREATE TRIGGER [dbo].[Customer_InsteadOfDELETE]
       ON [dbo].[Customers]
INSTEAD OF DELETE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
 
       SELECT @CustomerId = DELETED.CustomerId       
       FROM DELETED
		-- No se puede borrar Cliente 2
       IF @CustomerId = 2
       BEGIN
              RAISERROR('Record cannot be deleted',16 ,1)
              ROLLBACK
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'Record cannot be deleted.')
       END
       ELSE
       BEGIN
              DELETE FROM Customers
              WHERE CustomerId = @CustomerId
 
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'Instead Of Delete')
       END
END
GO

-- Try Out


CREATE PROC Probar_Instead_Delete
	@CustomerId INT
AS
		DELETE Customers
		WHERE CustomerId = @CustomerId
GO

EXEC Probar_Instead_Delete 3

-- Consultamos

SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO


EXEC Probar_Instead_Delete 2


--Mens 50000, Nivel 16, Estado 1, Procedimiento Customer_InsteadOfDELETE, Línea 15
--Record cannot be deleted
--Mens 3609, Nivel 16, Estado 1, Procedimiento Probar_Instead_Delete, Línea 4
--La transacción terminó en el desencadenador. Se anuló el lote.

--(2 filas afectadas)

-- Consultamos

SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO

DELETE Customers
GO
-- Consultamos

SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO

--LogId	CustomerId	ACTION
--1	3	Instead Of Delete
--2	2	Record cannot be deleted.
--3	4	Instead Of Delete
-------------------
-- INSTEAD OF INSERT

--Instead Of Insert Triggers
--These triggers are executed instead of any of the Insert, Update or Delete operations.
--For example consider an Instead of Trigger for Insert operation, whenever an Insert is performed the Trigger will be executed first and if the Trigger inserts record then only the record will be inserted.
--Below is an example of an Instead Of Insert Trigger. Whenever anyone tries to insert a row from the Customers table the following trigger is executed.
--Inside the Trigger, I have added a condition that if a record with the Name already exists then such a record must not be inserted and an error must be raised. Also a record is inserted in the CustomerLogs table.
--If a record with the Name does not exists in the table then an insert query is executed which inserts the record and a record is inserted in the CustomerLogs table.
CREATE TRIGGER [dbo].[Customer_InsteadOfINSERT]
       ON [dbo].[Customers]
INSTEAD OF INSERT
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT, @Name VARCHAR(50), @Country VARCHAR(50)
       DECLARE @Message VARCHAR(100)
 
       SELECT @CustomerId = INSERTED.CustomerId,
              @Name = INSERTED.Name,
              @Country = INSERTED.Country       
       FROM INSERTED
 
       IF (EXISTS(SELECT CustomerId FROM Customers WHERE Name = @Name))
       BEGIN
              SET @Message = 'Record with name ' + @Name + ' already exists.'
              RAISERROR(@Message, 16 ,1)
              ROLLBACK
       END
       ELSE
       BEGIN
              INSERT INTO Customers
              VALUES(@CustomerId, @Name, @Country)
 
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'InsteadOf Insert')
       END
END

-- INSTEAD OF UPDATE

--Instead Of Update Triggers
--These triggers are executed instead of any of the Insert, Update or Delete operations.
--For example consider an Instead of Trigger for Update operation, whenever an Update is performed the Trigger will be executed first and if the Trigger updates record then only the record will be updated.
---- Below is an example of an Instead Of Update Trigger. Whenever anyone tries to update a row from the Customers table the following trigger is executed.
--Inside the Trigger, I have added a condition that if the CustomerId column of the record is updated then such a record must not be updated and an error must be raised. Also a record is inserted in the CustomerLogs table.
--If any other column is updated then an update query is executed which updates the record and a record is inserted in the CustomerLogs table.


CREATE TRIGGER [dbo].[Customer_InsteadOfUPDATE]
       ON [dbo].[Customers]
INSTEAD OF UPDATE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT, @Name VARCHAR(50), @Country VARCHAR(50)
 
       SELECT @CustomerId = INSERTED.CustomerId,
              @Name = INSERTED.Name,
              @Country = INSERTED.Country       
       FROM INSERTED
 
       IF UPDATE(CustomerId)
       BEGIN
              RAISERROR('CustomerId cannot be updated.', 16 ,1)
              ROLLBACK
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'CustomerId cannot be updated.')
       END
       ELSE
       BEGIN
              UPDATE Customers
              SET Name = @Name,
              Country = @Country
              WHERE CustomerId = @CustomerId
 
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'InsteadOf Update')
       END
END
--------------------

-- The purpose of this trigger is to monitor every insert for the abbreviation ‘Ave’ 
-- and replace it with the full word ‘Avenue’.
Use AdventureWorks2014
GO
DISABLE TRIGGER Person.uAddress ON Person.Address;
GO
DISABLE TRIGGER safety ON DATABASE;
GO

IF OBJECT_ID('Person.Direcciones','U') is not Null
DROP TABLE Person.Direcciones
GO
SELECT [AddressLine1],[City],[StateProvinceID],[PostalCode]
INTO Person.Direcciones
FROM Person.Address
GO
SELECT * FROM Person.Direcciones
GO
IF OBJECT_ID('tr_Direcciones','TR') is not Null
DROP TRIGGER tr_Direcciones
GO
CREATE TRIGGER tr_Direcciones
ON Person.Direcciones
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS
		(
		SELECT AddressLine1
		FROM Inserted
		WHERE RIGHT(AddressLine1, 3) = 'Ave'
		)
		INSERT INTO Person.Direcciones
			(AddressLine1, City, StateProvinceID, PostalCode)
			SELECT REPLACE(AddressLine1	, 'Ave', 'Avenue'), City, StateProvinceID, PostalCode
			FROM Inserted;
	ELSE
		INSERT INTO Person.Direcciones
			(AddressLine1, City, StateProvinceID, PostalCode)
			SELECT AddressLine1, City, StateProvinceID, PostalCode
			FROM Inserted;
END
GO


--The first two beginning lines are identical to the previous example where we give the trigger a name and specify what table it should monitor. Next, we use the “Instead of Insert” key phrase so our trigger will fire prior to the new row being inserted. The “If Exists” statement looks for the abbreviation “Ave” at the end the new row to be inserted. If it exists, we replace it with the word “Avenue”, if it doesn’t exist, we’ll just insert what was entered.
--Next we’ll insert a record containing the “Ave” abbreviation. 
INSERT INTO Person.Direcciones	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES	('Honduras Ave', 'city3', 79, '33333')
GO
INSERT INTO Person.Direcciones	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES	('Perez Ave', 'city3', 79, '44444');
GO	
INSERT INTO Person.Direcciones	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES	('Juan florez', 'city3', 79, '55555');
GO	
-- The new trigger didn’t utilize the Test table we created, so instead we’ll select directly from the Person.Address table to verify the trigger worked successfully.

-- Avenue por Ave
SELECT AddressLine1
FROM Person.Direcciones
WHERE PostalCode = '33333';
GO
SELECT AddressLine1
FROM Person.Direcciones
WHERE PostalCode = '44444'
GO
-- Sin Cambio
SELECT AddressLine1
FROM Person.Direcciones
WHERE PostalCode = '55555'
GO

---------------------------
use AdventureWorks2014
go
select * from Production.ProductInventory
go
select ProductID,LocationID,Quantity
from Production.ProductInventory
WHERE ProductID = 1
  AND LocationID = 1
 go
CREATE TRIGGER Production.ProductIsRationed
   ON Production.ProductInventory
   FOR UPDATE
AS
   IF EXISTS 
      (
       SELECT 'True' 
       FROM Inserted i JOIN Deleted d
          ON i.ProductID = d.ProductID
             AND i.LocationID = d.LocationID
       WHERE ((d.Quantity - i.Quantity) > d.Quantity / 2)
          --AND (d.Quantity – i.Quantity > 0)
      )
   BEGIN
      RAISERROR('Cannot reduce stock by more than 50%% at once.',16,1)
      ROLLBACK TRAN
   END
   go

UPDATE Production.ProductInventory
SET Quantity = 1 -- Was 408 if you want to set it back
WHERE ProductID = 1
  AND LocationID = 1
  
  
  -----------------------
  
  create TRIGGER Production.ProductIsRationed2
   ON Production.ProductInventory
   FOR UPDATE
AS
   IF UPDATE(Quantity)
   BEGIN
     IF EXISTS 
      (
       SELECT 'True' 
       FROM Inserted i
       JOIN Deleted d
        ON i.ProductID = d.ProductID
       AND i.LocationID = d.LocationID
       WHERE (d.Quantity - i.Quantity) > d.Quantity / 2
        AND d.Quantity > 0
      )
     BEGIN
      RAISERROR('Cannot reduce stock by more than 50%% at once.',16,1)
      ROLLBACK TRAN
     END
  END
GO


BEGIN TRAN
  -- This one should work
  UPDATE Production.ProductInventory
  SET Quantity = 400  -- Was 408 if you want to set it back
  WHERE ProductID = 1
    AND LocationID = 1
  
  -- This one shouldn't
  UPDATE Production.ProductInventory
  SET Quantity = 1  -- Was 408 if you want to set it back
  WHERE ProductID = 1
    AND LocationID = 1
IF @@TRANCOUNT > 0
  ROLLBACK TRAN

  ----------------------------
USE master ;
CREATE DATABASE Triggers_Test;
USE Triggers_Test;
CREATE TABLE tb_Productos (
		idProducto int identity primary key,
		Nombre varchar(50) null,
		Precio int null);
		
CREATE TABLE tb_Productos_Audit_Insert (
		idProducto int primary key,
		Nombre varchar(50) null,
		Precio int null,
		Accion nvarchar(10) null,
		Fecha_accion datetime null);
GO	


INSERT INTO dbo.tb_Productos
		VALUES (N'Cocacola',N'5'),
				(N'Pepsi',N'4'),
				(N'Mirinda',N'3'),
				(N'Manaos',N'4'),
				(N'Paso de toros',N'3'),
				(N'Fanta',N'1'),
				(N'Seven up',N'4'),
				(N'Sprite',N'5');
GO				
IF OBJECT_ID ('[tg_Productos_Audit_Insert]', 'TR') IS NOT NULL
   DROP TRIGGER [tg_Productos_Audit_Insert]
GO				

				
CREATE TRIGGER [dbo]. [tg_Productos_Audit_Insert]  
ON [dbo].[tb_Productos] 
FOR INSERT  
AS 
DECLARE @now datetime 
DECLARE @accion nvarchar(10) 
BEGIN TRY 
	SET @now = getdate() 
	SET @accion = 'INSERTED' 
	INSERT INTO [dbo].[tb_Productos_Audit_Insert] 
			(idProducto, Nombre, Precio, Accion, Fecha_Accion) 
	SELECT INSERTED.idProducto, INSERTED.Nombre, INSERTED.Precio, @accion, @now 
		FROM INSERTED 
END TRY 
BEGIN CATCH 
	ROLLBACK TRANSACTION 
	RAISERROR ('HUBO UN ERROR SOBRE LA INSERCION DE LA TABLA AUDITORA DE PRODUTOS',16,1) 
END CATCH 
GO

SELECT * FROM tb_Productos;
			--------1	Cocacola		5
			--------2	Pepsi			4
			--------3	Mirinda			3
			--------4	Manaos			4
			--------5	Paso de toros	3
			--------6	Fanta			1
			--------7	Seven up		4
			--------8	Sprite			5	
			
SELECT * FROM tb_Productos_Audit_Insert;	
--No devuelve nada


--Hacemos insert para comprobar
INSERT INTO dbo.tb_Productos
		VALUES (N'Cocacola Zero',N'7'),
				(N'Pepsi Max',N'2');
GO		

--Hacemos select para comprobar
SELECT * FROM tb_Productos;
----------1		Cocacola		5
----------2		Pepsi			4
----------3		Mirinda			3
----------4		Manaos			4
----------5		Paso de toros	3
----------6		Fanta			1
----------7		Seven up		4
----------8		Sprite			5
----------21	Cocacola Zero	7
----------22	Pepsi Max		2

SELECT * FROM tb_Productos_Audit_Insert;
----------21	Cocacola Zero	7	INSERTED	2013-05-21 20:11:37.570
----------22	Pepsi Max		2	INSERTED	2013-05-21 20:11:37.570

----------------------
-- ClassRoom 
-- Dos Partes 
-- Primero para controlar las operaciones de Insertar y Borrar
--Crear una tabla auditoría para la tabla ProductInventory de AdventureWorks2014
--en la que se almacenarán los registros insertados y borrados más una columna
--que nos diga el tipo de registro 'I' para insertados y 'D'para borrados


--
USE AdventureWorks2014;
GO
IF OBJECT_ID('Production.ProductInventoryAudit','U') is not null
DROP TABLE Production.ProductInventoryAudit
GO
CREATE TABLE Production.ProductInventoryAudit (
		ProductID int not null,
		LocationID smallint not null,
		Shelf nvarchar(10) not null,
		Bin tinyint not null,
		Quantity smallint not null,
		rowguid uniqueidentifier not null,
		ModifiedDate date DEFAULT GETDATE() ,
		InsertOrDelete char(1) not null
			check (InsertOrDelete in('I','D')));
GO
SELECT * 
FROM Production.ProductInventoryAudit
GO
IF OBJECT_ID('Production.Inventario','U') is not null
DROP TABLE Production.Inventario
GO
SELECT *
INTO Production.Inventario
FROM Production.ProductInventory
GO
SELECT * 
FROM Production.Inventario
GO
-- Start Trigger
IF OBJECT_ID ('Production.trg_id_ProductionInventoryAudit', 'TR') IS NOT NULL
   DROP TRIGGER Production.trg_id_ProductionInventoryAudit
GO
CREATE TRIGGER Production.trg_id_ProductionInventoryAudit
ON Production.Inventario
FOR INSERT,DELETE
AS
	BEGIN
		set nocount on; --Para que no aparezca el recuento de filas (para no perder tiempo en ejecución)
		Insert Production.ProductInventoryAudit (ProductID,LocationID,Shelf,Bin,Quantity,rowguid,ModifiedDate,InsertOrDelete)
			select distinct i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity, i.rowguid, GETDATE(), 'I'
			from inserted AS i
		union
			select distinct d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity, d.rowguid, GETDATE(), 'D'
			from deleted AS d;
	END
GO
-- END Trigger
--Hacemos un select para probar
select * 
from Production.Inventario
--Devuelve 1069 filas

--Insertamos un registro
Insert Production.Inventario (ProductID,LocationID,Shelf,Bin,Quantity,[rowguid],ModifiedDate)
	Values (450,2,'A',4,22,NEWID(),GETDATE());
GO
select * 
from Production.ProductInventoryAudit;
GO
--Devuelve:
----------450	2	A	4	22	1B2B82B1-85D6-49B4-9895-0706FBE6EE6F	2013-05-21 20:47:10.183	 I

--Borramos ese mismo registro
delete Production.Inventario
	where ProductID = 450 and LocationID = 2;
GO

--Haciendo un select
select * 
from Production.ProductInventoryAudit
GO	
--Devuelve:
------450	2	A	4	22	1B2B82B1-85D6-49B4-9895-0706FBE6EE6F	2013-05-21 20:47:10.183	 I
------450	2	A	4	22	1B2B82B1-85D6-49B4-9895-0706FBE6EE6F	2013-05-21 20:49:41.290	 D
select * 
from Production.Inventario
where ProductID = 450 and LocationID = 2;
GO	
select * 
from Production.Inventario
-- where ProductID = 450 and LocationID = 2;
GO

-----------------------------------------------------------------------------------------------
-- Completo
-- Vamos a añadir dos restricciones al trigger anterior:
--  a)Que no nos deje insertar elementos en la shelf 'Á' por Control Stocks
--  b)Que no nos deje borrar artículos con cantidad mayor que cero

USE AdventureWorks2014;
GO
IF OBJECT_ID('Production.ProductInventoryAudit','U') is not null
DROP TABLE Production.ProductInventoryAudit
GO
CREATE TABLE Production.ProductInventoryAudit (
		ProductID int not null,
		LocationID smallint not null,
		Shelf nvarchar(10) not null,
		Bin tinyint not null,
		Quantity smallint not null,
		rowguid uniqueidentifier not null,
		ModifiedDate date DEFAULT GETDATE() ,
		InsertOrDelete char(1) not null
			check (InsertOrDelete in('I','D')));
GO
SELECT * 
FROM Production.ProductInventoryAudit
GO
IF OBJECT_ID('Production.Inventario','U') is not null
DROP TABLE Production.Inventario
GO
SELECT *
INTO Production.Inventario
FROM Production.ProductInventory
GO
SELECT * 
FROM Production.Inventario
GO
-- Start Trigger
IF OBJECT_ID ('Production.trg_uid_ProductInventoryAudit', 'TR') IS NOT NULL
   DROP TRIGGER Production.trg_uid_ProductInventoryAudit
GO
CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.Inventario
AFTER INSERT, DELETE
AS
SET NOCOUNT ON
-- Si intenta Insertar en la Estanteria A no lo permite
IF EXISTS
	(SELECT Shelf
	FROM inserted
	WHERE Shelf = 'A')
			BEGIN
			PRINT 'Shelf ''A'' is closed for new inventory.'
			ROLLBACK
			RETURN
	END
-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,rowguid, ModifiedDate,InsertOrDelete )
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,rowguid, ModifiedDate, InsertOrDelete)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,d.rowguid, GETDATE(), 'D'
FROM deleted d

-- Intentando borrar un articulo que tiene Existencias
IF EXISTS
		(SELECT Quantity
		FROM deleted
		WHERE Quantity > 0)
				BEGIN
				PRINT 'You cannot remove positive quantity rows!'
				ROLLBACK
				RETURN
				END
GO
-- End Trigger

-- Try Out
-- Shelf A B C

-- OK
Insert Production.Inventario (ProductID,LocationID,Shelf,Bin,Quantity,[rowguid],ModifiedDate)
	Values (555,2,'C',4,22,NEWID(),GETDATE());
GO
select * 
from Production.ProductInventoryAudit;
GO

--ProductID	LocationID	Shelf	Bin	Quantity	rowguid	ModifiedDate	InsertOrDelete
--555	2	C	4	22	EE3FFF90-17F2-4848-A5F0-44651ADACFBD	2016-05-24	I


select * 
from Production.Inventario
where ProductID = 555 and LocationID = 2;
GO

--ProductID	LocationID	Shelf	Bin	Quantity	rowguid	ModifiedDate
--555	2	C	4	22	EE3FFF90-17F2-4848-A5F0-44651ADACFBD	2016-05-24 10:21:44.160

-- No Permite
Insert Production.Inventario (ProductID,LocationID,Shelf,Bin,Quantity,[rowguid],ModifiedDate)
	Values (450,2,'A',4,22,NEWID(),GETDATE());
GO

--Shelf 'A' is closed for new inventory.
--Msg 3609, Level 16, State 1, Line 944
--The transaction ended in the trigger. The batch has been aborted.

-- No Inserta en tabla Auditoria
select * 
from Production.ProductInventoryAudit;
GO

-- Probando borrado
-- Falla porque tiene Unidades en stock
delete Production.Inventario
	where ProductID = 555 and LocationID = 2
GO

--You cannot remove positive quantity rows!
--Msg 3609, Level 16, State 1, Line 958
--The transaction ended in the trigger. The batch has been aborted.

-- Pongo cantidad a 0
UPDATE Production.Inventario
SET Quantity = 0
WHERE ProductID = 555 and LocationID = 2
GO
-- (1 row(s) affected)

-- Funciona
DELETE Production.Inventario
WHERE ProductID = 555 and LocationID = 2
GO

-- (1 row(s) affected)


-- Comprobando
select * 
from Production.ProductInventoryAudit
GO	


--ProductID	LocationID	Shelf	Bin	Quantity	rowguid	ModifiedDate	InsertOrDelete
--555	2	C	4	22	EE3FFF90-17F2-4848-A5F0-44651ADACFBD	2016-05-24	I
--555	2	C	4	0	EE3FFF90-17F2-4848-A5F0-44651ADACFBD	2016-05-24	D


SELECT * FROM Production.Inventario
WHERE ProductID = 555 and LocationID = 2
GO

-- No existe ya

------------------------------------------------

-----------------
create trigger Production.trg_controles_ProductionInventory
on Production.ProductInventory
for insert, delete
as
	begin
		set nocount on; --Para que no aparezca el recuento de filas (para no perder tiempo)
		if exists (select * from inserted where inserted.Shelf='A')
			begin
				raiserror ('No queda espacio en la estantería A ',16,3);
				rollback
			end
			
		if exists (select * from deleted where Quantity > 0)
			begin
				raiserror ('No puedes borrar este artículo, porque aún hay unidades en almacén ',16,3);
				rollback
			end
	end;
go

--Insertamos un registro
Insert Production.ProductInventory (ProductID,LocationID,Shelf,Bin,Quantity)
	Values (450,2,'A',4,22);
----------Msg 50000, Level 16, State 3, Procedure trg_controles_ProductionInventory, Line 9
----------No queda espacio en la estantería A 
----------Msg 3609, Level 16, State 1, Line 1
----------The transaction ended in the trigger. The batch has been aborted.

Insert Production.ProductInventory (ProductID,LocationID,Shelf,Bin,Quantity)
	Values (450,2,'B',4,22);
------------(1 row(s) affected)

--Intentamos borrar el registro insertado
delete Production.ProductInventory 
	where ProductID = 450 and LocationID = 2;

--------Msg 50000, Level 16, State 3, Procedure trg_controles_ProductionInventory, Line 15
--------No puedes borrar este artículo, porque aún hay unidades en almacén 
--------Msg 3609, Level 16, State 1, Line 1
--------The transaction ended in the trigger. The batch has been aborted.

--Deshabilitamos el trigger para borrar el registro
DISABLE TRIGGER Production.trg_controles_ProductionInventory ON Production.ProductInventory;

delete Production.ProductInventory 
	where ProductID = 450 and LocationID = 2;
----------------(1 row(s) affected)

--Habilitamos el trigger de nuevo
ENABLE TRIGGER Production.trg_controles_ProductionInventory ON Production.ProductInventory;
--------------------

use AdventureWorks2014
go
select * from Production.ProductInventory
go
select ProductID,LocationID,Quantity
from Production.ProductInventory
WHERE ProductID = 1
  AND LocationID = 1
 go
CREATE TRIGGER Production.ProductIsRationed
   ON Production.ProductInventory
   FOR UPDATE
AS
   IF EXISTS 
      (
       SELECT 'True' 
       FROM Inserted i JOIN Deleted d
          ON i.ProductID = d.ProductID
             AND i.LocationID = d.LocationID
       WHERE ((d.Quantity - i.Quantity) > d.Quantity / 2)
          --AND (d.Quantity – i.Quantity > 0)
      )
   BEGIN
      RAISERROR('Cannot reduce stock by more than 50%% at once.',16,1)
      ROLLBACK TRAN
   END
   go

UPDATE Production.ProductInventory
SET Quantity = 1 -- Was 408 if you want to set it back
WHERE ProductID = 1
  AND LocationID = 1
  
  
  -----------------------
  
  create TRIGGER Production.ProductIsRationed2
   ON Production.ProductInventory
   FOR UPDATE
AS
   IF UPDATE(Quantity)
   BEGIN
     IF EXISTS 
      (
       SELECT 'True' 
       FROM Inserted i
       JOIN Deleted d
        ON i.ProductID = d.ProductID
       AND i.LocationID = d.LocationID
       WHERE (d.Quantity - i.Quantity) > d.Quantity / 2
        AND d.Quantity > 0
      )
     BEGIN
      RAISERROR('Cannot reduce stock by more than 50%% at once.',16,1)
      ROLLBACK TRAN
     END
  END



BEGIN TRAN
  -- This one should work
  UPDATE Production.ProductInventory
  SET Quantity = 400  -- Was 408 if you want to set it back
  WHERE ProductID = 1
    AND LocationID = 1
  
  -- This one shouldn't
  UPDATE Production.ProductInventory
  SET Quantity = 1  -- Was 408 if you want to set it back
  WHERE ProductID = 1
    AND LocationID = 1
IF @@TRANCOUNT > 0
  ROLLBACK TRAN
  
  ----------------------
  
  -- Track all Inserts, Updates, and Deletes
CREATE TABLE Production.ProductInventoryAudit
(ProductID int NOT NULL ,
LocationID smallint NOT NULL ,
Shelf nvarchar(10) NOT NULL ,
Bin tinyint NOT NULL ,
Quantity smallint NOT NULL ,
rowguid uniqueidentifier NOT NULL ,
ModifiedDate datetime NOT NULL ,
InsOrUPD char(1) NOT NULL )
GO

-- Create trigger to populate Production.ProductInventoryAudit table
CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.ProductInventory
AFTER INSERT, DELETE
AS
SET NOCOUNT ON

-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,
i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,
d.rowguid, GETDATE(), 'D'
FROM deleted d

GO

-- Insert a new row
INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'A', 4, 22)

-- Delete a row
DELETE Production.ProductInventory
WHERE ProductID = 316 AND
LocationID = 6

-- Check the audit table
SELECT ProductID, LocationID, InsOrUpd
FROM Production.ProductInventoryAudit


--------------------

-- Handling Transactions Within DML Triggers

USE AdventureWorks2014
GO
-- Remove trigger if one already exists with same name
IF EXISTS
(SELECT 1
FROM sys.triggers
WHERE object_id =
OBJECT_ID(N'[Production].[trg_uid_ProductInventoryAudit]'))
DROP TRIGGER [Production].[trg_uid_ProductInventoryAudit]
GO

CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.ProductInventory
AFTER INSERT, DELETE
AS
SET NOCOUNT ON

IF EXISTS
(SELECT Shelf
FROM inserted
WHERE Shelf = 'A')
BEGIN
PRINT 'Shelf ''A'' is closed for new inventory.'
ROLLBACK
END

-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,
i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,
d.rowguid, GETDATE(), 'D'
FROM deleted d

IF EXISTS
(SELECT Quantity
FROM deleted
WHERE Quantity > 0)
BEGIN
PRINT 'You cannot remove positive quantity rows!'
ROLLBACK
END
GO

INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'A', 4, 22)

BEGIN TRANSACTION

-- Deleting a row with a zero quantity
DELETE Production.ProductInventory
WHERE ProductID = 853 AND
LocationID = 7

-- Deleting a row with a non-zero quantity
DELETE Production.ProductInventory
WHERE ProductID = 999 AND
LocationID = 60

COMMIT TRANSACTION

SELECT ProductID, LocationID
FROM Production.ProductInventory
WHERE (ProductID = 853 AND
LocationID = 7) OR
(ProductID = 999 AND
LocationID = 60)


-------------------------

-- Creating a DDL Trigger That Audits Server-Level Events

USE master
GO

-- Disallow new Logins on the SQL instance
CREATE TRIGGER srv_trg_RestrictNewLogins
ON ALL SERVER
FOR CREATE_LOGIN
AS
PRINT 'No login creations without DBA involvement.'
ROLLBACK
GO

CREATE LOGIN JoeS WITH PASSWORD = 'A235921'
GO

DROP TRIGGER srv_trg_RestrictNewLogins
ON ALL SERVER

-------------------

-- Enabling and Disabling Table Triggers

USE AdventureWorks2014
GO

CREATE TRIGGER HumanResources.trg_Department
ON HumanResources.Department
AFTER INSERT
AS
PRINT 'The trg_Department trigger was fired'
GO

DISABLE TRIGGER HumanResources.trg_Department
ON HumanResources.Department

INSERT HumanResources.Department
(Name, GroupName)
VALUES ('Construction', 'Building Services')
GO
ENABLE TRIGGER HumanResources.trg_Department
ON HumanResources.Department
GO
INSERT HumanResources.Department
(Name, GroupName)
VALUES ('Cleaning', 'Building Services')
GO
--------------
use tempdb
go
if object_id('empleados') is not null
  drop table empleados;

 create table empleados(
  documento char(8) not null,
  nombre varchar(30) not null,
  domicilio varchar(30),
  seccion varchar(20),
  constraint PK_empleados primary key(documento),
 );

 insert into empleados values('22222222','Ana Acosta','Bulnes 56','Secretaria');
 insert into empleados values('23333333','Bernardo Bustos','Bulnes 188','Contaduria');
 insert into empleados values('24444444','Carlos Caseres','Caseros 364','Sistemas');
 insert into empleados values('25555555','Diana Duarte','Colon 1234','Sistemas');
 insert into empleados values('26666666','Diana Duarte','Colon 897','Sistemas');
 insert into empleados values('27777777','Matilda Morales','Colon 542','Gerencia');

 create trigger dis_empleados_borrar
  on empleados
  for delete
 as
  if (select count(*) from deleted)>1
  begin
    raiserror('No puede eliminar más de un 1 empleado', 16, 1)
    rollback transaction
  end;

 create trigger dis_empleados_actualizar
  on empleados
  for update
 as
  if update(documento)
  begin
    raiserror('No puede modificar el documento de los empleados', 16, 1)
    rollback transaction
  end;

 create trigger dis_empleados_insertar
  on empleados
  for insert
 as
  if (select seccion from inserted)='Gerencia'
  begin
    raiserror('No puede ingresar empleados en la sección "Gerencia".', 16, 1)
    rollback transaction
  end;

 delete from empleados where domicilio like 'Bulnes%';

  alter table empleados
  disable trigger dis_empleados_borrar;

 delete from empleados where domicilio like 'Bulnes%';

 select *from empleados;

 update empleados set documento='23030303' where documento='23333333';

 insert into empleados values('28888888','Juan Juarez','Jamaica 123','Gerencia');

 alter table empleados
  disable trigger dis_empleados_actualizar, dis_empleados_insertar;

 update empleados set documento='20000444' where documento='24444444';

 select *from empleados;

 insert into empleados values('28888888','Juan Juarez','Jamaica 123','Gerencia');

 select *from empleados;

 alter table empleados
  enable trigger all;

 update empleados set documento='30000000' where documento='28888888';
 
 
 -------------------------
 
 -- Creating an INSTEAD OF DML Trigger

USE AdventureWorks2014
GO
select * from HumanResources.Department
-- Create Department "Approval" table
CREATE TABLE HumanResources.DepartmentApproval
(Name nvarchar(50) NOT NULL UNIQUE,
GroupName nvarchar(50) NOT NULL,
ModifiedDate datetime NOT NULL DEFAULT GETDATE())
GO

-- Create view to see both approved and pending approval departments
CREATE VIEW HumanResources.vw_Department
AS
SELECT Name, GroupName, ModifiedDate, 'Approved' Status
FROM HumanResources.Department
UNION
SELECT Name, GroupName, ModifiedDate, 'Pending Approval' Status
FROM HumanResources.DepartmentApproval
GO
select * from HumanResources.vw_Department
-- Create an INSTEAD OF trigger on the new view
CREATE TRIGGER HumanResources.trg_vw_Department
ON HumanResources.vw_Department
INSTEAD OF INSERT
AS
INSERT HumanResources.DepartmentApproval(Name, GroupName)
SELECT i.Name, i.GroupName
FROM inserted i
WHERE i.Name NOT IN (SELECT Name FROM HumanResources.DepartmentApproval)
GO

-- Insert into the new view, even though view is a UNION
-- of two different tables
INSERT HumanResources.vw_Department(Name, GroupName)
VALUES ('Print Production', 'Manufacturing')

-- Check the view's contents
SELECT Status, Name
FROM HumanResources.vw_Department
WHERE GroupName = 'Manufacturing'

------------------------
-- Auditoria Inventario


USE AdventureWorks2014
GO
-- crear tabla Auditoria Inventario
IF OBJECT_ID('Production.ProductInventoryAudit','U') is not null
Drop table Production.ProductInventoryAudit
go
CREATE TABLE Production.ProductInventoryAudit
(ProductID int NOT NULL ,
LocationID smallint NOT NULL ,
Shelf nvarchar(10) NOT NULL ,
Bin tinyint NOT NULL ,
Quantity smallint NOT NULL ,
rowguid uniqueidentifier NOT NULL ,
ModifiedDate datetime NOT NULL ,
InsOrUPD char(1) NOT NULL )
GO
--
select * from Production.ProductInventory
go


-- Borrar Trigger si ya existe
IF EXISTS
(SELECT 1
FROM sys.triggers
WHERE object_id = OBJECT_ID('[Production].[trg_uid_ProductInventoryAudit]'))
DROP TRIGGER [Production].[trg_uid_ProductInventoryAudit]
GO
-- Trigger 
-- Evita Insertar en Estanteria A y borrar articulos con existencias

CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.ProductInventory
AFTER INSERT, DELETE
AS
IF EXISTS
(SELECT Shelf
FROM inserted
WHERE Shelf = 'A')
BEGIN
PRINT 'Estanteria ''A'' cerrada por Inventario.'
ROLLBACK
END

-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,
i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,rowguid, ModifiedDate, InsOrUPD)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,d.rowguid, GETDATE(), 'D'
FROM deleted d

IF EXISTS
(SELECT Quantity FROM deleted WHERE Quantity > 0)
BEGIN
PRINT 'Hay Unidades en Stocks no puedes borrar!'
ROLLBACK
END
GO
-- Fin Trigger

-- Probando Trigger provoco el error
-- Estanteria 'A' cerrada por Inventario.

INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'A', 4, 22)

-- Deja Insertar

INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'N/A', 4, 22)
-- Probando Trigger provoco el error

select * from Production.ProductInventory
WHERE Quantity=0


BEGIN TRANSACTION

-- Borrando una Fila con cantidad = 0
-- lo Hace
DELETE Production.ProductInventory
WHERE ProductID = 853 AND LocationID = 7

DELETE Production.ProductInventory
WHERE ProductID = 882 AND LocationID = 7


-- Intenta Borrar una Fila con cantidad distinta de 0
-- error Hay Unidades en Stocks no puedes borrar!
DELETE Production.ProductInventory
WHERE ProductID = 999 AND LocationID = 60

COMMIT TRANSACTION

-- Comprobación de operaciones

SELECT ProductID, LocationID
FROM Production.ProductInventory
WHERE (ProductID = 853 AND LocationID = 7) OR
(ProductID = 999 AND LocationID = 60)

-- Tabla Auditoria

Select * 
from Production.ProductInventoryAudit







  
  ----------------------
  
  -- Track all Inserts, Updates, and Deletes
CREATE TABLE Production.ProductInventoryAudit
(ProductID int NOT NULL ,
LocationID smallint NOT NULL ,
Shelf nvarchar(10) NOT NULL ,
Bin tinyint NOT NULL ,
Quantity smallint NOT NULL ,
rowguid uniqueidentifier NOT NULL ,
ModifiedDate datetime NOT NULL ,
InsOrUPD char(1) NOT NULL )
GO

-- Create trigger to populate Production.ProductInventoryAudit table
CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.ProductInventory
AFTER INSERT, DELETE
AS
SET NOCOUNT ON

-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,
i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,
d.rowguid, GETDATE(), 'D'
FROM deleted d

GO

-- Insert a new row
INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'A', 4, 22)

-- Delete a row
DELETE Production.ProductInventory
WHERE ProductID = 316 AND
LocationID = 6

-- Check the audit table
SELECT ProductID, LocationID, InsOrUpd
FROM Production.ProductInventoryAudit


--------------------

-- Handling TransactionsWithin DML Triggers

USE AdventureWorks2014
GO
-- Remove trigger if one already exists with same name
IF EXISTS
(SELECT 1
FROM sys.triggers
WHERE object_id =
OBJECT_ID(N'[Production].[trg_uid_ProductInventoryAudit]'))
DROP TRIGGER [Production].[trg_uid_ProductInventoryAudit]
GO

CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.ProductInventory
AFTER INSERT, DELETE
AS
SET NOCOUNT ON

IF EXISTS
(SELECT Shelf
FROM inserted
WHERE Shelf = 'A')
BEGIN
PRINT 'Shelf ''A'' is closed for new inventory.'
ROLLBACK
END

-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,
i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,
d.rowguid, GETDATE(), 'D'
FROM deleted d

IF EXISTS
(SELECT Quantity
FROM deleted
WHERE Quantity > 0)
BEGIN
PRINT 'You cannot remove positive quantity rows!'
ROLLBACK
END
GO

INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'A', 4, 22)

BEGIN TRANSACTION

-- Deleting a row with a zero quantity
DELETE Production.ProductInventory
WHERE ProductID = 853 AND
LocationID = 7

-- Deleting a row with a non-zero quantity
DELETE Production.ProductInventory
WHERE ProductID = 999 AND
LocationID = 60

COMMIT TRANSACTION

SELECT ProductID, LocationID
FROM Production.ProductInventory
WHERE (ProductID = 853 AND
LocationID = 7) OR
(ProductID = 999 AND
LocationID = 60)


-------------------------

-- Creating a DDL Trigger That Audits Server-Level Events

USE master
GO

-- Disallow new Logins on the SQL instance
CREATE TRIGGER srv_trg_RestrictNewLogins
ON ALL SERVER
FOR CREATE_LOGIN
AS
PRINT 'No login creations without DBA involvement.'
ROLLBACK
GO

CREATE LOGIN JoeS WITH PASSWORD = 'A235921'
GO

DROP TRIGGER srv_trg_RestrictNewLogins
ON ALL SERVER

-------------------

-- Enabling and Disabling Table Triggers

USE AdventureWorks2014
GO

CREATE TRIGGER HumanResources.trg_Department
ON HumanResources.Department
AFTER INSERT
AS
PRINT 'The trg_Department trigger was fired'
GO

DISABLE TRIGGER HumanResources.trg_Department
ON HumanResources.Department

INSERT HumanResources.Department
(Name, GroupName)
VALUES ('Construction', 'Building Services')

ENABLE TRIGGER HumanResources.trg_Department
ON HumanResources.Department

INSERT HumanResources.Department
(Name, GroupName)
VALUES ('Cleaning', 'Building Services')

--------------
use tempdb
go
if object_id('empleados') is not null
  drop table empleados;

 create table empleados(
  documento char(8) not null,
  nombre varchar(30) not null,
  domicilio varchar(30),
  seccion varchar(20),
  constraint PK_empleados primary key(documento),
 );

 insert into empleados values('22222222','Ana Acosta','Bulnes 56','Secretaria');
 insert into empleados values('23333333','Bernardo Bustos','Bulnes 188','Contaduria');
 insert into empleados values('24444444','Carlos Caseres','Caseros 364','Sistemas');
 insert into empleados values('25555555','Diana Duarte','Colon 1234','Sistemas');
 insert into empleados values('26666666','Diana Duarte','Colon 897','Sistemas');
 insert into empleados values('27777777','Matilda Morales','Colon 542','Gerencia');

 create trigger dis_empleados_borrar
  on empleados
  for delete
 as
  if (select count(*) from deleted)>1
  begin
    raiserror('No puede eliminar más de un 1 empleado', 16, 1)
    rollback transaction
  end;

 create trigger dis_empleados_actualizar
  on empleados
  for update
 as
  if update(documento)
  begin
    raiserror('No puede modificar el documento de los empleados', 16, 1)
    rollback transaction
  end;

 create trigger dis_empleados_insertar
  on empleados
  for insert
 as
  if (select seccion from inserted)='Gerencia'
  begin
    raiserror('No puede ingresar empleados en la sección "Gerencia".', 16, 1)
    rollback transaction
  end;

 delete from empleados where domicilio like 'Bulnes%';

  alter table empleados
  disable trigger dis_empleados_borrar;

 delete from empleados where domicilio like 'Bulnes%';

 select *from empleados;

 update empleados set documento='23030303' where documento='23333333';

 insert into empleados values('28888888','Juan Juarez','Jamaica 123','Gerencia');

 alter table empleados
  disable trigger dis_empleados_actualizar, dis_empleados_insertar;

 update empleados set documento='20000444' where documento='24444444';

 select *from empleados;

 insert into empleados values('28888888','Juan Juarez','Jamaica 123','Gerencia');

 select *from empleados;

 alter table empleados
  enable trigger all;

 update empleados set documento='30000000' where documento='28888888';
 
 
 -------------------------
 
 -- Creating an INSTEAD OF DML Trigger

USE AdventureWorks2014
GO
select * from HumanResources.Department
-- Create Department "Approval" table
CREATE TABLE HumanResources.DepartmentApproval
(Name nvarchar(50) NOT NULL UNIQUE,
GroupName nvarchar(50) NOT NULL,
ModifiedDate datetime NOT NULL DEFAULT GETDATE())
GO

-- Create view to see both approved and pending approval departments
CREATE VIEW HumanResources.vw_Department
AS
SELECT Name, GroupName, ModifiedDate, 'Approved' Status
FROM HumanResources.Department
UNION
SELECT Name, GroupName, ModifiedDate, 'Pending Approval' Status
FROM HumanResources.DepartmentApproval
GO
select * from HumanResources.vw_Department
-- Create an INSTEAD OF trigger on the new view
CREATE TRIGGER HumanResources.trg_vw_Department
ON HumanResources.vw_Department
INSTEAD OF INSERT
AS
INSERT HumanResources.DepartmentApproval(Name, GroupName)
SELECT i.Name, i.GroupName
FROM inserted i
WHERE i.Name NOT IN (SELECT Name FROM HumanResources.DepartmentApproval)
GO

-- Insert into the new view, even though view is a UNION
-- of two different tables
INSERT HumanResources.vw_Department(Name, GroupName)
VALUES ('Print Production', 'Manufacturing')

-- Check the view's contents
SELECT Status, Name
FROM HumanResources.vw_Department
WHERE GroupName = 'Manufacturing'

------------------------

USE AdventureWorks2014
GO
-- crear tabla Auditoria Inventario

CREATE TABLE Production.ProductInventoryAudit
(ProductID int NOT NULL ,
LocationID smallint NOT NULL ,
Shelf nvarchar(10) NOT NULL ,
Bin tinyint NOT NULL ,
Quantity smallint NOT NULL ,
rowguid uniqueidentifier NOT NULL ,
ModifiedDate datetime NOT NULL ,
InsOrUPD char(1) NOT NULL )
GO

-- Borrar Trigger si ya existe
IF EXISTS
(SELECT 1
FROM sys.triggers
WHERE object_id = OBJECT_ID(N'[Production].[trg_uid_ProductInventoryAudit]'))
DROP TRIGGER [Production].[trg_uid_ProductInventoryAudit]
GO
-- Trigger 
-- Evita Insertar en Estanteria A y borrar articulos con existencias

CREATE TRIGGER Production.trg_uid_ProductInventoryAudit
ON Production.ProductInventory
AFTER INSERT, DELETE
AS
IF EXISTS
(SELECT Shelf
FROM inserted
WHERE Shelf = 'A')
BEGIN
PRINT 'Estanteria ''A'' cerrada por Inventario.'
ROLLBACK
END

-- Inserted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,
rowguid, ModifiedDate, InsOrUPD)
SELECT DISTINCT i.ProductID, i.LocationID, i.Shelf, i.Bin, i.Quantity,
i.rowguid, GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT Production.ProductInventoryAudit
(ProductID, LocationID, Shelf, Bin, Quantity,rowguid, ModifiedDate, InsOrUPD)
SELECT d.ProductID, d.LocationID, d.Shelf, d.Bin, d.Quantity,d.rowguid, GETDATE(), 'D'
FROM deleted d

IF EXISTS
(SELECT Quantity FROM deleted WHERE Quantity > 0)
BEGIN
PRINT 'Hay Unidades en Stocks no puedes borrar!'
ROLLBACK
END
GO

INSERT Production.ProductInventory
(ProductID, LocationID, Shelf, Bin, Quantity)
VALUES (316, 6, 'A', 4, 22)

-- 
BEGIN TRANSACTION

-- Borrando una Fila con cantidad = 0
DELETE Production.ProductInventory
WHERE ProductID = 853 AND LocationID = 7

-- Borrando una Fila con cantidad distinta de 0
DELETE Production.ProductInventory
WHERE ProductID = 999 AND LocationID = 60

COMMIT TRANSACTION

-- Comprobación de operaciones

SELECT ProductID, LocationID
FROM Production.ProductInventory
WHERE (ProductID = 853 AND LocationID = 7) OR
(ProductID = 999 AND LocationID = 60)

-- Tabla Auditoria

Select * from Production.ProductInventoryAudit






---------------------------

Use AdventureWorks2014
go
drop table test
go
CREATE TABLE Test
(
 col1 varchar(50)
);


create TRIGGER control
ON Person.Address
AFTER INSERT
AS
INSERT INTO Test(col1)
VALUES 	('Control ')
go
-- Probar

INSERT INTO Person.Address
	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES
	('address1', 'city1', 79, '53169');

select * from Test

DISABLE TRIGGER control ON Person.Address;

ENABLE TRIGGER control ON Person.Address;
GO

--Inserted and Deleted Tables
--Triggers have access to two special tables that track deleted items and inserted items. The ‘Inserted’ and ‘Deleted’ tables are automatically managed by SQL Server. In this second example, we’ll capture the zip code inserted into the Person.Address table and copy it to our Test auditing table. Modify the trigger previously created to select the PostalCode from the Person.Address table as shown.
Use AdventureWorks2014
go
drop table test
go
CREATE TABLE Test
(
 col1 varchar(50)
);
ALTER TRIGGER Person.TestTrigger1
ON Person.Address
AFTER INSERT
AS
INSERT INTO Test(col1)
	SELECT PostalCode
	FROM Inserted;
--Insert a new record into the Person.Address table with a zip code of ‘22222’ 
--using the following TSQL:
INSERT INTO Person.Address
	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES
	('address2', 'city2', 79, '95597');
	
select * from Test
-- Now when we select from out Test table, two rows will be returned, 
--the origianl row ‘trigger fired’ and new row showing the zip code ‘22222’
 --from the inserted table.
DISABLE TRIGGER Person.TestTrigger1 ON Person.Address;

ENABLE TRIGGER Person.TestTrigger1 ON Person.Address;
GO
----------------

-- the purpose of this trigger is to monitor every insert for the abbreviation ‘Ave’ and replace it with the full word ‘Avenue’.
Use AdventureWorks2014
go

CREATE TRIGGER tr_Direccion
ON Person.Address
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS
		(
		SELECT AddressLine1
		FROM Inserted
		WHERE RIGHT(AddressLine1, 3) = 'Ave'
		)
		INSERT INTO Person.Address
			(AddressLine1, City, StateProvinceID, PostalCode)
			SELECT REPLACE(AddressLine1	, 'Ave', 'Avenue'), City, StateProvinceID, PostalCode
			FROM Inserted;
	ELSE
		INSERT INTO Person.Address
			(AddressLine1, City, StateProvinceID, PostalCode)
			SELECT AddressLine1, City, StateProvinceID, PostalCode
			FROM Inserted;
END;


--The first two beginning lines are identical to the previous example where we give the trigger a name and specify what table it should monitor. Next, we use the “Instead of Insert” key phrase so our trigger will fire prior to the new row being inserted. The “If Exists” statement looks for the abbreviation “Ave” at the end the new row to be inserted. If it exists, we replace it with the word “Avenue”, if it doesn’t exist, we’ll just insert what was entered.
--Next we’ll insert a record containing the “Ave” abbreviation. 
INSERT INTO Person.Address
	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES
	('address3 Ave', 'city3', 79, '33333');


INSERT INTO Person.Address
	(AddressLine1, City, StateProvinceID, PostalCode)
VALUES
	('Perez Ave', 'city3', 79, '44444');
		
-- The new trigger didn’t utilize the Test table we created, so instead we’ll select directly from the Person.Address table to verify the trigger worked successfully.

SELECT AddressLine1
FROM Person.Address
WHERE PostalCode = '33333';

SELECT AddressLine1
FROM Person.Address
WHERE PostalCode = '44444';

DISABLE TRIGGER tr_Direccion ON Person.Address;

ENABLE TRIGGER tr_Direccion ON Person.Address;

---------------------------------

- Creamos una base de datos si no existiese.  
-- --------------------------------------------------------------------  
  
IF NOT EXISTS (SELECT * from sys.databases where name = 'db_test')  
BEGIN  
    CREATE DATABASE db_test;  
END  
  
-- Establecemos la  base de datos predeterminada  
USE db_test;  
  
  
-- --------------------------------------------------------------------  
-- Creamos una tabla si no existiese.  
-- Representa los datos de expedientes  
-- --------------------------------------------------------------------  
  
IF NOT EXISTS (SELECT * FROM sys.sysobjects WHERE name='expedientes' AND xtype='U')     
BEGIN    
    CREATE TABLE expedientes (     
      code             VARCHAR(15)  NOT NULL,  
      state            VARCHAR(20)  DEFAULT 'INICIO',  
      stateChangedDate DATETIME,  
      PRIMARY KEY (code)       
    );     
END;    
  
-- Insertamos algunos expedientes de ejemplo  
DELETE FROM expedientes WHERE code IN ('exp1','exp2', 'exp3');  
INSERT INTO expedientes (code) VALUES ('exp1');  
INSERT INTO expedientes (code) VALUES ('exp2');  
INSERT INTO expedientes (code) VALUES ('exp3');  
  
-- Si no existe la tabla de cambios de esstado la creamos  
IF NOT EXISTS (SELECT * FROM sys.sysobjects WHERE name='expStatusHistory' AND xtype='U')     
BEGIN    
    CREATE TABLE expStatusHistory (  
      id    INT         IDENTITY,  
      code  VARCHAR(15) NOT NULL,  
      state VARCHAR(20) NOT NULL,  
      date  DATETIME   DEFAULT GetDate(),  
      PRIMARY KEY  (id)  
    );  
END;  
  
  
-- Borramos el Trigger si existiese  
IF OBJECT_ID ('StatusChangeDateTrigger', 'TR') IS NOT NULL  
BEGIN  
   DROP TRIGGER StatusChangeDateTrigger;  
END;  
  
GO -- Necesario  
  
-- Cremamos un Trigger sobre la tabla expedientes  
CREATE TRIGGER StatusChangeDateTrigger  
ON expedientes  
 AFTER UPDATE 
AS   
 -- ¿Ha cambiado el estado?  
 IF UPDATE(state)  
 BEGIN  
    -- Actualizamos el campo stateChangedDate a la fecha/hora actual  
    UPDATE expedientes SET stateChangedDate=GetDate() WHERE code=(SELECT code FROM inserted);  
  
    -- A modo de auditoría, añadimos un registro en la tabla expStatusHistory  
    INSERT INTO expStatusHistory  (code, state) (SELECT code, state FROM deleted WHERE code=deleted.code);  
      
    -- La tabla deleted contiene información sobre los valores ANTIGUOS mientras que la tabla inserted contiene los NUEVOS valores.  
    -- Ambas tablas son virtuales y tienen la misma estructura que la tabla a la que se asocia el Trigger.   
 END; 


Probamos

UPDATE expedientes SET state='PENDIENTE_COBRO' WHERE code='exp1'  

---------------------------
-- Usar desencadenador DML con un mensaje de aviso
-- El siguiente desencadenador DML imprime un mensaje en el cliente cuando alguien intenta agregar o cambiar datos en la tabla Customer de la base de datos AdventureWorks201420142014.

IF OBJECT_ID ('Sales.reminder1', 'TR') IS NOT NULL
   DROP TRIGGER Sales.reminder1;
GO
CREATE TRIGGER reminder1
ON Sales.Customer
AFTER INSERT, UPDATE 
AS RAISERROR ('Notify Customer Relations', 16, 10);
GO
-----------------------------------------------------------------
--- Crear Tabla ejemplos aspsnippet

USE Tempdb
GO
CREATE TABLE [dbo].[Customers](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Country] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[CustomerLogs](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NOT NULL,
	[ACTION] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CustomerLogs] PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

INSERT INTO Customers
SELECT 'Ana', 'A Coruña'
UNION ALL
SELECT 'Luis', 'Pontevedra'
UNION ALL
SELECT 'Pablo', 'Ourense'
UNION ALL
SELECT 'Veronica', 'Lugo'
GO
SELECT * FROM [Customers]
GO

-- http://www.aspsnippets.com/Articles/Simple-Insert-Update-and-Delete-Triggers-in-SQL-Server-with-example.aspx
-- http://www.aspsnippets.com/Articles/SQL-Server-Get-Inserted-Updated-and-Deleted-Row-values-in-Insert-Update-and-Delete-Triggers.aspx
-- http://www.aspsnippets.com/Articles/SQL-Server-Insert-data-to-another-Table-using-Insert-Update-and-Delete-Triggers.aspx
-- http://www.aspsnippets.com/Articles/SQL-Server-Instead-Of-Delete-Trigger-Example.aspx


--Instead Of Delete Triggers

--Instead Of triggers are executed instead of any of the Insert, Update or Delete operations.
--For example consider an Instead of Trigger for Delete operation, whenever a Delete is performed the Trigger will be executed first and if the Trigger deletes record then only the record will be deleted.
--Below is an example of an Instead Of Delete Trigger.
-- Whenever anyone tries to delete a row from the Customers table the following trigger is executed.

-- Inside the Trigger, I have added a condition that if record has CustomerId value 2 then such a record 
-- must not be deleted and an error must be raised. Also a record is inserted in the CustomerLogs table.

--If the CustomerId value is not 2 then a delete query is executed which deletes the record permanently and a record is inserted in the CustomerLogs table.


CREATE TRIGGER [dbo].[Customer_InsteadOfDELETE]
       ON [dbo].[Customers]
INSTEAD OF DELETE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
 
       SELECT @CustomerId = DELETED.CustomerId       
       FROM DELETED
		-- No se puede borrar Cliente 2
       IF @CustomerId = 2
       BEGIN
              RAISERROR('Record cannot be deleted',16 ,1)
              ROLLBACK
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'Record cannot be deleted.')
       END
       ELSE
       BEGIN
              DELETE FROM Customers
              WHERE CustomerId = @CustomerId
 
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'Instead Of Delete')
       END
END
GO


CREATE PROC Probar_Instead_Delete
	@CustomerId INT
AS
		DELETE Customers
		WHERE CustomerId = @CustomerId
GO

EXEC Probar_Instead_Delete 3

-- Consultamos

SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO


EXEC Probar_Instead_Delete 2


--Mens 50000, Nivel 16, Estado 1, Procedimiento Customer_InsteadOfDELETE, Línea 15
--Record cannot be deleted
--Mens 3609, Nivel 16, Estado 1, Procedimiento Probar_Instead_Delete, Línea 4
--La transacción terminó en el desencadenador. Se anuló el lote.

--(2 filas afectadas)

-- Consultamos

SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO

DELETE Customers
GO
-- Consultamos

SELECT * FROM Customers
GO
SELECT * FROM CustomerLogs
GO

--LogId	CustomerId	ACTION
--1	3	Instead Of Delete
--2	2	Record cannot be deleted.
--3	4	Instead Of Delete
-------------------
-- INSTEAD OF INSERT

--Instead Of Insert Triggers
--These triggers are executed instead of any of the Insert, Update or Delete operations.
--For example consider an Instead of Trigger for Insert operation, whenever an Insert is performed the Trigger will be executed first and if the Trigger inserts record then only the record will be inserted.
--Below is an example of an Instead Of Insert Trigger. Whenever anyone tries to insert a row from the Customers table the following trigger is executed.
--Inside the Trigger, I have added a condition that if a record with the Name already exists then such a record must not be inserted and an error must be raised. Also a record is inserted in the CustomerLogs table.
--If a record with the Name does not exists in the table then an insert query is executed which inserts the record and a record is inserted in the CustomerLogs table.
CREATE TRIGGER [dbo].[Customer_InsteadOfINSERT]
       ON [dbo].[Customers]
INSTEAD OF INSERT
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT, @Name VARCHAR(50), @Country VARCHAR(50)
       DECLARE @Message VARCHAR(100)
 
       SELECT @CustomerId = INSERTED.CustomerId,
              @Name = INSERTED.Name,
              @Country = INSERTED.Country       
       FROM INSERTED
 
       IF (EXISTS(SELECT CustomerId FROM Customers WHERE Name = @Name))
       BEGIN
              SET @Message = 'Record with name ' + @Name + ' already exists.'
              RAISERROR(@Message, 16 ,1)
              ROLLBACK
       END
       ELSE
       BEGIN
              INSERT INTO Customers
              VALUES(@CustomerId, @Name, @Country)
 
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'InsteadOf Insert')
       END
END

-- INSTEAD OF UPDATE

--Instead Of Update Triggers
--These triggers are executed instead of any of the Insert, Update or Delete operations.
--For example consider an Instead of Trigger for Update operation, whenever an Update is performed the Trigger will be executed first and if the Trigger updates record then only the record will be updated.
---- Below is an example of an Instead Of Update Trigger. Whenever anyone tries to update a row from the Customers table the following trigger is executed.
--Inside the Trigger, I have added a condition that if the CustomerId column of the record is updated then such a record must not be updated and an error must be raised. Also a record is inserted in the CustomerLogs table.
--If any other column is updated then an update query is executed which updates the record and a record is inserted in the CustomerLogs table.


CREATE TRIGGER [dbo].[Customer_InsteadOfUPDATE]
       ON [dbo].[Customers]
INSTEAD OF UPDATE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT, @Name VARCHAR(50), @Country VARCHAR(50)
 
       SELECT @CustomerId = INSERTED.CustomerId,
              @Name = INSERTED.Name,
              @Country = INSERTED.Country       
       FROM INSERTED
 
       IF UPDATE(CustomerId)
       BEGIN
              RAISERROR('CustomerId cannot be updated.', 16 ,1)
              ROLLBACK
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'CustomerId cannot be updated.')
       END
       ELSE
       BEGIN
              UPDATE Customers
              SET Name = @Name,
              Country = @Country
              WHERE CustomerId = @CustomerId
 
              INSERT INTO CustomerLogs
              VALUES(@CustomerId, 'InsteadOf Update')
       END
END





-----------
-- http://www.aspsnippets.com/Articles/Simple-Insert-Update-and-Delete-Triggers-in-SQL-Server-with-example.aspx

CREATE TRIGGER [dbo].[Customer_INSERT]
       ON [dbo].[Customers]
AFTER INSERT
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
 
       SELECT @CustomerId = INSERTED.CustomerId       
       FROM INSERTED
 
       INSERT INTO CustomerLogs
       VALUES(@CustomerId, 'Inserted')
END

CREATE TRIGGER [dbo].[Customer_UPDATE]
       ON [dbo].[Customers]
AFTER UPDATE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
       DECLARE @Action VARCHAR(50)
 
       SELECT @CustomerId = INSERTED.CustomerId       
       FROM INSERTED
 
       IF UPDATE(Name)
       BEGIN
              SET @Action = 'Updated Name'
       END
 
       IF UPDATE(Country)
       BEGIN
              SET @Action = 'Updated Country'
       END
 
       INSERT INTO CustomerLogs
       VALUES(@CustomerId, @Action)
END

CREATE TRIGGER [dbo].[Customer_DELETE]
       ON [dbo].[Customers]
AFTER DELETE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @CustomerId INT
 
       SELECT @CustomerId = DELETED.CustomerId       
       FROM DELETED
 
       INSERT INTO CustomerLogs
       VALUES(@CustomerId, 'Deleted')
END

-----------------------
-- https://blogs.msdn.microsoft.com/mvpawardprogram/2014/12/22/sql-server-2014-dml-triggers-tips-tricks-from-the-field/

-- http://www.dataprix.com/blog-it/bases-datos/sql-server-auditoria-datos-personalizada-mediante-triggers

-- http://www.fincher.org/tips/General/SQL.shtml

---------------------------
-- Un ejemplo de triggers para el control de Stock
USE master
GO
IF EXISTS (SELECT NAME FROM sys.databases
           WHERE name = 'StockArticulos')
  BEGIN
    DROP DATABASE StockArticulos
  END
GO
CREATE DATABASE StockArticulos
GO
USE StockArticulos
GO

CREATE TABLE dbo.Articulos 
(ID INT PRIMARY KEY, 
NOMBRE VARCHAR(100),
STOCK DECIMAL (18,2))
GO

CREATE TABLE dbo.Movimientos 
(TRANSACCION INT,
FECHA DATE DEFAULT(GETDATE()),
ARTICULO_ID INT FOREIGN KEY
REFERENCES DBO.ARTICULOS(ID),
CANTIDAD DECIMAL(18,2), 
TIPO CHAR(1) CHECK (TIPO ='I' OR TIPO = 'O'))
GO
-- Insertamos registros a la tabla Articulos
INSERT INTO dbo.Articulos(ID,NOMBRE,STOCK) 
VALUES (1,'Monitores',0),
(2,'CPU',0),
(3,'Mouse',0)
GO

IF EXISTS (SELECT * FROM sys.triggers
    WHERE   name ='MovimientosInsert')
DROP TRIGGER MovimientosInsert ON DATABASE;
GO
-- Creamos los triggers para tener actualizado los articulos
CREATE TRIGGER dbo.MovimientosInsert 
ON dbo.Movimientos
FOR INSERT
AS
BEGIN
  -- No retorna el mensaje de cantidad de registros afectados
  SET NOCOUNT ON  
  UPDATE DBO.ARTICULOS
  SET STOCK = STOCK + T.PARCIAL
  FROM DBO.ARTICULOS A
  INNER JOIN
  ( SELECT ARTICULO_ID,    SUM(CASE 
						WHEN TIPO='I' THEN CANTIDAD 
						ELSE -CANTIDAD 
						END)    AS PARCIAL 
	FROM INSERTED
    GROUP BY ARTICULO_ID
   ) T
   ON   
   A.ID = T.ARTICULO_ID
END
GO

CREATE TRIGGER dbo.MovimientosDelete ON dbo.Movimientos
FOR DELETE
AS
BEGIN
  -- No retorna el mensaje de cantidad de registros afectados
  SET NOCOUNT ON 
  UPDATE dbo.Articulos
  SET STOCK = STOCK - T.PARCIAL
  FROM dbo.Articulos A
  INNER JOIN
  ( SELECT ARTICULO_ID,
    SUM(CASE WHEN TIPO='I' THEN CANTIDAD ELSE -CANTIDAD END)
    AS PARCIAL FROM DELETED
    GROUP BY ARTICULO_ID
   ) T
   ON   A.ID = T.ARTICULO_ID
END
GO

--— Probemos el ejercicio
--— Mostremos el Stock actual
SELECT A.ID,A.NOMBRE,A.STOCK 
FROM dbo.Articulos A
GO
-- Insertemos un registro para el articulo 1
INSERT INTO dbo.Movimientos (TRANSACCION,ARTICULO_ID,FECHA,CANTIDAD,TIPO)
VALUES (1,1,GETDATE(),100,'I')
GO
-- Mostremos el Stock actual para el ID 1
SELECT A.ID,A.NOMBRE,A.STOCK 
FROM dbo.Articulos A 
WHERE A.ID = 1
GO
-- Insertemos otros registros
INSERT INTO dbo.Movimientos (TRANSACCION,ARTICULO_ID,FECHA,CANTIDAD,TIPO)
VALUES (2,1,GETDATE(),10,'I'), (3,1,GETDATE(),5,'O'), (4,2,GETDATE(),5,'I')
GO
--Mostremos el Stock actual para el ID 1
SELECT A.ID,A.NOMBRE,A.STOCK 
FROM dbo.Articulos A 
WHERE A.ID = 1
GO
--Eliminemos la transaccion (1) de cantidad = 100
DELETE FROM dbo.Movimientos WHERE TRANSACCION = 1
GO
-- Eliminemos la transaccion (3) de cantidad = 5
DELETE FROM dbo.Movimientos WHERE TRANSACCION = 3
GO
-- Mostremos el stock actual de la tabla Articulos
SELECT A.ID,A.NOMBRE,A.STOCK 
FROM dbo.Articulos A
GO
-- Eliminamos todos los movimientos realizados
DELETE FROM dbo.Movimientos
GO
-- Deshabilitar los triggers
ALTER TABLE dbo.Movimientos DISABLE TRIGGER ALL
GO
--— Mostremos lo que pasa se insertamos un registro en la tabla
--— Movimientos que tiene deshabilitados los triggers
INSERT INTO dbo.Movimientos (TRANSACCION,ARTICULO_ID,FECHA,CANTIDAD,TIPO)
VALUES (1,1,GETDATE(),100,'I')
GO
-- Mostremos el stock actual de la tabla Articulos
SELECT A.ID,A.NOMBRE,A.STOCK FROM dbo.Articulos A
GO
-- USE Tempdb
-- GO
DROP DATABASE StockArticulos
GO

---------------------------------
--This example trigger prints a message to the client when anyone tries to add or change data in the titles table.
--Note  Message 50009 is a user-defined message in sysmessages. For more information about creating user-defined messages, see sp_addmessage.
USE pubs
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'reminder' AND type = 'TR')
   DROP TRIGGER reminder
GO
CREATE TRIGGER reminder
ON titles
FOR INSERT, UPDATE 
AS RAISERROR (50009, 16, 10)
GO
----------------------------

Use a trigger business rule between the employee and jobs tables
Because CHECK constraints can reference only the columns on which the column- or table-level constraint is defined, any cross-table constraints (in this case, business rules) must be defined as triggers.
This example creates a trigger that, when an employee job level is inserted or updated, checks that the specified employee job level (job_lvls), on which salaries are based, is within the range defined for the job. To get the appropriate range, the jobs table must be referenced.

USE pubs
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'employee_insupd' AND type = 'TR')
   DROP TRIGGER employee_insupd
GO
CREATE TRIGGER employee_insupd
ON employee
FOR INSERT, UPDATE
AS
/* Get the range of level for this job type from the jobs table. */
DECLARE @min_lvl tinyint,
   @max_lvl tinyint,
   @emp_lvl tinyint,
   @job_id smallint
SELECT @min_lvl = min_lvl, 
   @max_lvl = max_lvl, 
   @emp_lvl = i.job_lvl,
   @job_id = i.job_id
FROM employee e INNER JOIN inserted i ON e.emp_id = i.emp_id 
   JOIN jobs j ON j.job_id = i.job_id
IF (@job_id = 1) and (@emp_lvl <> 10) 
BEGIN
   RAISERROR ('Job id 1 expects the default level of 10.', 16, 1)
   ROLLBACK TRANSACTION
END
ELSE
IF NOT (@emp_lvl BETWEEN @min_lvl AND @max_lvl)
BEGIN
   RAISERROR ('The level for job_id:%d should be between %d and %d.',
      16, 1, @job_id, @min_lvl, @max_lvl)
   ROLLBACK TRANSACTION
END

--Use COLUMNS_UPDATED
--This example creates two tables: an employeeData table and an auditEmployeeData table. The employeeData table, which holds sensitive employee payroll information, can be modified by members of the human resources department. If the employee's social security number (SSN), yearly salary, or bank account number is changed, an audit record is generated and inserted into the auditEmployeeData audit table.
--By using the COLUMNS_UPDATED() function, it is possible to test quickly for any changes to these columns that contain sensitive employee information. This use of COLUMNS_UPDATED() only works if you are trying to detect changes to the first 8 columns in the table.

USE pubs
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_NAME = 'employeeData')
   DROP TABLE employeeData
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_NAME = 'auditEmployeeData')
   DROP TABLE auditEmployeeData
GO
CREATE TABLE employeeData (
   emp_id int NOT NULL,
   emp_bankAccountNumber char (10) NOT NULL,
   emp_salary int NOT NULL,
   emp_SSN char (11) NOT NULL,
   emp_lname nchar (32) NOT NULL,
   emp_fname nchar (32) NOT NULL,
   emp_manager int NOT NULL
   )
GO
CREATE TABLE auditEmployeeData (
   audit_log_id uniqueidentifier DEFAULT NEWID(),
   audit_log_type char (3) NOT NULL,
   audit_emp_id int NOT NULL,
   audit_emp_bankAccountNumber char (10) NULL,
   audit_emp_salary int NULL,
   audit_emp_SSN char (11) NULL,
   audit_user sysname DEFAULT SUSER_SNAME(),
   audit_changed datetime DEFAULT GETDATE()
   )
GO
CREATE TRIGGER updEmployeeData 
ON employeeData 
FOR update AS
/*Check whether columns 2, 3 or 4 has been updated. If any or all of columns 2, 3 or 4 have been changed, create an audit record. The bitmask is: power(2,(2-1))+power(2,(3-1))+power(2,(4-1)) = 14. To check if all columns 2, 3, and 4 are updated, use = 14 in place of >0 (below).*/

   IF (COLUMNS_UPDATED() & 14) > 0
/*Use IF (COLUMNS_UPDATED() & 14) = 14 to see if all of columns 2, 3, and 4 are updated.*/
      BEGIN
-- Audit OLD record.
      INSERT INTO auditEmployeeData
         (audit_log_type,
         audit_emp_id,
         audit_emp_bankAccountNumber,
         audit_emp_salary,
         audit_emp_SSN)
         SELECT 'OLD', 
            del.emp_id,
            del.emp_bankAccountNumber,
            del.emp_salary,
            del.emp_SSN
         FROM deleted del

-- Audit NEW record.
      INSERT INTO auditEmployeeData
         (audit_log_type,
         audit_emp_id,
         audit_emp_bankAccountNumber,
         audit_emp_salary,
         audit_emp_SSN)
         SELECT 'NEW',
            ins.emp_id,
            ins.emp_bankAccountNumber,
            ins.emp_salary,
            ins.emp_SSN
         FROM inserted ins
   END
GO

/*Inserting a new employee does not cause the UPDATE trigger to fire.*/
INSERT INTO employeeData
   VALUES ( 101, 'USA-987-01', 23000, 'R-M53550M', N'Mendel', N'Roland', 32)
GO

/*Updating the employee record for employee number 101 to change the salary to 51000 causes the UPDATE trigger to fire and an audit trail to be produced.*/

UPDATE employeeData
   SET emp_salary = 51000
   WHERE emp_id = 101
GO
SELECT * FROM auditEmployeeData
GO

/*Updating the employee record for employee number 101 to change both the bank account number and social security number (SSN) causes the UPDATE trigger to fire and an audit trail to be produced.*/

UPDATE employeeData
   SET emp_bankAccountNumber = '133146A0', emp_SSN = 'R-M53550M'
   WHERE emp_id = 101
GO
SELECT * FROM auditEmployeeData
GO

------------------------------
-- https://www.mssqltips.com/sqlservertip/1804/using-instead-of-triggers-in-sql-server-for-dml-operations/

USE AdventureWorks2014
GO
-- Create table for employees
CREATE TABLE Employees 
(EmpCode VARCHAR(8) PRIMARY KEY, Name VARCHAR(50) NOT NULL, 
Designation VARCHAR(50) NOT NULL, QualificationCode TINYINT, 
Deleted BIT NOT NULL DEFAULT 0)
GO
-- Create look up table for employees qualification
CREATE TABLE Lib_Qualification 
(QualificationCode TINYINT PRIMARY KEY, Qualification VARCHAR(20) NOT NULL)
GO
-- Add constraint to lib_qualification
ALTER TABLE dbo.Lib_Qualification ADD CONSTRAINT
FK_Lib_Qualification_Lib_Qualification FOREIGN KEY
( QualificationCode ) REFERENCES dbo.Lib_Qualification
( QualificationCode ) ON UPDATE NO ACTION 
ON DELETE NO ACTION 
GO 
-- Add constraint to employees 
ALTER TABLE dbo.EMPLOYEES ADD CONSTRAINT
FK_EMPLOYEES_Lib_Qualification FOREIGN KEY
( QualificationCode ) REFERENCES dbo.Lib_Qualification
( QualificationCode ) ON UPDATE NO ACTION 
ON DELETE NO ACTION 
GO
-- Insert data into lib_qualification table
Insert into lib_qualification VALUES (1, 'MS')
Insert into lib_qualification VALUES (2, 'MCS')
Insert into lib_qualification VALUES (3, 'BCS')
Insert into lib_qualification VALUES (4, 'MBA')
GO
-- Insert data into employees table
Insert into Employees VALUES ('405-21-1' ,'Emp1' ,'Designation1' ,1 ,0)
Insert into Employees VALUES ('527-54-7' ,'Emp2' ,'Designation2' ,2 ,0)
Insert into Employees VALUES ('685-44-2' ,'Emp3' ,'Designation3' ,1 ,0)
Insert into Employees VALUES ('044-21-3' ,'Emp4' ,'Designation4' ,3 ,0)
Insert into Employees VALUES ('142-21-9' ,'Emp5' ,'Designation5' ,2 ,0)
GO
-- Create view by two base tables
CREATE VIEW vw_EmpQualification
AS
SELECT EmpCode, Name, Designation, Qualification
FROM employees E inner join lib_qualification Q
ON E.qualificationCOde = Q.QualificationCode
WHERE deleted = 0
GO 
Select * from vw_EmpQualification
GO

--Our view is comprised of two base tables. If someone tries to insert values using the view the following error will be generated and the insert will fail.

--At this point, the INSTEAD OF INSERT trigger provides us several options to handle insert operations on this view. For our example we will allow the users to insert data through this view, by having the trigger handle some logic for data integrity.

--The INSTEAD OF INSERT trigger will be created using the following script for Insert operations

USE AdventureWorks2014
GO
CREATE TRIGGER INSTEADOF_TR_I_EmpQualification 
ON vw_EmpQualification
INSTEAD OF INSERT AS
BEGIN
DECLARE @Code TINYINT
SELECT @Code = qualificationCode 
FROM lib_Qualification L INNER JOIN INSERTED I
ON L.qualification = I.qualification
IF (@code is NULL )
BEGIN
RAISERROR (N'The provided qualification does not exist in qualification library',
16, 1)
RETURN
END
INSERT INTO employees (empcode, name, designation,qualificationCode,deleted) 
SELECT empcode, name, designation, @code, 0 
FROM inserted 
END
GO

--We have just used the key word INSTEAD OF versus using the FOR or AFTER keyword in the trigger header and our required INSTEAD OF INSERT trigger has been created. Now we will verify the insert statement on this view which has two base tables. The INSTEAD OF trigger will seamlessly handle the insert operation in the trigger without an error.

USE AdventureWorks2014
GO 
-- Insert data in view
INSERT INTO vw_EmpQualification VALUES ('425-27-1', 'Emp8','Manager','MBA')
GO
-- To confirm the data insertion
SELECT * FROM vw_EmpQualification
GO

INSTEAD OF UPDATE Trigger for update operation

There may be several scenarios where using INSTEAD of triggers can solve this problem. In the case of views with multiple base tables, you may only issue update statements that affect a single base table at a time. If any update statement on our view affects multiple base tables at a time then the following error would be generated

The following script is for an INSTEAD OF UPDATE trigger is used to provided seemless update capability for multiple base tables

USE AdventureWorks2014
GO
CREATE TRIGGER INSTEADOF_TR_U_EmpQualification 
ON vw_EmpQualification
INSTEAD OF UPDATE AS
BEGIN
IF (UPDATE(qualification)) -- If qualification is updated
BEGIN
DECLARE @code TINYINT
UPDATE employees
SET @code = L.qualificationcode 
FROM lib_qualification L INNER JOIN inserted I 
ON L.qualification = I.qualification
IF (@code is NULL )
BEGIN
RAISERROR (N'The provided qualification does not exist in qualification library',
16, 1)
RETURN
END
UPDATE employees
SET qualificationCode = @code
FROM inserted I INNER JOIN employees E ON I.empcode = E.empcode
END

IF (UPDATE(EmpCode)) -- If employee code is updated
BEGIN
RAISERROR (N'You can not edit employee code, Transaction has been failed', 16, 1)
RETURN
END
IF (UPDATE(name)) -- If name is updated 
BEGIN
UPDATE employees
SET name = I.name 
FROM inserted I INNER JOIN employees E ON I.empcode = E.empcode 
WHERE E.empcode = I.empcode
END 

IF (UPDATE(designation)) -- If designation is updated
BEGIN
UPDATE employees
SET designation = I.designation 
FROM inserted I INNER JOIN employees E ON I.empcode = E.empcode 
WHERE E.empcode = I.empcode
END
END
GO

Now we can verify the proper functioning of our trigger for an update statement.

USE AdventureWorks2014
GO 
-- Update data in view
UPDATE vw_EmpQualification
SET designation = 'Designation4 Updated', Qualification = 'MCS'
WHERE empcode = '044-21-3'
GO
-- To confirm the data update
SELECT * FROM vw_EmpQualification
GO

INSTEAD OF trigger for delete operation

INSTEAD OF trigger may be attached for delete operations. In our case we are required that when rows are deleted through the view, a deleted flag in the table should be marked "1" for those rows, but rows should not actually be deleted. Such rows may be deleted in bulk later at specified time if needed. For this we may create the following INSTEAD OF DELETE trigge

USE AdventureWorks2014
GO 
CREATE TRIGGER INSTEADOF_TR_D_EmpQualification 
ON vw_EmpQualification
INSTEAD OF DELETE AS
BEGIN
update employees
set deleted = 1
where empcode in (select empcode from deleted)
END
GO

To verify the implementation for deletes the following script can be used

USE AdventureWorks2014
GO 
-- Delete data in view
DELETE FROM vw_EmpQualification
WHERE Designation = 'Manager'
GO
-- To confirm the data update
SELECT * FROM vw_EmpQualification
SELECT * FROM Employees
GO

The deleted row still exist in the base table, but it is not shown in the view because the deleted flag is set to "1" in the base table

----------------------------------

-- http://www.techbrothersit.com/2013/09/tsql-dml-after-trigger-for-insertupdate.html

--TSQL - DML After Trigger for Insert,Update and Delete Operation
--Scenario: 
--Sometime we have to write a trigger on table to capture changes for different operation such as Insert, Update and Delete. Here is sample Code that can be modified according to the Source Table.

--Solution:

--I have created dbo.Customer Table as Source Table on which I want to create DML After trigger. After that I have created an Audit Table for dbo.Customer with name dbo.Customer_Audit which is going to save all changes.


USE TestDB
GO
CREATE TABLE dbo.Customer
  (
     [CustomerID] INT IDENTITY(1, 1),
     [Name]       VARCHAR(50),
     [ADDRESS]    VARCHAR(100)
  )
GO
CREATE TABLE dbo.Customer_Audit
  (
     [CustomerID]    INT,
     [Name]          VARCHAR(50),
     [ADDRESS]       VARCHAR(100),
     [OperationDate] [DATETIME] NOT NULL,
     [Operation]     [VARCHAR](50) NOT NULL,
     [OperationBy]   [VARCHAR](100) NOT NULL
  )
GO

--Create DML After Trigger

CREATE TRIGGER [dbo].[Tr_Customer_Audit]
ON [dbo].[Customer]
FOR INSERT, UPDATE, DELETE
AS
    SET NOCOUNT ON;
 --Capture the Operation (Inserted, Deleted Or Updated)

    DECLARE @operation AS VARCHAR(10)
    DECLARE @Count AS INT

    SET @operation = 'Inserted'

    SELECT @Count = COUNT(*)
    FROM   DELETED

    IF @Count > 0
      BEGIN
          SET @operation = 'Deleted'

          SELECT @Count = COUNT(*)
          FROM   INSERTED

          IF @Count > 0
            SET @operation = 'Updated'
      END
--Capturing Delete Operation

    IF @operation = 'Deleted'
      BEGIN
          INSERT INTO dbo.Customer_Audit
                      ([CustomerID],
                       [Name],
                       [ADDRESS],
                       [OperationDate],
                       [Operation],
                       [OperationBy])
          SELECT [CustomerID],
                 [Name],
                 [ADDRESS],
                 GETDATE()    AS [OperationDate],
                 'Deleted'    AS [Operation],
                 Suser_name() AS [OperationBy]
          FROM   deleted
      END
    ELSE
      BEGIN
--Capturing Insert Operation

          IF @operation = 'Inserted'
            BEGIN
                INSERT INTO dbo.Customer_Audit
                            ([CustomerID],
                             [Name],
                             [ADDRESS],
                             [OperationDate],
                             [Operation],
                             [OperationBy])
                SELECT [CustomerID],
                       [Name],
                       [ADDRESS],
                       GETDATE()    AS [OperationDate],
                       'Inserted'   AS [Operation],
                       Suser_name() AS [OperationBy]
                FROM   inserted
            END
          
--Capture Update Operation

          ELSE
            BEGIN
                INSERT INTO dbo.Customer_Audit
                            ([CustomerID],
                             [Name],
                             [ADDRESS],
                             [OperationDate],
                             [Operation],
                             [OperationBy])
                SELECT [CustomerID],
                       [Name],
                       [ADDRESS],
                       GETDATE()    AS [OperationDate],
                       'Updated'    AS [Operation],
                       Suser_name() AS [OperationBy]
                FROM   inserted
            END
      END
GO

---------------------

How to Drop or Delete all Triggers from a Database in SQL Server
Sometime we have requirement to delete/drop all the triggers from a SQL Server Database. The below code can be used to drop all the triggers on all the tables you have created in a SQL Server database. Before you go ahead and run this script, please make sure you have chosen correct database and server as it will delete all the triggers from chosen SQL Server Database.



USE [Database]
GO 
DECLARE @TriggerName AS VARCHAR(500)
 -- Drop or Delete All Triggers in a Database in SQL Server 
DECLARE DropTrigger CURSOR FOR
  SELECT TRG.name AS TriggerName
  FROM   sys.triggers TRG
         INNER JOIN sys.tables TBL
                 ON TBL.OBJECT_ID = TRG.parent_id 
OPEN DropTrigger
 FETCH Next FROM DropTrigger INTO @TriggerName 
WHILE @@FETCH_STATUS = 0
  BEGIN
      DECLARE @SQL VARCHAR(MAX)=NULL
      SET @SQL='Drop Trigger ' + @TriggerName
      PRINT 'Trigger ::' + @TriggerName
            + ' Droped Successfully'
      EXEC (@SQL)
      PRINT @SQL
      FETCH Next FROM DropTrigger INTO @TriggerName
  END
CLOSE DropTrigger 
DEALLOCATE DropTrigger

-----------------------

How to Create Server Level Trigger in SQL Server - SQL Server DBA Tutorial
In this video tutorial you will learn how to create SQL Server Level Trigger in SQL Server using T-SQL script. Script will teach you how to create Server Level Trigger, how to store trigger output in a table, how to send email based on different events occurred on SQL Server instance such as creating database, dropping database etc. It also illustrates how to use DBMail in SQL Server to send alerts to your email.


USE [master]
GO 
/****** Object:  DdlTrigger [dbcreate]    Script Date: 3/9/2015 2:24:39 PM ******/ 
SET ANSI_NULLS ON
 GO 
SET 
QUOTED_IDENTIFIER ON 
GO 
CREATE TRIGGER [dbcreate] 
ON ALL SERVER
 FOR CREATE_DATABASE, Drop_database 
AS
BEGIN
                DECLARE @Eventdata XML
                SET @Eventdata = EVENTDATA()

                     IF EXISTS(SELECT 1 FROM MASTER.information_schema.tables WHERE table_name = 'PermissionAudit')
                     BEGIN
                           INSERT INTO MASTER.dbo.PermissionAudit
                                  (EventType,EventData, ServerLogin,TSQLText)
                                  VALUES (@Eventdata.value('(/EVENT_INSTANCE/EventType)[1]', 'nVarChar(100)'),
                                                @Eventdata, SYSTEM_USER,
                                                @Eventdata.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nVarChar(2000)' ))
                     END

   
DECLARE @Table NVARCHAR(MAX) 
DECLARE @body NVARCHAR(MAX) 
SET @Table = CAST((SELECT [EventType]   AS 'td',
                          '',
                          [EventData]   AS 'td',
                          '',
                          [ServerLogin] AS 'td',
                          '',
                          [TSQLText]    AS 'td'
                   FROM   MASTER.dbo.PermissionAudit
                   FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)) 
SET @body ='<html><body><H2>Audit Information From Trigger</H2>
<table border = 1> 
<tr>
<th> EventType </th> <th> EventData </th> <th> ServerLogin </th> <th> TSQLText </th> <th>' 
SET @body = @body + @Table + '</table></body></html>' 
EXEC msdb.dbo.sp_send_dbmail
  @profile_name = 'Test',
  @body = @body,
  @body_format ='HTML',
  @recipients = 'youremailaddress@domain.com',
  @subject = 'Audit Database Create or Drop';


    END
TRUNCATE TABLE MASTER.dbo.PermissionAudit
GO
ENABLE TRIGGER [dbcreate] ON ALL SERVER

GO

------------------------

Get all Triggers with Table Names in SQL Server
Often we come across situation where we need to find out the list of Tables on which triggers are enable. The below query will provide you list of all tables with triggers created on them.


SELECT TBL.name                   AS TableName,
       Schema_name(TBL.schema_id) AS Table_SchemaName,
       TRG.name                   AS TriggerName,
       TRG.parent_class_desc,
       CASE
         WHEN TRG.is_disabled = 0 THEN 'Enable'
         ELSE 'Disable'
       END                        AS TRG_Status 
FROM   sys.triggers TRG
       INNER JOIN sys.tables TBL
               ON TBL.OBJECT_ID = TRG.parent_id 

--------------------

How to Disable All the Triggers in SQL Server Database
Sometime we have requirement that we need to disable all the triggers in SQL Server Database. We can use Cursor in TSQL To loop through list of Triggers and then disable them.

The below script can be use to disable all the triggers in SQL Server Database.

USE [Database]

GO
 DECLARE @TriggerName AS VARCHAR(500) 
DECLARE @TableName AS VARCHAR(500) 
DECLARE @SchemaName AS VARCHAR(100) 
--Disable All Triggers in a Database in SQL Server
 DECLARE DisableTrigger CURSOR FOR
SELECT TBL.name                   AS TableName,
       Schema_name(TBL.schema_id) AS Table_SchemaName,
       TRG.name                   AS TriggerName 
FROM   sys.triggers TRG
       INNER JOIN sys.tables TBL
               ON TBL.OBJECT_ID = TRG.parent_id 
               AND TRG.is_disabled=0 
               AND TBL.is_ms_shipped=0 
 OPEN DisableTrigger 
FETCH Next FROM DisableTrigger INTO @TableName,@SchemaName,@TriggerName 
WHILE @@FETCH_STATUS = 0
  BEGIN
      DECLARE @SQL VARCHAR(MAX)=NULL

      SET @SQL='Disable Trigger ' + @TriggerName +' ON '+@SchemaName+'.'+@TableName

      EXEC (@SQL)
      PRINT 'Trigger ::' + @TriggerName + 'is disabled on '+@SchemaName+'.'+@TableName
      PRINT @SQL

      FETCH Next FROM DisableTrigger INTO @TableName,@SchemaName,@TriggerName
  END

CLOSE DisableTrigger
DEALLOCATE DisableTrigger



To check if all the triggers are disabled correctly in SQL Server Database, use below query

SELECT TBL.name                   AS TableName,
       Schema_name(TBL.schema_id) AS Table_SchemaName,
       TRG.name                   AS TriggerName,
       TRG.parent_class_desc,
       CASE
         WHEN TRG.is_disabled = 0 THEN 'Enable'
         ELSE 'Disable'
       END                        AS TRG_Status 
FROM   sys.triggers TRG
       INNER JOIN sys.tables TBL
               ON TBL.OBJECT_ID = TRG.parent_id 
              AND trg.is_disabled=1 --use this filter to get Disabled Triggers

------------------
-- https://technet.microsoft.com/es-es/library/ms175521(v=sql.105).aspx

--  desencadenador INSTEAD OF actualiza dos tablas base desde una vista. 
-- Además, se muestran los siguientes enfoques de control de errores:
-- Las inserciones duplicadas de la tabla Person se omiten y la información de la inserción se registra en la tabla PersonDuplicates.
-- Las inserciones de duplicados en EmployeeTable se convierten en una instrucción UPDATE que recupera la información actual de la tabla EmployeeTable sin generar una infracción de clave duplicada.
-- Las instrucciones Transact-SQL crean dos tablas base, una vista, una tabla para registrar errores y el desencadenador INSTEAD OF en la vista. Las siguientes tablas separan la información personal de la empresarial y constituyen las tablas base de la vista:
USE Tempdb
GO

CREATE TABLE Person
   (
    SSN         char(11) PRIMARY KEY,
    Name        nvarchar(100),
    Address     nvarchar(100),
    Birthdate   datetime
   )
GO
CREATE TABLE EmployeeTable
   (
    EmployeeID       int PRIMARY KEY,
    SSN              char(11) UNIQUE,
    Department       nvarchar(10),
    Salary           money,
    CONSTRAINT FKEmpPer FOREIGN KEY (SSN)
    REFERENCES Person (SSN)
   )
GO
-- Esta vista presenta los datos importantes de las dos tablas acerca de una persona:
CREATE VIEW Employee 
AS
SELECT P.SSN as SSN, Name, Address,
       Birthdate, EmployeeID, Department, Salary
FROM Person P, EmployeeTable E
WHERE P.SSN = E.SSN
GO
-- Puede registrar intentos de insertar filas con números de seguridad social duplicados. 
--La tabla PersonDuplicates registra los valores insertados, 
-- el nombre del usuario que intentó realizar la inserción y la hora de la inserción.
CREATE TABLE PersonDuplicates
   (
    SSN           char(11),
    Name          nvarchar(100),
    Address       nvarchar(100),
    Birthdate     datetime,
    InsertSNAME   nchar(100),
    WhenInserted  datetime
   )
GO
-- El desencadenador INSTEAD OF inserta filas en varias tablas base desde una única vista. 
-- Los intentos de insertar filas con números de seguridad social duplicados se registran 
-- en la tabla PersonDuplicates. 
-- Las filas duplicadas de EmployeeTable se cambian por instrucciones de actualización.

CREATE TRIGGER IO_Trig_INS_Employee ON Employee
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
-- Check for duplicate Person. If there is no duplicate, do an insert.
IF (NOT EXISTS (SELECT P.SSN
      FROM Person P, inserted I
      WHERE P.SSN = I.SSN))
   INSERT INTO Person
      SELECT SSN,Name,Address,Birthdate
      FROM inserted
ELSE
-- Log an attempt to insert duplicate Person row in PersonDuplicates table.
   INSERT INTO PersonDuplicates
      SELECT SSN,Name,Address,Birthdate,SUSER_SNAME(),GETDATE()
      FROM inserted
-- Check for duplicate Employee. If no there is duplicate, do an INSERT.
IF (NOT EXISTS (SELECT E.SSN
      FROM EmployeeTable E, inserted
      WHERE E.SSN = inserted.SSN))
   INSERT INTO EmployeeTable
      SELECT EmployeeID,SSN, Department, Salary
      FROM inserted
ELSE
--If there is a duplicate, change to UPDATE so that there will not
--be a duplicate key violation error.
   UPDATE EmployeeTable
      SET EmployeeID = I.EmployeeID,
          Department = I.Department,
          Salary = I.Salary
   FROM EmployeeTable E, inserted I
   WHERE E.SSN = I.SSN
END
--------------
-- https://www.mssqltips.com/sqlservertip/1804/using-instead-of-triggers-in-sql-server-for-dml-operations/
-- http://www.dotnet-tricks.com/Tutorial/sqlserver/OPUH170312-After-Trigger,-Instead-of-Trigger-Example.html
-- http://sqlperformance.com/2015/09/sql-plan/instead-of-triggers


