USE AdventureWorksLT
GO
DROP TABLE IF EXISTS SalesLT.CallLog
GO
-- Create a table for the demo
CREATE TABLE SalesLT.CallLog
(
	CallID int IDENTITY PRIMARY KEY NOT NULL,
	CallTime datetime NOT NULL DEFAULT GETDATE(),
	SalesPerson nvarchar(256) NOT NULL,
	CustomerID int NOT NULL REFERENCES SalesLT.Customer(CustomerID),
	PhoneNumber nvarchar(25) NOT NULL,
	Notes nvarchar(max) NULL
);
GO

-- Insert a row
INSERT INTO SalesLT.CallLog
VALUES
('2015-01-01T12:30:00', 'adventure-works\pamela0', 1, '245-555-0173', 'Returning call re: enquiry about delivery');
GO
SELECT * FROM SalesLT.CallLog;
GO
-- Insert defaults and nulls
INSERT INTO SalesLT.CallLog
VALUES
(DEFAULT, 'adventure-works\david8', 2, '170-555-0127', NULL);

SELECT * FROM SalesLT.CallLog;

-- Insert a row with explicit columns
INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\jillian0', 3, '279-555-0130');

SELECT * FROM SalesLT.CallLog;

-- Insert multiple rows
INSERT INTO SalesLT.CallLog
VALUES
(DATEADD(mi,-2, GETDATE()), 'adventure-works\jillian0', 4, '710-555-0173', NULL),
(DEFAULT, 'adventure-works\shu0', 5, '828-555-0186', 'Called to arrange deliver of order 10987');

SELECT * FROM SalesLT.CallLog;

-- Insert the results of a query
INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber, Notes)
SELECT SalesPerson, CustomerID, Phone, 'Sales promotion call'
FROM SalesLT.Customer
WHERE CompanyName = 'Big-Time Bike Store';

SELECT * FROM SalesLT.CallLog;

-- Retrieving inserted identity
INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\josé1', 10, '150-555-0127');

SELECT SCOPE_IDENTITY();

SELECT * FROM SalesLT.CallLog;

--Overriding Identity
SET IDENTITY_INSERT SalesLT.CallLog ON;

INSERT INTO SalesLT.CallLog (CallID, SalesPerson, CustomerID, PhoneNumber)
VALUES
(9, 'adventure-works\josé1', 11, '926-555-0159');

SET IDENTITY_INSERT SalesLT.CallLog OFF;

SELECT * FROM SalesLT.CallLog;
GO
INSERT INTO SalesLT.CallLog (CallID, SalesPerson, CustomerID, PhoneNumber)
VALUES
(10, 'adventure-works\ana', 12, '927-555-0159');
GO

-- Msg 544, Level 16, State 1, Line 74
-- Cannot insert explicit value for identity column in table 'CallLog' when IDENTITY_INSERT is set to OFF.


--Overriding Identity
SET IDENTITY_INSERT SalesLT.CallLog ON;
Go
INSERT INTO SalesLT.CallLog (CallID, SalesPerson, CustomerID, PhoneNumber)
VALUES
(10, 'adventure-works\ana', 12, '927-555-0159');
GO

-- (1 row affected)


SELECT * FROM SalesLT.CallLog;
GO

SELECT SCOPE_IDENTITY();
GO

-- 10

INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\juan', 13, '927-556-0159');
GO

--Msg 545, Level 16, State 1, Line 102
--Explicit value must be specified for identity column in table 'CallLog' either when IDENTITY_INSERT is set to ON or when a replication user is inserting into a NOT FOR REPLICATION identity column.

--Overriding Identity
SET IDENTITY_INSERT SalesLT.CallLog OFF;
Go

INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\juan', 13, '927-556-0159');
GO


--Msg 547, Level 16, State 0, Line 114
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK__CallLog__Custome__0A9D95DB". The conflict occurred in database "AdventureWorksLT", table "SalesLT.Customer", column 'CustomerID'.
--The statement has been terminated.

SELECT * FROM SalesLT.Customer
GO
-- No tiene 13 14 15

INSERT INTO SalesLT.CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\juan', 16, '927-556-0159');
GO

-- (1 row affected)


SELECT * FROM SalesLT.CallLog;
GO

SELECT c.CallID,c.SalesPerson,c.CustomerID,c.PhoneNumber,cu.CustomerID,cu.CompanyName
FROM SalesLT.CallLog c JOIN SalesLT.Customer cu
ON c.CustomerID = cu.CustomerID
GO