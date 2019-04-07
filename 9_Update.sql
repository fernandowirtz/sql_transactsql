-- https://msdn.microsoft.com/es-es/library/ms177523.aspx
-- Trabajando con actualizaciones
-- UPDATE Cambiar contenido de 1 o varias columnas

USE AdventureWorks2014
GO
SELECT *
FROM Sales.SalesPerson
go
--
SELECT *
INTO VentasPersona
FROM Sales.SalesPerson

GO
drop table VentasPersona
go
SELECT Bonus, CommissionPct, SalesQuota
	INTO VentasPersona
	FROM Sales.SalesPerson
	WHERE (Bonus = 0);
GO

SELECT *
FROM VentasPersona ;

-- Actualizar todos los campos de determinadas columnas de una tabla

UPDATE dbo.VentasPersona
	SET Bonus = 6000, CommissionPct = .10, SalesQuota = NULL;
GO

--
--
USE pubs
GO

SELECT *
FROM authors ;

SELECT *
INTO Autores
FROM Authors
Go
-- Actualizamos el campo 'contract' de la tabla autores cuyo código postal empiece por 94

UPDATE autores
SET contract = 1
WHERE zip LIKE '94%'

--
--
USE AdventureWorks2014
GO

SELECT *
INTO Producto
FROM Production.Product ;

UPDATE Producto
SET color = 'metallic red'
WHERE (Name LIKE 'Road-250%')
		AND ( Color = 'red') ;
GO
SELECT Name,color from Producto
GO

-- Hacemos una selección para ver que es lo que va a actualizar
SELECT TOP (10) * 
	FROM HumanResources.Employee ;
GO
SELECT  * 
Into Empleados
FROM HumanResources.Employee ;
GO
-- Actualizamos sólo los 10 primeros campos 
UPDATE TOP (10) Empleados
	SET VacationHours = VacationHours * 1.25 ;
GO

--
--
USE pubs
GO
SELECT *
	INTO tmptitulos
	FROM titles ;
SELECT *
	INTO tmpeditoriales
	FROM publishers ;
-- Probar SELECT
SELECT pub_id
FROM tmpeditoriales
WHERE (pub_name = 'new moon books')
	 AND (state = 'ma')
-- Resultado SELECT
--        0736
-- Asignamos al campo un valor obtenido con una 'select'
UPDATE tmptitulos
	SET pub_id = (
					SELECT pub_id
						FROM tmpeditoriales
						WHERE pub_name = 'new moon books'
							AND state = 'ma' );
GO



-- Lo mismo 

UPDATE tmptitulos
SET pub_id = 0736
GO


UPDATE tmptitulos
	SET pub_id = (
					SELECT pub_id
						FROM tmpeditoriales
						WHERE pub_name = 'new moon books'
							AND state = 'ma' )
							OUTPUT DELETED.*,INSERTED.*;
GO

--
--
USE AdventureWorks2014
GO
SELECT ProductID
	FROM Purchasing.ProductVendor
	WHERE  [LastReceiptCost]= 50.2635 
GO
DROP TABLE Productos
GO
SELECT *
INTO Productos
FROM Production.Product
GO
UPDATE Productos
SET ListPrice = ListPrice + 2
GO
-- Actualizar ListPrice porque sino es 0
-- Asignamos al campo un valor obtenido con una 'select'

UPDATE Productos
	SET ListPrice = ListPrice * 2
	WHERE ProductID IN (
							SELECT ProductID
								FROM Purchasing.ProductVendor
								WHERE  [LastReceiptCost]= 50.2635 );
GO


-- Lo mismo que la anterior, pero usando 'joins'


UPDATE Productos
	SET ListPrice = ListPrice * 2
	FROM Production.Product AS p
	INNER JOIN Purchasing.ProductVendor AS pv
	ON	p.ProductID = pv.ProductID
			AND pv.[LastReceiptCost]= 50.2635 ;
GO
-----------------------
-- Clausula Output - Update - Stored Procedure

