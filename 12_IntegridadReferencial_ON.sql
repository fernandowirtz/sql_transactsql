-- http://www.techonthenet.com/sql_server/foreign_keys/foreign_delete.php
-- http://www.sqlteam.com/article/using-set-null-and-set-default-with-foreign-key-constraints


------------------------------------------------------------------------------------------------------
								-- Integridad Referencial - FK (Foreign Key) 
								-- (Referential Integrity)
								-- ON DELETE / UPDATE
									-- NO ACTION      (Default)
									-- CASCADE
									-- SET NULL 
									-- SET DEFAULT
------------------------------------------------------------------------------------------------------
USE tempdb
GO
--CREATE DATABASE Prueba
--GO
--USE Prueba
--GO
-- DROP DATABASE Prueba

if object_id('libros') is not null
	drop table libros;

if object_id('editoriales') is not null
	drop table editoriales;
-- Table Parent
create table editoriales(
	codigo tinyint,
	nombre varchar(20),
	primary key (codigo));
GO
-- Table Child
create table libros(
	codigo int identity,
	titulo varchar(40),
	autor varchar(30),
	codigoeditorial tinyint default 3);
GO

insert into editoriales values(1,'Emece');
insert into editoriales values(2,'Planeta');
insert into editoriales values(3,'Siglo XXI');
GO
insert into libros values('El aleph','Borges',1);
insert into libros values('Martin Fierro','Jose Hernandez',2);
insert into libros values('Aprenda PHP','Mario Molina',2);
GO
------------------
-- Parent Table : Editoriales
-- Child Table : Libros

--Muestra la información sobre restricciones de una tabla
sp_helpconstraint libros;
GO

--Añadimos una restricción FK al campo 'codigoeditorial' de 'libros'
ALTER TABLE libros
ADD CONSTRAINT FK_libros_codigoeditorial
		FOREIGN KEY (codigoeditorial) 
		REFERENCES editoriales (codigo); 
Go
--Muestra la información sobre restricciones de una tabla
sp_helpconstraint libros;
GO
--Resultado del procedimiento almacenado
--DEFAULT on column codigoeditorial		DF__libros__codigoed__1ED998B2		(n/a)		(n/a)		(n/a)		(n/a)				((1))
--FOREIGN KEY							FK_libros_codigoeditorial			No Action	No Action	Enabled		Is_For_Replication	codigoeditorial
--	 	 	 	 																												REFERENCES PruebasDB.dbo.editoriales (codigo)

--Hint:
--See
--delete_action      update_action


--DESHABILITAR/HABILITAR UNA RESTRICCIÓN
--Deshabilitar
ALTER TABLE libros
		NOCHECK CONSTRAINT FK_libros_codigoeditorial;
GO		
--DEFAULT on column codigoeditorial		DF__libros__codigoed__1ED998B2		(n/a)		(n/a)		(n/a)		(n/a)				((1))
--FOREIGN KEY							FK_libros_codigoeditorial			No Action	No Action	Disabled	Is_For_Replication	codigoeditorial
sp_helpconstraint libros;
GO	 	 	 	 																													REFERENCES PruebasDB.dbo.editoriales (codigo)
		
		
		
--Habilitar una restricción deshabilitada
ALTER TABLE libros
		CHECK CONSTRAINT FK_libros_codigoeditorial;
GO	
sp_helpconstraint libros;
GO

	
--Eliminar una restricción
ALTER TABLE libros
		DROP CONSTRAINT FK_libros_codigoeditorial;
		--DEFAULT on column codigoeditorial		DF__libros__codigoed__1ED998B2		(n/a)		(n/a)		(n/a)		(n/a)				((1))
GO
sp_helpconstraint libros
GO

--Caso 1: NO ACTION (Por Defecto)

ALTER TABLE libros
ADD CONSTRAINT FK_libros_codigoeditorial
		FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
GO
sp_helpconstraint libros;
GO
-- Al intentar borrar codigo en la Tabla Editoriales NO ACTION 
-- (No lo permite)
DELETE
	FROM editoriales
	WHERE codigo=2
