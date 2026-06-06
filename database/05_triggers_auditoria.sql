-- =========================================================
-- SCRIPT 05 - TRIGGERS DE AUDITORÍA
-- Proyecto: Tienda de ropa online
-- =========================================================


-- =========================================================
-- AUDITORÍA PERSONAS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_personas (
    aud_id SERIAL PRIMARY KEY,
    per_id INT,
    nombre VARCHAR(50),
    telefono VARCHAR(20),
    correo VARCHAR(50),
    genero CHAR(1),
    fecha_nacimiento DATE,
    rol_id INT,
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por VARCHAR(50)
);

CREATE OR REPLACE FUNCTION f_aud_personas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO aud_personas (
        per_id,
        nombre,
        telefono,
        correo,
        genero,
        fecha_nacimiento,
        rol_id,
        operacion,
        fecha_cambio,
        registrado_por
    )
    VALUES (
        COALESCE(NEW.per_id, OLD.per_id),
        COALESCE(NEW.nombre, OLD.nombre),
        COALESCE(NEW.telefono, OLD.telefono),
        COALESCE(NEW.correo, OLD.correo),
        COALESCE(NEW.genero, OLD.genero),
        COALESCE(NEW.fecha_nacimiento, OLD.fecha_nacimiento),
        COALESCE(NEW.rol_id, OLD.rol_id),
        SUBSTRING(TG_OP, 1, 1),
        NOW(),
        CURRENT_USER
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_personas ON personas;

CREATE TRIGGER tr_aud_personas
AFTER INSERT OR UPDATE OR DELETE ON personas
FOR EACH ROW
EXECUTE FUNCTION f_aud_personas();


-- =========================================================
-- AUDITORÍA PRODUCTOS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_productos (
    aud_id SERIAL PRIMARY KEY,
    pro_id INT,
    nombre VARCHAR(100),
    precio NUMERIC(10,2),
    activo BOOLEAN,
    cat_id INT,
    est_id INT,
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por VARCHAR(50)
);

CREATE OR REPLACE FUNCTION f_aud_productos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO aud_productos (
        pro_id,
        nombre,
        precio,
        activo,
        cat_id,
        est_id,
        operacion,
        fecha_cambio,
        registrado_por
    )
    VALUES (
        COALESCE(NEW.pro_id, OLD.pro_id),
        COALESCE(NEW.nombre, OLD.nombre),
        COALESCE(NEW.precio, OLD.precio),
        COALESCE(NEW.activo, OLD.activo),
        COALESCE(NEW.cat_id, OLD.cat_id),
        COALESCE(NEW.est_id, OLD.est_id),
        SUBSTRING(TG_OP, 1, 1),
        NOW(),
        CURRENT_USER
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_productos ON productos;

CREATE TRIGGER tr_aud_productos
AFTER INSERT OR UPDATE OR DELETE ON productos
FOR EACH ROW
EXECUTE FUNCTION f_aud_productos();


-- =========================================================
-- AUDITORÍA INVENTARIOS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_inventarios (
    aud_id SERIAL PRIMARY KEY,
    inv_id INT,
    pro_id INT,
    stock INT,
    tal_id INT,
    col_id INT,
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por VARCHAR(50)
);

CREATE OR REPLACE FUNCTION f_aud_inventarios()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO aud_inventarios (
        inv_id,
        pro_id,
        stock,
        tal_id,
        col_id,
        operacion,
        fecha_cambio,
        registrado_por
    )
    VALUES (
        COALESCE(NEW.inv_id, OLD.inv_id),
        COALESCE(NEW.pro_id, OLD.pro_id),
        COALESCE(NEW.stock, OLD.stock),
        COALESCE(NEW.tal_id, OLD.tal_id),
        COALESCE(NEW.col_id, OLD.col_id),
        SUBSTRING(TG_OP, 1, 1),
        NOW(),
        CURRENT_USER
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_inventarios ON inventarios;

CREATE TRIGGER tr_aud_inventarios
AFTER INSERT OR UPDATE OR DELETE ON inventarios
FOR EACH ROW
EXECUTE FUNCTION f_aud_inventarios();


-- =========================================================
-- AUDITORÍA VENTAS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_ventas (
    aud_id SERIAL PRIMARY KEY,
    ven_id INT,
    per_id INT,
    fecha DATE,
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por VARCHAR(50)
);

CREATE OR REPLACE FUNCTION f_aud_ventas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO aud_ventas (
        ven_id,
        per_id,
        fecha,
        operacion,
        fecha_cambio,
        registrado_por
    )
    VALUES (
        COALESCE(NEW.ven_id, OLD.ven_id),
        COALESCE(NEW.per_id, OLD.per_id),
        COALESCE(NEW.fecha, OLD.fecha),
        SUBSTRING(TG_OP, 1, 1),
        NOW(),
        CURRENT_USER
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_ventas ON ventas;

CREATE TRIGGER tr_aud_ventas
AFTER INSERT OR UPDATE OR DELETE ON ventas
FOR EACH ROW
EXECUTE FUNCTION f_aud_ventas();


-- =========================================================
-- AUDITORÍA PAGOS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_pagos (
    aud_id SERIAL PRIMARY KEY,
    pag_id INT,
    ven_id INT,
    met_id INT,
    monto NUMERIC(10,2),
    fecha DATE,
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por VARCHAR(50)
);

CREATE OR REPLACE FUNCTION f_aud_pagos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO aud_pagos (
        pag_id,
        ven_id,
        met_id,
        monto,
        fecha,
        operacion,
        fecha_cambio,
        registrado_por
    )
    VALUES (
        COALESCE(NEW.pag_id, OLD.pag_id),
        COALESCE(NEW.ven_id, OLD.ven_id),
        COALESCE(NEW.met_id, OLD.met_id),
        COALESCE(NEW.monto, OLD.monto),
        COALESCE(NEW.fecha, OLD.fecha),
        SUBSTRING(TG_OP, 1, 1),
        NOW(),
        CURRENT_USER
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_pagos ON pagos;

CREATE TRIGGER tr_aud_pagos
AFTER INSERT OR UPDATE OR DELETE ON pagos
FOR EACH ROW
EXECUTE FUNCTION f_aud_pagos();