-- Incrementando dias de vacaciones
-- 
SELECT TOP 10 BusinessEntityID,VacationHours,ModifiedDate
FROM HumanResources.Employee;
GO
-- CREATE PROCEDURE xxxxx
ALTER PROC Actualizar_Variable
AS
BEGIN
IF OBJECT_ID('HumanResources.Empleado','U') is Not Null
DROP TABLE HumanResources.Empleado
SELECT *
INTO HumanResources.Empleado
FROM HumanResources.Employee;
DECLARE @MyTableVar table(
    EmpID int NOT NULL ,
    OldVacationHours int,
    NewVacationHours int,
    ModifiedDate datetime);
UPDATE TOP (10) HumanResources.Empleado
SET VacationHours = VacationHours * 2,
    ModifiedDate = GETDATE() 
OUTPUT inserted.BusinessEntityID ,
       deleted.VacationHours ,
       inserted.VacationHours,
       inserted.ModifiedDate 
INTO @MyTableVar;
--Display the result set of the table variable.
Print 'Tabla Output'
SELECT EmpID as Empleado, OldVacationHours as HorasVacacionesAntiguas,
	 NewVacationHours  as HorasVacacionesNuevas,CAST(ModifiedDate as DATE ) as FechaCambio
FROM @MyTableVar;
--Display the result set of the table.
Print 'Tabla Empleado'
SELECT TOP (10) BusinessEntityID as Empleado, VacationHours as [Horas de Vacaciones Actualizadas], ModifiedDate
FROM HumanResources.Empleado;
END
GO

EXEC Actualizar_Variable
GO


-- Release 2

CREATE PROC Actualizar_Variable_2
	@Dias int
AS
BEGIN
IF OBJECT_ID('HumanResources.Empleado','U') is Not Null
	DROP TABLE HumanResources.Empleado
SELECT *
INTO HumanResources.Empleado
FROM HumanResources.Employee;
DECLARE @MyTableVar table(
    EmpID int NOT NULL ,
    OldVacationHours int,
    NewVacationHours int,
    ModifiedDate datetime);
UPDATE TOP (10) HumanResources.Empleado
SET VacationHours = VacationHours + @Dias,
    ModifiedDate = GETDATE() 
OUTPUT inserted.BusinessEntityID ,
       deleted.VacationHours ,
       inserted.VacationHours,
       inserted.ModifiedDate 
INTO @MyTableVar;
--Display the result set of the table variable.
Print 'Tabla Output'
SELECT EmpID as Empleado, OldVacationHours as HorasVacacionesAntiguas,
	 NewVacationHours  as HorasVacacionesNuevas,CAST(ModifiedDate as DATE ) as FechaCambio
FROM @MyTableVar;
--Display the result set of the table.
Print 'Tabla Empleado'
SELECT TOP (10) BusinessEntityID as Empleado, VacationHours as [Horas de Vacaciones Actualizadas], ModifiedDate
FROM HumanResources.Empleado;
END
GO

EXEC Actualizar_Variable_2 
GO

--Msg 201, Level 16, State 4, Procedure Actualizar_Variable_2, Line 247
--Procedure or function 'Actualizar_Variable_2' expects parameter '@Dias', 
-- which was not supplied.
-- Hint
-- @Dias int default 2 No Error
EXEC Actualizar_Variable_2 3
GO
EXEC Actualizar_Variable_2 @Dias=10
GO




---------------------




USE MYDB
GO
CREATE TABLE Employee
(
   EMP_Id          INT IDENTITY(1,1)    NOT NULL,
   Emp_Name        VARCHAR(100)        NOT NULL,
   Emp_LastName    VARCHAR(100)        ,
   Emp_DOB         DATE,
   emp_DOJ         DATETIME            DEFAULT GETDATE()
)
GO
INSERT INTO Employee(Emp_Name,Emp_LastName,Emp_DOB) OUTPUT inserted.*VALUES ('William','George','1986-04-12')
GO
UPDATE   Employee SET Emp_LastName='John'  OUTPUT deleted.*,inserted.*WHERE Emp_id=1
GO
DELETE FROM Employee  OUTPUT deleted.*  WHERE Emp_id=1


