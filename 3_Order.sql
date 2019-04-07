--Departamento comercial necesita saber el precio de venta promedio 
-- de cada producto

Use [Northwind]

Select Productid, avg(unitprice) as Precio
from [Order Details]
group by productid
order by 1
-- Mostar un listado de las ciudades en orden del numero de clientes 

select city, count(*) Numero
from customers
group by city
order by count(*) desc

--
-- Creamos

BD PruebasDb
Tabla Libros
--
CREATE DATABASE PruebasDB
go
USE PruebasDB
GO

USE Prueba

GO
IF OBJECT_ID ('Libros') IS NOT NULL
	DROP TABLE Libros ;

CREATE TABLE Libros (
	codigo INT IDENTITY,
	titulo VARCHAR(40) NOT NULL,
	autor VARCHAR(20) DEFAULT 'Desconocido',
	editorial VARCHAR(20),
	precio DECIMAL(6,2),
	cantidad TINYINT,
	PRIMARY KEY(codigo) );

INSERT INTO libros
	VALUES ('El aleph', 'Borges', 'Planeta', 15, NULL);
INSERT INTO libros
	VALUES ('Martin Fierro', 'Jose Hernandez', 'Emece', 22.20, 200);
INSERT INTO libros
	VALUES ('Antologia poetica', 'J.L. Borges', 'Planeta', NULL, 150);
INSERT INTO libros
	VALUES ('Aprenda PHP', 'Mario Molina', 'Emece', 18.20, NULL);
INSERT INTO libros
	VALUES ('Cervantes y el quijote', 'Bioy Casares- J.L. Borges', 'Paidos', NULL, 100);
INSERT INTO libros
	VALUES ('Manual de PHP', 'J.C. Paez', 'Siglo XXI', 31.80, 120);
INSERT INTO libros
	VALUES ('Harry Potter y la piedra filosofal', 'J.K. Rowling', DEFAULT, 45.00, 90);
INSERT INTO libros
	VALUES ('Harry Potter y la camara secreta', 'J.K. Rowling', 'Emece', 46.00, 100);
INSERT INTO libros (titulo, autor, cantidad)
	VALUES ('Alicia en el pais de las maravillas', 'Lewis Carroll', 220);
INSERT INTO libros (titulo, autor, cantidad)
	VALUES ('PHP de la A a la Z', DEFAULT, 0);
go
select * from Libros
go






-- ORDER By

-- Recuperar registros ordenados por título

SELECT *
	FROM libros
	ORDER BY titulo ;   -- Ascendente Por Defecto

SELECT *
	FROM libros
	ORDER BY codigo;
GO

SELECT *
	FROM libros
	ORDER BY codigo DESC;
GO




SELECT *
	FROM libros
	ORDER BY editorial;
GO
-- NULL arriba



-- Recuperar registros ordenados por editorial de mayor a menor 
-- usando 'desc'
SELECT *
	FROM libros
	ORDER BY editorial DESC;
GO


-- Recuperar registros ordenados por 2 criterios

SELECT titulo,editorial
	FROM libros
	ORDER BY editorial, titulo ;
GO
SELECT titulo,editorial
	FROM libros
	where editorial is not null
	ORDER BY editorial, titulo ;
GO

SELECT titulo,editorial
	FROM libros
	ORDER BY  titulo,editorial ;
GO


SELECT *
	FROM libros
	ORDER BY editorial, titulo DESC;
GO

-- Recuperar registros ordenados por 2 campos en distinto sentido
 
SELECT editorial,titulo
	FROM libros
	-- where editorial is not null
	ORDER BY  editorial DESC, titulo ASC;
GO




-- Recuperar registros ordenados por un campo que no aparece en el resultado

SELECT titulo, autor
	FROM libros
	ORDER BY precio DESC;
GO
-- Recuperar registros ordenados por precio indicado por su posición

SELECT titulo, autor, precio
	FROM libros
	ORDER BY 3 ;
GO




-- Recuperar registros ordenados por un campo calculado
SELECT titulo, autor, editorial, precio-(precio*0.1) AS 'Precio con descuento'
	FROM libros
	ORDER BY 4 ;
GO

----------------
-- Order By . Con Función de Fecha

USE AdventureWorks2014;
Go

SELECT HireDate
FROM HumanResources.Employee
GO


SELECT BusinessEntityID, JobTitle, HireDate, DATEPART(year, HireDate) AS ' Año Contrato'
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate);
GO


SELECT JobTitle, HireDate, year( HireDate) AS ' Año Contrato'
FROM HumanResources.Employee
ORDER BY year(HireDate);
GO


-- DESC
SELECT BusinessEntityID, JobTitle, HireDate, DATEPART(year, HireDate) AS ' Año Contrato'
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate) DESC
GO
-- Nota Podemos usar 'Año Contrato'

SELECT BusinessEntityID, JobTitle, HireDate, DATEPART(year, HireDate) AS 'Año Contrato'
FROM HumanResources.Employee
ORDER BY 'Año Contrato'
GO

-- Ordenar por Año Mes Dia
SELECT BusinessEntityID, JobTitle, HireDate,  DATEPART(year, HireDate) AS 'Año Contrato',
DATEPART(month, HireDate) AS 'Mes Contrato',DATEPART(day, HireDate) AS 'Dia Contrato'
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate),DATEPART(month, HireDate),DATEPART(day, HireDate)
GO



SELECT BusinessEntityID, JobTitle, HireDate, DATEPART(day, HireDate) AS 'Dia Contrato' ,
DATEPART(month, HireDate) AS 'Mes Contrato',DATEPART(year, HireDate) AS 'Año Contrato'
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate) DESC ,DATEPART(month, HireDate) DESC ,DATEPART(day, HireDate) DESC
GO

-- DESC

SELECT BusinessEntityID, JobTitle, HireDate,  DATEPART(year, HireDate) AS 'Año Contrato',
DATEPART(month, HireDate) AS 'Mes Contrato',DATEPART(day, HireDate) AS 'Dia Contrato'
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate) DESC ,DATEPART(month, HireDate) DESC ,DATEPART(day, HireDate) DESC
GO





-------------------------------------

-- Order By con Funcion Fecha

CREATE DATABASE Visitas
GO
USE Visitas
GO
 if object_id('visitas') is not null
  drop table visitas;

2- Créela con la siguiente estructura:
 create table visitas (
  numero int identity,
  nombre varchar(30) default 'Anonimo',
  mail varchar(50),
  pais varchar (20),
  fecha datetime,
  primary key(numero)
);

3- Ingrese algunos registros:
 insert into visitas (nombre,mail,pais,fecha)
  values ('Ana Maria Lopez','AnaMaria@hotmail.com','Argentina','2006-10-10 10:10');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Gustavo Gonzalez','GustavoGGonzalez@hotmail.com','Chile','2006-10-10 21:30');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-10-11 15:45');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Fabiola Martinez','MartinezFabiola@hotmail.com','Mexico','2006-10-12 08:15');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Fabiola Martinez','MartinezFabiola@hotmail.com','Mexico','2006-09-12 20:45');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-09-12 16:20');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-09-15 16:25');

-- Ordene los registros por fecha, en orden descendente.

