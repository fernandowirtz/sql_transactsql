----------------------
-- Ejemplo Trigger Auditoria Inventario 
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