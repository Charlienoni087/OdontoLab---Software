/* ============================================================
   1. CREAR BASE DE DATOS
   ============================================================ */

IF DB_ID(N'OdontolabDB') IS NULL
BEGIN
    CREATE DATABASE OdontolabDB;
END;
GO

USE OdontolabDB;
GO


/* ============================================================
   2. TABLA: USUARIOS
   ============================================================ */

CREATE TABLE dbo.Usuarios
(
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL,
    estado BIT NOT NULL
        CONSTRAINT DF_Usuarios_Estado DEFAULT 1,
    fecha_creacion DATETIME NOT NULL
        CONSTRAINT DF_Usuarios_Fecha DEFAULT GETDATE(),

    CONSTRAINT PK_Usuarios
        PRIMARY KEY (id_usuario),

    CONSTRAINT UQ_Usuarios_Correo
        UNIQUE (correo),

    CONSTRAINT CK_Usuarios_Correo
        CHECK (correo LIKE '%_@__%.__%'),

    CONSTRAINT CK_Usuarios_Rol
        CHECK (rol IN
        (
            'Administrador',
            'Odontologo',
            'Recepcionista',
            'Asistente'
        ))
);
GO


/* ============================================================
   3. TABLA: PACIENTES
   ============================================================ */

CREATE TABLE dbo.Pacientes
(
    id_paciente INT IDENTITY(1,1) NOT NULL,
    nombre_paciente VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,
    correo VARCHAR(150) NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(200) NULL,
    fecha_registro DATETIME NOT NULL
        CONSTRAINT DF_Pacientes_Fecha DEFAULT GETDATE(),

    CONSTRAINT PK_Pacientes
        PRIMARY KEY (id_paciente),

    CONSTRAINT UQ_Pacientes_Correo
        UNIQUE (correo),

    CONSTRAINT CK_Pacientes_Genero
        CHECK (genero IN ('M', 'F', 'O')),

    CONSTRAINT CK_Pacientes_FechaNacimiento
        CHECK (fecha_nacimiento <= CONVERT(DATE, GETDATE())),

    CONSTRAINT CK_Pacientes_Correo
        CHECK
        (
            correo IS NULL
            OR correo LIKE '%_@__%.__%'
        )
);
GO


/* ============================================================
   4. TABLA: EXPEDIENTES
   Un paciente puede tener un expediente.
   ============================================================ */

CREATE TABLE dbo.Expedientes
(
    id_expediente INT IDENTITY(1,1) NOT NULL,
    id_paciente INT NOT NULL,
    antecedentes_medicos VARCHAR(MAX) NULL,
    alergias VARCHAR(MAX) NULL,
    medicamentos_actuales VARCHAR(MAX) NULL,
    fecha_creacion DATETIME NOT NULL
        CONSTRAINT DF_Expedientes_Fecha DEFAULT GETDATE(),

    CONSTRAINT PK_Expedientes
        PRIMARY KEY (id_expediente),

    CONSTRAINT UQ_Expedientes_Paciente
        UNIQUE (id_paciente),

    CONSTRAINT FK_Expedientes_Pacientes
        FOREIGN KEY (id_paciente)
        REFERENCES dbo.Pacientes(id_paciente)
);
GO


/* ============================================================
   5. TABLA: PROCEDIMIENTOS CLINICOS
   activo = 1: disponible
   activo = 0: no disponible
   ============================================================ */

CREATE TABLE dbo.ProcedimientosClinicos
(
    id_procedimiento INT IDENTITY(1,1) NOT NULL,
    nombre_procedimiento VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    activo BIT NOT NULL
        CONSTRAINT DF_Procedimientos_Activo DEFAULT 1,

    CONSTRAINT PK_ProcedimientosClinicos
        PRIMARY KEY (id_procedimiento),

    CONSTRAINT CK_Procedimientos_Precio
        CHECK (precio_base >= 0)
);
GO


/* ============================================================
   6. TABLA: CITAS
   El estado de una cita tiene varios significados.
   Por eso se conserva como VARCHAR.
   ============================================================ */