select *
from visitas
order by fecha -- desc;


 -- Muestre el nombre del usuario, pais y el nombre del mes, ordenado por pais (ascendente) y nombre 
-- del mes (descendente)

 select nombre,pais,datename(month,fecha) as 'Nombre Mes'
  from visitas
  order by pais,datename(month,fecha) desc;

 --  Muestre el pais, el mes, el día y la hora y ordene las visitas por 
 -- nombre del mes, del día y la hora.

 select nombre,mail,
  datename(month,fecha) as mes,--3
  datename(day,fecha) as dia,
  datename(hour,fecha) as hora
  from visitas
  order by 3,4,5 desc -- datename(month,fecha),
  GO


select nombre,mail,
  datename(month,fecha) as mes,--3
  datename(day,fecha) as dia,
  datename(hour,fecha) as hora
  from visitas
  order by  datename(month,fecha),datename(day,fecha),datename(hour,fecha)
  GO
-- Muestre los mail, país, ordenado por país, de todos los que visitaron la página en octubre (4 
-- registros)

 select mail, pais
  from visitas
  where datename(month,fecha)='October'
  -- where datename(month,fecha)='Octubre'
  order by 2;

DROP DATABASE Visitas
GO
---------------------------------
-- 
USE AdventureWorks2014
GO

-- Con Predicado LIKE
SELECT ProductID, Name 
FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID DESC;
GO

SELECT BusinessEntityID, SalariedFlag
FROM HumanResources.Employee
ORDER BY CASE SalariedFlag WHEN 1 THEN BusinessEntityID END DESC
        ,CASE WHEN SalariedFlag = 0 THEN BusinessEntityID END;
GO

-- No
SELECT BusinessEntityID, LastName, TerritoryName, CountryRegionName
FROM Sales.vSalesPerson
WHERE TerritoryName IS NOT NULL
ORDER BY CASE CountryRegionName WHEN 'United States' THEN TerritoryName
         ELSE CountryRegionName END;
GO
-- Skip the first 5 rows from the sorted result set and return all 
--remaining rows.

SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID
GO

SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID OFFSET 5 ROWS;
GO
-- Skip 3 rows and return only the first 4 rows from the sorted result set.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID 
    OFFSET 3 ROWS
    FETCH NEXT 4 ROWS ONLY
GO


----------------


-----
En una página web se guardan los siguientes datos de las visitas: número de visita, nombre, mail, 
pais, fecha.
1- Elimine la tabla "visitas", si existe:
 if object_id('visitas') is not null
  drop table visitas;

2- Créela con la siguiente estructura:
 create table visitas (
  numero int identity,
  nombre varchar(30) default 'Anonimo',
  mail varchar(50),
  pais varchar (20),
  fecha datetime,
  primary key(numero)
);

3- Ingrese algunos registros:
 insert into visitas (nombre,mail,pais,fecha)
  values ('Ana Maria Lopez','AnaMaria@hotmail.com','Argentina','2006-10-10 10:10');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Gustavo Gonzalez','GustavoGGonzalez@hotmail.com','Chile','2006-10-10 21:30');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-10-11 15:45');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Fabiola Martinez','MartinezFabiola@hotmail.com','Mexico','2006-10-12 08:15');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Fabiola Martinez','MartinezFabiola@hotmail.com','Mexico','2006-09-12 20:45');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-09-12 16:20');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-09-15 16:25');

4- Ordene los registros por fecha, en orden descendente.

5- Muestre el nombre del usuario, pais y el nombre del mes, ordenado por pais (ascendente) y nombre 
del mes (descendente)

6- Muestre el pais, el mes, el día y la hora y ordene las visitas por nombre del mes, del día y la 
hora.

7- Muestre los mail, país, ordenado por país, de todos los que visitaron la página en octubre (4 
registros)

if object_id('visitas') is not null
  drop table visitas;

 create table visitas (
  numero int identity,
  nombre varchar(30) default 'Anonimo',
  mail varchar(50),
  pais varchar (20),
  fecha datetime,
  primary key(numero)
);

 insert into visitas (nombre,mail,pais,fecha)
  values ('Ana Maria Lopez','AnaMaria@hotmail.com','Argentina','2006-10-10 10:10');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Gustavo Gonzalez','GustavoGGonzalez@hotmail.com','Chile','2006-10-10 21:30');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-10-11 15:45');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Fabiola Martinez','MartinezFabiola@hotmail.com','Mexico','2006-10-12 08:15');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Fabiola Martinez','MartinezFabiola@hotmail.com','Mexico','2006-09-12 20:45');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-09-12 16:20');
 insert into visitas (nombre,mail,pais,fecha)
  values ('Juancito','JuanJosePerez@hotmail.com','Argentina','2006-09-15 16:25');

 select *from visitas
  order by fecha desc;

 select nombre,pais,datename(month,fecha)
  from visitas
  order by pais,datename(month,fecha) desc;

 select nombre,mail,
  datename(month,fecha) mes,
  datename(day,fecha) dia,
  datename(hour,fecha) hora
  from visitas
  order by 3,4,5;

 select mail, pais
  from visitas
  where datename(month,fecha)='Octubre'
  order by 2;
----------------------------
ORDER BY

http://msdn.microsoft.com/es-es/library/ms188385.aspx


 En el siguiente ejemplo se ordena el conjunto de resultados por la columna numérica ProductID. Dado que no se especifica un criterio de ordenación concreto, se utiliza el valor predeterminado (orden ascendente). 

USE AdventureWorks2014;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID;

B.Especificar una columna que no está definida en la lista de selección

En el siguiente ejemplo se ordena el conjunto de resultados por una columna que no está incluida en la lista de selección, pero sí definida en la tabla especificada en la cláusula FROM. 

USE AdventureWorks2014;
GO
SELECT ProductID, Name, Color
FROM Production.Product
ORDER BY ListPrice;


C.Especificar un alias como columna de ordenación

En el ejemplo siguiente se especifica el alias de columna SchemaName como columna de criterio de ordenación. 

USE AdventureWorks2014;
GO
SELECT name, SCHEMA_NAME(schema_id) AS SchemaName
FROM sys.objects
WHERE type = 'U'
ORDER BY SchemaName;

D.Especificar una expresión como columna de ordenación

En el ejemplo siguiente se utiliza una expresión como columna de ordenación. La expresión se define mediante la función DATEPART para ordenar el conjunto de resultados según el año de contratación de los empleados. 

USE AdventureWorks2014;
Go
SELECT BusinessEntityID, JobTitle, HireDate
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate);


A.Especificar un orden descendente

En el siguiente ejemplo se ordena el conjunto de resultados en sentido descendente según la columna numérica ProductID.
Transact-SQL

USE AdventureWorks2014;
GO
SELECT ProductID, Name 
FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID DESC;







En este ejemplo solo se devuelven las filas de Product que tienen una línea de productos de R y cuyo valor correspondiente a los días para fabricar es inferior a 4.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R' 
AND DaysToManufacture < 4
ORDER BY Name ASC;
GO

B.Especificar un orden ascendente

