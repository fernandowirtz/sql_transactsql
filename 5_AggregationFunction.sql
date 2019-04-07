-- Funciones de Agregado

--Devuelve la tasa de impuestos más baja (mínima).

USE AdventureWorks2014;
GO
-- Campo TaxRate   (Tipo de Impuesto)
SELECT TaxRate as  [Tasas]
FROM Sales.SalesTaxRate;
GO

SELECT DISTINCT TOP 3 TaxRate as  [Tasas]
FROM Sales.SalesTaxRate
-- ORDER BY 1 
ORDER BY TaxRate -- DESC
GO
-- Devuelve la tasa de impuestos más baja (minima).
SELECT MIN(TaxRate) [Tasa Minima]
FROM Sales.SalesTaxRate;
GO
-- Devuelve la tasa de impuestos más alta (maxima).
SELECT MAX(TaxRate) [Tasa Maxima]
FROM Sales.SalesTaxRate;
GO

SELECT MAX(TaxRate) TasaMaxima
FROM Sales.SalesTaxRate;
GO

SELECT MAX(TaxRate) Tasa Maxima
FROM Sales.SalesTaxRate;
GO
--Mens. 102, Nivel 15, Estado 1, Línea 1
--Sintaxis incorrecta cerca de 'Maxima'.

-- Usar AVG con DISTINCT
--Devuelve el precio de venta promedio de los productos. 
-- Si se especifica DISTINCT, solo se tienen en cuenta valores únicos en el cálculo.

SELECT AVG(DISTINCT ListPrice)
FROM Production.Product;


-- 437,4042


--Usar AVG sin DISTINCT
-- Sin DISTINCT, la función AVG busca el precio de venta promedio de todos los productos de la tabla Product 
-- incluidos los valores duplicados.
SELECT ListPrice
FROM Production.Product
GO

SELECT AVG(ListPrice)
FROM Production.Product;

-- 438.6662

-- Si se especifica DISTINCT, solo se tienen en cuenta valores únicos en el cálculo.

SELECT AVG(DISTINCT ListPrice)
FROM Production.Product;
--437.4042

-- Usar las funciones SUM y AVG para los cálculos
--En el ejemplo siguiente se calcula el promedio de horas de vacaciones y la suma de horas de baja por enfermedad que han utilizado los vicepresidentes de Adventure Works Cycles. Cada una de estas funciones de agregado produce un valor único de resumen para todas las filas recuperadas.
USE AdventureWorks2014;
GO
SELECT AVG(VacationHours)AS 'Average vacation hours', 
    SUM(SickLeaveHours) AS 'Total sick leave hours'
FROM HumanResources.Employee
WHERE JobTitle LIKE 'Vice President%'
GO

--El conjunto de resultados es el siguiente.
--Average vacation hours       Total sick leave hours
------------------------       ----------------------
--25                           97
--(1 row(s) affected)


-- B.Usar las funciones SUM y AVG con una cláusula GROUP BY
-- Cuando se utiliza con una cláusula GROUP BY, cada función de agregado produce un solo valor para cada grupo, en vez de para toda la tabla. En el ejemplo siguiente se obtienen valores de resumen para cada territorio de ventas. El resumen muestra el promedio de bonificaciones recibidas por los vendedores de cada territorio y la suma de las ventas realizadas hasta la fecha en cada territorio.

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
--------------------

A.Ejemplo sencillo
-- Tipo impositivo mayor (máximo).
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

 ----------------------





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

 SUM

 Ejemplos
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
