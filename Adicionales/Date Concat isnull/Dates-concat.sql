-- https://www.mssqltips.com/sqlservertip/1145/date-and-time-conversions-using-sql-server/

-- Date and Time Conversions Using SQL Server

--
select convert(varchar, getdate(), 1)
GO

-- 04/19/18

select convert(varchar, getdate(), 2)
Go

-- 18.04.19

select convert(varchar, getdate(), 106)
GO

-- 19 Apr 2018

select convert(varchar, getdate(), 110)
GO

-- 04-19-2018

select convert(varchar, getdate(), 111)
GO

-- 2018/04/19

-- TIME ONLY FORMATS

select convert(varchar, getdate(), 8)
GO

-- 19:50:57

select convert(varchar, getdate(), 114)
GO

-- 19:51:53:510


-- DATE & TIME FORMATS

select convert(varchar, getdate(), 0)
GO

-- Apr 19 2018  7:52PM

select convert(varchar, getdate(), 13)	
GO

-- 19 Apr 2018 19:53:03:247

SELECT GETDATE()

DECLARE @counter INT = 0
DECLARE @date DATETIME = '2018-04-19 17:52:22.407'

CREATE TABLE #dateFormats (dateFormatOption int, dateOutput varchar(40))

WHILE (@counter <= 150 )
BEGIN
   BEGIN TRY
      INSERT INTO #dateFormats
      SELECT CONVERT(varchar, @counter), CONVERT(varchar,@date, @counter) 
      SET @counter = @counter + 1
   END TRY
   BEGIN CATCH;
      SET @counter = @counter + 1
      IF @counter >= 150
      BEGIN
         BREAK
      END
   END CATCH
END

SELECT * FROM #dateFormats

-- https://www.mssqltips.com/sqlservertip/2985/concatenate-sql-server-columns-into-a-string-with-concat/

-- Concatenate SQL Server Columns into a String with CONCAT()
USE AdventureWorks2014
GO
SELECT 
    Title, 
    FirstName, 
    MiddleName, 
    LastName,
    Title+ ' ' + FirstName + ' ' + MiddleName + ' ' + LastName as MailingName
FROM Person.Person
GO
SELECT 
    Title, 
    FirstName, 
    MiddleName, 
    LastName,
    ISNULL(Title,'') + ' ' + ISNULL(FirstName,'') + ' ' 
  + ISNULL(MiddleName,'') + ' ' + ISNULL(LastName,'') as MailingName
FROM Person.Person
GO
SELECT 
    Title, 
    FirstName, 
    MiddleName, 
    LastName,
    CONCAT(Title,' ',FirstName,' ',MiddleName,' ',LastName) as MailingName
FROM Person.Person
GO
