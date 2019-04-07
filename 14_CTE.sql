-- CTE Common Table Expression

--CTE - "Common Table Expression"

--     Qué son los CTE ?

--     En la práctica los CTE son recordset de datos que cuentan con la ventaja de poder ser referenciados dentro de una sentencia select - update - insert - delete tantas veces como sea necesario
--      Básicamente actúan como vistas  y nos permiten prescindir del uso de tablas temporales, cursores, vistas y complejas lógicas (tales como subqueries "poco leíbles")
--      Los CTE permiten definir uno o varias subqueries con un Alias (el nombre del CTE), y luego utilizar esas subqueries referenciando diréctamente al Alias.

      
--    Para qué se usan?


--       Como ya se ha mencionado, para agilizar la lectura y escritura de queries complejas que requieren de subqueries, tablas temporales etc.
--       En aquellas ocasiones en la que es necesario referenciar el resultado de una tabla en múltiples ocasiones.
--       Para poder agrupar por una columna derivada de subqueries.
--       Para poder realizar consultas recursivas


--    Cuál es su syntaxis?

--    -          La sintaxis comienza con un WITH seguida del Nombre CTE
---         A continuación pueden detallarse los nombres de las columnas del CTE (opcional)
---         Luego un AS seguido de la SubConsulta entre paréntesis, esto último todo obligatorio 

--WITH NombredelCTE (columna1, columna2)
--AS
--(Subconsulta)
-----------------------------------------------------------------
-- Create a database to hold OUR books 
CREATE DATABASE CTE_Library 
GO 
USE CTE_Library 
GO
 -- create a table of authors 

 CREATE TABLE tblAuthor
		 ( AuthorId int PRIMARY KEY, 
		 FirstName varchar(50), 
		 LastName varchar(50) )
  GO 
  -- add some authors 
  INSERT tblAuthor (AuthorId, FirstName, LastName)   VALUES (1, 'John', 'Wyndham')
   INSERT tblAuthor (AuthorId, FirstName, LastName) VALUES (2, 'Barbara', 'Kingsolver')
    INSERT tblAuthor (AuthorId, FirstName, LastName) VALUES (3, 'Jane', 'Austen') 
	GO
	-- create a table of books 
	CREATE TABLE tblBook( 
			BookId int PRIMARY KEY,
			BookName varchar(100), 
			AuthorId int, Rating int ) 
	GO
	-- add some books 
	INSERT tblBook (BookId, BookName, AuthorId, Rating) VALUES (1, 'The Day of the Triffids', 1, 10)
	 INSERT tblBook (BookId, BookName, AuthorId, Rating) VALUES (2, 'The Chrysalids', 1, 8)
	 INSERT tblBook (BookId, BookName, AuthorId, Rating) VALUES (3, 'The Lacuna', 2, 10) 
	 INSERT tblBook (BookId, BookName, AuthorId, Rating) VALUES (4, 'The Poisonwood Bible', 2, 8) 
	 INSERT tblBook (BookId, BookName, AuthorId, Rating) VALUES (5, 'Pride and Prejudice', 3, 9)
GO

-- To list out in alphabetical order the authors who have written more than 1 book.

 SELECT a.FirstName + ' ' + a.LastName AS Author, COUNT(*) AS 'Number of books' 
 FROM tblAuthor AS a INNER JOIN tblBook AS b 
									ON a.AuthorId=b.AuthorId 
 GROUP BY a.FirstName + ' ' + a.LastName 
 HAVING COUNT(*) > 1
 ORDER BY Author
 GO


 -- Usando CTE

 USE CTE_Library; -- Semi-colon obligatoria antes de WITH

 WITH cteBooksByAuthor 
 AS 
 ( SELECT AuthorId, COUNT(*) AS CountBooks 
 FROM tblBook GROUP BY AuthorId ) 
 -- use this CTE 
 SELECT * FROM cteBooksByAuthor
 GO

 --AuthorId	CountBooks
	--		1			2
	--		2			2
	--		3			1

 USE CTE_Library; 
 -- List authors with the number of books they've written 
 WITH cteBooksByAuthor AS 
		 ( SELECT AuthorId, COUNT(*) AS CountBooks 
		 FROM tblBook GROUP BY AuthorId ) 
			-- use this CTE to show authors who have written  more than 1 book 
		 SELECT a.FirstName + ' ' + a.LastName AS Author, cte.CountBooks AS 'Number of books' 
		 FROM cteBooksByAuthor AS cte INNER JOIN tblAuthor AS a 
		 ON cte.AuthorId=a.AuthorId 
		 WHERE cte.CountBooks > 1
 GO

-- Author			Number of books
--John Wyndham				2
--Barbara Kingsolver	    2

 -- Suppose that you want to show for each author their book with the highest rating. 
 -- You could easily accomplish this with a single correlated subquery

 USE CTE_Library 
 GO 
 -- get a "temporary table" (a CTE) of highest score for each author 
 -- (don't need a semi-colon as this is now first statement in batch)
  WITH HighestRatings AS 
				  ( SELECT author.AuthorId, MAX(book.Rating) AS HighestRating
				   FROM tblBook AS book INNER JOIN tblAuthor AS author 
				   ON book.AuthorId=author.AuthorId 
				   GROUP BY author.AuthorId )
				-- get the name of book and name of author 
			SELECT author.FirstName + ' ' + author.LastName AS Author, 
			book.BookName AS Title, hr.HighestRating AS Rating 
			FROM HighestRatings AS hr 
			INNER JOIN tblBook AS book 
			ON hr.HighestRating=book.Rating and hr.AuthorId=book.AuthorId 
			INNER JOIN tblAuthor AS author ON book.AuthorId=author.AuthorId
 GO

-- Author						Title											Rating
--John Wyndham		The Day of the Triffids					10
--Barbara Kingsolver		The Lacuna							    10
--Jane Austen			Pride and Prejudice						  9


	DROP DATABASE CTE_Library
	GO
----------------
-- A common table expression (CTE) is a derived table that is defined and only stored for 
--the duration of the query. CTE’s can be used for recursive queries, 
--creating a view on demand and referencing the same table multiple times in the same query. 
-- CTE’s make your code more readable and manageable by reducing the complexity into 
--separate building blocks.  
-- CTE’s can be used in queries, User Defined Functions, Stored Procedures, Triggers or Views.


-- The following Script calculates the years of service for employees in the
--  adventure works database and returns the result set in descending order

USE AdventureWorks2012
GO
WITH Emp_CTE (LoginID , JobTitle , OrgLevel , Years_Employeed )
as
		 (  SELECT LoginID, JobTitle, OrganizationLevel, 
								datediff(year , HireDate , getdate())
		   FROM  [HumanResources] .[Employee]
		  )
		  select *   
		  from Emp_CTE
		 order by Years_Employeed desc 
 GO

 -------------------------------------
-- CTE para Actualizar

USE AdventureWorks2012
GO
-- Check - The value in the base table is updated
SELECT Color
FROM [Production].[Product]
WHERE ProductNumber = 'CA-6738';
-- Build CTE
;WITH CTEUpd(ProductID, Name, ProductNumber, Color)
AS(
SELECT ProductID, Name, ProductNumber, Color
FROM [Production].[Product]
WHERE ProductNumber = 'CA-6738')
-- Update CTE
UPDATE CTEUpd SET Color = 'Rainbow';
-- Check - The value in the base table is updated
SELECT Color
FROM [Production].[Product]
WHERE ProductNumber = 'CA-6738';

-----------------------
----------------
-- https://msdn.microsoft.com/es-es/CTE_Library/ms175972.aspx

-- A.Crear una expresión de tabla común simple

-- Número total de pedidos de ventas por año para cada representante de 
-- ventas en Adventure Works Cycles.

-- Define the CTE expression name and column list.
USE AdventureWorks2012
GO
WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)
AS
-- Define the CTE query.
(
    SELECT SalesPersonID, SalesOrderID, YEAR(OrderDate) AS SalesYear
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
)
-- Define the outer query referencing the CTE name.
SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, SalesYear
FROM Sales_CTE
GROUP BY SalesYear, SalesPersonID
ORDER BY SalesPersonID, SalesYear;
GO