En el siguiente ejemplo se ordena el conjunto de resultados en orden ascendente según la columna Name. Observe que los caracteres están ordenados alfabéticamente, no numéricamente. Es decir, 10 se ordena antes que 2.
Transact-SQL

USE AdventureWorks2014;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY Name ASC ;


C.Especificar orden ascendente y también descendente

En el siguiente ejemplo se ordena el conjunto de resultados según dos columnas. El conjunto de resultados se ordena en primer lugar en sentido ascendente según la columna FirstName y, a continuación, en orden descendente según la columna LastName.
Transact-SQL

USE AdventureWorks2014;
GO
SELECT LastName, FirstName FROM Person.Person
WHERE LastName LIKE 'R%'
ORDER BY FirstName ASC, LastName DESC ;


Especificar un orden condicional

En los ejemplos siguientes se utiliza la expresión CASE en una cláusula ORDER BY para determinar de manera condicional el criterio de ordenación de las filas según el valor de una columna dada. En el primer ejemplo se evalúe el valor de la columna SalariedFlag de la tabla HumanResources.Employee. Los empleados que tienen la columna SalariedFlag establecida en 1 se devuelven en orden descendente según el BusinessEntityID. Los empleados que tienen la columna SalariedFlag establecida en 0 se devuelven en orden ascendente según el BusinessEntityID. En el segundo ejemplo, el conjunto de resultados se ordena según la columna TerritoryName cuando la columna CountryRegionName es igual a 'United States' y según la columna CountryRegionName en las demás filas.
Transact-SQL

SELECT BusinessEntityID, SalariedFlag
FROM HumanResources.Employee
ORDER BY CASE SalariedFlag WHEN 1 THEN BusinessEntityID END DESC
        ,CASE WHEN SalariedFlag = 0 THEN BusinessEntityID END;
GO


Transact-SQL

SELECT BusinessEntityID, LastName, TerritoryName, CountryRegionName
FROM Sales.vSalesPerson
WHERE TerritoryName IS NOT NULL
ORDER BY CASE CountryRegionName WHEN 'United States' THEN TerritoryName
         ELSE CountryRegionName END;

A.Especificar constantes enteras para los valores de OFFSET y FETCH

En el siguiente ejemplo se especifica una constante entera como valor para las cláusulas OFFSET y FETCH. La primera consulta devuelve todas las filas ordenadas según la columna DepartmentID. Compare los resultados devueltos por esta consulta con los de las dos consultas siguientes. La consulta siguiente utiliza la cláusula OFFSET 5 ROWS para omitir las primeras 5 filas y devolver todas las restantes. La última consulta utiliza la cláusula OFFSET 0 ROWS para comenzar por la primera fila y, a continuación, utiliza FETCH NEXT 10 ROWS ONLY para limitar las filas devueltas a 10 filas del conjunto de resultados ordenado.
Transact-SQL


USE AdventureWorks2014;
GO
-- Return all rows sorted by the column DepartmentID.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID;

-- Skip the first 5 rows from the sorted result set and return all remaining rows.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID OFFSET 5 ROWS;

-- Skip 0 rows and return only the first 10 rows from the sorted result set.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID 
    OFFSET 0 ROWS
    FETCH NEXT 10 ROWS ONLY;


B.Especificar variables para los valores de OFFSET y FETCH

En el siguiente ejemplo se declaran las variables @StartingRowNumber y @FetchRows, y se especifican estas variables en las cláusulas OFFSET y FETCH.
Transact-SQL

USE AdventureWorks2014;
GO
-- Specifying variables for OFFSET and FETCH values  
DECLARE @StartingRowNumber tinyint = 1
      , @FetchRows tinyint = 8;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber ROWS 
    FETCH NEXT @FetchRows ROWS ONLY;


Usar ORDER BY con UNION, EXCEPT e INTERSECT

Cuando una consulta utiliza los operadores UNION, EXCEPT o INTERSECT, la cláusula ORDER BY se debe especificar al final de la instrucción y se ordenan los resultados de las consultas combinadas. En el siguiente ejemplo se devuelven todos los productos que son rojos o amarillos y la lista combinada se ordena según la columna ListPrice.
Transact-SQL

USE AdventureWorks2014;
GO
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Red'
-- ORDER BY cannot be specified here.
UNION ALL
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Yellow'
ORDER BY ListPrice ASC;




http://www.c-sharpcorner.com/uploadfile/6897bc/group-by-and-order-by-clause-in-sql-2005/

http://www.c-sharpcorner.com/UploadFile/rohatash/using-having-clause-in-sql-server-2012/



---------------

COUNT
-----------------------
http://msdn.microsoft.com/es-es/library/ms175997.aspx

 Si los valores devueltos son superiores a 2^31-1, COUNT genera un error. En su lugar, utilice COUNT_BIG.
Ejemplos
A.Usar COUNT y DISTINCT

En el ejemplo siguiente se muestra el número de cargos diferentes que puede tener un empleado 
que trabaja en Adventure Works Cycles.

USE AdventureWorks2014;
GO
SELECT COUNT(DISTINCT Title)
FROM HumanResources.Employee;
GO

El conjunto de resultados es el siguiente.

-----------

67

(1 row(s) affected)
B.Usar COUNT(*)

En el ejemplo siguiente se muestra el número total de empleados que trabajan en Adventure Works Cycles.

USE AdventureWorks2014;
GO
SELECT COUNT(*)
FROM HumanResources.Employee;
GO

El conjunto de resultados es el siguiente.

-----------

290

(1 row(s) affected)
C.Usar COUNT(*) con otros agregados

En el ejemplo siguiente se muestra que COUNT(*) se puede combinar con otras funciones de agregado de la lista de selección.

USE AdventureWorks2014;
GO
SELECT COUNT(*), AVG(Bonus)
FROM Sales.SalesPerson
WHERE SalesQuota > 25000;
GO

El conjunto de resultados es el siguiente.

----------- ---------------------

14 3472.1428

(1 row(s) affected)
C.Usar la cláusula OVER

En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar valores agregados para cada departamento de la tabla HumanResources.Department.

USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;

El conjunto de resultados es el siguiente.

Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

---------------------------------

COUNT



-- Contar Nº de registros de la Tabla Libros

SELECT COUNT(*) AS [Num. de libros]
FROM libros ;

-- Contar los libros de la Editorial Planeta

SELECT COUNT(*) AS [Num. de libros]
FROM libros
WHERE editorial = 'Planeta' ;



-- Contar los registros que tienen precio, sin tener en cuenta los 
--	valores nulos (especificamos el campo que queremos contar)



SELECT COUNT(precio)
	FROM libros ;




-- Contar los registros que tienen precio, sin tener en cuenta los 
--	valores duplicados (especificamos el campo que queremos contar)

SELECT COUNT(DISTINCT precio)
	FROM libros ;


Contar el número de cargos diferentes que puede tener un empleado que trabaja en Adventure Works Cycles.

USE AdventureWorks2014;
GO
SELECT COUNT(DISTINCT Title)
FROM HumanResources.Employee;
GO

El conjunto de resultados es el siguiente.

-----------

67

(1 row(s) affected)





 Número total de empleados que trabajan en Adventure Works Cycles.