The output of the above statements shows capturing the values of identity column/ column which has default values is much easier using the OUTPUT clause. The output of the OUTPUT clause can be put it in a table or a table variable. Let us see a sample below:


--Inserting the output of output clause into TableVariable
DECLARE @Employee TABLE (Emp_id INT,Emp_name VARCHAR(100),Emp_DOJ DATETIME)


INSERT INTO Employee(Emp_Name,Emp_LastName,Emp_DOF)
OUTPUT inserted.emp_id,inserted.emp_name,inserted.emp_DOJ INTO @Employee VALUES ('William','George','1986-04-12')


SELECT * FROM @Employee GO
--Inserting the output of output clause into Table for maintainging the history
CREATE TABLE Employee_History
(
   History_id          INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
   EMP_Id              INT                 NOT NULL ,
   Emp_Name            VARCHAR(100)        NOT NULL,
   Emp_LastName        VARCHAR(100)        ,
   Emp_DOB             DATE                ,
   emp_DOJ             DATETIME            ,
   InsertdDate         DATETIME            )GO
UPDATE   Employee 
SET Emp_LastName='John' 
OUTPUT deleted.*,GETDATE() 
INTO  Employee_History(emp_id,Emp_Name,Emp_LastName,Emp_DOB,Emp_DOJ,InsertdDate)
WHERE Emp_id=1

---------------------
-- UPDATE con OUTPUT y Variable Tabla

USE AdventureWorks2014;
GO
DROP TABLE HumanResources.Empleado
GO

SELECT *
INTO HumanResources.Empleado
FROM HumanResources.Employee
GO
SELECT TOP (10) BusinessEntityID, VacationHours, ModifiedDate
FROM HumanResources.Empleado
GO

-- Nota:Todo junto sino:
-- Msg 1087, Level 15, State 2, Line 232
-- Must declare the table variable "@MyTableVar".


DECLARE @MyTableVar table(
    EmpID int NOT NULL,
    OldVacationHours int,
    NewVacationHours int,
    ModifiedDate date);
UPDATE TOP (10) HumanResources.Empleado
SET VacationHours = VacationHours + 10,
    ModifiedDate = GETDATE() 
OUTPUT inserted.BusinessEntityID,
       deleted.VacationHours,
       inserted.VacationHours,
       inserted.ModifiedDate
INTO @MyTableVar;

--Display the result set of the table variable.
SELECT EmpID, OldVacationHours, NewVacationHours, ModifiedDate
FROM @MyTableVar;
GO
--Display the result set of the table.
SELECT TOP (20) BusinessEntityID, VacationHours, ModifiedDate
FROM HumanResources.Empleado
GO

-------------------
CREATE PROC UPDATE_OUTPUT_TABLE
AS
	BEGIN
	DECLARE @MyTableVar table(
    EmpID int NOT NULL,
    OldVacationHours int,
    NewVacationHours int,
    ModifiedDate date);
UPDATE TOP (10) HumanResources.Empleado
SET VacationHours = VacationHours + 10,
    ModifiedDate = GETDATE() 
OUTPUT inserted.BusinessEntityID,
       deleted.VacationHours,
       inserted.VacationHours,
       inserted.ModifiedDate
INTO @MyTableVar;
--Display the result set of the table variable.
SELECT EmpID, OldVacationHours, NewVacationHours, ModifiedDate
FROM @MyTableVar;
--Display the result set of the table.
SELECT TOP (20) BusinessEntityID, VacationHours, ModifiedDate
FROM HumanResources.Empleado
END
GO
EXEC UPDATE_OUTPUT_TABLE
GO

----------------------

-- Usar OUTPUT INTO con una instrucción UPDATE
--En el ejemplo siguiente se actualiza un 25 por ciento la columna VacationHours de las 10 primeras filas de la tabla Employee. La cláusula OUTPUT devuelve el valor de VacationHours antes de aplicar la instrucción UPDATE en la columna deleted.VacationHours, y el valor actualizado de la columna inserted.VacationHours en la variable table@MyTableVar.
--Las dos instrucciones SELECT que le siguen devuelven los valores en @MyTableVar y los resultados de la operación de actualización en la tabla Employee.