GO
	
----	Msg 547, Level 16, State 0, Line 6
----The DELETE statement conflicted with the REFERENCE constraint "FK_libros_codigoeditorial". The conflict occurred in database "PruebasDB", table "dbo.libros", column 'codigoeditorial'.
----The statement has been terminated.

-- el error sale por ir contra la integridad referencial. 
-- Para corregirlo...

-- DISABLE CONSTRAINT

ALTER TABLE libros
		NOCHECK CONSTRAINT FK_libros_codigoeditorial
GO
sp_helpconstraint libros;
GO
ALTER TABLE libros
		DROP CONSTRAINT FK_libros_codigoeditorial;
GO

DELETE
	FROM editoriales
	WHERE codigo=2
GO
-- (1 row(s) affected)
	
SELECT * FROM Editoriales
GO

-- Rebuild Table Editoriales
SELECT * FROM Editoriales
GO
SELECT * FROM Libros
GO
--Caso 2: SET NULL
ALTER TABLE libros
ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales (codigo)
	ON DELETE     SET NULL
GO

DELETE
	FROM editoriales
	WHERE codigo=2;
GO

SELECT * FROM editoriales;
SELECT * FROM libros;	
GO

--Se ve como elimina la editorial 2 en la tabla padre, en la tabla hijo pone null en los libros con código 2 y 3
--Ahora restablecemos los valores

-- Practicando INSERT y UPDATE en lugar de regenerar las Tablas
insert into editoriales values(2,'Planeta');

UPDATE libros
		SET codigoeditorial = 2
		WHERE codigoeditorial IS NULL;
GO


--Caso 3: SET DEFAULT
--Nota: el valor DEFAULT tiene que existir en la tabla editoriales (padre), si no, no apuntaría a nada y se perdería la integridad referencial

ALTER TABLE libros
ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales (codigo)
	ON DELETE     SET DEFAULT;
GO
sp_help 'Editoriales'
GO
sp_help 'Libros'
GO
-- Código por defecto para Editorial 3
GO
DELETE
	FROM editoriales
	WHERE codigo=2;
GO

SELECT * FROM editoriales;
SELECT * FROM libros;	
GO
--Al eliminar un registro de la tabla padre, les asigna a sus hijos el valor del padre establecido por defecto

--codigo	titulo	autor	codigoeditorial
--1	El aleph	Borges	1
--2	Martin Fierro	Jose Hernandez	3
--3	Aprenda PHP	Mario Molina	3

--Caso 4: CASCADE

ALTER TABLE libros
ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales (codigo)
	ON DELETE CASCADE;
	--ON UPDATE CASCADE;
GO
sp_helpconstraint libros
GO
DELETE
	FROM editoriales
	WHERE codigo=2;
GO
-- (1 row(s) affected)

SELECT * FROM editoriales;
SELECT * FROM libros;	
GO
--Vemos cómo se eliminan los registros de la tabla libros que apuntan al registro eliminado de la tabla editoriales
-- Al Borrar Registro en Editoriales borra los relacionados en Libros

-- Tabla Editoriales

--codigo	nombre
--1	Emece
--3	Siglo XXI

-- Tabla Libros
--codigo	titulo	autor	codigoeditorial
--1	El aleph	Borges	1


---------------------------------------------------
--

USE Prueba
GO

-- Añadimos una restricción de clave foránea al campo 'codigoeditorial' de 'libros'
ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo);

-- Muestra la información sobre restricciones de una tabla
sp_helpconstraint libros;

-- Para deshabilitar una restricción
ALTER TABLE libros
	NOCHECK CONSTRAINT FK_libros_codigoeditorial ;

-- Para habilitar una restricción previamente deshabilitada
ALTER TABLE libros
	CHECK CONSTRAINT FK_libros_codigoeditorial ;

-- Para eliminar una restricción
ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;


--
--
if object_id('libros') is not null
	drop table libros;

if object_id('editoriales') is not null
	drop table editoriales;

create table libros(
	codigo int identity,
	titulo varchar(40),
	autor varchar(30),
	codigoeditorial tinyint default 1
);

