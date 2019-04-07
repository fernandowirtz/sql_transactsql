CREATE TRIGGER trg_SoloBorraUno
ON Empleados
FOR DELETE
AS
	IF (@@ROWCOUNT>1)
		BEGIN
			RAISERROR('No puedes borrar m�s de un registro',15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operaci�n Correcta'
GO

DELETE Empleados
GO
--Msg 50000, Level 15, State 1, Procedure trg_SoloBorraUno, Line 7 [Batch Start Line 267]
--No puedes borrar m�s de un registro
--Msg 3609, Level 16, State 1, Line 268
--The transaction ended in the trigger. The batch has been aborted.

DELETE Empleados
WHERE EmployeeID=1
GO
--Operaci�n Correcta

--(1 row affected)
