USE OdontolabDB;
GO

-- =========================================
-- CREAR REGISTRO DE ODONTOGRAMA
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearOdontograma
    @id_expediente INT,
    @id_usuario INT,
    @numero_diente TINYINT,
    @cara_diente VARCHAR(20),
    @estado_condicion VARCHAR(30),
    @observaciones VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Odontogramas (
        id_expediente,
        id_usuario,
        numero_diente,
        cara_diente,
        estado_condicion,
        observaciones
    )
    VALUES (
        @id_expediente,
        @id_usuario,
        @numero_diente,
        @cara_diente,
        @estado_condicion,
        @observaciones
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_odontograma;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR ODONTOGRAMAS
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarOdontogramas
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        o.id_odontograma,
        o.id_expediente,
        p.nombre_paciente,
        p.apellidos,
        o.id_usuario,
        o.numero_diente,
        o.cara_diente,
        o.estado_condicion,
        o.observaciones,
        o.fecha_actualizacion
    FROM dbo.Odontogramas AS o
    INNER JOIN dbo.Expedientes AS e
        ON e.id_expediente = o.id_expediente
    INNER JOIN dbo.Pacientes AS p
        ON p.id_paciente = e.id_paciente
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR p.nombre_paciente LIKE '%' + @buscar + '%'
        OR p.apellidos LIKE '%' + @buscar + '%'
        OR o.estado_condicion LIKE '%' + @buscar + '%'
        OR o.cara_diente LIKE '%' + @buscar + '%'
        OR CONVERT(VARCHAR(3), o.numero_diente)
            LIKE '%' + @buscar + '%'
    ORDER BY
        p.apellidos,
        p.nombre_paciente,
        o.numero_diente,
        o.cara_diente
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR REGISTRO DE ODONTOGRAMA
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarOdontograma
    @id_odontograma INT,
    @id_expediente INT,
    @id_usuario INT,
    @numero_diente TINYINT,
    @cara_diente VARCHAR(20),
    @estado_condicion VARCHAR(30),
    @observaciones VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Odontogramas
    SET
        id_expediente = @id_expediente,
        id_usuario = @id_usuario,
        numero_diente = @numero_diente,
        cara_diente = @cara_diente,
        estado_condicion = @estado_condicion,
        observaciones = @observaciones,
        fecha_actualizacion = GETDATE()
    WHERE id_odontograma = @id_odontograma;

    IF @@ROWCOUNT = 0
        THROW 50017, 'No existe el registro de odontograma indicado.', 1;
END;
GO

-- =========================================
-- ELIMINAR REGISTRO DE ODONTOGRAMA
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarOdontograma
    @id_odontograma INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Odontogramas
    WHERE id_odontograma = @id_odontograma;

    IF @@ROWCOUNT = 0
        THROW 50018, 'No existe el registro de odontograma indicado.', 1;
END;
GO