-- =========================================================
-- SCRIPT 06 - TRIGGERS DE AUDITORÍA
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
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_personas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_personas (
            per_id, nombre, telefono, correo, genero,
            fecha_nacimiento, rol_id, operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.per_id, NEW.nombre, NEW.telefono, NEW.correo, NEW.genero,
            NEW.fecha_nacimiento, NEW.rol_id, 'I', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_personas (
            per_id, nombre, telefono, correo, genero,
            fecha_nacimiento, rol_id, operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.per_id, NEW.nombre, NEW.telefono, NEW.correo, NEW.genero,
            NEW.fecha_nacimiento, NEW.rol_id, 'U', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_personas (
            per_id, nombre, telefono, correo, genero,
            fecha_nacimiento, rol_id, operacion, fecha_cambio, registrado_por
        )
        VALUES (
            OLD.per_id, OLD.nombre, OLD.telefono, OLD.correo, OLD.genero,
            OLD.fecha_nacimiento, OLD.rol_id, 'D', NOW(), CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_personas ON personas;

CREATE TRIGGER tr_aud_personas
AFTER INSERT OR UPDATE OR DELETE ON personas
FOR EACH ROW
EXECUTE FUNCTION f_aud_personas();

-- =========================================================
-- AUDITORÍA DETALLE_VENTA
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_detalle_ventas (
    aud_id SERIAL PRIMARY KEY,
    det_id INT,
    ven_id INT,
    inv_id INT,
    cantidad INT,
    precio_unitario NUMERIC(10,2),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_detalle_ventas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_detalle_ventas (
            det_id, ven_id, inv_id, cantidad, precio_unitario,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.det_id, NEW.ven_id, NEW.inv_id, NEW.cantidad, NEW.precio_unitario,
            'I', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_detalle_ventas (
            det_id, ven_id, inv_id, cantidad, precio_unitario,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.det_id, NEW.ven_id, NEW.inv_id, NEW.cantidad, NEW.precio_unitario,
            'U', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_detalle_ventas (
            det_id, ven_id, inv_id, cantidad, precio_unitario,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            OLD.det_id, OLD.ven_id, OLD.inv_id, OLD.cantidad, OLD.precio_unitario,
            'D', NOW(), CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_detalle_ventas ON detalle_ventas;

CREATE TRIGGER tr_aud_detalle_ventas
AFTER INSERT OR UPDATE OR DELETE ON detalle_ventas
FOR EACH ROW
EXECUTE FUNCTION f_aud_detalle_ventas();


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
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_productos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_productos (
            pro_id, nombre, precio, activo, cat_id, est_id,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.pro_id, NEW.nombre, NEW.precio, NEW.activo, NEW.cat_id, NEW.est_id,
            'I', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_productos (
            pro_id, nombre, precio, activo, cat_id, est_id,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.pro_id, NEW.nombre, NEW.precio, NEW.activo, NEW.cat_id, NEW.est_id,
            'U', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_productos (
            pro_id, nombre, precio, activo, cat_id, est_id,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            OLD.pro_id, OLD.nombre, OLD.precio, OLD.activo, OLD.cat_id, OLD.est_id,
            'D', NOW(), CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
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
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_inventarios()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_inventarios (
            inv_id, pro_id, stock, tal_id, col_id,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.inv_id, NEW.pro_id, NEW.stock, NEW.tal_id, NEW.col_id,
            'I', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_inventarios (
            inv_id, pro_id, stock, tal_id, col_id,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.inv_id, NEW.pro_id, NEW.stock, NEW.tal_id, NEW.col_id,
            'U', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_inventarios (
            inv_id, pro_id, stock, tal_id, col_id,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            OLD.inv_id, OLD.pro_id, OLD.stock, OLD.tal_id, OLD.col_id,
            'D', NOW(), CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
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
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_ventas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_ventas (
            ven_id, per_id, fecha,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.ven_id, NEW.per_id, NEW.fecha,
            'I', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_ventas (
            ven_id, per_id, fecha,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.ven_id, NEW.per_id, NEW.fecha,
            'U', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_ventas (
            ven_id, per_id, fecha,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            OLD.ven_id, OLD.per_id, OLD.fecha,
            'D', NOW(), CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
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
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_pagos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_pagos (
            pag_id, ven_id, met_id, monto, fecha,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.pag_id, NEW.ven_id, NEW.met_id, NEW.monto, NEW.fecha,
            'I', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_pagos (
            pag_id, ven_id, met_id, monto, fecha,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            NEW.pag_id, NEW.ven_id, NEW.met_id, NEW.monto, NEW.fecha,
            'U', NOW(), CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_pagos (
            pag_id, ven_id, met_id, monto, fecha,
            operacion, fecha_cambio, registrado_por
        )
        VALUES (
            OLD.pag_id, OLD.ven_id, OLD.met_id, OLD.monto, OLD.fecha,
            'D', NOW(), CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_pagos ON pagos;

CREATE TRIGGER tr_aud_pagos
AFTER INSERT OR UPDATE OR DELETE ON pagos
FOR EACH ROW
EXECUTE FUNCTION f_aud_pagos();

