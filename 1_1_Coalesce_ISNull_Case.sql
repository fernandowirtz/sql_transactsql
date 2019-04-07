SELECT Name, Size
FROM SalesLT.Product;
GO

SELECT Name, ISNULL(TRY_CAST(Size AS Integer),0) AS NumericSize
FROM SalesLT.Product;

SELECT ProductNumber, ISNULL(Color, '') + ', ' + ISNULL(Size, '') AS ProductDetails
FROM SalesLT.Product;


--  Devuelve un valor NULL si las dos expresiones especificadas son iguales.
--  Por ejemplo, SELECT NULLIF(4,4) AS Same, NULLIF(5,7) AS Different; devuelve NULL para la primera columna (4 y 4) porque los dos valores de entrada son iguales. La segunda columna devuelve el primer valor (5) porque los dos valores de entrada son diferentes.


SELECT Name, NULLIF(Color, 'Multi') AS SingleColor
FROM SalesLT.Product;

--A. Devolver importes del presupuesto que no han cambiado
--En el ejemplo siguiente se crea una tabla denominada budgets para mostrar un departamento (dept), su presupuesto actual (current_year) y su presupuesto anterior (previous_year). En el año actual se utiliza NULL para los departamentos cuyos presupuestos no han cambiado desde el año anterior y 0 para los presupuestos que aún no se han determinado. Para averiguar el promedio de los departamentos que reciben un presupuesto e incluir el valor del presupuesto del año anterior (utilice el valor previous_year cuando el de current_year es NULL), combine las funciones NULLIF y COALESCE.

CREATE TABLE dbo.budgets  
(  
   dept            tinyint   IDENTITY,  
   current_year      decimal   NULL,  
   previous_year   decimal   NULL  
);  
INSERT budgets VALUES(100000, 150000);  
INSERT budgets VALUES(NULL, 300000);  
INSERT budgets VALUES(0, 100000);  
INSERT budgets VALUES(NULL, 150000);  
INSERT budgets VALUES(300000, 250000);  
GO    
SET NOCOUNT OFF;  
SELECT AVG(NULLIF(COALESCE(current_year,  
   previous_year), 0.00)) AS 'Average Budget'  
FROM budgets;  
GO

--B. Comparar NULLIF y CASE
--Para mostrar la similitud entre NULLIF y CASE, las siguientes consultas determinan si los valores de las columnas MakeFlag y FinishedGoodsFlag coinciden. En la primera consulta se utiliza NULLIF. La segunda consulta utiliza la expresión CASE.

USE AdventureWorks2014  
GO  
SELECT ProductID, MakeFlag, FinishedGoodsFlag,   
   NULLIF(MakeFlag,FinishedGoodsFlag)AS 'Null if Equal'  
FROM Production.Product  
WHERE ProductID < 10;  
GO  

SELECT ProductID, MakeFlag, FinishedGoodsFlag,'Null if Equal' =  
   CASE  
       WHEN MakeFlag = FinishedGoodsFlag THEN NULL  
       ELSE MakeFlag  
   END  
FROM Production.Product  
WHERE ProductID < 10;  
GO


-- En el siguiente ejemplo se crea una tabla budgets, se cargan datos y se usa NULLIF para devolver un valor null 
-- si current_year ni previous_year contienen datos.

CREATE TABLE budgets (  
   dept           tinyint,  
   current_year   decimal(10,2),  
   previous_year  decimal(10,2)  
);  

INSERT INTO budgets VALUES(1, 100000, 150000);  
INSERT INTO budgets VALUES(2, NULL, 300000);  
INSERT INTO budgets VALUES(3, 0, 100000);  
INSERT INTO budgets VALUES(4, NULL, 150000);  
INSERT INTO budgets VALUES(5, 300000, 300000);  

SELECT dept, NULLIF(current_year,previous_year) AS LastBudget  
FROM budgets;






-- En el ejemplo siguiente se muestra cómo COALESCE selecciona los datos de la primera columna que tiene un valor no nulo. 
-- En este ejemplo se usa la base de datos AdventureWorks2012.
USE Adventureworks2014
GO
SELECT Name, Class, Color, ProductNumber,  
COALESCE(Class, Color, ProductNumber) AS FirstNotNull  
FROM Production.Product;
Go




