USE OdontolabDB;
GO

-- =========================================
-- CREAR EXPEDIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_CrearExpediente
    @id_paciente INT,
    @antecedentes_medicos VARCHAR(MAX) = NULL,
    @alergias VARCHAR(MAX) = NULL,
    @medicamentos_actuales VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Expedientes (
        id_paciente,
        antecedentes_medicos,
        alergias,
        medicamentos_actuales
    )
    VALUES (
        @id_paciente,
        @antecedentes_medicos,
        @alergias,
        @medicamentos_actuales
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_expediente;
END;
GO

-- =========================================
-- MOSTRAR / BUSCAR EXPEDIENTES
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_MostrarExpedientes
    @buscar NVARCHAR(100) = NULL,
    @pagina INT = 1,
    @tamPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina < 1 SET @pagina = 1;
    IF @tamPagina < 1 SET @tamPagina = 10;

    SELECT
        e.id_expediente,
        e.id_paciente,
        p.nombre_paciente,
        p.apellidos,
        e.antecedentes_medicos,
        e.alergias,
        e.medicamentos_actuales,
        e.fecha_creacion
    FROM dbo.Expedientes AS e
    INNER JOIN dbo.Pacientes AS p
        ON p.id_paciente = e.id_paciente
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR p.nombre_paciente LIKE '%' + @buscar + '%'
        OR p.apellidos LIKE '%' + @buscar + '%'
        OR e.alergias LIKE '%' + @buscar + '%'
    ORDER BY p.apellidos, p.nombre_paciente
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- =========================================
-- ACTUALIZAR EXPEDIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarExpediente
    @id_expediente INT,
    @id_paciente INT,
    @antecedentes_medicos VARCHAR(MAX) = NULL,
    @alergias VARCHAR(MAX) = NULL,
    @medicamentos_actuales VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Expedientes
    SET
        id_paciente = @id_paciente,
        antecedentes_medicos = @antecedentes_medicos,
        alergias = @alergias,
        medicamentos_actuales = @medicamentos_actuales
    WHERE id_expediente = @id_expediente;

    IF @@ROWCOUNT = 0
        THROW 50007, 'No existe el expediente indicado.', 1;
END;
GO

-- =========================================
-- ELIMINAR EXPEDIENTE
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_EliminarExpediente
    @id_expediente INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Expedientes
    WHERE id_expediente = @id_expediente;

    IF @@ROWCOUNT = 0
        THROW 50008, 'No existe el expediente indicado.', 1;
END;
GO