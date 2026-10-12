USE OdontoLabDB;
GO

CREATE OR ALTER PROC dbo.sp_CrearAdministradorInicial
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @usuarioApp VARCHAR(100) = 'SISTEMA';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Crear el administrador inicial solamente si no existe.
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuarios
            WHERE nombre_usuario = 'admin'
        )
        BEGIN
            INSERT INTO dbo.Usuarios
            (
                nombre_usuario,
                correo,
                contrasena,
                rol,
                estado
            )
            VALUES
            (
                'admin',
                'admin@gmail.com',
                CONVERT(
                    VARCHAR(255),
                    HASHBYTES('SHA2_256', N'Admin123+'),
                    2
                ),
                'Administrador',
                1
            );
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO