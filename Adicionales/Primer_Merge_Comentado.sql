DROP DATABASE IF EXISTS Fusionar
GO

CREATE DATABASE Fusionar
GO
USE Fusionar
GO

IF object_id('Productos') IS NOT NULL
	DROP TABLE Productos ;
IF object_id('Frutas') IS NOT NULL
	DROP TABLE Frutas ;
GO
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


-- WHEN  MATCHED 
-- UPDATE

SELECT *
FROM Productos p JOIN Frutas f
ON p.nombre = f.nombre
GO

--Nombre	Precio				Nombre	Precio
--Manzanas	3.99			    Manzanas	6.00
--Uvas	    4.00					Uvas	4.00




-- WHEN NOT MATCHED BY TARGET
-- INSERT
SELECT Nombre
FROM Frutas
EXCEPT
SELECT Nombre
FROM Productos
GO


--Nombre
--Bananas
--Mandarinas
--Naranjas


-- WHEN NOT MATCHED BY SOURCE
-- DELETE
SELECT Nombre
FROM Productos
EXCEPT
SELECT Nombre
FROM Frutas
GO

 
--Nombre
--Leche
--Miel
--Pan


SELECT Nombre
FROM Productos
INTERSECT
SELECT Nombre
FROM Frutas
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
	( ActionType NVARCHAR(10), DelNombre NVARCHAR(60), DelPrecio varchar(12),
	InsNombre NVARCHAR(60), InsPrecio varchar(12));
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

-- Outcome

--ActionType	DelNombre	DelPrecio	InsNombre	InsPrecio
--INSERT	        NULL	NULL		Bananas			4.95
--INSERT	        NULL	NULL		Mandarinas		3.95
--INSERT	        NULL	NULL		Naranjas		2.50
--DELETE	        Leche	2.40		NULL			NULL	**
--DELETE	        Miel	4.99		NULL			NULL	**
--UPDATE	      Manzanas	3.99		Manzanas		6.00	*
--DELETE	       Pan	    2.45		NULL			NULL	**
--UPDATE	       Uvas	    4.00		Uvas			4.00	*

DROP DATABASE Fusionar
GO
-----------------
-- Activity Monitor lento

DROP DATABASE IF EXISTS Fusiona
GO
CREATE DATABASE Fusiona
GO
USE Fusiona
GO

IF object_id('Productos') IS NOT NULL
	DROP TABLE Productos ;
IF object_id('Frutas') IS NOT NULL
	DROP TABLE Frutas ;
GO
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

CREATE PROC Fusion_Productos
AS
	BEGIN
			DROP TABLE IF EXISTS ProductosSalida
			CREATE TABLE ProductosSalida(
				ActionType NVARCHAR(10), DelNombre NVARCHAR(60), DelPrecio varchar(12),
				InsNombre NVARCHAR(60),	InsPrecio varchar(12));
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
  			SELECT * FROM ProductosSalida
	END
GO

EXEC Fusion_Productos
GO

--ActionType	DelNombre	DelPrecio	InsNombre	InsPrecio
--INSERT	NULL	NULL	Bananas	4.95
--INSERT	NULL	NULL	Mandarinas	3.95
--INSERT	NULL	NULL	Naranjas	2.50
--DELETE	Leche	2.40	NULL	NULL
--DELETE	Miel	4.99	NULL	NULL
--UPDATE	Manzanas	3.99	Manzanas	6.00
--DELETE	Pan	2.45	NULL	NULL
--UPDATE	Uvas	4.00	Uvas	4.00

SELECT * 
FROM ProductosSalida
ORDER BY ActionType
GO


--ActionType	DelNombre	DelPrecio	InsNombre	InsPrecio
--DELETE	Leche	2.40	NULL	NULL
--DELETE	Miel	4.99	NULL	NULL
--DELETE	Pan	2.45	NULL	NULL
--INSERT	NULL	NULL	Bananas	4.95
--INSERT	NULL	NULL	Mandarinas	3.95
--INSERT	NULL	NULL	Naranjas	2.50
--UPDATE	Manzanas	3.99	Manzanas	6.00
--UPDATE	Uvas	4.00	Uvas	4.00



DROP DATABASE Fusiona
GO