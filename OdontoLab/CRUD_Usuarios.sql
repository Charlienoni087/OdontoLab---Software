USE OdontolabDB;
GO

-- =========================================
-- CREAR USUARIO
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearUsuario
    @nombre_usuario VARCHAR(100),
    @correo VARCHAR(150),
    @contrasena VARCHAR(255),
    @rol VARCHAR(20),
    @estado VARCHAR(15) = 'Activo'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Usuarios (
        nombre_usuario,
        correo,
        contrasena,
        rol,
        estado
    )
    VALUES (
        @nombre_usuario,
        @correo,
        @contrasena,
        @rol,
        @estado
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_usuario;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR USUARIOS
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarUsuarios
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        id_usuario,
        nombre_usuario,
        correo,
        rol,
        estado,
        fecha_creacion
    FROM dbo.Usuarios
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR nombre_usuario LIKE '%' + @buscar + '%'
        OR correo LIKE '%' + @buscar + '%'
        OR rol LIKE '%' + @buscar + '%'
    ORDER BY nombre_usuario
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR USUARIO
-- La contraseña solo cambia si se proporciona.
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarUsuario
    @id_usuario INT,
    @nombre_usuario VARCHAR(100),
    @correo VARCHAR(150),
    @rol VARCHAR(20),
    @estado VARCHAR(15),
    @contrasena VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Usuarios
    SET
        nombre_usuario = @nombre_usuario,
        correo = @correo,
        rol = @rol,
        estado = @estado,
        contrasena = COALESCE(
            NULLIF(@contrasena, ''),
            contrasena
        )
    WHERE id_usuario = @id_usuario;

    IF @@ROWCOUNT = 0
        THROW 50001, 'No existe el usuario indicado.', 1;
END;
GO

-- =========================================
-- ELIMINAR USUARIO
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarUsuario
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.Citas
        WHERE id_usuario = @id_usuario
    )
    OR EXISTS (
        SELECT 1
        FROM dbo.DetalleExpediente
        WHERE id_usuario = @id_usuario
    )
    OR EXISTS (
        SELECT 1
        FROM dbo.Odontogramas
        WHERE id_usuario = @id_usuario
    )
    BEGIN
        THROW 50002,
            'El usuario tiene registros relacionados. Puede desactivarlo.',
            1;
    END;

    DELETE FROM dbo.Usuarios
    WHERE id_usuario = @id_usuario;

    IF @@ROWCOUNT = 0
        THROW 50003, 'No existe el usuario indicado.', 1;
END;
GO