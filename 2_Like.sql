----    LIKE -------
--  PATRON LIKE = PARA QUE SAQUE TODOS LOS NOMBRE QUE TENGAN RELACION CON (A CORUÑA, LA CORUÑA, CORUÑA)
--  CARACTERES COMODIN  WILDCARDS 
--   % PERCENT SIGN ( 1 OR N CARACTERES)
--  _ UNDERSCORE  (1)
--  []  SQUARE BRACKETS  (CARACTERES (AC SOLO) O RANGE DE CARACTERES(A-D  = ABCD))
--  ^ CARET CIRCUNFLEJO 


USE Pubs
GO
-- INFORMACION DE LOS REGISTROS QUE LLEVE LA PALABRA COMPUTER
-- Case-Insensitive
SELECT title_id, title
FROM titles
-- WHERE title like '%computer%'
WHERE title like 'computer%'
GO

/* PS1372	Computer Phobic AND Non-Phobic Individuals: Behavior Variations
BU1111	Cooking with Computers: Surreptitious Balance Sheets
BU7832	Straight Talk About Computers
MC3026	The Psychology of Computer Cooking
BU2075	You Can Combat Computer Stress!
*/

-- Siendo la palabra más pequeña hace la busqueda igual

SELECT title_id, title
FROM titles
WHERE title like '%compu%'
GO


-- No hace diferencia entre mayusculas y minusculas CASE_INSENSITIVE

SELECT title_id, title
FROM titles
WHERE title like '%compuTER%'
GO


-- Devolver los telefonos que empiecen por 415

SELECT [phone]
FROM [dbo].[authors]
WHERE [phone] like '415%'
GO

-- Todos los telefonos que no empiecen por 415
SELECT [phone]
FROM [dbo].[authors]
WHERE [phone] not like '415%'
GO


-- 
SELECT [au_id],[au_lname],[au_fname]
FROM [dbo].[authors]
WHERE [au_lname] like '[BM]%' -- En la primera posicion una (B) o UNA (M)
GO

 SELECT [au_id],[au_lname],[au_fname]
FROM [dbo].[authors]
-- WHERE [au_fname] like '[CS]%'
WHERE [au_fname] like '[CS]heryl' -- En la primera posicion una (C) o UNA (S) y despues (heryl)
GO


SELECT [au_id],[au_lname],[au_fname]
FROM [dbo].[authors]
WHERE [au_lname] like '[Ck]ars[ei]n'-- En la primera posicion una (d) o una (k) 
GO 


SELECT [au_id],[au_lname],[au_fname]
FROM [dbo].[authors]
WHERE [au_lname] like '[a-d]%'-- En la primera posicion a b c d 
GO 

SELECT [au_id],[au_lname],[au_fname]
FROM [dbo].[authors]
WHERE [au_lname] like '[^a-d]%'-- En la primera posicion distinta de a b c d   
GO 
-- 17
SELECT [au_id],[au_lname],[au_fname]
FROM [dbo].[authors]
WHERE [au_lname] not like '[a-d]%'-- En la primera posicion distinta de a b c d 
GO 
-- 17