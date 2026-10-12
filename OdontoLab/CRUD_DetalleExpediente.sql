USE OdontolabDB;
GO

-- =========================================
-- CREAR DETALLE DE EXPEDIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearDetalleExpediente
    @id_expediente INT,
    @id_usuario INT,
    @id_cita INT = NULL,
    @fecha_consulta DATETIME = NULL,
    @motivo_consulta VARCHAR(255) = NULL,
    @diagnostico VARCHAR(500) = NULL,
    @id_procedimiento INT = NULL,
    @tratamiento_notas VARCHAR(MAX) = NULL,
    @indicaciones VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.DetalleExpediente (
        id_expediente,
        id_usuario,
        id_cita,
        fecha_consulta,
        motivo_consulta,
        diagnostico,
        id_procedimiento,
        tratamiento_notas,
        indicaciones
    )
    VALUES (
        @id_expediente,
        @id_usuario,
        @id_cita,
        COALESCE(@fecha_consulta, GETDATE()),
        @motivo_consulta,
        @diagnostico,
        @id_procedimiento,
        @tratamiento_notas,
        @indicaciones
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_detalle;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR DETALLES CLINICOS
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarDetallesExpediente
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        d.id_detalle,
        d.id_expediente,
        p.nombre_paciente,
        p.apellidos,
        d.id_usuario,
        u.nombre_usuario,
        d.id_cita,
        d.fecha_consulta,
        d.motivo_consulta,
        d.diagnostico,
        d.id_procedimiento,
        pc.nombre_procedimiento,
        d.tratamiento_notas,
        d.indicaciones
    FROM dbo.DetalleExpediente AS d
    INNER JOIN dbo.Expedientes AS e
        ON e.id_expediente = d.id_expediente
    INNER JOIN dbo.Pacientes AS p
        ON p.id_paciente = e.id_paciente
    INNER JOIN dbo.Usuarios AS u
        ON u.id_usuario = d.id_usuario
    LEFT JOIN dbo.ProcedimientosClinicos AS pc
        ON pc.id_procedimiento = d.id_procedimiento
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR p.nombre_paciente LIKE '%' + @buscar + '%'
        OR p.apellidos LIKE '%' + @buscar + '%'
        OR d.diagnostico LIKE '%' + @buscar + '%'
        OR pc.nombre_procedimiento LIKE '%' + @buscar + '%'
    ORDER BY d.fecha_consulta DESC
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR DETALLE DE EXPEDIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarDetalleExpediente
    @id_detalle INT,
    @id_expediente INT,
    @id_usuario INT,
    @id_cita INT = NULL,
    @fecha_consulta DATETIME,
    @motivo_consulta VARCHAR(255) = NULL,
    @diagnostico VARCHAR(500) = NULL,
    @id_procedimiento INT = NULL,
    @tratamiento_notas VARCHAR(MAX) = NULL,
    @indicaciones VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.DetalleExpediente
    SET
        id_expediente = @id_expediente,
        id_usuario = @id_usuario,
        id_cita = @id_cita,
        fecha_consulta = @fecha_consulta,
        motivo_consulta = @motivo_consulta,
        diagnostico = @diagnostico,
        id_procedimiento = @id_procedimiento,
        tratamiento_notas = @tratamiento_notas,
        indicaciones = @indicaciones
    WHERE id_detalle = @id_detalle;

    IF @@ROWCOUNT = 0
        THROW 50015, 'No existe el detalle clinico indicado.', 1;
END;
GO

-- =========================================
-- ELIMINAR DETALLE DE EXPEDIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarDetalleExpediente
    @id_detalle INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.DetalleExpediente
    WHERE id_detalle = @id_detalle;

    IF @@ROWCOUNT = 0
        THROW 50016, 'No existe el detalle clinico indicado.', 1;
END;
GO