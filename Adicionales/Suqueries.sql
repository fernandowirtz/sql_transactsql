
-- Using a Subquery in a WHERE Clause
--The following query implicitly joins the authors table (pubs database) with
--itself to find all authors living in the same city as the author with the last name
--“Green”.

-- SELF-JOIN
USE Pubs
GO
SELECT a1.au_lname, a1.au_fname, a1.city, a1.[state]
FROM dbo.authors AS a1, dbo.authors AS a2
WHERE a1.city = a2.city
			AND a2.au_lname = 'Green'
GO

ALTER PROC Misma_Ciudad
	  @apellido varchar(50) ='Green'
AS
	BEGIN
		SELECT a1.au_lname, a1.au_fname, a1.city, a1.[state]
		FROM dbo.authors AS a1, dbo.authors AS a2
		WHERE a1.city = a2.city
			AND a2.au_lname = @apellido
	END
GO
-- SELECT * FROM Authors
Misma_Ciudad 
EXEC Misma_Ciudad 
EXECUTE Misma_Ciudad 'Green'
EXECUTE Misma_Ciudad 'Carson'  -- White

-- Using Subqueries

SELECT au_lname, au_fname, city, [state]
FROM dbo.authors
WHERE city =
(SELECT city
FROM dbo.authors
WHERE au_lname = 'Green');
GO

CREATE PROC Misma_Ciudad_Sub
	  @apellido varchar(50) ='Green'
AS
	BEGIN
		SELECT au_lname, au_fname, city, [state]
		FROM dbo.authors
		WHERE city =
							(SELECT city
							FROM dbo.authors
							WHERE au_lname =  @apellido)
	END
GO