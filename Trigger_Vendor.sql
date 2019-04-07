-- Trigger

USE [AdventureWorks2014]
GO


-- https://docs.microsoft.com/es-es/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-2017

----------------
--Optimización de los desencadenadores DML
--Los desencadenadores funcionan en transacciones (implícitas o no) y, mientras están abiertos, bloquean recursos. El bloqueo seguirá vigente hasta que la transacción se confirme (con COMMIT) o se rechace (con ROLLBACK). Cuanto más tiempo se ejecute un desencadenador, mayor será la probabilidad de que se bloquee otro proceso. Por lo tanto, los desencadenadores se deben escribir de forma que se reduzca su duración siempre que sea posible. Una manera de conseguirlo consiste en liberar un desencadenador cuando una instrucción DML cambie 0 filas.

--Para liberar el desencadenador de un comando que no cambia ninguna fila, use la variable del sistema ROWCOUNT_BIG.

--El siguiente fragmento de código de T-SQL lo consigue, y debería aparecer al principio de cada desencadenador DML:



IF (@@ROWCOUNT_BIG = 0)
RETURN;

-------------------------------------


--  Usar un desencadenador DML AFTER para exigir una regla de negocios entre las tablas PurchaseOrderHeader y Vendor
--Debido a que las restricciones CHECK solo pueden hacer referencia a las columnas en las que se han definido las restricciones de columna o de tabla, cualquier restricción entre tablas, en este caso, reglas de negocios, debe definirse como desencadenadores.

-- En el ejemplo siguiente se crea un desencadenador DML en la base de datos AdventureWorks2012. 
-- El desencadenador comprueba que la solvencia del proveedor es satisfactoria (no es 5) 
-- cuando se intenta insertar un nuevo pedido de compra en la tabla PurchaseOrderHeader. 
-- Para obtener la solvencia del proveedor, debe hacerse referencia a la tabla Vendor. 
-- Si la solvencia no es satisfactoria, se obtiene un mensaje y no se ejecuta la inserción.

sp_help "Purchasing.PurchaseOrderHeader"
GO
sp_help "Purchasing.Vendor"
GO	
SELECT * FROM Purchasing.PurchaseOrderHeader
SELECT * FROM Purchasing.Vendor
GO

SELECT *
FROM Purchasing.PurchaseOrderHeader p JOIN Purchasing.Vendor v
ON v.BusinessEntityID = p.VendorID
GO
DROP TABLE IF EXISTS Purchasing.PedidosCompra
GO
SELECT *
INTO Purchasing.PedidosCompra
FROM Purchasing.PurchaseOrderHeader
GO

SELECT * FROM Purchasing.PedidosCompra
GO

-- This trigger prevents a row from being inserted in the Purchasing.PurchaseOrderHeader 
-- table when the credit rating of the specified vendor is set to 5 (below average).  

DROP TRIGGER IF EXISTS Purchasing.LowCredit
GO
CREATE TRIGGER Purchasing.LowCredit 
ON Purchasing.PedidosCompra
AFTER INSERT
AS  
IF (@@ROWCOUNT= 0)
RETURN;
IF EXISTS (SELECT *  
           FROM Purchasing.PedidosCompra AS p   
           JOIN inserted AS i   
           ON p.PurchaseOrderID = i.PurchaseOrderID   
           JOIN Purchasing.Vendor AS v   
           ON v.BusinessEntityID = p.VendorID  
           WHERE v.CreditRating = 5  
          )  