-- B.Usar una expresión de tabla común para limitar recuentos y promedios de informes

-- Número medio de pedidos de venta correspondiente a todos los años para los representantes de ventas.

WITH Sales_CTE (SalesPersonID, NumberOfOrders)
AS
(
    SELECT SalesPersonID, COUNT(*)
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
)
SELECT AVG(NumberOfOrders) AS "Average Sales Per Person"
FROM Sales_CTE;
GO


-- C.Usar varias definiciones de CTE en una sola consulta

-- En el ejemplo siguiente se muestra cómo definir más de una CTE en una sola consulta. Observe que se usa una coma para separar las definiciones de consulta CTE. La función FORMAT, utilizada para mostrar las cantidades de moneda en un formato de moneda, está disponible en SQL Server 2012 y versiones posteriores.

WITH Sales_CTE (SalesPersonID, TotalSales, SalesYear)
AS
-- Define the first CTE query.
(
    SELECT SalesPersonID, SUM(TotalDue) AS TotalSales, YEAR(OrderDate) AS SalesYear
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
       GROUP BY SalesPersonID, YEAR(OrderDate)

)
,   -- Use a comma to separate multiple CTE definitions.

-- Define the second CTE query, which returns sales quota data by year for each sales person.
Sales_Quota_CTE (BusinessEntityID, SalesQuota, SalesQuotaYear)
AS
(
       SELECT BusinessEntityID, SUM(SalesQuota)AS SalesQuota, YEAR(QuotaDate) AS SalesQuotaYear
       FROM Sales.SalesPersonQuotaHistory
       GROUP BY BusinessEntityID, YEAR(QuotaDate)
)

-- Define the outer query by referencing columns from both CTEs.
SELECT SalesPersonID
  , SalesYear
  , FORMAT(TotalSales,'C','en-us') AS TotalSales
  , SalesQuotaYear
  , FORMAT (SalesQuota,'C','en-us') AS SalesQuota
  , FORMAT (TotalSales -SalesQuota, 'C','en-us') AS Amt_Above_or_Below_Quota
FROM Sales_CTE
JOIN Sales_Quota_CTE ON Sales_Quota_CTE.BusinessEntityID = Sales_CTE.SalesPersonID
                    AND Sales_CTE.SalesYear = Sales_Quota_CTE.SalesQuotaYear
ORDER BY SalesPersonID, SalesYear;
GO

-- D.Usar una expresión de tabla común recursiva para mostrar varios niveles de recursividad

-- Muestra la lista jerárquica de los directivos y de los empleados que tienen a su cargo. En el ejemplo se empieza creando y rellenando la tabla dbo.MyEmployees.

-- Create an Employee table.
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30)  NOT NULL,
LastName  nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
 CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC) 
);
-- Populate the table with values.
INSERT INTO dbo.MyEmployees VALUES 
 (1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16,  N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23,  N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

USE AdventureWorks2012;
GO
WITH DirectReports(ManagerID, EmployeeID, Title, EmployeeLevel) AS 
(
    SELECT ManagerID, EmployeeID, Title, 0 AS EmployeeLevel
    FROM dbo.MyEmployees 
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.ManagerID, e.EmployeeID, e.Title, EmployeeLevel + 1
    FROM dbo.MyEmployees AS e
        INNER JOIN DirectReports AS d
        ON e.ManagerID = d.EmployeeID 
)
SELECT ManagerID, EmployeeID, Title, EmployeeLevel 
FROM DirectReports
ORDER BY ManagerID;
GO

-- E.Usar una expresión de tabla común recursiva para mostrar dos niveles de recursividad

-- Muestra los directivos y los empleados que tienen a su cargo. El número de niveles devueltos está limitado a dos.

USE AdventureWorks2012;
GO
WITH DirectReports(ManagerID, EmployeeID, Title, EmployeeLevel) AS 
(
    SELECT ManagerID, EmployeeID, Title, 0 AS EmployeeLevel
    FROM dbo.MyEmployees 
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.ManagerID, e.EmployeeID, e.Title, EmployeeLevel + 1
    FROM dbo.MyEmployees AS e
        INNER JOIN DirectReports AS d
        ON e.ManagerID = d.EmployeeID 
)
SELECT ManagerID, EmployeeID, Title, EmployeeLevel 
FROM DirectReports
WHERE EmployeeLevel <= 2 ;
GO

-- F.Usar una expresión de tabla común recursiva para mostrar una lista jerárquica

-- El ejemplo siguiente, que está basado en el ejemplo D, agrega los nombres del directivo y de los empleados, y sus cargos respectivos. La jerarquía de directivos y empleados se resalta más mediante la aplicación de sangrías a cada nivel.

USE AdventureWorks2012;
GO
WITH DirectReports(Name, Title, EmployeeID, EmployeeLevel, Sort)
AS (SELECT CONVERT(varchar(255), e.FirstName + ' ' + e.LastName),
        e.Title,
        e.EmployeeID,
        1,
        CONVERT(varchar(255), e.FirstName + ' ' + e.LastName)
    FROM dbo.MyEmployees AS e
    WHERE e.ManagerID IS NULL
    UNION ALL
    SELECT CONVERT(varchar(255), REPLICATE ('|    ' , EmployeeLevel) +
        e.FirstName + ' ' + e.LastName),
        e.Title,
        e.EmployeeID,
        EmployeeLevel + 1,
        CONVERT (varchar(255), RTRIM(Sort) + '|    ' + FirstName + ' ' + 
                 LastName)
    FROM dbo.MyEmployees AS e
    JOIN DirectReports AS d ON e.ManagerID = d.EmployeeID
    )
SELECT EmployeeID, Name, Title, EmployeeLevel
FROM DirectReports 
ORDER BY Sort;
GO

-- H.Usar una expresión de tabla común para recorrer selectivamente y paso a paso una relación recursiva en una instrucción SELECT

-- En el ejemplo siguiente se muestra la jerarquía de ensamblados y componentes de producto necesarios para fabricar la bicicleta correspondiente a ProductAssemblyID = 800.

USE AdventureWorks2012;
GO
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
        b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b
    WHERE b.ProductAssemblyID = 800
          AND b.EndDate IS NULL
    UNION ALL
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
        bom.EndDate, ComponentLevel + 1
    FROM Production.BillOfMaterials AS bom 
        INNER JOIN Parts AS p
        ON bom.ProductAssemblyID = p.ComponentID
        AND bom.EndDate IS NULL
)
SELECT AssemblyID, ComponentID, Name, PerAssemblyQty, EndDate,
        ComponentLevel 
FROM Parts AS p
    INNER JOIN Production.Product AS pr
    ON p.ComponentID = pr.ProductID
ORDER BY ComponentLevel, AssemblyID, ComponentID;
GO


-- I.Usar una CTE recursiva en una instrucción UPDATE

-- En el siguiente ejemplo se actualiza el valor de PerAssemblyQty para todos los componentes que se utilizan para fabricar el producto 'Road-550-W Yellow, 44' (ProductAssemblyID800). La expresión de tabla común devuelve una lista jerárquica de los elementos que se utilizan para fabricar ProductAssemblyID 800 y los componentes que se utilizan para crear esos elementos, etc. Solo se modifican las filas devueltas por la expresión de tabla común.

USE AdventureWorks2012;
GO
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
        b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b
    WHERE b.ProductAssemblyID = 800
          AND b.EndDate IS NULL
    UNION ALL
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
        bom.EndDate, ComponentLevel + 1
    FROM Production.BillOfMaterials AS bom 
        INNER JOIN Parts AS p
        ON bom.ProductAssemblyID = p.ComponentID
        AND bom.EndDate IS NULL
)
UPDATE Production.BillOfMaterials
SET PerAssemblyQty = c.PerAssemblyQty * 2
FROM Production.BillOfMaterials AS c
JOIN Parts AS d ON c.ProductAssemblyID = d.AssemblyID
WHERE d.ComponentLevel = 0;

-- J.Usar varios miembros no recursivos y recursivos

