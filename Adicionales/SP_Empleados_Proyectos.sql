
--USE tempdb
--GO
DROP DATABASE IF EXISTS Empresa
GO
CREATE DATABASE Empresa
GO
USE Empresa
GO

CREATE TABLE Projects(
  ProjectID int IDENTITY NOT NULL,
  Name VARCHAR(50) NOT NULL,
  Description ntext NULL,
  StartDate smalldatetime NOT NULL,
  EndDate smalldatetime NULL,
  CONSTRAINT PK_Projects PRIMARY KEY CLUSTERED (ProjectID ASC)
)
GO

SET IDENTITY_INSERT Projects ON

INSERT INTO Projects (ProjectID, Name, Description, StartDate, EndDate)
VALUES (1, 'Classic Vest', 'Research, design and development of Classic Vest. Light-weight, wind-resistant, packs to fit into a pocket.', '20030601', NULL)

INSERT INTO Projects (ProjectID, Name, Description, StartDate, EndDate)
VALUES (2, 'Cycling Cap', 'Research, design and development of Cycling Cap. Traditional style with a flip-up brim; one-size fits all.', '20010601', '20030601')

INSERT INTO Projects (ProjectID, Name, Description, StartDate, EndDate)
VALUES (3, 'Full-Finger Gloves', 'Research, design and development of Full-Finger Gloves. Synthetic palm, flexible knuckles, breathable mesh upper. Worn by the AWC team riders.', '20020601', '20030601')

INSERT INTO Projects (ProjectID, Name, Description, StartDate, EndDate)
VALUES (4, 'Half-Finger Gloves', 'Research, design and development of Half-Finger Gloves. Full padding, improved finger flex, durable palm, adjustable closure.', '20020601', '20030601')
GO

SELECT * FROM Projects
GO
CREATE TABLE EmployeesProjects(
  EmployeeID int NOT NULL,
  ProjectID int NOT NULL,
  CONSTRAINT PK_EmployeesProjects PRIMARY KEY CLUSTERED (EmployeeID ASC, ProjectID ASC)
)
GO

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (1, 4)

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (1, 24)

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (1, 38)

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (1, 113)

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (3, 1)

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (3, 21)

INSERT INTO EmployeesProjects (EmployeeID, ProjectID)
VALUES (3, 58)
GO

SELECT * FROM EmployeesProjects
GO
SELECT EmployeeID,COUNT(EmployeeID) as Projects
FROM EmployeesProjects
GROUP BY EmployeeID 
ORDER BY 2 DESC
GO

DROP TABLE IF EXISTS Employees
GO
CREATE TABLE Employees(
  EmployeeID int NOT NULL,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  MiddleName VARCHAR(50) NULL,
  JobTitle VARCHAR(50) NOT NULL,
  DepartmentID int NOT NULL,
  ManagerID int NULL,
  HireDate smalldatetime NOT NULL,
  Salary money NOT NULL,
  AddressID int NULL,
  CONSTRAINT PK_Employees PRIMARY KEY CLUSTERED (EmployeeID ASC)
)
GO

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (1, 'Guy', 'Gilbert', 'R', 'Production Technician', 7, 16, '19980731', 12500, 166)

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (2, 'Kevin', 'Brown', 'F', 'Marketing Assistant', 4, 6, '19990226', 13500, 102)

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (3, 'Roberto', 'Tamburello', NULL, 'Engineering Manager', 1, 12, '19991212', 43300, 193)

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (4, 'Rob', 'Walters', NULL, 'Senior Tool Designer', 2, 3, '20000105', 29800, 155)

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (5, 'Thierry', 'D''Hers', 'B', 'Tool Designer', 2, 263, '20000111', 25000, 40)

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (6, 'David', 'Bradley', 'M', 'Marketing Manager', 5, 109, '20000120', 37500, 199)

INSERT INTO Employees (EmployeeID, FirstName, LastName, MiddleName, JobTitle, DepartmentID, ManagerID, HireDate, Salary, AddressID)
VALUES (7, 'JoLynn', 'Dobney', 'M', 'Production Supervisor', 7, 21, '20000126', 25000, 275)
GO
SELECT * FROM Employees
GO

-- BEGIN EXAMPLE

-- Employees with more than Three Projects

CREATE PROCEDURE usp_AssignProject 
	(@employeeID int, @projectID int)
AS
BEGIN
  DECLARE @maxEmployeeProjectsCount int = 3;
  DECLARE @employeeProjectsCount int;

  BEGIN TRAN
  INSERT INTO EmployeesProjects (EmployeeID, ProjectID) 
  VALUES (@employeeID, @projectID)

  SET @employeeProjectsCount = (
    SELECT COUNT(*)
    FROM EmployeesProjects
    WHERE EmployeeID = @employeeID
  )
  IF(@employeeProjectsCount > @maxEmployeeProjectsCount)
    BEGIN
      RAISERROR('The employee has too many projects!', 16, 1);
      ROLLBACK;
	  RETURN
    END
  ELSE	
		BEGIN
			COMMIT
		END
