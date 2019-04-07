CREATE TRIGGER trg_SoloBorraUno
ON Empleados
FOR DELETE
AS
	IF (@@ROWCOUNT>1)
		BEGIN
			RAISERROR('No puedes borrar más de un registro',15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación Correcta'
GO

DELETE Empleados
GO
--Msg 50000, Level 15, State 1, Procedure trg_SoloBorraUno, Line 7 [Batch Start Line 267]
--No puedes borrar más de un registro
--Msg 3609, Level 16, State 1, Line 268
--The transaction ended in the trigger. The batch has been aborted.

DELETE Empleados
WHERE EmployeeID=1
GO
--Operación Correcta

--(1 row affected)

IF Sino existiera el registro que se pretende borrar??
----------------------

- Example Trigger AdventureWorks
ALTER TRIGGER [HumanResources].[dEmployee] 
ON [HumanResources].[Employee] 
INSTEAD OF DELETE 
 AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN
        RAISERROR
            (N'Employees cannot be deleted. They can only be marked as not current.', -- Message
            10, -- Severity.
            1); -- State.

        -- Rollback any active or uncommittable transactions
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END;
END;