-- En el ejemplo siguiente se utilizan varios miembros no recursivos y recursivos para devolver todos los antecesores de una persona especificada. Se crea una tabla y se insertan valores en ella para establecer la genealogía familiar devuelta por la CTE recursiva.

-- Genealogy table
IF OBJECT_ID('dbo.Person','U') IS NOT NULL DROP TABLE dbo.Person;
GO
CREATE TABLE dbo.Person(ID int, Name varchar(30), Mother int, Father int);
GO
INSERT dbo.Person 
VALUES(1, 'Sue', NULL, NULL)
      ,(2, 'Ed', NULL, NULL)
      ,(3, 'Emma', 1, 2)
      ,(4, 'Jack', 1, 2)
      ,(5, 'Jane', NULL, NULL)
      ,(6, 'Bonnie', 5, 4)
      ,(7, 'Bill', 5, 4);
GO
-- Create the recursive CTE to find all of Bonnie's ancestors.
WITH Generation (ID) AS
(
-- First anchor member returns Bonnie's mother.
    SELECT Mother 
    FROM dbo.Person
    WHERE Name = 'Bonnie'
UNION
-- Second anchor member returns Bonnie's father.
    SELECT Father 
    FROM dbo.Person
    WHERE Name = 'Bonnie'
UNION ALL
-- First recursive member returns male ancestors of the previous generation.
    SELECT Person.Father
    FROM Generation, Person
    WHERE Generation.ID=Person.ID
UNION ALL
-- Second recursive member returns female ancestors of the previous generation.
    SELECT Person.Mother
    FROM Generation, dbo.Person
    WHERE Generation.ID=Person.ID
)
SELECT Person.ID, Person.Name, Person.Mother, Person.Father
FROM Generation, dbo.Person
WHERE Generation.ID = Person.ID;
GO
--------------------------

USE Northwind
GO
-- Averiguar las ventas agregadas por empleado usando un CTE y evitando tener que agrupar por demasiados campos. 
-- Empezamos por crear una consulta que nos devuelva ese dato agrupado por id de empleado:

SELECT     Employees.EmployeeID, 

SUM([Order Details].UnitPrice * [Order Details].Quantity * [Order Details].Discount)

FROM         Employees INNER JOIN
                       Orders ON Employees.EmployeeID = Orders.EmployeeID INNER JOIN
                       [Order Details] ON Orders.OrderID = [Order Details].OrderID
                       GROUP BY Employees.EmployeeID
GO

-- Lo bueno de esta consulta es que, a pesar de tener que cruzar 3 tablas, es muy fácil de obtener, pues solo debemos agrupar por un campo: el ID de empleado.

-- Ahora nos gustaría usar ese resultado parcial para ligarlo con el resto de datos de empleados o cualquier otra información de otras tablas que podamos necesitar. En este caso vamos a enlazarlo simplemente con el nombre y los apellidos de cada empleado para ver cómo usar esto en una CTE. Evidentemente podría usarse para cualquier consulta más compleja, involucrando más tablas.

WITH
     cteVentasxEmpleado
     AS
     (
         SELECT     Employees.EmployeeID, 
         SUM([Order Details].UnitPrice * [Order Details].Quantity * [Order Details].Discount) AS Total
         FROM         Employees INNER JOIN
                               Orders ON Employees.EmployeeID = Orders.EmployeeID INNER JOIN
                               [Order Details] ON Orders.OrderID = [Order Details].OrderID
                               GROUP BY Employees.EmployeeID
     )
     SELECT FirstName, LastName, cteVentasxEmpleado.Total From Employees 
     INNER JOIN cteVentasxEmpleado ON Employees.EmployeeID = cteVentasxEmpleado.EmployeeID
     ORDER BY cteVentasxEmpleado.Total DESC
GO

-- Fíjate en que el segundo campo (el que devuelve las ventas agrupadas) no tenía nombre y he tenido que darle uno ("Total" en este caso). Es obligatorio que todos los campos que se devuelvan de la subconsulta para la CTE tengan nombre. Si no se lo especificamos con AS en el caso de campos calculados, tendríamos que usar la sintaxis opcional que indica exactamente el nombre de los campos entre paréntesis, vista más arriba. Pero así es más cómodo.

-- Entonces, indicamos entre WITH y AS el nombre de nuestra CTE (podemos pensar en ella como una tabla temporal) y tras los paréntesis escribimos la consulta que necesitemos, usando para ello el nombre anterior como si fuese una tabla más.

-- CONSEJO: Si utilizas este tipo de construcción desde código, no desde la interfaz de administración, conviene poner siempre delante del WITH un símbolo de punto y coma, así ;WITH. El motivo es que como WITH se utiliza también en otras construcciones, el intérprete de consultas puede generar un error confundiendo la sintaxis. De hecho suele ocurrir. Así que, si utilizas un CTE y te funciona bien desde el Management Studio pero te da un error de sintaxis si lo metes en tu código, es debido a esto. Basta con poner un ";" delante y problema solucionado.

-----------------------------
https://sqltrainning.wordpress.com/tag/joseph-arquimedes-collado-tineo/



En algunas ocasiones deseamos hacer una consulta la cual se notaria complicada por la razón de que utiliza muchas condiciones, tal vez tendríamos que combinar varias tablas entre otras razones. También aveces ese conjunto de resultados que condicionamos queremos utilizarlo para combinarlos con otros resultados.

Aquí es donde entra en juego la CTE (“Common Table Expresion”) o expresión de tabla común, esta nos permite definir este conjunto de datos pero no como una tabla persistente, sino como una tabla temporal que puede ser local o global y la ventaja es que podemos hacer referencia a ella misma. Cuando se hace referencia a ella misma a este proceso se le conoce como tabla común recursiva.

Luego de la declaración de una CTE, las sentencias que podemos utilizar son: SELECT, INSERT, UPDATE y DELETE, pero estas tiene que hacer referencia a la o las columnas de la CTE. Las clausulas que no se pueden utilizar en una CTE son: ORDER BY, INTO, OPTION y FOR BROWSE. Se puede utilizar el operador INNER JOIN, GROUP BY.

Tenemos el siguiente caso. Es un gestor de Tiendas y Almacén de las mismas. Vamos a suponer que necesitamos  el Id del almacén, el nombre del almacén, la descripción del almacén y la ubicación del almacén. Todo esto siempre y cuando los Id_almacen de la tabla Almacén y Tienda coincidan o no, mientras que los Id_supervisor de la tabla Supervisor coincidan totalmente con los Id_supervisor de la tabla Almacén. Luego de ese resultado solamente queremos los registros cuando el campo descripción contenga la palabra Ropa.

CREATE TABLE dbo.Supervisor
(
Id_supervisor int identity(1,1),
nombre varchar(60),
apellido varchar(60),
cedula varchar(13),
fecha_registro date
)

INSERT INTO dbo.Supervisor
VALUES(‘maria Pilar’,‘Hernandez’,‘0000000000000’,GETDATE())
CREATE TABLE dbo.Tienda
(
Id_tienda int identity(1,1),
Id_almacen int NOT NULL,
nombre varchar(80),
descripcion varchar(80),
ubicacion varchar(100),
telefono varchar(10) NOT NULL
)

INSERT INTO dbo.Tienda
VALUES(1,‘Seredes’,‘Solo electrodomesticos’,‘El pantal’,‘0000000000’),
(2,‘Yupi’,‘Electrodomesticos y ropa’,‘oujia’,‘1111111111’),
(1,‘Tijuana’,‘Solo ropa’,’higueral’,‘2222222222’),
(2,‘Yamil’,‘Solo ropa’,‘Alma rosa’,‘9090909090’),
(1,‘Americana’,‘Solo canzado’,‘higueral’,‘8080808080’),
(3,‘Sotanos’,‘Solo ropa’,‘higueral’,‘3030303030’)

CREATE TABLE dbo.Almacen
(
Id_almacen int identity(1,1),
Id_supervisor int NOT NULL,
nombre varchar(60),
descripcion varchar(60),
ubicacion varchar(100),
telefono varchar(10)
)

