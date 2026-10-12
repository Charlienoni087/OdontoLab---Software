USE OdontolabDB;
GO

-- =========================================
-- CREAR CITA
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearCita
    @id_paciente INT,
    @id_usuario INT,
    @fecha_hora_inicio DATETIME,
    @fecha_hora_fin DATETIME,
    @motivo VARCHAR(255) = NULL,
    @estado VARCHAR(20) = 'Programada',
    @notas VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Citas (
        id_paciente,
        id_usuario,
        fecha_hora_inicio,
        fecha_hora_fin,
        motivo,
        estado,
        notas
    )
    VALUES (
        @id_paciente,
        @id_usuario,
        @fecha_hora_inicio,
        @fecha_hora_fin,
        @motivo,
        @estado,
        @notas
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_cita;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR CITAS
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarCitas
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        c.id_cita,
        c.id_paciente,
        p.nombre_paciente,
        p.apellidos,
        c.id_usuario,
        u.nombre_usuario,
        c.fecha_hora_inicio,
        c.fecha_hora_fin,
        c.motivo,
        c.estado,
        c.notas
    FROM dbo.Citas AS c
    INNER JOIN dbo.Pacientes AS p
        ON p.id_paciente = c.id_paciente
    INNER JOIN dbo.Usuarios AS u
        ON u.id_usuario = c.id_usuario
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR p.nombre_paciente LIKE '%' + @buscar + '%'
        OR p.apellidos LIKE '%' + @buscar + '%'
        OR u.nombre_usuario LIKE '%' + @buscar + '%'
        OR c.estado LIKE '%' + @buscar + '%'
        OR c.motivo LIKE '%' + @buscar + '%'
    ORDER BY c.fecha_hora_inicio DESC
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR CITA
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarCita
    @id_cita INT,
    @id_paciente INT,
    @id_usuario INT,
    @fecha_hora_inicio DATETIME,
    @fecha_hora_fin DATETIME,
    @motivo VARCHAR(255) = NULL,
    @estado VARCHAR(20),
    @notas VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Citas
    SET
        id_paciente = @id_paciente,
        id_usuario = @id_usuario,
        fecha_hora_inicio = @fecha_hora_inicio,
        fecha_hora_fin = @fecha_hora_fin,
        motivo = @motivo,
        estado = @estado,
        notas = @notas
    WHERE id_cita = @id_cita;

    IF @@ROWCOUNT = 0
        THROW 50012, 'No existe la cita indicada.', 1;
END;
GO

-- =========================================
-- ELIMINAR CITA
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarCita
    @id_cita INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.DetalleExpediente
        WHERE id_cita = @id_cita
    )
    BEGIN
        THROW 50013,
            'La cita esta relacionada con un detalle clinico y no puede eliminarse.',
            1;
    END;

    DELETE FROM dbo.Citas
    WHERE id_cita = @id_cita;

    IF @@ROWCOUNT = 0
        THROW 50014, 'No existe la cita indicada.', 1;
END;
GO