create table editoriales(
	codigo tinyint,
	nombre varchar(20),
	primary key (codigo)
);

insert into editoriales values(1,'Emece');
insert into editoriales values(2,'Planeta');
insert into editoriales values(3,'Siglo XXI');
insert into libros values('El aleph','Borges',1);
insert into libros values('Martin Fierro','Jose Hernandez',2);
insert into libros values('Aprenda PHP','Mario Molina',2);

-- Caso 1: NO ACTION
ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo);
	
DELETE 
	FROM editoriales
	WHERE  codigo = 2;

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;

-- Caso 2: SET NULL
ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
	ON DELETE
		SET NULL ;
	
DELETE 
	FROM editoriales
	WHERE  codigo = 2;

SELECT *
	FROM editoriales

SELECT *
	FROM libros

INSERT INTO editoriales
	VALUES ( 2, 'Planeta' );

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;

sp_helpconstraint libros ;

-- Caso 3: SET DEFAULT
ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
	ON DELETE
		SET DEFAULT ;
	
DELETE 
	FROM editoriales
	WHERE  codigo = 2;

SELECT *
	FROM editoriales

SELECT *
	FROM libros

INSERT INTO editoriales
	VALUES ( 2, 'Planeta' );

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;

sp_helpconstraint libros ;

-- Caso 4: CASCADE

USE Prueba
GO

ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
	ON DELETE
		CASCADE
	ON UPDATE
		CASCADE ;

SELECT * 
	FROM libros ;

SELECT *
	FROM editoriales ;

DELETE 
	FROM editoriales
	WHERE  codigo = 2;

UPDATE editoriales
	SET codigo = 10
	WHERE codigo = 1 ;

SELECT *
	FROM editoriales

SELECT *
	FROM libros

--
--
ALTER TABLE clientes
	ADD CONSTRAINT FK_clientes_codigoprovincia
	FOREIGN KEY (codigoprovincia)
	REFERENCES provincias(codigo)
	ON UPDATE
		CASCADE
	ON DELETE
		NO ACTION ;

DELETE
	FROM provincias
	WHERE codigo = 3 ;

UPDATE provincias
	SET codigo = 9
	WHERE codigo = 3 ;

SELECT *
	FROM provincias ;
	
SELECT *
	FROM clientes ;

ALTER TABLE clientes
	DROP CONSTRAINT FK_clientes_codigoprovincia ;

ALTER TABLE clientes 
	ADD CONSTRAINT FK_clientes_codigoprovincia
	FOREIGN KEY (codigoprovincia)
	REFERENCES provincias(codigo)
	ON UPDATE
		CASCADE
	ON DELETE
		CASCADE ;

sp_helpconstraint clientes ;

EXEC sp_helpconstraint provincias ;

--
--
ALTER TABLE clientes
	DROP CONSTRAINT FK_clientes_codigoprovincia ;

ALTER TABLE clientes 
	ADD CONSTRAINT FK_clientes_codigoprovincia
	FOREIGN KEY (codigoprovincia)
	REFERENCES provincias(codigo)
	ON DELETE
		SET NULL ;
	-- no da información correcta en la información de constraints (no action)

sp_helpconstraint clientes ;

EXEC sp_helpconstraint provincias ;

-----------------------------
-- Example DataBase Pubs
-- 
USE Pubs
GO
-- Backup Pubsthen restoring
-- Tables Authors TitleAuthor Titles
-- Doing Diagram
-- Deleting Title ON CASCADE Delete Reference in TitleAuthor
-- TitleAuthor.title_id is FK with titles
SELECT authors.au_fname, authors.au_lname, titles.title,TitleAuthor.title_id
   FROM authors   INNER JOIN TitleAuthor
   ON authors.au_id = TitleAuthor.au_id
   INNER JOIN titles 
   ON TitleAuthor.title_id = titles.title_id
   WHERE au_lname = 'Ringer' AND au_fname='Anne'
   ORDER BY authors.au_lname
GO
SELECT COUNT(*) as titulos FROM titles
GO
-- 18
SELECT COUNT(*) as referencias FROM titleauthor
GO
-- 25

