-- sqlserver ya
uSE Tempdb
GO
if object_id ('libros') is not null
  drop table libros;
-- Creamos la tabla:

 create table libros(
  codigo int identity,
  titulo varchar(40) not null,
  autor varchar(20) default 'Desconocido',
  editorial varchar(20),
  precio decimal(6,2),
  primary key(codigo)
 );
Ingresamos algunos registros:

 insert into libros
  values('El aleph','Borges','Emece',15.90);
 insert into libros
  values('Antología poética','J. L. Borges','Planeta',null);
 insert into libros
  values('Alicia en el pais de las maravillas','Lewis Carroll',null,19.90);
 insert into libros
  values('Matematica estas ahi','Paenza','Siglo XXI',15);
 insert into libros
  values('Martin Fierro','Jose Hernandez',default,40);
 insert into libros
  values('Aprenda PHP','Mario Molina','Nuevo siglo',null);
 insert into libros
  values('Uno','Richard Bach','Planeta',20);

--
  select *
  from libros
  GO

  -- (7 row(s) affected)



-- Averiguemos la cantidad de libros usando la función "count()":

 select count(*) AS NúmerodeLibros
  from libros
GO

-- Nota que incluye todos los libros aunque tengan valor nulo en algún campo.

-- Contamos los libros de editorial "Planeta":

 select count(*) AS NúmerodeLibros
  from libros
  where editorial='Planeta';
GO

--2

-- Contamos los registros que tienen precio (sin tener en cuenta los que tienen valor nulo),
--  usando la función "count(precio)":
select count(*) AS NúmerodeLibros
  from libros
GO
-- 7

 select count(precio) AS NúmerodeLibros
  from libros
GO
-- 5
select count(titulo) AS NúmerodeLibros
  from libros
GO
select count(editorial) AS NúmerodeLibros
  from libros
GO
-- 5
select  count(*) AS NúmerodeLibros
  from libros
GO
select  editorial AS NúmerodeLibros
  from libros
GO
-- 7
select count(distinct editorial) AS NúmerodeLibros
  from libros
GO
-- 4

-- Ejemplos COUNT 

USE AdventureWorks2014
GO
SELECT  JobTitle
FROM HumanResources.Employee
where JobTitle is not null
GO
-- 290


SELECT  DISTINCT JobTitle
FROM HumanResources.Employee
where JobTitle is not null
GO

-- (67 row(s) affected)


SELECT  DISTINCT JobTitle Titulos   -- Cabecera
FROM HumanResources.Employee
ORDER BY 1 
GO

-- (67 row(s) affected)


-- Crear Tabla Empleados   SELECT / INTO
Select [BusinessEntityID],[NationalIDNumber],[JobTitle]
INTO Empleados
FROM HumanResources.Employee
Where [Gender]='F'
GO
-- 84
-- Nota: Empleados no tendrá PK


select * 
from Empleados
where JobTitle is not null
GO
-- (84 row(s) affected)

select * 
from Empleados
where JobTitle is null
GO
-- 0
--  Count(*)
SELECT  Count(*) as Empleados
FROM Empleados
GO
--84

-- Count(Campo)
SELECT  Count(JobTitle) Titulos
FROM Empleados
GO
--84
SELECT  Count(DISTINCT JobTitle) Titulos
FROM Empleados
GO
-- 36

Update Empleados
SET JobTitle = NULL
WHERE BusinessEntityId = 2
Go
--Mens. 515, Nivel 16, Estado 2, Línea 1
--No se puede insertar el valor NULL en la columna 'JobTitle', 
--tabla 'AdventureWorks2014.dbo.Empleados'. 
-- La columna no admite valores NULL. Error de UPDATE.
--Se terminó la instrucción.

-- Modifico esta Constraint
ALTER TABLE dbo.Empleados 
ALTER COLUMN [JobTitle]  nvarchar(50) NULL
GO

Update Empleados
SET JobTitle = NULL
WHERE BusinessEntityId = 2
Go

-- (1 filas afectadas)

-- No cuenta NULL

SELECT  Count(JobTitle)
FROM Empleados
GO
 
-- 83

-- Contar sin Duplicados
-- 
SELECT  JobTitle as Titulos
FROM HumanResources.Employee
GO


SELECT  Count(JobTitle)
FROM HumanResources.Employee
GO
-- 290
SELECT  Count(DISTINCT JobTitle)
FROM HumanResources.Employee
GO
-- 67