-- En este ejemplo, la tabla wages incluye tres columnas con información acerca del sueldo anual de los empleados: 
-- la tarifa por hora, el salario y la comisión. 
-- No obstante, un empleado recibe solo un tipo de sueldo. 
-- Para determinar el importe total pagado a todos los empleados, utilice COALESCE para obtener solo los valores no NULL 
-- que se encuentran en hourly_wage, salary y commission.

SET NOCOUNT ON;  
GO  
USE tempdb;  
IF OBJECT_ID('dbo.wages') IS NOT NULL  
    DROP TABLE wages;  
GO  
CREATE TABLE dbo.wages  
(  
    emp_id        tinyint   identity,  
    hourly_wage   decimal   NULL,  
    salary        decimal   NULL,  
    commission    decimal   NULL,  
    num_sales     tinyint   NULL  
);  
GO  
INSERT dbo.wages (hourly_wage, salary, commission, num_sales)  
VALUES  
    (10.00, NULL, NULL, NULL),  
    (20.00, NULL, NULL, NULL),  
    (30.00, NULL, NULL, NULL),  
    (40.00, NULL, NULL, NULL),  
    (NULL, 10000.00, NULL, NULL),  
    (NULL, 20000.00, NULL, NULL),  
    (NULL, 30000.00, NULL, NULL),  
    (NULL, 40000.00, NULL, NULL),  
    (NULL, NULL, 15000, 3),  
    (NULL, NULL, 25000, 2),  
    (NULL, NULL, 20000, 6),  
    (NULL, NULL, 14000, 4);  
GO  
SET NOCOUNT OFF;  
GO  
SELECT CAST(COALESCE(hourly_wage * 40 * 52,   
   salary,   
   commission * num_sales) AS money) AS 'Total Salary'   
FROM dbo.wages  
ORDER BY 'Total Salary';  
GO
-----

USE AdventureWorksLT
GO
SELECT Name, COALESCE(DiscontinuedDate, SellEndDate, SellStartDate) AS FirstNonNullDate
FROM SalesLT.Product;
GO
--Searched case
SELECT Name,
		CASE
			WHEN SellEndDate IS NULL THEN 'On Sale'
			ELSE 'Discontinued'
		END AS SalesStatus
FROM SalesLT.Product;

--Simple case
SELECT Name,
		CASE Size
			WHEN 'S' THEN 'Small'
			WHEN 'M' THEN 'Medium'
			WHEN 'L' THEN 'Large'
			WHEN 'XL' THEN 'Extra-Large'
			ELSE ISNULL(Size, 'n/a')
		END AS ProductSize
FROM SalesLT.Product;

------------------------------------

SELECT CAST(ProductID AS varchar(5)) + ': ' + Name AS ProductName
FROM SalesLT.Product;

SELECT CONVERT(varchar(5), ProductID) + ': ' + Name AS ProductName
FROM SalesLT.Product;

SELECT SellStartDate,
       CONVERT(nvarchar(30), SellStartDate) AS ConvertedDate,
	   CONVERT(nvarchar(30), SellStartDate, 126) AS ISO8601FormatDate
FROM SalesLT.Product;


----
SELECT Name,Size
FROM SalesLT.Product;
GO

SELECT Name, CAST (Size AS Integer) AS NumericSize
FROM SalesLT.Product; --(note error - some sizes are incompatible)


-- https://docs.microsoft.com/es-es/sql/t-sql/functions/try-cast-transact-sql
-- TRY_CAST or TRY_CONVERT
-- Devuelve una conversión de valor al tipo de datos especificado si la conversión se realiza correctamente; de lo contrario, devuelve NULL.

--A. TRY_CAST devuelve NULL
--En el ejemplo siguiente se muestra que TRY_CAST devuelve NULL cuando se produce un error en la conversión.

SELECT   
    CASE WHEN TRY_CAST('test' AS float) IS NULL   
    THEN 'Cast failed'  
    ELSE 'Cast succeeded'  
END AS Result;  
GO

SET DATEFORMAT dmy;  
SELECT TRY_CAST('12/31/2010' AS datetime2) AS Result;  
GO





SELECT Name, TRY_CAST (Size AS Integer) AS NumericSize
FROM SalesLT.Product; --(note incompatible sizes are returned as NULL)