USE AdventureWorks2014;
GO
SELECT COUNT(*)
FROM HumanResources.Employee;
GO

El conjunto de resultados es el siguiente.

-----------

290


----------------------------

SUM

USE AdventureWorks2014;
GO
SELECT Color, SUM(ListPrice), SUM(StandardCost)
FROM Production.Product
WHERE Color IS NOT NULL 
    AND ListPrice != 0.00 
    AND Name LIKE 'Mountain%'
GROUP BY Color
ORDER BY Color;
GO


-- Mostrar la cantidad total de libros en existencia
SELECT SUM(cantidad)
	FROM libros ;

-- Mostrar la cantidad total de libros de la editorial 'Emece' en existencia
SELECT SUM(cantidad)
	FROM libros
	WHERE editorial = 'Emece' ;


MAX

En el siguiente ejemplo se devuelve el tipo impositivo mayor (máximo).

USE AdventureWorks2014;
GO
SELECT MAX(TaxRate)
FROM Sales.SalesTaxRate;
GO

-- Queremos saber cuál es el libro más caro que hay en stock
SELECT MAX(precio)
	FROM libros ;

MIN

USE AdventureWorks2014;
GO
SELECT MIN(TaxRate)
FROM Sales.SalesTaxRate;
GO


-- Queremos saber cuál es el libro más barato que hay en stock
SELECT MIN(precio)
	FROM libros ;

-- Queremos saber cuál es la media de precio de los libros
SELECT AVG(precio)
	FROM libros ;

-- Precio mínimo de los libros de 'Rowling'
SELECT MIN(precio)
	FROM libros
	WHERE autor LIKE '%Rowling%' ;


AVG

A.Usar las funciones SUM y AVG para los cálculos
En el ejemplo siguiente se calcula el promedio de horas de vacaciones y la suma de horas de baja por enfermedad 
que han utilizado los vicepresidentes de Adventure Works Cycles.
 Cada una de estas funciones de agregado produce un valor único de resumen para todas las filas recuperadas.
USE AdventureWorks2014;
GO
SELECT AVG(VacationHours)AS 'Average vacation hours', 
    SUM(SickLeaveHours) AS 'Total sick leave hours'
FROM HumanResources.Employee
WHERE JobTitle LIKE 'Vice President%';

	
-- Queremos saber cuál es la media de precio de los libros (usando valores únicos)
SELECT AVG(DISTINCT precio)
	FROM libros ;

.Usar AVG con DISTINCT
En la instrucción siguiente se devuelve el precio de venta promedio de los productos. 
Si se especifica DISTINCT, solo se tienen en cuenta valores únicos en el cálculo.
USE AdventureWorks2014;
GO
SELECT AVG(DISTINCT ListPrice)
FROM Production.Product;

Sin DISTINCT, la función AVG busca el precio de venta promedio de todos los productos de la tabla Product 
incluidos los valores duplicados.
USE AdventureWorks2014;
GO
SELECT AVG(ListPrice)
FROM Production.Product;
El conjunto de resultados es el siguiente.
------------------------------
438.6662
(1 row(s) affected)

OVER
http://msdn.microsoft.com/es-es/library/ms189461.aspx


GROUP

Cuando se utiliza con una cláusula GROUP BY, cada función de agregado produce un solo valor para cada grupo, en vez de para toda la tabla. En el ejemplo siguiente se obtienen valores de resumen para cada territorio de ventas. El resumen muestra el promedio de bonificaciones recibidas por los vendedores de cada territorio y la suma de las ventas realizadas hasta la fecha en cada territorio.
USE AdventureWorks2014;
GO
SELECT TerritoryID, AVG(Bonus)as 'Average bonus', SUM(SalesYTD) as 'YTD sales'
FROM Sales.SalesPerson
GROUP BY TerritoryID;
GO
El conjunto de resultados es el siguiente.
TerritoryID Average Bonus         YTD Sales
----------- --------------------- ---------------------
NULL        0.00                  1252127.9471
1           4133.3333             4502152.2674
2           4100.00               3763178.1787
3           2500.00               3189418.3662
4           2775.00               6709904.1666
5           6700.00               2315185.611
6           2750.00               4058260.1825
7           985.00                3121616.3202
8           75.00                 1827066.7118
9           5650.00               1421810.9242
10          5150.00               4116871.2277

(11 row(s) affected)

A.Utilizar una cláusula GROUP BY simple
En el ejemplo siguiente se recupera el total de cada SalesOrderID de la tabla SalesOrderDetail.
USE AdventureWorks2014;
GO
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail AS sod
GROUP BY SalesOrderID
ORDER BY SalesOrderID;

B.Utilizar una cláusula GROUP BY con varias tablas
En el ejemplo siguiente se recupera el número de empleados de cada City de la tabla Address combinada con la tabla EmployeeAddress.
USE AdventureWorks2014;
GO
SELECT a.City, COUNT(bea.AddressID) EmployeeCount
FROM Person.BusinessEntityAddress AS bea 
    INNER JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
GROUP BY a.City
ORDER BY a.City;

Utilizar una cláusula GROUP BY con una expresión
En el ejemplo siguiente se recuperan las ventas totales de cada año con la función DATEPART. Debe incluirse la misma expresión en la lista SELECT y en la cláusula GROUP BY.
USE AdventureWorks2014;
GO
SELECT DATEPART(yyyy,OrderDate) AS N'Year'
    ,SUM(TotalDue) AS N'Total Order Amount'
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(yyyy,OrderDate)
ORDER BY DATEPART(yyyy,OrderDate);



-- Queremos saber la cantidad de libros que hay de cada editorial
SELECT editorial, COUNT(*)
	FROM libros
	GROUP BY editorial ;

-- Queremos saber la cantidad de libros que hay de cada editorial evitando valores nulos
SELECT editorial, COUNT(editorial) AS [Total libros]
	FROM libros
	WHERE editorial IS NOT NULL
	GROUP BY editorial ;

-- Cantidad de libros con precio no nulo de cada editorial
SELECT editorial, COUNT(precio)
	FROM libros
	GROUP BY editorial ;

-- Valor total de los libros agrupados por editorial
SELECT editorial, SUM(precio)
	FROM libros
	GROUP BY editorial ;

-- El máximo y el mínimo valor de los libros, agrupados por editorial
SELECT editorial, MAX(precio) AS [Precio máximo], MIN(precio) AS [Precio mínimo]
	FROM libros
	GROUP BY editorial ;
	
-- Promedio del valor de los libros agrupado por editoriales
SELECT editorial, AVG(precio) AS [Precio medio]
	FROM libros
	GROUP BY editorial ;

-- Queremos saber la cantidad de libros que hay de cada editorial con precio menor que 30
SELECT editorial, COUNT(*)
	FROM libros
	WHERE precio < 30
	GROUP BY editorial ;

ALL

Esta característica se quitará en una versión futura de Microsoft SQL Server. 
Evite utilizar esta característica en nuevos trabajos de desarrollo y tenga previsto modificar las aplicaciones
 que actualmente la utilizan.Incluye todos los grupos y conjuntos de resultados, 
