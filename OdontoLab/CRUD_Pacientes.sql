USE OdontolabDB;
GO

-- =========================================
-- CREAR PACIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearPaciente
    @nombre_paciente VARCHAR(100),
    @apellidos VARCHAR(100),
    @fecha_nacimiento DATE,
    @genero CHAR(1),
    @correo VARCHAR(150) = NULL,
    @telefono VARCHAR(20),
    @direccion VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Pacientes (
        nombre_paciente,
        apellidos,
        fecha_nacimiento,
        genero,
        correo,
        telefono,
        direccion
    )
    VALUES (
        @nombre_paciente,
        @apellidos,
        @fecha_nacimiento,
        @genero,
        @correo,
        @telefono,
        @direccion
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_paciente;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR PACIENTES
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarPacientes
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        id_paciente,
        nombre_paciente,
        apellidos,
        fecha_nacimiento,
        genero,
        correo,
        telefono,
        direccion,
        fecha_registro
    FROM dbo.Pacientes
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR nombre_paciente LIKE '%' + @buscar + '%'
        OR apellidos LIKE '%' + @buscar + '%'
        OR telefono LIKE '%' + @buscar + '%'
        OR correo LIKE '%' + @buscar + '%'
    ORDER BY apellidos, nombre_paciente
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR PACIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarPaciente
    @id_paciente INT,
    @nombre_paciente VARCHAR(100),
    @apellidos VARCHAR(100),
    @fecha_nacimiento DATE,
    @genero CHAR(1),
    @correo VARCHAR(150) = NULL,
    @telefono VARCHAR(20),
    @direccion VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Pacientes
    SET
        nombre_paciente = @nombre_paciente,
        apellidos = @apellidos,
        fecha_nacimiento = @fecha_nacimiento,
        genero = @genero,
        correo = @correo,
        telefono = @telefono,
        direccion = @direccion
    WHERE id_paciente = @id_paciente;

    IF @@ROWCOUNT = 0
        THROW 50004, 'No existe el paciente indicado.', 1;
END;
GO

-- =========================================
-- ELIMINAR PACIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarPaciente
    @id_paciente INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.Expedientes
        WHERE id_paciente = @id_paciente
    )
    OR EXISTS (
        SELECT 1
        FROM dbo.Citas
        WHERE id_paciente = @id_paciente
    )
    BEGIN
        THROW 50005,
            'No se puede eliminar el paciente porque tiene expedientes o citas relacionadas.',
            1;
    END;

    DELETE FROM dbo.Pacientes
    WHERE id_paciente = @id_paciente;

    IF @@ROWCOUNT = 0
        THROW 50006, 'No existe el paciente indicado.', 1;
END;
GO