CREATE TABLE dbo.Citas
(
    id_cita INT IDENTITY(1,1) NOT NULL,
    id_paciente INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_hora_inicio DATETIME NOT NULL,
    fecha_hora_fin DATETIME NOT NULL,
    motivo VARCHAR(255) NULL,
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Citas_Estado DEFAULT 'Programada',
    notas VARCHAR(MAX) NULL,

    CONSTRAINT PK_Citas
        PRIMARY KEY (id_cita),

    CONSTRAINT FK_Citas_Pacientes
        FOREIGN KEY (id_paciente)
        REFERENCES dbo.Pacientes(id_paciente),

    CONSTRAINT FK_Citas_Usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuarios(id_usuario),

    CONSTRAINT CK_Citas_Horario
        CHECK (fecha_hora_fin > fecha_hora_inicio),

    CONSTRAINT CK_Citas_Estado
        CHECK (estado IN
        (
            'Programada',
            'Confirmada',
            'Cancelada',
            'Completada',
            'No asistio'
        ))
);
GO


/* ============================================================
   7. TABLA: DETALLE EXPEDIENTE
   ============================================================ */

CREATE TABLE dbo.DetalleExpediente
(
    id_detalle INT IDENTITY(1,1) NOT NULL,
    id_expediente INT NOT NULL,
    id_usuario INT NOT NULL,
    id_cita INT NULL,
    fecha_consulta DATETIME NOT NULL
        CONSTRAINT DF_Detalle_Fecha DEFAULT GETDATE(),
    motivo_consulta VARCHAR(255) NULL,
    diagnostico VARCHAR(500) NULL,
    id_procedimiento INT NULL,
    tratamiento_notas VARCHAR(MAX) NULL,
    indicaciones VARCHAR(MAX) NULL,

    CONSTRAINT PK_DetalleExpediente
        PRIMARY KEY (id_detalle),

    CONSTRAINT FK_Detalle_Expedientes
        FOREIGN KEY (id_expediente)
        REFERENCES dbo.Expedientes(id_expediente)
        ON DELETE CASCADE,

    CONSTRAINT FK_Detalle_Usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuarios(id_usuario),

    CONSTRAINT FK_Detalle_Citas
        FOREIGN KEY (id_cita)
        REFERENCES dbo.Citas(id_cita),

    CONSTRAINT FK_Detalle_Procedimientos
        FOREIGN KEY (id_procedimiento)
        REFERENCES dbo.ProcedimientosClinicos(id_procedimiento)
);
GO


/* ============================================================
   8. TABLA: ODONTOGRAMAS
   ============================================================ */

