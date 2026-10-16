-- =================================================================================
-- 1. CREACIÓN DE LA BASE DE DATOS
-- =================================================================================
IF DB_ID(N'OdontolabDB') IS NULL
    CREATE DATABASE OdontolabDB;
GO

USE OdontolabDB;
GO

-- =================================================================================
-- 2. CREACIÓN DE TABLAS
-- =================================================================================

-- TABLA USUARIOS
IF OBJECT_ID('dbo.Usuarios', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuarios (
        id_usuario INT IDENTITY(1,1) PRIMARY KEY,
        nombre_usuario VARCHAR(100) NOT NULL,
        correo VARCHAR(150) NOT NULL UNIQUE,
        contrasena VARCHAR(255) NOT NULL,
        rol VARCHAR(20) NOT NULL,
        estado VARCHAR(15) NOT NULL DEFAULT 'Activo',
        fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT CK_Usuarios_Correo
            CHECK (correo LIKE '%_@__%.__%'),

        CONSTRAINT CK_Usuarios_Rol
            CHECK (rol IN (
                'Administrador',
                'Odontologo',
                'Recepcionista',
                'Asistente'
            )),

        CONSTRAINT CK_Usuarios_Estado
            CHECK (estado IN (
                'Activo',
                'Inactivo',
                'Suspendido'
            ))
    );
END;
GO

-- TABLA PACIENTES
IF OBJECT_ID('dbo.Pacientes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Pacientes (
        id_paciente INT IDENTITY(1,1) PRIMARY KEY,
        nombre_paciente VARCHAR(100) NOT NULL,
        apellidos VARCHAR(100) NOT NULL,
        cedula VARCHAR(20) NULL,
        fecha_nacimiento DATE NOT NULL,
        telefono VARCHAR(20) NOT NULL,
        correo VARCHAR(150) NULL,
        direccion VARCHAR(200) NULL,
        fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT CK_Pacientes_FechaNac
            CHECK (fecha_nacimiento <= CONVERT(DATE, GETDATE())),

        CONSTRAINT CK_Pacientes_Correo
            CHECK (
                correo IS NULL
                OR correo LIKE '%_@__%.__%'
            )
    );

    -- Índices únicos filtrados (permiten múltiples NULL para menores/sin correo, pero evitan duplicados)
    CREATE UNIQUE NONCLUSTERED INDEX UQ_Pacientes_Cedula 
        ON dbo.Pacientes(cedula) WHERE cedula IS NOT NULL;

    CREATE UNIQUE NONCLUSTERED INDEX UQ_Pacientes_Correo 
        ON dbo.Pacientes(correo) WHERE correo IS NOT NULL;
END;
GO

-- TABLA EXPEDIENTES
IF OBJECT_ID('dbo.Expedientes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Expedientes (
        id_expediente INT IDENTITY(1,1) PRIMARY KEY,
        id_paciente INT NOT NULL UNIQUE,
        antecedentes_medicos VARCHAR(MAX) NULL,
        alergias VARCHAR(MAX) NULL,
        medicamentos_actuales VARCHAR(MAX) NULL,
        fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Expedientes_Pacientes
            FOREIGN KEY (id_paciente)
            REFERENCES dbo.Pacientes(id_paciente)
    );
END;
GO

-- TABLA PROCEDIMIENTOS CLINICOS
IF OBJECT_ID('dbo.ProcedimientosClinicos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProcedimientosClinicos (
        id_procedimiento INT IDENTITY(1,1) PRIMARY KEY,
        nombre_procedimiento VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,
        precio_base DECIMAL(10,2) NOT NULL,

        CONSTRAINT CK_Procedimientos_Precio
            CHECK (precio_base >= 0)
    );
END;
GO

-- TABLA CITAS
IF OBJECT_ID('dbo.Citas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Citas (
        id_cita INT IDENTITY(1,1) PRIMARY KEY,
        id_paciente INT NOT NULL,
        id_usuario INT NOT NULL,
        fecha_hora_inicio DATETIME NOT NULL,
        fecha_hora_fin DATETIME NOT NULL,
        motivo VARCHAR(255) NULL,
        estado VARCHAR(20) NOT NULL DEFAULT 'Programada',
        notas VARCHAR(MAX) NULL,

        CONSTRAINT FK_Citas_Pacientes
            FOREIGN KEY (id_paciente)
            REFERENCES dbo.Pacientes(id_paciente),

        CONSTRAINT FK_Citas_Usuarios
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.Usuarios(id_usuario),

        CONSTRAINT CK_Citas_Horario
            CHECK (fecha_hora_fin > fecha_hora_inicio),

        CONSTRAINT CK_Citas_Estado
            CHECK (estado IN (
                'Programada',
                'Confirmada',
                'Cancelada',
                'Completada',
                'No asistio'
            ))
    );
END;
GO

-- TABLA DETALLE EXPEDIENTE
IF OBJECT_ID('dbo.DetalleExpediente', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DetalleExpediente (
        id_detalle INT IDENTITY(1,1) PRIMARY KEY,
        id_expediente INT NOT NULL,
        id_usuario INT NOT NULL,
        id_cita INT NULL,
        fecha_consulta DATETIME NOT NULL DEFAULT GETDATE(),
        motivo_consulta VARCHAR(255) NULL,
        diagnostico VARCHAR(500) NULL,
        id_procedimiento INT NULL,
        tratamiento_notas VARCHAR(MAX) NULL,
        indicaciones VARCHAR(MAX) NULL,

        CONSTRAINT FK_DetExp_Expedientes
            FOREIGN KEY (id_expediente)
            REFERENCES dbo.Expedientes(id_expediente)
            ON DELETE CASCADE,

        CONSTRAINT FK_DetExp_Usuarios
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.Usuarios(id_usuario),

        CONSTRAINT FK_DetExp_Citas
            FOREIGN KEY (id_cita)
            REFERENCES dbo.Citas(id_cita),

        CONSTRAINT FK_DetExp_Procedimientos
            FOREIGN KEY (id_procedimiento)
            REFERENCES dbo.ProcedimientosClinicos(id_procedimiento)
    );
END;
GO

-- TABLA ODONTOGRAMAS
IF OBJECT_ID('dbo.Odontogramas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Odontogramas (
        id_odontograma INT IDENTITY(1,1) PRIMARY KEY,
        id_expediente INT NOT NULL,
        id_usuario INT NOT NULL,
        numero_diente TINYINT NOT NULL,
        cara_diente VARCHAR(20) NOT NULL,
        estado_condicion VARCHAR(30) NOT NULL,
        observaciones VARCHAR(255) NULL,
        fecha_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Odont_Expedientes
            FOREIGN KEY (id_expediente)
            REFERENCES dbo.Expedientes(id_expediente)
            ON DELETE CASCADE,

        CONSTRAINT FK_Odont_Usuarios
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.Usuarios(id_usuario),

        CONSTRAINT CK_Odont_Cara
            CHECK (cara_diente IN (
                'Mesial',
                'Distal',
                'Vestibular',
                'Lingual',
                'Palatino',
                'Oclusal',
                'Incisal'
            )),

        CONSTRAINT CK_Odont_Estado
            CHECK (estado_condicion IN (
                'Sano',
                'Cariado',
                'Obturado',
                'Extraido',
                'Ausente',
                'Corona',
                'Endodoncia',
                'Sellante',
                'Fracturado',
                'Protesis'
            )),

        CONSTRAINT UQ_Odont_DienteCara
            UNIQUE (id_expediente, numero_diente, cara_diente)
    );
END;
GO

-- TABLA ROLES
IF OBJECT_ID('dbo.tblRoles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblRoles (
        idRol INT IDENTITY(1,1) NOT NULL,
        nombreRol NVARCHAR(50) NOT NULL,
        activo BIT NOT NULL DEFAULT 1,

        CONSTRAINT PK_tblRoles PRIMARY KEY (idRol),
        CONSTRAINT CK_tblRoles_nombreRol CHECK(nombreRol IN ('Administrador', 'Recepcionista', 'Asistente', 'Doctor')),
        CONSTRAINT UQ_tblRoles_nombreRol UNIQUE (nombreRol)
    );
END;
GO

-- TABLA LOG REPORTES
IF OBJECT_ID('dbo.LogErrores', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LogErrores (
        idLog INT IDENTITY(1,1) NOT NULL,
        mensajeError NVARCHAR(MAX) NOT NULL,
        numeroError INT NULL,
        procedimiento NVARCHAR(100) NULL,
        lineaError INT NULL,
        usuarioApp NVARCHAR(25) NOT NULL,
        fechaError DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_LogErrores PRIMARY KEY (idLog)
    );
END;
GO

PRINT 'OdontoLabDB: tablas creadas o verificadas correctamente.';
GO

-- =================================================================================
-- 3. PROCEDIMIENTOS ALMACENADOS DE PACIENTES
-- =================================================================================

-- CREAR PACIENTE
CREATE OR ALTER PROCEDURE dbo.sp_CrearPaciente
    @nombre_paciente VARCHAR(100),
    @apellidos VARCHAR(100),
    @cedula VARCHAR(20) = NULL,
    @fecha_nacimiento DATE,
    @telefono VARCHAR(20),
    @correo VARCHAR(150) = NULL,
    @direccion VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpiar espacios o convertir cadena vacía en NULL para no violar los índices únicos
    SET @cedula = NULLIF(LTRIM(RTRIM(@cedula)), '');
    SET @correo = NULLIF(LTRIM(RTRIM(@correo)), '');

    INSERT INTO dbo.Pacientes (
        nombre_paciente,
        apellidos,
        cedula,
        fecha_nacimiento,
        telefono,
        correo,
        direccion
    )
    VALUES (
        @nombre_paciente,
        @apellidos,
        @cedula,
        @fecha_nacimiento,
        @telefono,
        @correo,
        @direccion
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_paciente;
END;
GO

-- MOSTRAR / BUSCAR PACIENTES
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
        cedula,
        fecha_nacimiento,
        telefono,
        correo,
        direccion,
        fecha_registro
    FROM dbo.Pacientes
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR nombre_paciente LIKE '%' + @buscar + '%'
        OR apellidos LIKE '%' + @buscar + '%'
        OR cedula LIKE '%' + @buscar + '%'
        OR telefono LIKE '%' + @buscar + '%'
        OR correo LIKE '%' + @buscar + '%'
    ORDER BY apellidos, nombre_paciente
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- ACTUALIZAR PACIENTE
CREATE OR ALTER PROCEDURE dbo.sp_ActualizarPaciente
    @id_paciente INT,
    @nombre_paciente VARCHAR(100),
    @apellidos VARCHAR(100),
    @cedula VARCHAR(20) = NULL,
    @fecha_nacimiento DATE,
    @telefono VARCHAR(20),
    @correo VARCHAR(150) = NULL,
    @direccion VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @cedula = NULLIF(LTRIM(RTRIM(@cedula)), '');
    SET @correo = NULLIF(LTRIM(RTRIM(@correo)), '');

    UPDATE dbo.Pacientes
    SET
        nombre_paciente = @nombre_paciente,
        apellidos = @apellidos,
        cedula = @cedula,
        fecha_nacimiento = @fecha_nacimiento,
        telefono = @telefono,
        correo = @correo,
        direccion = @direccion
    WHERE id_paciente = @id_paciente;

    IF @@ROWCOUNT = 0
        THROW 50004, 'No existe el paciente indicado.', 1;
END;
GO

-- ELIMINAR PACIENTE
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

PRINT 'Procedimientos almacenados de Pacientes creados o actualizados correctamente.';
GO