incluso aquellos en los que no hay filas que cumplan la condición de búsqueda especificada en la cláusula WHERE. 
Cuando se especifica ALL, se devuelven valores NULL para las columnas de resumen de los grupos que no cumplen 
la condición de búsqueda. No puede especificar ALL con los operadores CUBE y ROLLUP.

-- Queremos saber la cantidad de libros que hay de cada editorial con precio menor que 30 (todos)
SELECT editorial, COUNT(*)
	FROM libros
	WHERE precio < 30
	GROUP BY ALL editorial ;


HAVING

Utilizar una cláusula GROUP BY con una cláusula HAVING
En el ejemplo siguiente se usa la cláusula HAVING para especificar cuáles de los grupos generados en la cláusula GROUP BY deben incluirse en el conjunto de resultados.
USE AdventureWorks2014;
GO
SELECT DATEPART(yyyy,OrderDate) AS N'Year'
    ,SUM(TotalDue) AS N'Total Order Amount'
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(yyyy,OrderDate)
HAVING DATEPART(yyyy,OrderDate) >= N'2003'
ORDER BY DATEPART(yyyy,OrderDate);

En el ejemplo siguiente, donde se utiliza una cláusula HAVING simple, se recupera el total de cada SalesOrderID de la tabla SalesOrderDetail que exceda $100000.00.
Transact-SQL
USE AdventureWorks2014 ;
GO
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 100000.00
ORDER BY SalesOrderID ;





-- Cantidad de libros agrupados por editorial pero considerando sólo ciertos grupos,
--	por ejemplo los que devuelven un valor mayor a 2
SELECT editorial, COUNT(*)
	FROM libros
	GROUP BY editorial
		HAVING COUNT(*) > 2 ;

-- Promedio de los precios de los libros agrupados por editorial, pero solo aquellos grupos
--	que el promedio del precio supere los 25€
SELECT editorial, AVG(precio)
	FROM libros
	GROUP BY editorial
		HAVING AVG(precio) > 25 ;

-- Cantidad de libros sin considerar los que tienen precio nulo, agrupados por editorial, pero
--	sin considerar la editorial 'Planeta'
SELECT editorial, SUM(cantidad) AS Ejemplares
	FROM libros
	WHERE precio IS NOT NULL
	GROUP BY editorial
		HAVING editorial != 'Planeta' ;

SELECT editorial, SUM(cantidad) AS Ejemplares
	FROM libros
	WHERE precio IS NOT NULL AND
		editorial != 'Planeta'
	GROUP BY editorial

-- Mayor valor de los libros, agrupados y ordenados por editorial, y seleccionamos
--	las filas que tienen un valor menor de 100 y mayor a 30
SELECT editorial, MAX(precio)
	FROM libros
	GROUP BY editorial
		HAVING MAX(precio) > 30 AND
			MAX(precio) < 100
	ORDER BY editorial ;

SELECT editorial, MAX(precio)
	FROM libros
	WHERE precio > 30 AND
		precio < 100
	GROUP BY editorial
	ORDER BY editorial ;


----------------

AVG
http://msdn.microsoft.com/es-es/library/ms177677.aspx
A.Usar las funciones SUM y AVG para los cálculos

En el ejemplo siguiente se calcula el promedio de horas de vacaciones y la suma de horas de baja por enfermedad que han utilizado los vicepresidentes de Adventure Works Cycles. Cada una de estas funciones de agregado produce un valor único de resumen para todas las filas recuperadas.

USE AdventureWorks2014;
GO
SELECT AVG(VacationHours)AS 'Average vacation hours', 
    SUM(SickLeaveHours) AS 'Total sick leave hours'
FROM HumanResources.Employee
WHERE JobTitle LIKE 'Vice President%';

El conjunto de resultados es el siguiente.

Average vacation hours       Total sick leave hours

----------------------       ----------------------

25                           97

(1 row(s) affected)
B.Usar las funciones SUM y AVG con una cláusula GROUP BY

Cuando se utiliza con una cláusula GROUP BY, cada función de agregado produce un solo valor para cada grupo, en vez de para toda la tabla. En el ejemplo siguiente se obtienen valores de resumen para cada territorio de ventas. El resumen muestra el promedio de bonificaciones recibidas por los vendedores de cada territorio y la suma de las ventas realizadas hasta la fecha en cada territorio.

USE AdventureWorks2014;
GO
SELECT TerritoryID, AVG(Bonus)as 'Average bonus', SUM(SalesYTD) as 'YTD sales'
FROM Sales.SalesPerson
GROUP BY TerritoryID;
GO

El conjunto de resultados es el siguiente.

TerritoryID Average Bonus         YTD Sales
----------- --------------------- ---------------------
NULL        0.00                  1252127.9471
1           4133.3333             4502152.2674
2           4100.00               3763178.1787
3           2500.00               3189418.3662
4           2775.00               6709904.1666
5           6700.00               2315185.611
6           2750.00               4058260.1825
7           985.00                3121616.3202
8           75.00                 1827066.7118
9           5650.00               1421810.9242
10          5150.00               4116871.2277

(11 row(s) affected)

C.Usar AVG con DISTINCT

En la instrucción siguiente se devuelve el precio de venta promedio de los productos. Si se especifica DISTINCT, solo se tienen en cuenta valores únicos en el cálculo.

USE AdventureWorks2014;
GO
SELECT AVG(DISTINCT ListPrice)
FROM Production.Product;

El conjunto de resultados es el siguiente.

------------------------------

437.4042

(1 row(s) affected)
D.Usar AVG sin DISTINCT

Sin DISTINCT, la función AVG busca el precio de venta promedio de todos los productos de la tabla Product incluidos los valores duplicados.

USE AdventureWorks2014;
GO
SELECT AVG(ListPrice)
FROM Production.Product;

El conjunto de resultados es el siguiente.

------------------------------

438.6662

(1 row(s) affected)
E.Usar la cláusula OVER

En el ejemplo siguiente se usa la función AVG con la cláusula OVER para proporcionar una media móvil de ventas anuales para cada territorio de la tabla Sales.SalesPerson. Se crean particiones de los datos por TerritoryID y se ordenan lógicamente por SalesYTD. Esto significa que la función AVG se calcula para cada territorio en función del año de ventas. Observe que para TerritoryID 1, solo hay dos filas para el año de ventas 2005, que representan los dos vendedores con ventas durante ese año. Se calculan las ventas medias de estas dos filas y la tercera fila que representa las ventas durante el año 2006 se incluye en el cálculo.

USE AdventureWorks2014;
GO
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                           ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;

El conjunto de resultados es el siguiente.

BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           559,697.56           559,697.56
287              NULL        2006        519,905.93           539,801.75           1,079,603.50
285              NULL        2007        172,524.45           417,375.98           1,252,127.95
283              1           2005        1,573,012.94         1,462,795.04         2,925,590.07
280              1           2005        1,352,577.13         1,462,795.04         2,925,590.07
284              1           2006        1,576,562.20         1,500,717.42         4,502,152.27
275              2           2005        3,763,178.18         3,763,178.18         3,763,178.18
277              3           2005        3,189,418.37         3,189,418.37         3,189,418.37
276              4           2005        4,251,368.55         3,354,952.08         6,709,904.17
281              4           2005        2,458,535.62         3,354,952.08         6,709,904.17