--au_fname	au_lname	title
--Anne	Ringer	The Gourmet Microwave
--Anne	Ringer	Is Anger the Enemy?

EXEC sp_helpconstraint titles
GO
-- pubs.dbo.titleauthor: FK__titleauth__title__1ED998B2
EXEC sp_helpconstraint titleauthor
GO
-- To modify a check constraint
-- To modify a CHECK constraint using Transact-SQL, you must first delete the existing CHECK constraint and then re-create it with the new definition. For more information, see Delete Check Constraints and Create Check Constraints

-- Going [dbo].[titleauthor] GUI 
-- [FK__titleauth__title__1ED998B2]
-- MOdify changing CASCADE

ALTER TABLE [dbo].[titleauthor] 
DROP CONSTRAINT [FK__titleauth__title__1ED998B2]
GO
-- Command(s) completed successfully.

--Msg 547, Level 16, State 0, Procedure Borrar_Referencias_Titulos, Line 511
--The DELETE statement conflicted with the REFERENCE constraint "FK__sales__title_id__24927208". The conflict occurred in database "pubs", table "dbo.sales", column 'title_id'.
--The statement has been terminated.
ALTER TABLE [dbo].[sales]
NOCHECK CONSTRAINT [FK__sales__title_id__24927208]
GO

ALTER TABLE [dbo].[roysched]
NOCHECK CONSTRAINT [FK__roysched__title___267ABA7A]
GO
-- Command(s) completed successfully.
ALTER TABLE Person.ContactBackup
ADD CONSTRAINT FK_ContactBacup_Contact FOREIGN KEY (ContactID)
    REFERENCES Person.Person (BusinessEntityID) ;
GO
ALTER TABLE [dbo].[titleauthor]  
ADD CONSTRAINT FK_Titulo_TituloAutor FOREIGN KEY([title_id])
REFERENCES [dbo].[titles] ([title_id])
ON DELETE CASCADE
ON UPDATE CASCADE
GO
-- Command(s) completed successfully.


-- With SP
IF OBJECT_ID('Borrar_Titulos_Referencias','P') is not null 
	DROP PROCEDURE Borrar_Titulos_Referencias
GO
ALTER PROC Borrar_Referencias_Titulos
	@Apellidos Varchar(50),@Nombre Varchar(50)
AS
BEGIN
DELETE Titles
WHERE Titles.title_id IN 
           (SELECT  t.title_id
		    FROM authors a JOIN titleauthor t
			ON a.au_id = t.au_id
            WHERE au_lname = @Apellidos AND au_fname=@Nombre)
END
GO

-- If Not CASCADE
--Msg 547, Level 16, State 0, Procedure Borrar_Referencias_Titulos, Line 491
--The DELETE statement conflicted with the REFERENCE constraint "FK__titleauth__title__1ED998B2". The conflict occurred in database "pubs", table "dbo.titleauthor", column 'title_id'.
--The statement has been terminated.


EXECUTE Borrar_Referencias_Titulos  @Apellidos='Dull', @Nombre= 'Ann'
GO
EXEC Borrar_Referencias_Titulos  @Apellidos='Panteley', @Nombre= 'Sylvia'
GO
EXEC Borrar_Referencias_Titulos  @Apellidos='Ringer', @Nombre= 'Anne'
GO
SELECT COUNT(*) as titulos FROM titles
GO
-- 18
SELECT COUNT(*) as referencias FROM titleauthor
GO
-- 25
---------------------

--Otro ejemplo: documento 'SQL Server Foreign Key Update.....'

-- Create child table
IF EXISTS (SELECT * FROM sys.objects
WHERE name = N'EmpEducation' AND [type] = 'U')
DROP TABLE EmpEducation

CREATE TABLE EmpEducation
	(
		EduID SMALLINT IDENTITY(1,1) PRIMARY KEY,
		empno SMALLINT NULL DEFAULT 100,
		DegreeTitle VARCHAR(50)
	)
GO