CREATE TABLE dbo.Odontogramas
(
    id_odontograma INT IDENTITY(1,1) NOT NULL,
    id_expediente INT NOT NULL,
    id_usuario INT NOT NULL,
    numero_diente TINYINT NOT NULL,
    cara_diente VARCHAR(20) NOT NULL,
    estado_condicion VARCHAR(30) NOT NULL,
    observaciones VARCHAR(255) NULL,
    fecha_actualizacion DATETIME NOT NULL
        CONSTRAINT DF_Odontogramas_Fecha DEFAULT GETDATE(),

    CONSTRAINT PK_Odontogramas
        PRIMARY KEY (id_odontograma),

    CONSTRAINT FK_Odontogramas_Expedientes
        FOREIGN KEY (id_expediente)
        REFERENCES dbo.Expedientes(id_expediente)
        ON DELETE CASCADE,

    CONSTRAINT FK_Odontogramas_Usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuarios(id_usuario),

    CONSTRAINT CK_Odontogramas_Cara
        CHECK (cara_diente IN
        (
            'Mesial',
            'Distal',
            'Vestibular',
            'Lingual',
            'Palatino',
            'Oclusal',
            'Incisal'
        )),

    CONSTRAINT CK_Odontogramas_Estado
        CHECK (estado_condicion IN
        (
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

    CONSTRAINT UQ_Odontogramas_DienteCara
        UNIQUE
        (
            id_expediente,
            numero_diente,
            cara_diente
        )
);
GO


/* ============================================================
   9. INDICES PARA RELACIONES Y CONSULTAS
   ============================================================ */

CREATE INDEX IX_Citas_Paciente
    ON dbo.Citas(id_paciente);
GO

CREATE INDEX IX_Citas_Usuario
    ON dbo.Citas(id_usuario);
GO

CREATE INDEX IX_Citas_Fecha
    ON dbo.Citas(fecha_hora_inicio);
GO

CREATE INDEX IX_Detalle_Expediente
    ON dbo.DetalleExpediente(id_expediente);
GO

CREATE INDEX IX_Odontogramas_Expediente
    ON dbo.Odontogramas(id_expediente);
GO


/* ============================================================
   10. CRUD DE USUARIOS
   ============================================================ */

-- CREAR USUARIO

CREATE OR ALTER PROCEDURE dbo.sp_CrearUsuario
    @nombre_usuario VARCHAR(100),
    @correo VARCHAR(150),
    @contrasena VARCHAR(255),
    @rol VARCHAR(20),
    @estado BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

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
        @nombre_usuario,
        @correo,
        @contrasena,
        @rol,
        @estado
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_usuario;
END;
GO

-- MOSTRAR USUARIOS CON BUSQUEDA Y PAGINACION

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
    ORDER BY nombre_usuario, id_usuario
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- ACTUALIZAR USUARIO

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarUsuario
    @id_usuario INT,
    @nombre_usuario VARCHAR(100),
    @correo VARCHAR(150),
    @rol VARCHAR(20),
    @estado BIT,
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

-- ELIMINAR USUARIO

CREATE OR ALTER PROCEDURE dbo.sp_EliminarUsuario
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM dbo.Citas
        WHERE id_usuario = @id_usuario
    )
    OR EXISTS (
        SELECT 1 FROM dbo.DetalleExpediente
        WHERE id_usuario = @id_usuario
    )
    OR EXISTS (
        SELECT 1 FROM dbo.Odontogramas
        WHERE id_usuario = @id_usuario
    )
    BEGIN
        THROW 50002,
            'El usuario tiene registros relacionados. Desactivalo en su lugar.',
            1;
    END;

    DELETE FROM dbo.Usuarios
    WHERE id_usuario = @id_usuario;

    IF @@ROWCOUNT = 0
        THROW 50003, 'No existe el usuario indicado.', 1;
END;
GO


/* ============================================================
   11. CRUD DE PACIENTES
   ============================================================ */

-- CREAR PACIENTE

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

    INSERT INTO dbo.Pacientes
    (
        nombre_paciente,
        apellidos,
        fecha_nacimiento,
        genero,
        correo,
        telefono,
        direccion
    )
    VALUES
    (
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

-- MOSTRAR PACIENTES

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
    ORDER BY apellidos, nombre_paciente, id_paciente
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- ACTUALIZAR PACIENTE

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

-- ELIMINAR PACIENTE

CREATE OR ALTER PROCEDURE dbo.sp_EliminarPaciente
    @id_paciente INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM dbo.Expedientes
        WHERE id_paciente = @id_paciente
    )
    OR EXISTS (
        SELECT 1 FROM dbo.Citas
        WHERE id_paciente = @id_paciente
    )
    BEGIN
        THROW 50005,
            'El paciente tiene expedientes o citas relacionadas.',
            1;
    END;

    DELETE FROM dbo.Pacientes
    WHERE id_paciente = @id_paciente;

    IF @@ROWCOUNT = 0
        THROW 50006, 'No existe el paciente indicado.', 1;
END;
GO


/* ============================================================
   12. CRUD DE EXPEDIENTES
   ============================================================ */

-- CREAR EXPEDIENTE

CREATE OR ALTER PROCEDURE dbo.sp_CrearExpediente
    @id_paciente INT,
    @antecedentes_medicos VARCHAR(MAX) = NULL,
    @alergias VARCHAR(MAX) = NULL,
    @medicamentos_actuales VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Expedientes
    (
        id_paciente,
        antecedentes_medicos,
        alergias,
        medicamentos_actuales
    )
    VALUES
    (
        @id_paciente,
        @antecedentes_medicos,
        @alergias,
        @medicamentos_actuales
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_expediente;
END;
GO

-- MOSTRAR EXPEDIENTES

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
    FROM dbo.Expedientes e
    INNER JOIN dbo.Pacientes p
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

-- ACTUALIZAR EXPEDIENTE

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

-- ELIMINAR EXPEDIENTE

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


/* ============================================================
   13. CRUD DE PROCEDIMIENTOS CLINICOS
   ============================================================ */

-- CREAR PROCEDIMIENTO CLINICO

CREATE OR ALTER PROCEDURE dbo.sp_CrearProcedimientoClinico
    @nombre_procedimiento VARCHAR(100),
    @descripcion VARCHAR(255) = NULL,
    @precio_base DECIMAL(10,2),
    @activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ProcedimientosClinicos
    (
        nombre_procedimiento,
        descripcion,
        precio_base,
        activo
    )
    VALUES
    (
        @nombre_procedimiento,
        @descripcion,
        @precio_base,
        @activo
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id_procedimiento;
END;
GO

-- MOSTRAR PROCEDIMIENTOS CLINICOS

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
        precio_base,
        activo
    FROM dbo.ProcedimientosClinicos
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR nombre_procedimiento LIKE '%' + @buscar + '%'
        OR descripcion LIKE '%' + @buscar + '%'
    ORDER BY nombre_procedimiento, id_procedimiento
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- ACTUALIZAR PROCEDIMIENTO CLINICO

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarProcedimientoClinico
    @id_procedimiento INT,
    @nombre_procedimiento VARCHAR(100),
    @descripcion VARCHAR(255) = NULL,
    @precio_base DECIMAL(10,2),
    @activo BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ProcedimientosClinicos
    SET
        nombre_procedimiento = @nombre_procedimiento,
        descripcion = @descripcion,
        precio_base = @precio_base,
        activo = @activo
    WHERE id_procedimiento = @id_procedimiento;

    IF @@ROWCOUNT = 0
        THROW 50009, 'No existe el procedimiento clinico indicado.', 1;
END;
GO

-- ELIMINAR PROCEDIMIENTO CLINICO

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
            'El procedimiento esta asociado a registros clinicos.',
            1;
    END;

    DELETE FROM dbo.ProcedimientosClinicos
    WHERE id_procedimiento = @id_procedimiento;

    IF @@ROWCOUNT = 0
        THROW 50011, 'No existe el procedimiento clinico indicado.', 1;
END;
GO


/* ============================================================
   14. CRUD DE CITAS
   ============================================================ */

-- CREAR CITA

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

    INSERT INTO dbo.Citas
    (
        id_paciente,
        id_usuario,
        fecha_hora_inicio,
        fecha_hora_fin,
        motivo,
        estado,
        notas
    )
    VALUES
    (
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

-- MOSTRAR CITAS

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
    FROM dbo.Citas c
    INNER JOIN dbo.Pacientes p
        ON p.id_paciente = c.id_paciente
    INNER JOIN dbo.Usuarios u
        ON u.id_usuario = c.id_usuario
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR p.nombre_paciente LIKE '%' + @buscar + '%'
        OR p.apellidos LIKE '%' + @buscar + '%'
        OR u.nombre_usuario LIKE '%' + @buscar + '%'
        OR c.estado LIKE '%' + @buscar + '%'
        OR c.motivo LIKE '%' + @buscar + '%'
    ORDER BY c.fecha_hora_inicio DESC, c.id_cita
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- ACTUALIZAR CITA

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

-- ELIMINAR CITA

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
            'La cita esta relacionada con registros clinicos.',
            1;
    END;

    DELETE FROM dbo.Citas
    WHERE id_cita = @id_cita;

    IF @@ROWCOUNT = 0
        THROW 50014, 'No existe la cita indicada.', 1;
END;
GO


/* ============================================================
   15. CRUD DE DETALLE DE EXPEDIENTE
   ============================================================ */

-- CREAR DETALLE

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

    INSERT INTO dbo.DetalleExpediente
    (
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
    VALUES
    (
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

-- MOSTRAR DETALLES

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
    FROM dbo.DetalleExpediente d
    INNER JOIN dbo.Expedientes e
        ON e.id_expediente = d.id_expediente
    INNER JOIN dbo.Pacientes p
        ON p.id_paciente = e.id_paciente
    INNER JOIN dbo.Usuarios u
        ON u.id_usuario = d.id_usuario
    LEFT JOIN dbo.ProcedimientosClinicos pc
        ON pc.id_procedimiento = d.id_procedimiento
    WHERE
        NULLIF(LTRIM(RTRIM(@buscar)), N'') IS NULL
        OR p.nombre_paciente LIKE '%' + @buscar + '%'
        OR p.apellidos LIKE '%' + @buscar + '%'
        OR d.diagnostico LIKE '%' + @buscar + '%'
        OR pc.nombre_procedimiento LIKE '%' + @buscar + '%'
    ORDER BY d.fecha_consulta DESC, d.id_detalle
    OFFSET (@pagina - 1) * @tamPagina ROWS
    FETCH NEXT @tamPagina ROWS ONLY;
END;
GO

-- ACTUALIZAR DETALLE

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
        THROW 50015, 'No existe el detalle indicado.', 1;
END;
GO

-- ELIMINAR DETALLE

CREATE OR ALTER PROCEDURE dbo.sp_EliminarDetalleExpediente
    @id_detalle INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.DetalleExpediente
    WHERE id_detalle = @id_detalle;

    IF @@ROWCOUNT = 0
        THROW 50016, 'No existe el detalle indicado.', 1;
END;
GO


/* ============================================================
   16. CRUD DE ODONTOGRAMAS
   ============================================================ */

-- CREAR ODONTOGRAMA

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

    INSERT INTO dbo.Odontogramas
    (
        id_expediente,
        id_usuario,
        numero_diente,
        cara_diente,
        estado_condicion,
        observaciones
    )
    VALUES
    (
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

-- MOSTRAR ODONTOGRAMAS

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
    FROM dbo.Odontogramas o
    INNER JOIN dbo.Expedientes e
        ON e.id_expediente = o.id_expediente
    INNER JOIN dbo.Pacientes p
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

-- ACTUALIZAR ODONTOGRAMA

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
        THROW 50017, 'No existe el registro indicado.', 1;
END;
GO

-- ELIMINAR ODONTOGRAMA

CREATE OR ALTER PROCEDURE dbo.sp_EliminarOdontograma
    @id_odontograma INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Odontogramas
    WHERE id_odontograma = @id_odontograma;

    IF @@ROWCOUNT = 0
        THROW 50018, 'No existe el registro indicado.', 1;
END;
GO


/* ============================================================
   17. PROCEDIMIENTOS AUXILIARES PARA COMBOBOX
   ============================================================ */

-- COMBOBOX PACIENTES

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

-- COMBOBOX USUARIOS ACTIVOS

CREATE OR ALTER PROCEDURE dbo.sp_ComboUsuariosActivos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_usuario,
        nombre_usuario,
        rol
    FROM dbo.Usuarios
    WHERE estado = 1
    ORDER BY nombre_usuario;
END;
GO

-- COMBOBOX EXPEDIENTES

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
    FROM dbo.Expedientes e
    INNER JOIN dbo.Pacientes p
        ON p.id_paciente = e.id_paciente
    ORDER BY p.apellidos, p.nombre_paciente;
END;
GO

-- COMBOBOX PROCEDIMIENTOS CLINICOS ACTIVOS

CREATE OR ALTER PROCEDURE dbo.sp_ComboProcedimientosActivos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_procedimiento,
        nombre_procedimiento,
        precio_base
    FROM dbo.ProcedimientosClinicos
    WHERE activo = 1
    ORDER BY nombre_procedimiento;
END;
GO


/* ============================================================
   18. VERIFICAR TABLAS
   ============================================================ */

SELECT
    TABLE_NAME AS Tabla
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO


/* ============================================================
   19. VERIFICAR PROCEDIMIENTOS ALMACENADOS
   ============================================================ */

SELECT
    name AS ProcedimientoAlmacenado
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('dbo')
ORDER BY name;
GO

PRINT 'OdontoLabDB: script ejecutado correctamente.';
GO