(10 row(s) affected)

En este ejemplo, la cláusula OVER no incluye PARTITION BY.Esto significa que la función se aplicará a todas las filas devueltas por la consulta.La cláusula ORDER BY especificada en la cláusula OVER determina el orden lógico al que se aplica la función AVG.La consulta devuelve una media móvil de ventas por año para todos los territorios de ventas especificados en la cláusula WHERE.La cláusula ORDER BY especificada en la instrucción SELECT determina el orden en que se muestran las filas de la consulta.

SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;

El conjunto de resultados es el siguiente.

BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           2,449,684.05         17,147,788.35
275              2           2005        3,763,178.18         2,449,684.05         17,147,788.35
276              4           2005        4,251,368.55         2,449,684.05         17,147,788.35
277              3           2005        3,189,418.37         2,449,684.05         17,147,788.35
280              1           2005        1,352,577.13         2,449,684.05         17,147,788.35
281              4           2005        2,458,535.62         2,449,684.05         17,147,788.35
283              1           2005        1,573,012.94         2,449,684.05         17,147,788.35
284              1           2006        1,576,562.20         2,138,250.72         19,244,256.47
287              NULL        2006        519,905.93           2,138,250.72         19,244,256.47
285              NULL        2007        172,524.45           1,941,678.09         19,416,780.93
(10 row(s) affected)


---------------

SUM

A.Usar SUM para devolver datos de resumen

En los ejemplos siguientes se muestra cómo usar la función SUM para devolver datos de resumen.

USE AdventureWorks2014;
GO
SELECT Color, SUM(ListPrice), SUM(StandardCost)
FROM Production.Product
WHERE Color IS NOT NULL 
    AND ListPrice != 0.00 
    AND Name LIKE 'Mountain%'
GROUP BY Color
ORDER BY Color;
GO

El conjunto de resultados es el siguiente.

Color

--------------- --------------------- ---------------------

Black           27404.84              5214.9616

Silver          26462.84              14665.6792

White           19.00                 6.7926

(3 row(s) affected)
B.Usar la cláusula OVER

En el ejemplo siguiente se usa la función SUM con la cláusula OVER para proporcionar un total acumulado de ventas anuales para cada territorio de la tabla Sales.SalesPerson. Se crean particiones de los datos por TerritoryID y se ordenan lógicamente por SalesYTD. Esto significa que la función SUM se calcula para cada territorio en función del año de ventas. Observe que para TerritoryID 1, solo hay dos filas para el año de ventas 2005, que representan los dos vendedores con ventas durante ese año. Se calculan las ventas acumuladas de estas dos filas y la tercera fila que representa las ventas durante el año 2006 se incluye en el cálculo.

USE AdventureWorks2014;
GO
SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                           ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID 
                                            ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY TerritoryID,SalesYear;

El conjunto de resultados es el siguiente.


BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           559,697.56           559,697.56
287              NULL        2006        519,905.93           539,801.75           1,079,603.50
285              NULL        2007        172,524.45           417,375.98           1,252,127.95
283              1           2005        1,573,012.94         1,462,795.04         2,925,590.07
280              1           2005        1,352,577.13         1,462,795.04         2,925,590.07
284              1           2006        1,576,562.20         1,500,717.42         4,502,152.27
275              2           2005        3,763,178.18         3,763,178.18         3,763,178.18
277              3           2005        3,189,418.37         3,189,418.37         3,189,418.37
276              4           2005        4,251,368.55         3,354,952.08         6,709,904.17
281              4           2005        2,458,535.62         3,354,952.08         6,709,904.17

(10 row(s) affected)

En este ejemplo, la cláusula OVER no incluye PARTITION BY.Esto significa que la función se aplicará a todas las filas devueltas por la consulta.La cláusula ORDER BY especificada en la cláusula OVER determina el orden lógico al que se aplica la función SUM.La consulta devuelve un total acumulado de ventas por año para todos los territorios de ventas especificados en la cláusula WHERE.La cláusula ORDER BY especificada en la instrucción SELECT determina el orden en que se muestran las filas de la consulta.

SELECT BusinessEntityID, TerritoryID 
   ,DATEPART(yy,ModifiedDate) AS SalesYear
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS MovingAvg
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (ORDER BY DATEPART(yy,ModifiedDate) 
                                            ),1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5
ORDER BY SalesYear;

El conjunto de resultados es el siguiente.

BusinessEntityID TerritoryID SalesYear   SalesYTD             MovingAvg            CumulativeTotal
---------------- ----------- ----------- -------------------- -------------------- --------------------
274              NULL        2005        559,697.56           2,449,684.05         17,147,788.35
275              2           2005        3,763,178.18         2,449,684.05         17,147,788.35
276              4           2005        4,251,368.55         2,449,684.05         17,147,788.35
277              3           2005        3,189,418.37         2,449,684.05         17,147,788.35
280              1           2005        1,352,577.13         2,449,684.05         17,147,788.35
281              4           2005        2,458,535.62         2,449,684.05         17,147,788.35
283              1           2005        1,573,012.94         2,449,684.05         17,147,788.35
284              1           2006        1,576,562.20         2,138,250.72         19,244,256.47
287              NULL        2006        519,905.93           2,138,250.72         19,244,256.47
285              NULL        2007        172,524.45           1,941,678.09         19,416,780.93
(10 row(s) affected)


----------------------
MAX
A.Ejemplo sencillo

En el siguiente ejemplo se devuelve el tipo impositivo mayor (máximo).

USE AdventureWorks2014;
GO
SELECT MAX(TaxRate)
FROM Sales.SalesTaxRate;
GO

El conjunto de resultados es el siguiente.

-------------------

19.60

Warning, null value eliminated from aggregate.

(1 row(s) affected)
B.Usar la cláusula OVER

En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar los valores agregados de cada departamento en la tabla HumanResources.Department.

USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;

El conjunto de resultados es el siguiente.

Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

--------------

MIN

A.Ejemplo sencillo

En el ejemplo siguiente se devuelve la tasa de impuestos más baja (mínima).

USE AdventureWorks2014;
GO
SELECT MIN(TaxRate)
FROM Sales.SalesTaxRate;
GO

El conjunto de resultados es el siguiente.

-------------------

5.00

(1 row(s) affected)
B.Usar la cláusula OVER

En el ejemplo siguiente se usan las funciones MIN, MAX, AVG y COUNT con la cláusula OVER para proporcionar valores agregados para cada departamento de la tabla HumanResources.Department.