-- Create parent table
IF EXISTS (SELECT * FROM sys.objects
WHERE name = N'employees' AND [type] = 'U')
DROP TABLE employees

CREATE TABLE employees
	(
		empno SMALLINT PRIMARY KEY ,
		EmpName VARCHAR(70)
	)
GO

-- Create FK relationship
IF EXISTS (SELECT * FROM sys.objects
WHERE name = N'FK_EmpEducation_Employees' AND [type] = 'F')
ALTER TABLE EmpEducation
DROP Constraint FK_EmpEducation_Employees
GO

ALTER TABLE EmpEducation
ADD CONSTRAINT [FK_EmpEducation_Employees]
	FOREIGN KEY (empno)REFERENCES employees(empno)
GO 

-- Insert records in parent table
INSERT INTO employees
	SELECT 1, 'Atif' UNION ALL
	SELECT 2, 'Shehzad' UNION ALL
	SELECT 3, 'khurram' UNION ALL
	SELECT 4, 'Ahmed' UNION ALL
	SELECT 5, 'Uzair'
GO

-- Insert records in parent table
INSERT INTO EmpEducation
	SELECT 1, 'MS' UNION ALL
	SELECT 2, 'MBA' UNION ALL
	SELECT 1, 'BS' UNION ALL
	SELECT 2, 'MS' UNION ALL
	SELECT 3, 'BS'
GO 

-- Caso 1: Update and delete with 'No Action' rule
-- Try to update referenced PK
UPDATE Employees
SET empno = 100 WHERE empno = 1
GO
--Error:
		--Msg 547, Level 16, State 0, Line 1
		--The UPDATE statement conflicted with the REFERENCE constraint "FK_EmpEducation_Employees". The conflict occurred in database "PruebasDB", table "dbo.EmpEducation", column 'empno'.
		--The statement has been terminated.

 --Try to delete record with referenced PK
DELETE FROM Employees
WHERE empno = 2
GO  
--Error:
		--Msg 547, Level 16, State 0, Line 1
		--The DELETE statement conflicted with the REFERENCE constraint "FK_EmpEducation_Employees". The conflict occurred in database "PruebasDB", table "dbo.EmpEducation", column 'empno'.
		--The statement has been terminated.
		
-- Caso 4: Create FK relationship with CASCADE
-- Create FK relationship
IF EXISTS (SELECT * FROM sys.objects
WHERE name = N'FK_EmpEducation_Employees' AND [type] = 'F')
ALTER TABLE EmpEducation
	DROP Constraint FK_EmpEducation_Employees
GO
ALTER TABLE EmpEducation
ADD CONSTRAINT [FK_EmpEducation_Employees]
FOREIGN KEY (empno)REFERENCES employees(empno)
ON DELETE CASCADE ON UPDATE CASCADE 
GO 

--Si ahora ejecutamos la sentecia siguiente aplicará a la tabla hijo
--los cambios que hagamos en la tabla padre
UPDATE Employees
SET empno = 100 WHERE empno = 1
GO
DELETE FROM Employees
WHERE empno = 2
GO 

SELECT * FROM employees;
SELECT * FROM EmpEducation;



-----------------------

-- Integridad REferencial On DELETE / UPDATE

--NO ACTION
--CASCADE
--SET NULL
--SET DEFAULT


-- Trabajando con borrados/Actualizaciones
--
Create database pruebasdb
go
USE PruebasDB
GO


if object_id('libros') is not null
	drop table libros;

if object_id('editoriales') is not null
	drop table editoriales;

create table libros(
	codigo int identity,
	titulo varchar(40),
	autor varchar(30),
	codigoeditorial tinyint default 1
);

create table editoriales(
	codigo tinyint,
	nombre varchar(20),
	primary key (codigo)
);

insert into editoriales values(1,'Emece');
insert into editoriales values(2,'Planeta');
insert into editoriales values(3,'Siglo XXI');

insert into libros values('El aleph','Borges',1);
insert into libros values('Martin Fierro','Jose Hernandez',2);
insert into libros values('Aprenda PHP','Mario Molina',2);