INSERT INTO dbo.Almacen
VALUES(2,‘Almacenen Unidos’,‘Electrodomesticos’,‘Tenares’,‘7770000000’),
(1,‘Almacen Hernandez’,‘Electrodomesticos y ropa’,‘Cotui’,‘9990000000’),
(1,‘Almacen JB’,‘Ropa y calzado’,‘SPM’,‘1010000000’),
(1,‘Almacen Julio’,‘Calzado’,’Puerto principe’,‘9876543267’),
(1,‘Almacen MC’,‘Ropa’,‘SPM’,‘8769087654’)
WITH A (Almacen,Nombre,Descripcion,Ubicacion) AS
(

SELECT
p.Id_almacen,p.nombre,p.descripcion,p.ubicacion
FROM Almacen p
LEFT JOIN dbo.Tienda t ON(p.Id_almacen=t.Id_almacen)
INNER JOIN dbo.Supervisor s ON(p.Id_supervisor=s.Id_supervisor)
WHERE s.Id_supervisor=1

)

SELECT
Almacen,Nombre,Descripcion
FROM A
WHERE Descripcion LIKE ‘%Ropa%’

Su pregunta seria: Pero por que mejor no se realizo la consulta como las hacen los demás normalmente, con el código que esta dentro del WITH bastaba solo tenia que hacer algunos JOINs y un WHERE para definir las mismas condiciones que la CTE, por que tendría que usar una CTE?

Ese resultado que obtenemos cuando consultamos la CTE

SELECT
Almacen,Nombre,Descripcion
FROM A
WHERE Descripcion LIKE ‘%Ropa%’

Resultado WITH

Es que la CTE A podríamos hacer un JOIN con otra tabla a partir del Almacén que en este caso representa el Id_almacen, y la ventaja seria de que ya ese conjunto de datos fue condicionado y ya solo quedaría combinarlo con otros. Otra cosa importante es que le podemos asignar nombres a las columnas o dejarlo vació los paréntesis y colocar alias a los campos. Para declarar otra CTE luego de haber declarado una anteriormente :

WITH A AS
(

SELECT
Id_tienda
FROM dbo.Tienda

), B AS
(

SELECT
Id_Tienda
FROM dbo.Tienda

)

SELECT
*
FROM A
INNER JOIN B ON(a.Id_Tienda=b.Id_Tienda)

-- -----------------------------------------------
-- Simple Recursive Query Example

CREATE TABLE dbo.Area(
   AreaID int NOT NULL,
   AreaName varchar(100) NOT NULL,
   ParentAreaID int NULL,
   AreaType varchar(20) NOT NULL
CONSTRAINT PK_Area PRIMARY KEY CLUSTERED 
( AreaID ASC
) ON [PRIMARY])
GO

INSERT INTO dbo.Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(1, 'Canada', null, 'Country')
 
INSERT INTO dbo.Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(2, 'United States', null, 'Country')
 
INSERT INTO dbo.Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(3, 'Saskatchewan', 1, 'State')
 
INSERT INTO dbo.Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(4, 'Saskatoon', 3, 'City')
 
INSERT INTO dbo.Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(5, 'Florida', 2, 'State')
 
INSERT INTO dbo.Area(AreaID,AreaName,ParentAreaID,AreaType)
VALUES(6, 'Miami', 5, 'City')

select * from dbo.Area
where AreaType = 'City'

-- However, what if I wanted to return all cities in Canada?

WITH AreasCTE AS
( 
--anchor select, start with the country of Canada, which will be the root element for our search
SELECT AreaID, AreaName, ParentAreaID, AreaType
FROM dbo.Area 
WHERE AreaName = 'Canada'
UNION ALL
--recursive select, recursive until you reach a leaf (an Area which is not a parent of any other area)
SELECT a.AreaID, a.AreaName, a.ParentAreaID, a.AreaType 
FROM dbo.Area a 
INNER JOIN AreasCTE s ON a.ParentAreaID = s.AreaID 
) 
--Now, you will have all Areas in Canada, so now let's filter by the AreaType "City"
SELECT * FROM AreasCTE  
where AreaType = 'City' 
GO

-----------------

USE AdventureWorks2012
GO
with Emp_CTE (LoginID , JobTitle , OrgLevel , Years_Employeed )
as
 (  SELECT LoginID, JobTitle, OrganizationLevel, datediff(year , HireDate , getdate())
     FROM [AdventureWorks2012].[HumanResources] .[Employee]
  )
  select *   
   from Emp_CTE
 order by Years_Employeed desc 
 GO

 --
 WITH
  cteTotalSales (SalesPersonID, NetSales)
  AS
  (
    SELECT SalesPersonID, ROUND(SUM(SubTotal), 2)
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
  )
SELECT
  sp.FirstName + ' ' + sp.LastName AS FullName,
  sp.City + ', ' + StateProvinceName AS Location,
  ts.NetSales
FROM Sales.vSalesPerson AS sp
  INNER JOIN cteTotalSales AS ts
    ON sp.BusinessEntityID = ts.SalesPersonID
ORDER BY ts.NetSales DESC
GO

-- Varias CTE

WITH
  cteTotalSales (SalesPersonID, NetSales)
  AS
  (
    SELECT SalesPersonID, ROUND(SUM(SubTotal), 2)
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
      AND OrderDate BETWEEN '2003-01-01 00:00:00.000'
        AND '2003-12-31 23:59:59.000'
    GROUP BY SalesPersonID
  ),
  cteTargetDiff (SalesPersonID, SalesQuota, QuotaDiff)
  AS
  (
    SELECT ts.SalesPersonID,
      CASE
        WHEN sp.SalesQuota IS NULL THEN 0
        ELSE sp.SalesQuota
      END,
      CASE
        WHEN sp.SalesQuota IS NULL THEN ts.NetSales
        ELSE ts.NetSales - sp.SalesQuota
      END
    FROM cteTotalSales AS ts
      INNER JOIN Sales.SalesPerson AS sp
      ON ts.SalesPersonID = sp.BusinessEntityID
  )
SELECT
  sp.FirstName + ' ' + sp.LastName AS FullName,
  sp.City,
  ts.NetSales,
  td.SalesQuota,
  td.QuotaDiff
FROM Sales.vSalesPerson AS sp
  INNER JOIN cteTotalSales AS ts
    ON sp.BusinessEntityID = ts.SalesPersonID
  INNER JOIN cteTargetDiff AS td
    ON sp.BusinessEntityID = td.SalesPersonID
ORDER BY ts.NetSales DESC
GO

-- 
IF OBJECT_ID('Employees', 'U') IS NOT NULL
DROP TABLE dbo.Employees
GO
CREATE TABLE dbo.Employees
(
  EmployeeID int NOT NULL PRIMARY KEY,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL,
  ManagerID int NULL
)
GO
INSERT INTO Employees VALUES (101, 'Ken', 'Sánchez', NULL)
INSERT INTO Employees VALUES (102, 'Terri', 'Duffy', 101)
INSERT INTO Employees VALUES (103, 'Roberto', 'Tamburello', 101)
INSERT INTO Employees VALUES (104, 'Rob', 'Walters', 102)
INSERT INTO Employees VALUES (105, 'Gail', 'Erickson', 102)
INSERT INTO Employees VALUES (106, 'Jossef', 'Goldberg', 103)
INSERT INTO Employees VALUES (107, 'Dylan', 'Miller', 103)
INSERT INTO Employees VALUES (108, 'Diane', 'Margheim', 105)
INSERT INTO Employees VALUES (109, 'Gigi', 'Matthew', 105)
INSERT INTO Employees VALUES (110, 'Michael', 'Raheem', 106)
GO

WITH
  cteReports (EmpID, FirstName, LastName, MgrID, EmpLevel)
  AS
  (
    SELECT EmployeeID, FirstName, LastName, ManagerID, 1
    FROM Employees
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.ManagerID,
      r.EmpLevel + 1
    FROM Employees e
      INNER JOIN cteReports r
        ON e.ManagerID = r.EmpID
  )