END
GO
--testing 
EXEC usp_AssignProject 2, 1; -- no projects initially
GO
SELECT EmployeeID,COUNT(EmployeeID) as Projects
FROM EmployeesProjects
GROUP BY EmployeeID 
ORDER BY 2 DESC
GO
--EmployeeID	Projects
--1	4
--3	3
--2	1
EXEC usp_AssignProject 2, 2;
GO
EXEC usp_AssignProject 2, 3;
GO
SELECT EmployeeID,COUNT(EmployeeID) as Projects
FROM EmployeesProjects
GROUP BY EmployeeID 
ORDER BY 2 DESC
GO

-- 2	3

EXEC usp_AssignProject 2, 4; -- raiserror & rollback
GO

--(1 row affected)
--Msg 50000, Level 16, State 1, Procedure usp_AssignProject, Line 19 [Batch Start Line 163]
--The employee has too many projects!

SELECT EmployeeID,COUNT(EmployeeID) as Projects
FROM EmployeesProjects
GROUP BY EmployeeID 
ORDER BY 2 DESC
GO

--EmployeeID	Projects
--1					4
--2					3
--3					3


************

/* Same result without transaction */

DROP PROCEDURE IF EXISTS usp_AssignProject_v4
GO
CREATE PROCEDURE usp_AssignProject_v4
(
                 @emloyeeId INT,
                 @projectID INT
)
AS
     BEGIN
         IF(
           (
               SELECT COUNT(EmployeeID)
               FROM EmployeesProjects
               WHERE EmployeeID = @emloyeeId
           ) < 3)
             BEGIN
                 INSERT INTO EmployeesProjects(EmployeeID,
                                               ProjectID
                                              )
                 VALUES
                 (
                        @emloyeeId,
                        @projectID
                 );
         END;
             ELSE
				BEGIN
                 RAISERROR('The employee has too many projects!', 16, 1);
				END;
     END;
	 

-- END EXAMPLE

-- Employees with more than some projects

DROP PROCEDURE IF EXISTS usp_AssignProject_v1
GO
CREATE OR ALTER PROCEDURE usp_AssignProject_v1 
	(@numprojects int = 3,@employeeID int, @projectID int)
AS
BEGIN
  -- DECLARE @maxEmployeeProjectsCount int ;
  DECLARE @employeeProjectsCount int = 0;
  IF @numprojects>5
	BEGIN
		PRINT 'Num. de Proyectos no permitidos. Regla de empresa General'
		RETURN
	END  
  BEGIN TRAN
  INSERT INTO EmployeesProjects (EmployeeID, ProjectID) 
  VALUES (@employeeID, @projectID)

  SET @employeeProjectsCount = (
    SELECT COUNT(*)
    FROM EmployeesProjects
    WHERE EmployeeID = @employeeID
  )
  IF(@employeeProjectsCount > @numprojects)
    BEGIN
      RAISERROR('The employee has too many projects!', 16, 1);
      ROLLBACK;
	  RETURN;
    END
  ELSE	
		BEGIN
			COMMIT
		END
END
GO
-- TESTING 
EXEC usp_AssignProject_v1 9,4,1; -- no projects initially
GO
-- Num. de Proyectos no permitidos. Regla de empresa General

-- No doy numero de proyectos asume 3 por defecto
-- La situación esta asi
SELECT *
FROM EmployeesProjects
GO
SELECT EmployeeID,COUNT(EmployeeID) as Projects
FROM EmployeesProjects
GROUP BY EmployeeID 
ORDER BY 2 DESC
GO

--EmployeeID	Projects
--1					4
--2					3
--3					3

-- Empleado 2 ya tiene 3 proyectos asignados
EXEC usp_AssignProject 2,4; 
GO

--(1 row affected)
--Msg 50000, Level 16, State 1, Procedure usp_AssignProject, Line 19 [Batch Start Line 241]
--The employee has too many projects!

-- Problema cuando intentas asignarle al mismo empleado el mismo proyecto

EXEC usp_AssignProject 2,1; 
GO	

--Msg 2627, Level 14, State 1, Procedure usp_AssignProject, Line 9 [Batch Start Line 250]
--Violation of PRIMARY KEY constraint 'PK_EmployeesProjects'. Cannot insert duplicate key in object 'dbo.EmployeesProjects'. The duplicate key value is (2, 1).
--The statement has been terminated.
--
DROP PROCEDURE IF EXISTS usp_AssignProject_v2
GO
CREATE OR ALTER PROCEDURE usp_AssignProject_v2 
	(@numprojects int = 3,@employeeID int, @projectID int)