USE AdventureWorks2014;
GO
DROP TABLE HumanResources.Empleado
GO
SELECT *
INTO HumanResources.Empleado
FROM HumanResources.Employee
GO
DECLARE @MyTableVar table(
    EmpID int NOT NULL,
    OldVacationHours int,
    NewVacationHours int,
    ModifiedDate datetime);

UPDATE TOP (10) HumanResources.Empleado
SET VacationHours = VacationHours * 1.25,
    ModifiedDate = GETDATE() 
OUTPUT inserted.BusinessEntityID,
       deleted.VacationHours,
       inserted.VacationHours,
       inserted.ModifiedDate
INTO @MyTableVar;

--Display the result set of the table variable.
SELECT EmpID, OldVacationHours, NewVacationHours, ModifiedDate
FROM @MyTableVar;
GO
--Display the result set of the table.
SELECT TOP (10) BusinessEntityID, VacationHours, ModifiedDate
FROM HumanResources.Empleado
GO
------------------
-- D.Usar OUTPUT INTO para devolver una expresión
-- El ejemplo siguiente, que se basa en el ejemplo C, define una expresión en la cláusula OUTPUT como la diferencia entre el valor actualizado de VacationHours y el valor de VacationHours antes de aplicar la actualización. El valor de esta expresión se devuelve a la variable table@MyTableVar en la columna VacationHoursDifference.


USE AdventureWorks2014;
GO
DECLARE @MyTableVar table(
    EmpID int NOT NULL,
    OldVacationHours int,
    NewVacationHours int,
    VacationHoursDifference int,
    ModifiedDate datetime);

UPDATE TOP (10) HumanResources.Employee
SET VacationHours = VacationHours * 1.25,
    ModifiedDate = GETDATE()
OUTPUT inserted.BusinessEntityID,
       deleted.VacationHours,
       inserted.VacationHours,
       inserted.VacationHours - deleted.VacationHours,
       inserted.ModifiedDate
INTO @MyTableVar;

--Display the result set of the table variable.
SELECT EmpID, OldVacationHours, NewVacationHours, 
    VacationHoursDifference, ModifiedDate
FROM @MyTableVar;
GO
SELECT TOP (10) BusinessEntityID, VacationHours, ModifiedDate
FROM HumanResources.Employee;
GO

-------------

-- F.Usar OUTPUT INTO con from_table_name en una instrucción DELETE
-- En el ejemplo siguiente se eliminan las filas de la tabla ProductProductPhoto según los criterios 
-- de búsqueda definidos en la cláusula FROM de la instrucción DELETE. 
-- La cláusula OUTPUT devuelve columnas de la tabla que se elimina 
-- (deleted.ProductID, deleted.ProductPhotoID) y de la tabla Product.
--  La tabla se utiliza en la cláusula FROM para especificar las filas que se van a eliminar.

USE AdventureWorks2014;
GO
SELECT * FROM Production.ProductProductPhoto
GO
SELECT * FROM Production.Product
GO
DECLARE @MyTableVar table (
    ProductID int NOT NULL, 
    ProductName nvarchar(50)NOT NULL,
    ProductModelID int NOT NULL, 
    PhotoID int NOT NULL);

DELETE Production.ProductProductPhoto
OUTPUT DELETED.ProductID,
       p.Name,
       p.ProductModelID,
       DELETED.ProductPhotoID
    INTO @MyTableVar
FROM Production.ProductProductPhoto AS ph
JOIN Production.Product as p 
    ON ph.ProductID = p.ProductID 
    WHERE p.ProductModelID BETWEEN 120 and 130;

--Display the results of the table variable.
SELECT ProductID, ProductName, ProductModelID, PhotoID 
FROM @MyTableVar
ORDER BY ProductModelID;
GO

---