SELECT
  FirstName + ' ' + LastName AS FullName,
  EmpLevel,
  (SELECT FirstName + ' ' + LastName FROM Employees
    WHERE EmployeeID = cteReports.MgrID) AS Manager
FROM cteReports
ORDER BY EmpLevel, MgrID
GO

----------------------------------

-- Tabla de ventas donde están todas las ventas hechas y el ID de los vendedores que las hicieron.

-- Piensen que necesitan un reporte donde aparezca el total de ventas y el nombre del vendedor.

-- Los datos extendidos del vendedor están en otra tabla. Además como el reporte totaliza la cantidad de ventas se requiere un query con una función de agregado ( count(*) ) Dado que existe este agregado no es posible usar un simple join, sino que tendríamos que usar una subconsulta o una tabla temporal:
USE AdventureWorks2012
GO
sp_help 'Sales.vSalesPerson'
GO
select Vendedores.FirstName, VentasAgrupadas.VentasTotales from
(
   SELECT Sales.SalesOrderHeader.SalesPersonID, COUNT(*) as VentasTotales
   FROM Sales.SalesOrderHeader
   WHERE Sales.SalesOrderHeader.SalesPersonID IS NOT NULL
   GROUP BY Sales.SalesOrderHeader.SalesPersonID
) as VentasAgrupadas
inner join Sales.vSalesPerson as Vendedores 
on Vendedores.BusinessEntityID=VentasAgrupadas.SalesPersonID
order by VentasAgrupadas.VentasTotales
GO
-- Como se aprecia esto es engorroso y poco claro.

-- Con un CTE es mucho más sencillo, ya que no existe la necesidad de la subconsulta sino que parece como si declaráramos una variable de tipo tabla o vista con los resultados que queremos:

WITH VentasAgrupadas(IdVendedor, VentasTotales)
as
(
  SELECT Sales.SalesOrderHeader.SalesPersonID, COUNT(*)
  FROM Sales.SalesOrderHeader
  WHERE Sales.SalesOrderHeader.SalesPersonID IS NOT NULL
  GROUP BY Sales.SalesOrderHeader.SalesPersonID
)
SELECT Vendedores.FirstName, VentasAgrupadas.VentasTotales
FROM Sales.vSalesPerson as Vendedores
INNER JOIN VentasAgrupadas ON Vendedores.BusinessEntityID=VentasAgrupadas.IdVendedor
ORDER BY VentasAgrupadas.VentasTotales
GO

--
-- Otro Ejemplo
USE AdventureWorks2012
GO
WITH EmpTitle (JobTitle,numtibles) AS
(SELECT a.JobTitle, COUNT(*) numtibles
  FROM HumanResources.Employee as a
 GROUP BY a.JobTitle)
 SELECT B.BusinessEntityID, B.JobTitle, C.numtibles
   FROM EmpTitle as C INNER JOIN HumanResources.Employee as B 
   ON C.JobTitle=B.JobTitle
GO

--***********************************--
--Misma Consulta Utilizando Tablas Derivadas....
--***********************************--
SELECT B.BusinessEntityID, B.JobTitle, EmpTitle.numtibles
FROM (SELECT a.JobTitle, COUNT(*) numtibles
FROM HumanResources.Employee as a
GROUP BY a.JobTitle) as EmpTitle 
INNER JOIN HumanResources.Employee as B 
ON EmpTitle.JobTitle=B.JobTitle
GO

---------------------
-- http://www.4guysfromrolla.com/webtech/071906-1.shtml

USE Northwind
GO

WITH ProductAndCategoryNamesOverTenDollars (ProductName, CategoryName, UnitPrice) AS
(
   SELECT
      p.ProductName,
      c.CategoryName,
      p.UnitPrice
   FROM Products p
      INNER JOIN Categories c ON
         c.CategoryID = p.CategoryID
   WHERE p.UnitPrice > 10.0
)
SELECT *
FROM ProductAndCategoryNamesOverTenDollars
ORDER BY CategoryName ASC, UnitPrice ASC, ProductName ASC
GO

WITH CategoryAndNumberOfProducts (CategoryID, CategoryName, NumberOfProducts) AS
(
   SELECT
      CategoryID,
      CategoryName,
      (SELECT COUNT(1) FROM Products p
       WHERE p.CategoryID = c.CategoryID) as NumberOfProducts
   FROM Categories c
),
ProductsOverTenDollars (ProductID, CategoryID, ProductName, UnitPrice) AS
(
   SELECT
      ProductID,
      CategoryID,
      ProductName,
      UnitPrice
   FROM Products p
   WHERE UnitPrice > 10.0
)
SELECT c.CategoryName, c.NumberOfProducts,
      p.ProductName, p.UnitPrice
FROM ProductsOverTenDollars p
   INNER JOIN CategoryAndNumberOfProducts c ON
      p.CategoryID = c.CategoryID
ORDER BY ProductName
GO

-- a list of employees including how many other employees they directly managed.

WITH EmployeeSubordinatesReport (EmployeeID, LastName, FirstName, NumberOfSubordinates, ReportsTo) AS
(
   SELECT
      EmployeeID,
      LastName,
      FirstName,
      (SELECT COUNT(1) FROM Employees e2
       WHERE e2.ReportsTo = e.EmployeeID) as NumberOfSubordinates,
      ReportsTo
   FROM Employees e
)

SELECT LastName, FirstName, NumberOfSubordinates
FROM EmployeeSubordinatesReport
GO

-- Now, imagine that our boss (Andrew Fuller, perhaps) comes charging into our office and demands 
--that the report also lists each employee's manager's name and number of subordinates 
-- (if the employee has a manager, that is - Mr. Fuller is all to quick to point out that he reports to no one).
--  Adding such functionality is a snap with the CTE - just add it in a LEFT JOIN!

WITH EmployeeSubordinatesReport (EmployeeID, LastName, FirstName, NumberOfSubordinates, ReportsTo) AS
(
   SELECT
      EmployeeID,
      LastName,
      FirstName,
      (SELECT COUNT(1) FROM Employees e2
       WHERE e2.ReportsTo = e.EmployeeID) as NumberOfSubordinates,
      ReportsTo
   FROM Employees e
)

SELECT Employee.LastName, Employee.FirstName, Employee.NumberOfSubordinates,
   Manager.LastName as ManagerLastName, Manager.FirstName as ManagerFirstName, Manager.NumberOfSubordinates as ManagerNumberOfSubordinates
FROM EmployeeSubordinatesReport Employee
   LEFT JOIN EmployeeSubordinatesReport Manager ON
      Employee.ReportsTo = Manager.EmployeeID
GO


WITH EmployeeHierarchy (EmployeeID, LastName, FirstName, ReportsTo, HierarchyLevel) AS
(
   -- Base case
   SELECT
      EmployeeID,
      LastName,
      FirstName,
      ReportsTo,
      1 as HierarchyLevel
   FROM Employees
   WHERE ReportsTo IS NULL

   UNION ALL

   -- Recursive step
   SELECT
      e.EmployeeID,
      e.LastName,
      e.FirstName,
      e.ReportsTo,
      eh.HierarchyLevel + 1 AS HierarchyLevel
   FROM Employees e
      INNER JOIN EmployeeHierarchy eh ON
         e.ReportsTo = eh.EmployeeID
)

SELECT *
FROM EmployeeHierarchy
ORDER BY HierarchyLevel, LastName, FirstName
GO

---------------
-- En la base de datos AdventureWorks existe una tabla con históricos de precios de productos.
USE AdventureWorks2012
go
Select  * 
from Production.ProductCostHistory
order  by ProductID asc,StartDate asc;
GO
-- Queremos hacer una consulta que nos devuelva el primer precio que tuvo asignado cada producto, es decir, para el producto 707 tendría que devolver la prima fila, que se corresponde con el año 2001 y un precio de 12,0278. Lo primero que se nos puede venir a la cabeza será un GROUP BY, pero os adelanto que no va a salir bien :-). Mediante una agrupación podríamos saber la primera fecha para cada productId, pero: ¿y el precio? Tendríamos que hacer un InnerJoin posterior que utilizase este resultado: se complica mucho más si metemos más campos debido a que en el JOIN vamos a tener que igualar todos los campos para asegurarnos de que estamos seleccionando la misma fila.

-- La solución con CTE quedaría así:

with   Ampliada(ProductId,StandardCost,Indice) as
   (select   ProductID ,StandardCost, 
    RANK() over(partition by ProductId order by StartDate) Indice 
    from   Production.ProductCostHistory )
select * from Ampliada where Indice=1
go

----------------------------------

-- Manager - Employeee

--Simple Example of Recursive CTE

--Recursive is the process in which the query executes itself. It is used to get results based on the output of base query. We can use CTE as Recursive CTE (Common Table Expression). You can read my previous articles about CTE by searching at http://search.SQLAuthority.com .

--Here, the result of CTE is repeatedly used to get the final resultset. The following example will explain in detail where I am using AdventureWorks database and try to find hierarchy of Managers and Employees.

USE AdventureWorks2012
GO
WITH Emp_CTE AS (
SELECT EmployeeID, ContactID, LoginID, ManagerID, Title, BirthDate
FROM HumanResources.Employee
WHERE ManagerID IS NULL
UNION ALL
SELECT e.EmployeeID, e.ContactID, e.LoginID, e.ManagerID, e.Title, e.BirthDate
FROM HumanResources.Employee e
INNER JOIN Emp_CTE ecte ON ecte.EmployeeID = e.ManagerID
)
SELECT *
FROM Emp_CTE
GO

--In the above example Emp_CTE is a Common Expression Table, the base record for the CTE is derived by the first sql query before UNION ALL. The result of the query gives you the EmployeeID which don’t have ManagerID.

--Second query after UNION ALL is executed repeatedly to get results and it will continue until it returns no rows. For above e.g. Result will have EmployeeIDs which have ManagerID (ie, EmployeeID of the first result).  This is obtained by joining CTE result with Employee table on columns EmployeeID of CTE with ManagerID of table Employee.

--This process is recursive and will continue till there is no ManagerID who doesn’t have EmployeeID.

------------------------

http://www.mssqltips.com/sqlservertip/1520/recursive-queries-using-common-table-expressions-cte-in-sql-server/

https://ask.sqlservercentral.com/questions/33679/how-to-find-a-bus-route.html

http://sqlpro.developpez.com/cours/sqlserver/cte-recursives/


http://blogs.solidq.com/es/sql-server/common-table-expression-cte-recursiva-en-sql-server/

-- Common table expression (CTE) recursiva en SQL Server

--Ejemplo, dada la siguiente tabla:

USE Prueba
GO
if exists (select * from sys.tables where name = 'Rutas')
			drop table Rutas
go

create table Rutas (
origin char(3)
, destination char(3)
, price money
)
GO
--En la que:
--    origin representa el origen del vuelo,
--    destination, representa el destino del vuelo,
--    y, price, el precio del vuelo.

-- Y dadas las siguientes combinaciones de vuelos:

insert dbo.Rutas select 'ALC', 'MAD', 100

insert dbo.Rutas select 'ALC', 'ROM', 1200

insert dbo.Rutas select 'ALC', 'BCN', 250

insert dbo.Rutas select 'MAD', 'ALC', 100

insert dbo.Rutas select 'MAD', 'BCN', 75

insert dbo.Rutas select 'BCN', 'MAD', 75

insert dbo.Rutas select 'MAD', 'ROM', 750

insert dbo.Rutas select 'ROM', 'ALC', 1200

insert dbo.Rutas select 'BCN', 'ROM', 400

insert dbo.Rutas select 'MAD', 'TEF', 1300

insert dbo.Rutas select 'TEF', 'ROM', 1500

GO

-- Por ejemplo, que el vuelo de ALC, a MAD vale 100€, el vuelo de ALC a ROM vale 1200, y así sucesivamente.

-- Si quisiéramos buscar todos los vuelos cuyo origen tienen ALC, y su destino es ROM, 
-- podríamos aplicar la siguiente consulta:

select *
from Rutas
where origin = 'ALC' and destination = 'ROM'
GO

-- Que nos devolvería:
--origin	destination	price
--ALC			ROM			1200,00

--En realidad, esta consulta devolverá vuelos “directos” entre Alicante (ALC) y Roma (ROM), 
-- pero ¿qué pasa con las escalas? 
-- Porque en la lista anterior, para ir de Alicante a Roma, podríamos elegir las siguientes combinaciones de vuelos:

--ALC-ROM

--ALC-BCN-ROM

--ALC-MAD-ROM

--ALC-MAD-BCN-ROM

--ALC-BCN-MAD-ROM

--ALC-MAD-TEF-ROM

--ALC-BCN-MAD-TEF-ROM

-- Es decir, las combinaciones serían: un vuelo directo, dos vuelos con una escala (pasando por BCN, o MAD), 
-- tres vuelos con dos escalas, y un “estratosférico” Alicante – Barcelona – Madrid – Tenerife – Roma, 
-- con cuatro escalas 

-- Una búsqueda de todos los trayectos cuyo origen es ALC, y su destino es ROM.

--Para ello:

--    Se localizan todos los vuelos cuyo origen es ALC 1)
--    De todos los resultados de 1), para todos los vuelos existentes (toda la tabla) se buscan vuelos cuyo 
--  origen es el destino de la lista 1), y además, el destino no esté en alguno de los tramos anteriores 
--  en otras palabras, evitar pasar dos veces por el mismo aeropuerto
--    Así iterativamente, dejando de buscar cuando:
--        se hallan procesado todos los vuelos existentes.
--        o se haya llegado al destino final que es ROM.



--  Declaración de variables

DECLARE @origin CHAR(3)
DECLARE @destination CHAR(3)
DECLARE @stops INT
SET @origin = 'ALC'
SET @destination = 'ROM'
;WITH paths AS (
		SELECT origin, destination, price
		, cast (origin + '-' + destination as varchar(200)) as [Ruta]
		, 1 as stops
		FROM dbo.Rutas
		WHERE origin = @origin
		UNION ALL
		-- elemento de recursión
		SELECT M.origin, t.destination, t.price + M.price
		, cast (M.[Ruta] + '-'+ t.destination as varchar(200))
		, M.stops + 1
		FROM dbo.Rutas AS t
		JOIN paths AS M
		ON t.origin = M.destination
		WHERE M.[Ruta] NOT LIKE '%-'+ t.destination + '-%'
		AND M.[Ruta] NOT LIKE t.destination + '-%'
		AND M.[Ruta] NOT LIKE '%-' + t.destination
		) SELECT * FROM paths
		WHERE destination = @destination
		ORDER BY price ASC
GO


-- Resultado

--origin	destination	price	Ruta	stops
--ALC	ROM	575,00	ALC-MAD-BCN-ROM	3
--ALC	ROM	650,00	ALC-BCN-ROM	2
--ALC	ROM	850,00	ALC-MAD-ROM	2
--ALC	ROM	1075,00	ALC-BCN-MAD-ROM	3
--ALC	ROM	1200,00	ALC-ROM	1
--ALC	ROM	2900,00	ALC-MAD-TEF-ROM	3
--ALC	ROM	3125,00	ALC-BCN-MAD-TEF-ROM	4


-- Variante
-- http://www.ciiycode.com/7HBHJigXXgUX/sql-server-recursive-self-join-of-a-table-no-with-clause

CREATE TABLE routes
(
    ID int identity not null primary key,
    from int,
    to int,
    length int not null
)
GO
--I changed some stuff around to make it easier to play with. For example, avoid [from] and [to] as column names.
--I hard coded ID1 and ID2 rather than using variables.
--I didn't worry about "length."
--You'll see it find circuitous routes, but doesn't let them repeat any step.
--Not optimized--just showing how it works.
--I'm having some trouble getting the code formatting to stick. I'll post and try to edit.

GO

INSERT INTO routes VALUES 
  (1,'a','b')
 ,(2,'a','c')
 ,(3,'a','d')
 ,(4,'b','c')
 ,(5,'b','d')
 ,(6,'c','d')
 ,(7,'d','c')

GO

