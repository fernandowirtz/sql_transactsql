-- Stored Procedure

-- 	Change Password


-- Realizar un SP para cambiar contraseña de un usuario
-- Controlar que el email que se introduce existe para un usuario determinado.

-- v3 Comprobar que la contraseña no es la misma

-- Estructura de la Tabla
-- Usuario(Id,Email,Password)


USE TempDB
GO
DROP TABLE IF EXISTS Usuario
GO
CREATE TABLE Usuario
( Id Int IDENTITY PRIMARY KEY,
  Email VARCHAR(MAX),
  Password VARCHAR(MAX)
)
GO
INSERT Usuario
VALUES 	('a@yahoo.es','abcd1234.'),
	('b@yahoo.es','abcd1234.'),
	('c@yahoo.es','abcd1234.'),
	('d@yahoo.es','abcd1234.'),
	('e@yahoo.es','abcd1234.')
GO
SELECT * FROM Usuario
GO
--v1
CREATE PROCEDURE ChangePassword_v1
(
                 @email       VARCHAR(MAX),
                 @newPassword VARCHAR(MAX) 
)
AS
     BEGIN
         DECLARE @credentialId INT=
         (
             SELECT Id
             FROM Usuario
             WHERE Email = @email
         );
		 
		 -- Check if Email exists
         IF(@credentialId IS NULL)
             BEGIN
                 RAISERROR('The email does''t exist!', 16, 1)
		 RETURN
             END;
		 
		 -- Assign the new password
         UPDATE Usuario
           SET Password = @newPassword
           WHERE Id = @credentialId;
     END;
GO

-- Usuario Existe

EXEC ChangePassword_v1 'a@yahoo.es','B'
GO
SELECT * FROM Usuario
GO

-- 1	a@yahoo.es	B


-- Usuario no existe

EXEC ChangePassword_v1 'z@yahoo.es','A'
GO

--Msg 50000, Level 16, State 1, Procedure ChangePassword_v1, Line 18 [Batch Start Line 73]
--The email does't exist!

SELECT * FROM Usuario
GO

--v2
CREATE PROCEDURE ChangePassword_v2
(
                 @email       VARCHAR(MAX),
                 @newPassword VARCHAR(MAX) 
)
AS
     BEGIN
         DECLARE @credentialId INT;
         SELECT @credentialId=Id
         FROM Usuario
         WHERE Email = @email;
         PRINT @credentialId		 
		 -- Check if Email exists
         IF(@credentialId IS NULL)
             BEGIN
                 RAISERROR('The email does''t exist!', 16, 1)
					RETURN
             END;
		 
		 -- Assign the new password
         UPDATE Usuario
           SET Password = @newPassword
           WHERE Id = @credentialId;
     END;
GO

-- Usuario Existe

EXEC ChangePassword_v2 'a@yahoo.es','B'
GO
SELECT * FROM Usuario
GO

-- Usuario no existe

EXEC ChangePassword_v2 'z@yahoo.es','A'
GO

--Msg 50000, Level 16, State 1, Procedure ChangePassword_v2, Line 16 [Batch Start Line 118]
--The email does't exist!

-- v3

-- Comprobar que la contraseña no es la misma

DROP PROCEDURE IF EXISTS ChangePassword_v3
GO
CREATE PROCEDURE ChangePassword_v3
(
                 @email       VARCHAR(MAX),
                 @newPassword VARCHAR(MAX) 
)
AS
     BEGIN
         DECLARE @credentialId INT;
         SELECT @credentialId=Id
         FROM Usuario
         WHERE Email = @email;
         PRINT @credentialId		 
		 -- Check if Email exists
         IF(@credentialId IS NULL)
             BEGIN
                 RAISERROR('The email does''t exist!', 16, 1)
				 RETURN
             END;
		-- Assign the new password
		IF EXISTS(SELECT password
						FROM Usuario
						WHERE password = @newPassword)
				BEGIN 
					PRINT('Contraseña ya existe')
					ROLLBACK
					RETURN
				END
         ELSE
				BEGIN
					UPDATE Usuario
                    SET Password = @newPassword
                    WHERE Id = @credentialId
				END
	END;
GO

-- Usuario Existe

EXEC ChangePassword_v3 'a@yahoo.es','B'
GO
SELECT * FROM Usuario
GO

-- Usuario no existe

EXEC ChangePassword_v3 'z@yahoo.es','A'
GO

--Msg 50000, Level 16, State 1, Procedure ChangePassword_v2, Line 16 [Batch Start Line 118]
--The email does't exist!

-- Intentando cambiar Password repetida mensaje de error

EXEC ChangePassword_v3 'b@yahoo.es','abcd1234.'
GO

--2
--Contraseña ya existe
--Msg 3903, Level 16, State 1, Procedure ChangePassword_v3, Line 25 [Batch Start Line 181]
--The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.

EXEC ChangePassword_v3 'b@yahoo.es','norepetida'
GO

--2
--(1 row affected)

SELECT * FROM Usuario
GO

--Id	Email	   Password
--1	a@yahoo.es	B
--2	b@yahoo.es	norepetida
--3	c@yahoo.es	abcd1234.
--4	d@yahoo.es	abcd1234.
--5	e@yahoo.es	abcd1234.
