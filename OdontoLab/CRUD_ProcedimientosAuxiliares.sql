USE OdontolabDB;
GO

-- =========================================
-- COMBOBOX DE PACIENTES
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ComboPacientes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_paciente,
        CONCAT(nombre_paciente, ' ', apellidos) AS nombre_completo
    FROM dbo.Pacientes
    ORDER BY apellidos, nombre_paciente;
END;
GO

-- =========================================
-- COMBOBOX DE USUARIOS ACTIVOS
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ComboUsuariosActivos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_usuario,
        nombre_usuario,
        rol
    FROM dbo.Usuarios
    WHERE estado = 'Activo'
    ORDER BY nombre_usuario;
END;
GO

-- =========================================
-- COMBOBOX DE EXPEDIENTES
-- =========================================

CREATE OR ALTER PROCEDURE dbo.sp_ComboExpedientes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.id_expediente,
        e.id_paciente,
        CONCAT(
            p.nombre_paciente,
            ' ',
            p.apellidos
        ) AS paciente
    FROM dbo.Expedientes AS e
    INNER JOIN dbo.Pacientes AS p
        ON p.id_paciente = e.id_paciente
    ORDER BY p.apellidos, p.nombre_paciente;
END;
GO