WITH cte AS (
 --anchor
 SELECT id
       ,start
       ,finish
       ,',' + CAST(id AS VARCHAR(MAX)) + ',' route_ids
   FROM routes
  WHERE start = 'a'

  UNION ALL
 --recursive part    
 SELECT a.id
       ,a.start
       ,b.finish
       ,route_ids + CAST(b.id AS VARCHAR(MAX)) + ','
   FROM cte a
        INNER JOIN
        routes b ON a.finish = b.start 
  WHERE CHARINDEX(',' + CAST(b.id AS VARCHAR(MAX)) + ',',a.route_ids,1)  = 0
)
SELECT start,finish,route_ids 
 FROM cte
WHERE finish = 'c'
ORDER BY LEN(route_ids)





CREATE TABLE routes ( ID int /identity/ not null primary key ,start char(1)--int ,finish char(1)--int --,[length] int not null )











-- http://stackoverflow.com/questions/22641105/sql-server-recursive-self-join-of-a-table-no-with-clause

drop table routes
GO
CREATE TABLE routes ( ID int identity not null primary key ,
		start char(1) ,finish char(1),[length] int not null )
GO

INSERT INTO routes VALUES 
  (1,'a','b')
 ,(2,'a','c')
 ,(3,'a','d')
 ,(4,'b','c')
 ,(5,'b','d')
 ,(6,'c','d')
 ,(7,'d','c')

GO

WITH cte AS (
 --anchor
 SELECT id
       ,start
       ,finish
       ,',' + CAST(id AS VARCHAR(MAX)) + ',' route_ids
   FROM routes
  WHERE start = 'a'

  UNION ALL
 --recursive part    
 SELECT a.id
       ,a.start
       ,b.finish
       ,route_ids + CAST(b.id AS VARCHAR(MAX)) + ','
   FROM cte a
        INNER JOIN
        routes b ON a.finish = b.start 
  WHERE CHARINDEX(',' + CAST(b.id AS VARCHAR(MAX)) + ',',a.route_ids,1)  = 0
)
SELECT start,finish,route_ids 
 FROM cte
WHERE finish = 'c'
GO
---------------------------
https://ask.sqlservercentral.com/questions/33679/how-to-find-a-bus-route.html

