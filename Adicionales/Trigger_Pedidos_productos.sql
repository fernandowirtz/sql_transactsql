-- DESENCADENADOR QUE DESCUENTA LA EXISTENCIA DE LA TABLA PRODUCTOS SEGUN EL PEDIDO
DROP DATABASE IF EXISTS Almacen
GO
Create Database Almacen
Go
Use Almacen
Go
DROP TABLE IF EXISTS Productos
GO
DROP TABLE IF EXISTS Pedidos
GO
-- Hint
-- Error incluso con Pedidos !!!!
--Msg 3726, Level 16, State 1, Line 8
--Could not drop object 'Productos' because it is referenced by a FOREIGN KEY constraint.

sp_helpconstraint productos
GO
sp_helpconstraint pedidos
GO
ALTER TABLE Pedidos
	NOCHECK CONSTRAINT  Pk_Id_Producto
GO
ALTER TABLE Pedidos
	CHECK CONSTRAINT  Pk_Id_Producto
GO
Create  Table Productos (
Id_Producto Char (8) Primary Key Not Null,
Nombreproducto Varchar (25) Not Null,
Existencia Int Null,
Precio Decimal(10,2) Not Null,
Precioventa Decimal (10,2)
)
Go
Create Table Pedidos ( 
Id_Pedido Int Identity,
Id_Producto Char (8) Not Null,
Cantidad_Pedido Int 
Constraint  Pk_Id_Producto Foreign Key (Id_Producto)
References Productos (Id_Producto)
)
Go 
--INSERTAMOS REGISTROS A LA TABLA PRODUCTOS PARA REALIZAR LA DEMOSTRACIÓN
Insert Into Productos Values ('P001', 'Filtros Pantalla', 5, 10, 12.5)
Insert Into Productos Values ('P002', 'Parlantes', 7, 10, 11.5)
Insert Into Productos Values ('P003', 'Mouse', 8, 4.5, 6)
Go 
SELECT * 
FROM Productos
ORDER BY Id_Producto
GO
SELECT * FROM Pedidos
GO
--CREAMOS DESENCADENADOR CON TRIGGER
DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
Create Trigger Trg_Pedido_Articulos
On Pedidos
For Insert
As
		Update Productos 
		Set Existencia = Existencia - (Select Cantidad_Pedido From Inserted)
		Where Id_Producto = (Select Id_Producto From Inserted)
Go

-- PUEDES VERIFICAR LAS CANTIDADES, LUEGO REALIZAS EL PEDIDO DE LA SIGUIENTE MANERA
-- 
-- En Productos
-- P003    	Mouse	8	4.50	6.00
Insert Into Pedidos Values ('P003',5)
GO
--COMO VERAS QUE SI FUNCIONA, EL TRIGGER DESCONTÓ LA CANTIDAD SEGÚN EL PEDIDO
Select * From Productos
GO
--P003    	Mouse	3	4.50	6.00
Select * From Pedidos
GO
-- 1	P003    	5

DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
Create Trigger Trg_Pedido_Articulos
On Pedidos
For Insert
As
		DECLARE @Existencias int
		SELECT  @Existencias=Existencia
		FROM Productos 
		Where Id_Producto = (Select Id_Producto From Inserted)
		IF  @Existencias < (Select Cantidad_Pedido From Inserted)
			BEGIN
				RAISERROR ('No hay Existencias.', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               ); 
				RETURN
			END
		ELSE
			BEGIN	
				Update Productos 
				Set Existencia = Existencia - (Select Cantidad_Pedido From Inserted)
				Where Id_Producto = (Select Id_Producto From Inserted)
			END
Go

SELECT * FROM Productos
GO
-- P003    	Mouse	8	4.50	6.00


-- Se piden mas Existencias de las que hay

Insert Into Pedidos Values ('P003',9)
GO

--Msg 50000, Level 16, State 1, Procedure Trg_Pedido_Articulos, Line 11 [Batch Start Line 112]
--No hay Existencias.

--(1 row affected)

SELECT * FROM Productos
GO
-- No hace el descuento en productos
-- P003    	Mouse	8	4.50	6.00

SELECT * FROM Pedidos
GO
-- Hace el pedido
-- 1	P003    	9

-- Añadir ROLLBACK TRAN
DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
Create Trigger Trg_Pedido_Articulos
On Pedidos
For Insert
As
		DECLARE @Existencias int
		SELECT  @Existencias=Existencia
		FROM Productos 
		Where Id_Producto = (Select Id_Producto From Inserted)
		IF  @Existencias < (Select Cantidad_Pedido From Inserted)
			BEGIN
				RAISERROR ('No hay Existencias.', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               ); 
			   ROLLBACK TRAN
			    RETURN
			END
		ELSE
			BEGIN	
				Update Productos 
				Set Existencia = Existencia - (Select Cantidad_Pedido From Inserted)
				Where Id_Producto = (Select Id_Producto From Inserted)
			END
Go

SELECT * FROM Productos
GO
-- P003    	Mouse	8	4.50	6.00


-- Se piden mas Existencias de las que hay

Insert Into Pedidos Values ('P003',9)
GO

--Msg 50000, Level 16, State 1, Procedure Trg_Pedido_Articulos, Line 11 [Batch Start Line 165]
--No hay Existencias.
--Msg 3609, Level 16, State 1, Line 166
--The transaction ended in the trigger. The batch has been aborted.

SELECT * FROM Productos
GO

-- P003    	Mouse	8	4.50	6.00

SELECT * FROM Pedidos
GO
-- Sin Pedido


-- -- P002    	Parlantes	7	10.00	11.50

Insert Into Pedidos Values ('P002',2)
GO

SELECT * FROM Productos
GO

-- P002    	Parlantes	5	10.00	11.50


SELECT * FROM Pedidos
GO

-- 2	P002    	2