BEGIN  
		RAISERROR ('A vendor''s credit rating is too low to accept new  
		purchase orders.', 16, 1);  
		ROLLBACK TRANSACTION;  
		RETURN   
END;  
GO  

SELECT * FROM Purchasing.PedidosCompra ORDER BY VendorID
GO
-- This statement attempts to insert a row into the PurchaseOrderHeader table  
-- for a vendor that has a below average credit rating.  
-- The AFTER INSERT trigger is fired and the INSERT transaction is rolled back.  


SELECT BusinessEntityID,CreditRating FROM Purchasing.Vendor
GO
SELECT BusinessEntityID FROM Purchasing.Vendor WHERE CreditRating=5
GO

--BusinessEntityID
--1550
--1652

SELECT * 
FROM Purchasing.PedidosCompra 
WHERE VendorID IN (1550,1632) 
ORDER BY VendorID
GO

SELECT TOP 3 BusinessEntityID 
FROM Purchasing.Vendor 
WHERE CreditRating!=5
GO

--BusinessEntityID
--1492
--1494
--1496

INSERT INTO Purchasing.PedidosCompra (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight,[TotalDue],[ModifiedDate])  
VALUES (  
2  
,3  
,261  
,1652  
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638
,13
,GETDATE());  
GO

--Msg 50000, Level 16, State 1, Procedure LowCredit, Line 16 [Batch Start Line 114]
--A vendor's credit rating is too low to accept new  
--		purchase orders.
--Msg 3609, Level 16, State 1, Line 115
--The transaction ended in the trigger. The batch has been aborted.



INSERT INTO Purchasing.PedidosCompra (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight,[TotalDue],[ModifiedDate])  
VALUES (  
2  
,3  
,261  
,1492 
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638
,14
,GETDATE());  
GO
--(1 row affected)

SELECT [PurchaseOrderID],[RevisionNumber],[ShipDate],[ModifiedDate]
FROM Purchasing.PedidosCompra 
order by 4 DESC
--WHERE [ModifiedDate]=GETDATE()
GO

---------------------------
DROP TRIGGER IF EXISTS Purchasing.LowCredit
GO
CREATE TRIGGER Purchasing.LowCredit 
ON Purchasing.Purchasing.PedidosCompra
AS  
IF (@@ROWCOUNT_BIG  = 0)
RETURN;
IF EXISTS (SELECT *  
           FROM Purchasing.PedidosCompra AS p   
           JOIN inserted AS i   
           ON p.PurchaseOrderID = i.PurchaseOrderID   
           JOIN Purchasing.Vendor AS v   
           ON v.BusinessEntityID = p.VendorID  
           WHERE v.CreditRating = 5  
          )  
BEGIN  
RAISERROR ('A vendor''s credit rating is too low to accept new  
purchase orders.', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO  

-- This statement attempts to insert a row into the PurchaseOrderHeader table  
-- for a vendor that has a below average credit rating.  
-- The AFTER INSERT trigger is fired and the INSERT transaction is rolled back.  

INSERT INTO Purchasing.PedidosCompra (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)  
VALUES (2,3,261,1652,4,GETDATE(),GETDATE(),44594.55,3567.564,1114.8638 );  
GO

-----------------




----------------------
CREATE TRIGGER Purchasing.LowCredit 
ON Purchasing.PurchaseOrderHeader  
AFTER INSERT  
AS  
IF (@@ROWCOUNT_BIG  = 0)
RETURN;
IF EXISTS (SELECT *  
           FROM Purchasing.PurchaseOrderHeader AS p   
           JOIN inserted AS i   
           ON p.PurchaseOrderID = i.PurchaseOrderID   
           JOIN Purchasing.Vendor AS v   
           ON v.BusinessEntityID = p.VendorID  
           WHERE v.CreditRating = 5  
          )  
BEGIN  
RAISERROR ('A vendor''s credit rating is too low to accept new  
purchase orders.', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO  

-- This statement attempts to insert a row into the PurchaseOrderHeader table  
-- for a vendor that has a below average credit rating.  
-- The AFTER INSERT trigger is fired and the INSERT transaction is rolled back.  

INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status, EmployeeID,  
VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)  
VALUES (  
2  
,3  
,261  
,1652  
,4  
,GETDATE()  
,GETDATE()  
,44594.55  
,3567.564  
,1114.8638 );  
GO