-- Añadimos una restricción de clave foránea al campo 'codigoeditorial' de 'libros'

ALTER TABLE libros
ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo);
GO

-- Muestra la información sobre restricciones de una tabla

sp_helpconstraint libros;

-- Para deshabilitar una restricción
ALTER TABLE libros
	NOCHECK CONSTRAINT FK_libros_codigoeditorial ;

-- Para habilitar una restricción previamente deshabilitada
ALTER TABLE libros
	CHECK CONSTRAINT FK_libros_codigoeditorial ;

-- Para eliminar una restricción

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;


-- Caso 1: NO ACTION

ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo);


	
DELETE 
	FROM editoriales
	WHERE  codigo = 2;


--Msg 547, Level 16, State 0, Line 1
--The DELETE statement conflicted with the REFERENCE constraint "FK_libros_codigoeditorial". The conflict occurred in database "pruebasdb", table "dbo.libros", column 'codigoeditorial'.
--The statement has been terminated.

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;

-- Again DELETE and works
-- (1 row(s) affected)

-- Caso 2: SET NULL

ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
	ON DELETE	SET NULL ;
	
SELECT *
	FROM editoriales

SELECT *
	FROM libros
	
DELETE 
	FROM editoriales
	WHERE  codigo = 2;

SELECT *
	FROM editoriales

SELECT *
	FROM libros

INSERT INTO editoriales
	VALUES ( 2, 'Planeta' );

UPDATE sobre Libros

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;

sp_helpconstraint libros ;

-- Caso 3: SET DEFAULT
Nota: Puedes poner 1 2 3 sino no funciona en Libros

ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
	ON DELETE
		SET DEFAULT ;
SELECT *
	FROM editoriales

SELECT *
	FROM libros
	
DELETE 
	FROM editoriales
	WHERE  codigo = 2;

SELECT *
	FROM editoriales

SELECT *
	FROM libros

INSERT INTO editoriales
	VALUES ( 2, 'Planeta' );

ALTER TABLE libros
	DROP CONSTRAINT FK_libros_codigoeditorial ;

sp_helpconstraint libros ;

-- Caso 4: CASCADE
ALTER TABLE libros
	ADD CONSTRAINT FK_libros_codigoeditorial
	FOREIGN KEY (codigoeditorial) REFERENCES editoriales(codigo)
	ON DELETE
		CASCADE
	ON UPDATE
		CASCADE ;


DELETE 
	FROM editoriales
	WHERE  codigo = 2;

UPDATE editoriales
	SET codigo = 10
	WHERE codigo = 1 ;

SELECT *
	FROM editoriales

SELECT *
	FROM libros

--
--
ALTER TABLE clientes
	ADD CONSTRAINT FK_clientes_codigoprovincia
	FOREIGN KEY (codigoprovincia)
	REFERENCES provincias(codigo)
	ON UPDATE
		CASCADE
	ON DELETE
		NO ACTION ;

DELETE
	FROM provincias
	WHERE codigo = 3 ;

UPDATE provincias
	SET codigo = 9
	WHERE codigo = 3 ;

SELECT *
	FROM provincias ;
	
SELECT *
	FROM clientes ;

ALTER TABLE clientes
	DROP CONSTRAINT FK_clientes_codigoprovincia ;

ALTER TABLE clientes 
	ADD CONSTRAINT FK_clientes_codigoprovincia
	FOREIGN KEY (codigoprovincia)
	REFERENCES provincias(codigo)
	ON UPDATE
		CASCADE
	ON DELETE
		CASCADE ;

sp_helpconstraint clientes ;

EXEC sp_helpconstraint provincias ;

--
--
ALTER TABLE clientes
	DROP CONSTRAINT FK_clientes_codigoprovincia ;

ALTER TABLE clientes 
	ADD CONSTRAINT FK_clientes_codigoprovincia
	FOREIGN KEY (codigoprovincia)
	REFERENCES provincias(codigo)
	ON DELETE
		SET NULL ;
	-- no da información correcta en la información de constraints (no action)

sp_helpconstraint clientes ;

EXEC sp_helpconstraint provincias ;

