USE OdontolabDB;
GO

-- =========================================
-- CREAR PROCEDIMIENTO CLINICO
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearProcedimientoClinico
    @nombre_procedimiento VARCHAR(100),
    @descripcion VARCHAR(255) = NULL,
    @precio_base DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ProcedimientosClinicos (
        nombre_procedimiento,
        descripcion,
        precio_base
    )
    VALUES (
        @nombre_procedimiento,
        @descripcion,
        @precio_base
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_procedimiento;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR PROCEDIMIENTOS CLINICOS
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarProcedimientosClinicos
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        id_procedimiento,
        nombre_procedimiento,
        descripcion,
        precio_base
    FROM dbo.ProcedimientosClinicos
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR nombre_procedimiento LIKE '%' + @buscar + '%'
        OR descripcion LIKE '%' + @buscar + '%'
    ORDER BY nombre_procedimiento
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR PROCEDIMIENTO CLINICO
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarProcedimientoClinico
    @id_procedimiento INT,
    @nombre_procedimiento VARCHAR(100),
    @descripcion VARCHAR(255) = NULL,
    @precio_base DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ProcedimientosClinicos
    SET
        nombre_procedimiento = @nombre_procedimiento,
        descripcion = @descripcion,
        precio_base = @precio_base
    WHERE id_procedimiento = @id_procedimiento;

    IF @@ROWCOUNT = 0
        THROW 50009, 'No existe el procedimiento clinico indicado.', 1;
END;
GO

-- =========================================
-- ELIMINAR PROCEDIMIENTO CLINICO
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarProcedimientoClinico
    @id_procedimiento INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.DetalleExpediente
        WHERE id_procedimiento = @id_procedimiento
    )
    BEGIN
        THROW 50010,
            'El procedimiento clinico esta asociado a un expediente.',
            1;
    END;

    DELETE FROM dbo.ProcedimientosClinicos
    WHERE id_procedimiento = @id_procedimiento;

    IF @@ROWCOUNT = 0
        THROW 50011, 'No existe el procedimiento clinico indicado.', 1;
END;
GO