USE AdventureWorks2014; 
GO
SELECT DISTINCT Name
       , MIN(Rate) OVER (PARTITION BY edh.DepartmentID) AS MinSalary
       , MAX(Rate) OVER (PARTITION BY edh.DepartmentID) AS MaxSalary
       , AVG(Rate) OVER (PARTITION BY edh.DepartmentID) AS AvgSalary
       ,COUNT(edh.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmployeesPerDept
FROM HumanResources.EmployeePayHistory AS eph
JOIN HumanResources.EmployeeDepartmentHistory AS edh
     ON eph.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department AS d
 ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY Name;

El conjunto de resultados es el siguiente.

Name                          MinSalary             MaxSalary             AvgSalary             EmployeesPerDept
----------------------------- --------------------- --------------------- --------------------- ----------------
Document Control              10.25                 17.7885               14.3884               5
Engineering                   32.6923               63.4615               40.1442               6
Executive                     39.06                 125.50                68.3034               4
Facilities and Maintenance    9.25                  24.0385               13.0316               7
Finance                       13.4615               43.2692               23.935                10
Human Resources               13.9423               27.1394               18.0248               6
Information Services          27.4038               50.4808               34.1586               10
Marketing                     13.4615               37.50                 18.4318               11
Production                    6.50                  84.1346               13.5537               195
Production Control            8.62                  24.5192               16.7746               8
Purchasing                    9.86                  30.00                 18.0202               14
Quality Assurance             10.5769               28.8462               15.4647               6
Research and Development      40.8654               50.4808               43.6731               4
Sales                         23.0769               72.1154               29.9719               18
Shipping and Receiving        9.00                  19.2308               10.8718               6
Tool Design                   8.62                  29.8462               23.5054               6

 (16 row(s) affected)

-----------------

GROUP

A.Utilizar una cláusula GROUP BY simple

En el ejemplo siguiente se recupera el total de cada SalesOrderID de la tabla SalesOrderDetail.

USE AdventureWorks2014;
GO
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail AS sod
GROUP BY SalesOrderID
ORDER BY SalesOrderID;

B.Utilizar una cláusula GROUP BY con varias tablas

En el ejemplo siguiente se recupera el número de empleados de cada City de la tabla Address combinada con la tabla EmployeeAddress.

USE AdventureWorks2014;
GO
SELECT a.City, COUNT(bea.AddressID) EmployeeCount
FROM Person.BusinessEntityAddress AS bea 
    INNER JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
GROUP BY a.City
ORDER BY a.City;

C.Utilizar una cláusula GROUP BY con una expresión

En el ejemplo siguiente se recuperan las ventas totales de cada año con la función DATEPART. Debe incluirse la misma expresión en la lista SELECT y en la cláusula GROUP BY.

USE AdventureWorks2014;
GO
SELECT DATEPART(yyyy,OrderDate) AS N'Year'
    ,SUM(TotalDue) AS N'Total Order Amount'
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(yyyy,OrderDate)
ORDER BY DATEPART(yyyy,OrderDate);

D.Utilizar una cláusula GROUP BY con una cláusula HAVING

En el ejemplo siguiente se usa la cláusula HAVING para especificar cuáles de los grupos generados en la cláusula GROUP BY deben incluirse en el conjunto de resultados.

USE AdventureWorks2014;
GO
SELECT DATEPART(yyyy,OrderDate) AS N'Year'
    ,SUM(TotalDue) AS N'Total Order Amount'
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(yyyy,OrderDate)
HAVING DATEPART(yyyy,OrderDate) >= N'2003'
ORDER BY DATEPART(yyyy,OrderDate);



---------------

HAVING

Ejemplos

En el ejemplo siguiente, donde se utiliza una cláusula HAVING simple, se recupera el total de cada SalesOrderID de la tabla SalesOrderDetail que exceda $100000.00.
Transact-SQL

USE AdventureWorks2014 ;
GO
SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 100000.00
ORDER BY SalesOrderID ;






A.Especificar una sola columna definida en la lista de selección
En el siguiente ejemplo se ordena el conjunto de resultados por la columna numérica ProductID. Dado que no se especifica un criterio de ordenación concreto, se utiliza el valor predeterminado (orden ascendente).
Transact-SQL
USE AdventureWorks2014;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID;

B.Especificar una columna que no está definida en la lista de selección
En el siguiente ejemplo se ordena el conjunto de resultados por una columna que no está incluida en la lista de selección, pero sí definida en la tabla especificada en la cláusula FROM.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT ProductID, Name, Color
FROM Production.Product
ORDER BY ListPrice;
C.Especificar un alias como columna de ordenación
En el ejemplo siguiente se especifica el alias de columna SchemaName como columna de criterio de ordenación.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT name, SCHEMA_NAME(schema_id) AS SchemaName
FROM sys.objects
WHERE type = 'U'
ORDER BY SchemaName;
D.Especificar una expresión como columna de ordenación
En el ejemplo siguiente se utiliza una expresión como columna de ordenación. La expresión se define mediante la función DATEPART para ordenar el conjunto de resultados según el año de contratación de los empleados.
Transact-SQL
USE AdventureWorks2014;
Go
SELECT BusinessEntityID, JobTitle, HireDate
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate);
Especificar un criterio de ordenación ascendente y descendente
A.Especificar un orden descendente
En el siguiente ejemplo se ordena el conjunto de resultados en sentido descendente según la columna numérica ProductID.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID DESC;
B.Especificar un orden ascendente
En el siguiente ejemplo se ordena el conjunto de resultados en orden ascendente según la columna Name. Observe que los caracteres están ordenados alfabéticamente, no numéricamente. Es decir, 10 se ordena antes que 2.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY Name ASC ;
C.Especificar orden ascendente y también descendente
En el siguiente ejemplo se ordena el conjunto de resultados según dos columnas. El conjunto de resultados se ordena en primer lugar en sentido ascendente según la columna FirstName y, a continuación, en orden descendente según la columna LastName.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT LastName, FirstName FROM Person.Person
WHERE LastName LIKE 'R%'
ORDER BY FirstName ASC, LastName DESC ;
Especificar una intercalación
En el siguiente ejemplo se muestra cómo especificar una intercalación en la cláusula ORDER BY puede cambiar el orden en que se devuelven los resultados de la consulta. Se crea una tabla que contiene una columna definida mediante una intercalación que no distingue entre mayúsculas y minúsculas, ni las tildes. Los valores se insertan con diversas diferencias de uso de mayúsculas, minúsculas y tildes. Dado que no se especifica ninguna intercalación en la cláusula ORDER BY, la primera consulta utiliza la intercalación de la columna al ordenar los valores. En la segunda consulta, se especifica una intercalación que distingue entre mayúsculas y minúsculas y las tildes; en consecuencia, cambia el orden en el que se devuelven las filas.
Transact-SQL
USE tempdb;
GO
CREATE TABLE #t1 (name nvarchar(15) COLLATE Latin1_General_CI_AI)
GO
INSERT INTO #t1 VALUES(N'Sánchez'),(N'Sanchez'),(N'sánchez'),(N'sanchez');

-- This query uses the collation specified for the column 'name' for sorting.
SELECT name
FROM #t1
ORDER BY name;
-- This query uses the collation specified in the ORDER BY clause for sorting.
SELECT name
FROM #t1
ORDER BY name COLLATE Latin1_General_CS_AS;
Especificar un orden condicional
En los ejemplos siguientes se utiliza la expresión CASE en una cláusula ORDER BY para determinar de manera condicional el criterio de ordenación de las filas según el valor de una columna dada. En el primer ejemplo se evalúe el valor de la columna SalariedFlag de la tabla HumanResources.Employee. Los empleados que tienen la columna SalariedFlag establecida en 1 se devuelven en orden descendente según el BusinessEntityID. Los empleados que tienen la columna SalariedFlag establecida en 0 se devuelven en orden ascendente según el BusinessEntityID. En el segundo ejemplo, el conjunto de resultados se ordena según la columna TerritoryName cuando la columna CountryRegionName es igual a 'United States' y según la columna CountryRegionName en las demás filas.
Transact-SQL
SELECT BusinessEntityID, SalariedFlag
FROM HumanResources.Employee
ORDER BY CASE SalariedFlag WHEN 1 THEN BusinessEntityID END DESC
        ,CASE WHEN SalariedFlag = 0 THEN BusinessEntityID END;