USE [busline]
 GO
 /****** Object:  Table [dbo].[BusStop]    Script Date: 02/16/2011 09:19:39 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TABLE [dbo].[BusStop](
     [BusStopID] [int] IDENTITY(1,1) NOT NULL,
     [BusStopName] [nvarchar](200) NULL,
 PRIMARY KEY CLUSTERED 
 (
     [BusStopID] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 ) ON [PRIMARY]
 GO
 SET IDENTITY_INSERT [dbo].[BusStop] ON
 INSERT [dbo].[BusStop] ([BusStopID], [BusStopName]) VALUES (1, N'Enköping')
 INSERT [dbo].[BusStop] ([BusStopID], [BusStopName]) VALUES (2, N'Örsundsbro')
 INSERT [dbo].[BusStop] ([BusStopID], [BusStopName]) VALUES (3, N'Uppsala')
 INSERT [dbo].[BusStop] ([BusStopID], [BusStopName]) VALUES (4, N'Bålsta')
 INSERT [dbo].[BusStop] ([BusStopID], [BusStopName]) VALUES (5, N'Arlanda')
 INSERT [dbo].[BusStop] ([BusStopID], [BusStopName]) VALUES (6, N'Strängnäs')
 SET IDENTITY_INSERT [dbo].[BusStop] OFF
 /****** Object:  Table [dbo].[BusLine]    Script Date: 02/16/2011 09:19:39 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TABLE [dbo].[BusLine](
     [LineNumber] [int] NOT NULL,
 PRIMARY KEY CLUSTERED 
 (
     [LineNumber] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 ) ON [PRIMARY]
 GO
 INSERT [dbo].[BusLine] ([LineNumber]) VALUES (801)
 INSERT [dbo].[BusLine] ([LineNumber]) VALUES (803)
 INSERT [dbo].[BusLine] ([LineNumber]) VALUES (804)
 INSERT [dbo].[BusLine] ([LineNumber]) VALUES (877)
 /****** Object:  Table [dbo].[BusFair_BusStop]    Script Date: 02/16/2011 09:19:39 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TABLE [dbo].[BusFair_BusStop](
     [BusFairID] [int] NOT NULL,
     [StartBusStopID] [int] NULL,
     [EndBusStopID] [int] NOT NULL,
     [startsat] [time](7) NULL,
     [stopsat] [time](7) NULL
 ) ON [PRIMARY]
 GO
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (1, 1, 2, CAST(0x07008482A8410000 AS Time), CAST(0x0700B864D9450000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (1, 2, 3, CAST(0x0700B864D9450000 AS Time), CAST(0x0700EC460A4A0000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (6, 1, 2, CAST(0x070040230E430000 AS Time), CAST(0x070074053F470000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (2, 3, 4, CAST(0x070010ACD1530000 AS Time), CAST(0x0700A25EB5580000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (6, 2, 3, CAST(0x070074053F470000 AS Time), CAST(0x0700A8E76F4B0000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (3, 3, 6, CAST(0x0700E03495640000 AS Time), CAST(0x0700C03AC26F0000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (7, 3, 6, CAST(0x07007870335C0000 AS Time), CAST(0x070048F9F66C0000 AS Time))
 INSERT [dbo].[BusFair_BusStop] ([BusFairID], [StartBusStopID], [EndBusStopID], [startsat], [stopsat]) VALUES (4, 1, 3, CAST(0x0700B893419F0000 AS Time), CAST(0x070006E78AA50000 AS Time))
 /****** Object:  Table [dbo].[BusFair]    Script Date: 02/16/2011 09:19:39 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE TABLE [dbo].[BusFair](
     [BusFairID] [int] IDENTITY(1,1) NOT NULL,
     [LineNumber] [int] NULL,
 PRIMARY KEY CLUSTERED 
 (
     [BusFairID] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 ) ON [PRIMARY]
 GO
 SET IDENTITY_INSERT [dbo].[BusFair] ON
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (1, 804)
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (2, 803)
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (3, 877)
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (4, 804)
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (5, 801)
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (6, 804)
 INSERT [dbo].[BusFair] ([BusFairID], [LineNumber]) VALUES (7, 877)
 SET IDENTITY_INSERT [dbo].[BusFair] OFF
 /****** Object:  StoredProcedure [dbo].[GetCheapestFair]    Script Date: 02/16/2011 09:19:45 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 --EXEC GetCheapestFair 1, 6, '07:30','21:00'
 CREATE PROC [dbo].[GetCheapestFair](@StartBusStopID int, @EndBusStopID int, @StartTime time, @MaxArrivalTime time)
 AS
 ;with CTE AS(
     SELECT    
         0 as RecLevel,
         bf.BusFairID ,
         bf.LineNumber,
         bfbs.StartBusStopID , 
         bsStart.BusStopName as StartBusStopName , 
         bfbs.EndBusStopID , 
         bsEnd.BusStopName as EndBusStopName, 
         bfbs.StartsAt, 
         bfbs.StopsAt 
     FROM 
         BusFair_BusStop bfbs
         INNER JOIN BusStop bsStart ON bfbs.StartBusStopID = bsStart.BusStopID
         INNER JOIN BusStop bsEnd ON bfbs.EndBusStopID = bsEnd.BusStopID 
         INNER JOIN BusFair bf ON bfbs.BusFairID = bf.BusFairID 
     WHERE 
         bsStart.BusStopID = @startBusStopID AND bfbs.StartsAt >= @startTime 
         AND bfbs.StopsAt <= @maxArrivalTime
 UNION ALL
     SELECT 
         CTE.RecLevel + 1 as RecLevel,
         bf.BusFairID ,
         bf.LineNumber,
         bfbs.startBusStopID , 
         bsStart.BusStopName , 
         bfbs.EndBusStopID, 
         bsEnd.BusStopName , 
         bfbs.StartsAt, 
         bfbs.StopsAt 
     FROM 
         BusFair_BusStop bfbs
         INNER JOIN BusStop bsStart ON bfbs.StartBusStopID = bsStart.BusStopID
         INNER JOIN BusStop bsEnd ON bfbs.EndBusStopID = bsEnd.BusStopID 
         INNER JOIN BusFair bf ON bfbs.BusFairID = bf.BusFairID 
         INNER JOIN CTE ON CTE.EndBusStopID = bfbs.startbusstopid 
     WHERE 
         bfbs.StopsAt <= @maxArrivalTime
         AND bfbs.StartsAt >= CTE.StopsAt 
 ),
 CTE2 AS(
 select top 1 * from CTE where endbusstopid = @endBusStopID order by StopsAt
 UNION ALL
 select CTE.* from CTE 
 INNER JOIN CTE2 ON CTE.EndBusStopID = CTE2.StartBusStopID
 AND CTE.recLevel = CTE2.recLevel -1
 AND CTE.StopsAt <= CTE2.StartsAt 
 WHERE CTE.reclevel>=0
 ),
 CTE3 AS(
 SELECT *, ROW_NUMBER() OVER (PARTITION BY RecLevel ORDER BY stopsAt )
  AS RowNum FROM CTE2 
 ),
 CTE4 AS(
     SELECT ROW_NUMBER() OVER(PARTITION BY LineNumber ORDER BY StartsAt) as MinTimePerLine,
     ROW_NUMBER() OVER(PARTITION BY LineNumber ORDER BY StopsAt DESC) as MaxTimePerLine,
     * FROM CTE3 WHERE RowNum=1
 )
 select distinct 
     (select startbusstopname from CTE4  c where MinTimePerLine=1 and c.linenumber=cte4.linenumber) as startstation, 
     (select startbusstopid from CTE4  c where mintimeperline=1 and c.linenumber=cte4.linenumber) as startstationid,
     (select startsat  from CTE4  c where mintimeperline=1 and c.linenumber=cte4.linenumber) as starttime,
     (select endbusstopname from CTE4  c where MaxTimePerLine=1 and c.linenumber=cte4.linenumber) as startstation, 
     (select endbusstopid from CTE4  c where maxtimeperline=1 and c.linenumber=cte4.linenumber) as startstationid,
     (select stopsat  from CTE4  c where maxtimeperline=1 and c.linenumber=cte4.linenumber) as starttime
     
 from CTE4 
 where mintimeperline = 1 or maxtimeperline=1
 GO
 /****** Object:  Default [DF__BusFair_B__EndBu__117F9D94]    Script Date: 02/16/2011 09:19:39 ******/
 ALTER TABLE [dbo].[BusFair_BusStop] ADD  DEFAULT ((0)) FOR [EndBusStopID]
 GO
 /****** Object:  ForeignKey [FK_BusFair_BusLine]    Script Date: 02/16/2011 09:19:39 ******/
 ALTER TABLE [dbo].[BusFair]  WITH CHECK ADD  CONSTRAINT [FK_BusFair_BusLine] FOREIGN KEY([LineNumber])
 REFERENCES [dbo].[BusLine] ([LineNumber])
 GO
 ALTER TABLE [dbo].[BusFair] CHECK CONSTRAINT [FK_BusFair_BusLine]
 GO


 -- Nota:

 -- I did note a very small thing to change: 
 select distinct (select startbusstopname from CTE4 c where MinTimePerLine=1 and c.linenumber=cte4.linenumber) as startstation, (select startbusstopid from CTE4 c where mintimeperline=1 and c.linenumber=cte4.linenumber) as startstationid, (select startsat from CTE4 c where mintimeperline=1 and c.linenumber=cte4.linenumber) as starttime, (select endbusstopname from CTE4 c where MaxTimePerLine=1 and c.linenumber=cte4.linenumber) as endstation, (select endbusstopid from CTE4 c where maxtimeperline=1 and c.linenumber=cte4.linenumber) as endstationid, (select stopsat from CTE4 c where maxtimeperline=1 and c.linenumber=cte4.linenumber) as endtime 

 -------------------------
 -- Using CTE to remove duplicate records


 USE AdventureWorks2014
 GO  -- Prepare temporary table to test the deletion of duplicate records
  
 SELECT * 
 INTO dbo.TempPersonContact 
 FROM Person.Person 
 GO
 SELECT FirstName, LastName, COUNT(1) AS NumberOfInstances 
 FROM dbo.TempPersonContact 
 GROUP BY FirstName, LastName 
 -- HAVING COUNT(1) > 1
 GO 
  -- Check the duplicate records 
 SELECT FirstName, LastName, COUNT(1) AS NumberOfInstances 
 FROM dbo.TempPersonContact 
 GROUP BY FirstName, LastName 
 HAVING COUNT(1) > 1
 GO 

    
 -- Scenario: For duplicate records, keep those with the highest EmailPromotion -- number. 
 -- If the EmailPromotion values tie for the duplicate reocrds, -- keep the record with the bigger ContactID --
  -- Note: by using CTE, we can affect the original table (dbo.TempPersonContact) 
  -- by referring to the CTE name (i.e. "Duplicates") 
  WITH Duplicates AS  
  ( SELECT [BusinessEntityID], ROW_NUMBER() OVER( PARTITION BY FirstName, LastName 
       ORDER BY EmailPromotion DESC, [BusinessEntityID]DESC) AS OrderID 
       FROM dbo.TempPersonContact ) 
   DELETE Duplicates WHERE OrderID > 1 
   GO -- Check the duplicate records; this should return no dataset since we have deleted in the previous statement SELECT FirstName, LastName, COUNT(1) AS NumberOfInstances FROM dbo.TempPersonContact GROUP BY FirstName, LastName HAVING COUNT(1) > 1 ;  
    -- Clean up table /* DROP TABLE dbo.TempPersonContact */

	------------------------
	-- http://social.technet.microsoft.com/wiki/contents/articles/22706.how-to-remove-duplicates-from-a-table-in-sql-server.aspx
	-- http://social.technet.microsoft.com/wiki/contents/articles/17785.transact-sql-portal.aspx
USE TempDB
GO
	CREATE TABLE Persons(
    Name varchar(50) NOT NULL,
    City varchar(30) NOT NULL,
    [State] char(2) NOT NULL
)
GO
INSERT INTO Persons(Name, City, [State]) VALUES('John', 'Dallas','TX')
INSERT INTO Persons(Name, City, [State]) VALUES('Mark', 'Seattle','WA')
INSERT INTO Persons(Name, City, [State]) VALUES('Nick', 'Phoenix','AZ')
INSERT INTO Persons(Name, City, [State]) VALUES('Laila', 'San Jose','CA')
INSERT INTO Persons(Name, City, [State]) VALUES('Samantha', 'Tulsa','OK')
INSERT INTO Persons(Name, City, [State]) VALUES('Bella', 'San Antonio','TX')
INSERT INTO Persons(Name, City, [State]) VALUES('John', 'Dallas','TX')
INSERT INTO Persons(Name, City, [State]) VALUES('John', 'Dallas','TX')
INSERT INTO Persons(Name, City, [State]) VALUES('Mark', 'Seattle','WA')
INSERT INTO Persons(Name, City, [State]) VALUES('Nick', 'Tempe','FL')
INSERT INTO Persons(Name, City, [State]) VALUES('John', 'Dallas','TX')
GO
SELECT * FROM Persons
GO

SELECT Name
    , City
    , [State]
    , ROW_NUMBER() OVER(PARTITION BY Name, City, [State] ORDER BY [Name]) AS Rnum
FROM Persons
GO


-- In the code by saying WHERE Rnum <> 1, we are asking SQL Server to keep all the records with Rank 1, which are not duplicates, and delete any other record. After executing this query in SQL Server Management Studio, you will end up with no duplicates in your table. To confirm that just run a simple query against your table.

;WITH CTE AS
(
SELECT Name
    , City
    , [State]
    , ROW_NUMBER() OVER(PARTITION BY Name, City, [State] ORDER BY [Name]) AS Rnum
FROM Persons
)
DELETE FROM CTE WHERE Rnum <> 1
GO

SELECT * FROM Persons
go
