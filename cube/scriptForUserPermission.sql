-- Create User if not exists
USE [master];

CREATE LOGIN [NT SERVICE\MSSQLServerOLAPService] FROM WINDOWS;

-- Add login permission
GO
USE LUCIDEX;
GO
CREATE USER [NT SERVICE\MSSQLServerOLAPService] FOR LOGIN [NT SERVICE\MSSQLServerOLAPService];
EXEC sp_addrolemember 'db_datareader', 'NT SERVICE\MSSQLServerOLAPService';