GO
Transact-SQL
SELECT BusinessEntityID, LastName, TerritoryName, CountryRegionName
FROM Sales.vSalesPerson
WHERE TerritoryName IS NOT NULL
ORDER BY CASE CountryRegionName WHEN 'United States' THEN TerritoryName
         ELSE CountryRegionName END;
Usar ORDER BY en una función de categoría
En el siguiente ejemplo se utiliza la cláusula ORDER BY en las funciones de categoría ROW_NUMBER, RANK, DENSE_RANK y NTILE.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT p.FirstName, p.LastName
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"
    ,RANK() OVER (ORDER BY a.PostalCode) AS "Rank"
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS "Dense Rank"
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS "Quartile"
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson AS s 
    INNER JOIN Person.Person AS p 
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address AS a 
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0;
Limitar el número de filas devueltas
En los siguientes ejemplos se utiliza OFFSET y FETCH para limitar el número de filas devueltas por una consulta.
A.Especificar constantes enteras para los valores de OFFSET y FETCH
En el siguiente ejemplo se especifica una constante entera como valor para las cláusulas OFFSET y FETCH. La primera consulta devuelve todas las filas ordenadas según la columna DepartmentID. Compare los resultados devueltos por esta consulta con los de las dos consultas siguientes. La consulta siguiente utiliza la cláusula OFFSET 5 ROWS para omitir las primeras 5 filas y devolver todas las restantes. La última consulta utiliza la cláusula OFFSET 0 ROWS para comenzar por la primera fila y, a continuación, utiliza FETCH NEXT 10 ROWS ONLY para limitar las filas devueltas a 10 filas del conjunto de resultados ordenado.
Transact-SQL
USE AdventureWorks2014;
GO
-- Return all rows sorted by the column DepartmentID.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID;

-- Skip the first 5 rows from the sorted result set and return all remaining rows.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID OFFSET 5 ROWS;

-- Skip 0 rows and return only the first 10 rows from the sorted result set.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID 
    OFFSET 0 ROWS
    FETCH NEXT 10 ROWS ONLY;
B.Especificar variables para los valores de OFFSET y FETCH
En el siguiente ejemplo se declaran las variables @StartingRowNumber y @FetchRows, y se especifican estas variables en las cláusulas OFFSET y FETCH.
Transact-SQL
USE AdventureWorks2014;
GO
-- Specifying variables for OFFSET and FETCH values  
DECLARE @StartingRowNumber tinyint = 1
      , @FetchRows tinyint = 8;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber ROWS 
    FETCH NEXT @FetchRows ROWS ONLY;
C.Especificar expresiones para los valores de OFFSET y FETCH
En el siguiente ejemplo se utiliza la expresión @StartingRowNumber - 1 para especificar el valor de OFFSET y la expresión @EndingRowNumber - @StartingRowNumber + 1 para especificar el valor de FETCH. Además, se especifica la sugerencia de consulta OPTIMIZE FOR. Esta sugerencia se puede usar para que se utilice un valor concreto para una variable local al compilar y optimizar la consulta. El valor se utiliza solo durante la optimización de la consulta y no durante la ejecución de la misma. Para obtener más información, vea Sugerencias de consulta (Transact-SQL).
Transact-SQL
USE AdventureWorks2014;
GO

-- Specifying expressions for OFFSET and FETCH values    
DECLARE @StartingRowNumber tinyint = 1
      , @EndingRowNumber tinyint = 8;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber - 1 ROWS 
    FETCH NEXT @EndingRowNumber - @StartingRowNumber + 1 ROWS ONLY
OPTION ( OPTIMIZE FOR (@StartingRowNumber = 1, @EndingRowNumber = 20) );
D.Especificar una subconsulta escalar constante para los valores de OFFSET y FETCH
En el siguiente ejemplo se utiliza una subconsulta escalar constante a fin de definir el valor para la cláusula FETCH. La subconsulta devuelve un valor único de la columna PageSize de la tabla dbo.AppSettings.
Transact-SQL
-- Specifying a constant scalar subquery
USE AdventureWorks2014;
GO
CREATE TABLE dbo.AppSettings (AppSettingID int NOT NULL, PageSize int NOT NULL);
GO
INSERT INTO dbo.AppSettings VALUES(1, 10);
GO
DECLARE @StartingRowNumber tinyint = 1;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber ROWS 
    FETCH NEXT (SELECT PageSize FROM dbo.AppSettings WHERE AppSettingID = 1) ROWS ONLY;
E.Ejecutar varias consultas en una sola transacción
En el siguiente ejemplo se muestra un método de implementar una solución de paginación que permite asegurarse de la devolución de resultados estables en todas las solicitudes de la consulta. La consulta se ejecuta en una sola transacción utilizando el nivel de aislamiento de instantánea, mientras que la columna especificada en la cláusula ORDER BY asegura la singularidad de la columna.
Transact-SQL
USE AdventureWorks2014;
GO

-- Ensure the database can support the snapshot isolation level set for the query.
IF (SELECT snapshot_isolation_state FROM sys.databases WHERE name = N'AdventureWorks2014') = 0
    ALTER DATABASE AdventureWorks2014 SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

-- Set the transaction isolation level  to SNAPSHOT for this query.
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

-- Beging the transaction
BEGIN TRANSACTION;
GO
-- Declare and set the variables for the OFFSET and FETCH values.
DECLARE @StartingRowNumber int = 1
      , @RowCountPerPage int = 3;

-- Create the condition to stop the transaction after all rows have been returned.
WHILE (SELECT COUNT(*) FROM HumanResources.Department) >= @StartingRowNumber
BEGIN

-- Run the query until the stop condition is met.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber - 1 ROWS 
    FETCH NEXT @RowCountPerPage ROWS ONLY;

-- Increment @StartingRowNumber value.
SET @StartingRowNumber = @StartingRowNumber + @RowCountPerPage;
CONTINUE
END;
GO
COMMIT TRANSACTION;
GO
Usar ORDER BY con UNION, EXCEPT e INTERSECT
Cuando una consulta utiliza los operadores UNION, EXCEPT o INTERSECT, la cláusula ORDER BY se debe especificar al final de la instrucción y se ordenan los resultados de las consultas combinadas. En el siguiente ejemplo se devuelven todos los productos que son rojos o amarillos y la lista combinada se ordena según la columna ListPrice.
Transact-SQL
USE AdventureWorks2014;
GO
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Red'
-- ORDER BY cannot be specified here.
UNION ALL
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Yellow'
ORDER BY ListPrice ASC;