AS
BEGIN
	DECLARE  @cuenta int = 0;
	-- PRINT cast(@employeeID as char(1))
	-- PRINT cast(@projectID as Char(1))
	SET @cuenta =
			(SELECT COUNT(*)
			FROM EmployeesProjects
			WHERE EmployeeID = @employeeID
						AND ProjectID = @projectID);
	-- PRINT cast(@cuenta as char)
	IF @cuenta > 0
		BEGIN	
			PRINT 'Este empleado ya tiene asignado este proyecto'
			RETURN
		END
  -- DECLARE @maxEmployeeProjectsCount int ;
  DECLARE @employeeProjectsCount int = 0;
  IF @numprojects>5
	BEGIN
		PRINT 'Num. de Proyectos no permitidos. Regla de empresa General'
		RETURN
	END 
  
  BEGIN TRAN
  INSERT INTO EmployeesProjects (EmployeeID, ProjectID) 
  VALUES (@employeeID, @projectID)

  SET @employeeProjectsCount = (
    SELECT COUNT(*)
    FROM EmployeesProjects
    WHERE EmployeeID = @employeeID
  )
  IF(@employeeProjectsCount > @numprojects)
    BEGIN
      RAISERROR('The employee has too many projects!', 16, 1);
      ROLLBACK;
	  RETURN;
    END
  ELSE	
		BEGIN
			COMMIT
		END
END
GO

SELECT *
FROM EmployeesProjects
GO
SELECT COUNT(*)
FROM EmployeesProjects
WHERE EmployeeID=2
		AND ProjectID=1
GO
-- 1
EXEC usp_AssignProject_v2 @employeeID=2,@ProjectID=1; 
GO
-- Este empleado ya tiene asignado este proyecto

EXEC usp_AssignProject_v2 @employeeID=4,@ProjectID=1; 
GO
SELECT *
FROM EmployeesProjects
WHERE employeeID=4
GO


-- Comprobar si existe Empleado o Proyecto

DROP PROCEDURE IF EXISTS usp_AssignProject_v3
GO
CREATE OR ALTER PROCEDURE usp_AssignProject_v3 
	(@numprojects int = 3,@employeeID int, @projectID int)
AS
BEGIN
	-- Existencia de Empleado
	IF NOT EXISTS(
		SELECT *
		FROM Employees
		WHERE EmployeeID = @employeeID
	)
		BEGIN
			PRINT 'EMPLEADO NO EXISTE'
			RETURN
		END
	--
	-- Existencia de Proyecto
	IF NOT EXISTS(
		SELECT *
		FROM Projects
		WHERE ProjectID = @projectID
	)
		BEGIN
			PRINT 'Proyecto NO EXISTE'
			RETURN
		END
	--
	DECLARE  @cuenta int = 0;
	-- PRINT cast(@employeeID as char(1))
	-- PRINT cast(@projectID as Char(1))
	SET @cuenta =
			(SELECT COUNT(*)
			FROM EmployeesProjects
			WHERE EmployeeID = @employeeID
						AND ProjectID = @projectID);
	-- PRINT cast(@cuenta as char)
	IF @cuenta > 0
		BEGIN	
			PRINT 'Este empleado ya tiene asignado este proyecto'
			RETURN
		END
  -- DECLARE @maxEmployeeProjectsCount int ;
  DECLARE @employeeProjectsCount int = 0;
  IF @numprojects>5
	BEGIN
		PRINT 'Num. de Proyectos no permitidos. Regla de empresa General'
		RETURN
	END 
  
  BEGIN TRAN
  INSERT INTO EmployeesProjects (EmployeeID, ProjectID) 
  VALUES (@employeeID, @projectID)

  SET @employeeProjectsCount = (
    SELECT COUNT(*)
    FROM EmployeesProjects
    WHERE EmployeeID = @employeeID
  )
  IF(@employeeProjectsCount > @numprojects)
    BEGIN
      RAISERROR('The employee has too many projects!', 16, 1);
      ROLLBACK;
	  RETURN;
    END
  ELSE	
		BEGIN
			COMMIT
		END
END
GO
SELECT * FROM Employees order by EmployeeID
GO
SELECT * FROM Projects order by ProjectID
GO
-- Empleado 6 no existe
EXEC usp_AssignProject_v3 @employeeID=6,@ProjectID=1; 
GO
-- Proyecto NO EXISTE

-- Proyecto	6 no existe
EXEC usp_AssignProject_v3 @employeeID=4,@ProjectID=6; 
GO
-- EMPLEADO NO EXISTE


SELECT *
FROM EmployeesProjects
GO
-----

