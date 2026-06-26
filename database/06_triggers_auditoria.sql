-- =========================================================
-- SCRIPT 06 - TRIGGERS DE AUDITORÍA
-- Proyecto: Tienda de ropa online
-- =========================================================


-- =========================================================
-- AUDITORÍA GENERAL
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
    activo BOOLEAN,
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
            per_id,
            nombre,
            telefono,
            correo,
            genero,
            fecha_nacimiento,
            rol_id,
            activo,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.per_id,
            NEW.nombre,
            NEW.telefono,
            NEW.correo,
            NEW.genero,
            NEW.fecha_nacimiento,
            NEW.rol_id,
            NEW.activo,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_personas (
            per_id,
            nombre,
            telefono,
            correo,
            genero,
            fecha_nacimiento,
            rol_id,
            activo,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.per_id,
            NEW.nombre,
            NEW.telefono,
            NEW.correo,
            NEW.genero,
            NEW.fecha_nacimiento,
            NEW.rol_id,
            NEW.activo,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_personas (
            per_id,
            nombre,
            telefono,
            correo,
            genero,
            fecha_nacimiento,
            rol_id,
            activo,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            OLD.per_id,
            OLD.nombre,
            OLD.telefono,
            OLD.correo,
            OLD.genero,
            OLD.fecha_nacimiento,
            OLD.rol_id,
            OLD.activo,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_personas
AFTER INSERT OR UPDATE OR DELETE ON personas
FOR EACH ROW
EXECUTE FUNCTION f_aud_personas();



-- =========================================================
-- AUDITORÍAS DEL CLIENTE
-- =========================================================

-- =========================================================
-- AUDITORÍA DIRECCIONES
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_direcciones (
    aud_id SERIAL PRIMARY KEY,
    dir_id INT,
    mun_id CHAR(5),
    linea VARCHAR(100),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_direcciones()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_direcciones (
            dir_id,
            mun_id,
            linea,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.dir_id,
            NEW.mun_id,
            NEW.linea,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_direcciones (
            dir_id,
            mun_id,
            linea,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.dir_id,
            NEW.mun_id,
            NEW.linea,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_direcciones (
            dir_id,
            mun_id,
            linea,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            OLD.dir_id,
            OLD.mun_id,
            OLD.linea,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_direcciones
AFTER INSERT OR UPDATE OR DELETE ON direcciones
FOR EACH ROW
EXECUTE FUNCTION f_aud_direcciones();


-- =========================================================
-- AUDITORÍA PERSONAS_DIRECCIONES
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_personas_direcciones (
    aud_id SERIAL PRIMARY KEY,
    pdi_id INT,
    per_id INT,
    dir_id INT,
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE OR REPLACE FUNCTION f_aud_personas_direcciones()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO aud_personas_direcciones (
            pdi_id,
            per_id,
            dir_id,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.pdi_id,
            NEW.per_id,
            NEW.dir_id,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_personas_direcciones (
            pdi_id,
            per_id,
            dir_id,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.pdi_id,
            NEW.per_id,
            NEW.dir_id,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_personas_direcciones (
            pdi_id,
            per_id,
            dir_id,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            OLD.pdi_id,
            OLD.per_id,
            OLD.dir_id,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_personas_direcciones
AFTER INSERT OR UPDATE OR DELETE ON personas_direcciones
FOR EACH ROW
EXECUTE FUNCTION f_aud_personas_direcciones();


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
            ven_id,
            per_id,
            fecha,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.ven_id,
            NEW.per_id,
            NEW.fecha,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_ventas (
            ven_id,
            per_id,
            fecha,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.ven_id,
            NEW.per_id,
            NEW.fecha,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_ventas (
            ven_id,
            per_id,
            fecha,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            OLD.ven_id,
            OLD.per_id,
            OLD.fecha,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_ventas
AFTER INSERT OR UPDATE OR DELETE ON ventas
FOR EACH ROW
EXECUTE FUNCTION f_aud_ventas();


-- =========================================================
-- AUDITORÍA DETALLE_VENTAS
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
            det_id,
            ven_id,
            inv_id,
            cantidad,
            precio_unitario,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.det_id,
            NEW.ven_id,
            NEW.inv_id,
            NEW.cantidad,
            NEW.precio_unitario,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_detalle_ventas (
            det_id,
            ven_id,
            inv_id,
            cantidad,
            precio_unitario,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            NEW.det_id,
            NEW.ven_id,
            NEW.inv_id,
            NEW.cantidad,
            NEW.precio_unitario,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_detalle_ventas (
            det_id,
            ven_id,
            inv_id,
            cantidad,
            precio_unitario,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            OLD.det_id,
            OLD.ven_id,
            OLD.inv_id,
            OLD.cantidad,
            OLD.precio_unitario,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_detalle_ventas
AFTER INSERT OR UPDATE OR DELETE ON detalle_ventas
FOR EACH ROW
EXECUTE FUNCTION f_aud_detalle_ventas();


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
            NEW.pag_id,
            NEW.ven_id,
            NEW.met_id,
            NEW.monto,
            NEW.fecha,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
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
            NEW.pag_id,
            NEW.ven_id,
            NEW.met_id,
            NEW.monto,
            NEW.fecha,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
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
            OLD.pag_id,
            OLD.ven_id,
            OLD.met_id,
            OLD.monto,
            OLD.fecha,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_pagos
AFTER INSERT OR UPDATE OR DELETE ON pagos
FOR EACH ROW
EXECUTE FUNCTION f_aud_pagos();



-- =========================================================
-- AUDITORÍAS DEL ADMINISTRADOR
-- =========================================================

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
            NEW.pro_id,
            NEW.nombre,
            NEW.precio,
            NEW.activo,
            NEW.cat_id,
            NEW.est_id,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
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
            NEW.pro_id,
            NEW.nombre,
            NEW.precio,
            NEW.activo,
            NEW.cat_id,
            NEW.est_id,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
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
            OLD.pro_id,
            OLD.nombre,
            OLD.precio,
            OLD.activo,
            OLD.cat_id,
            OLD.est_id,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

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
            NEW.inv_id,
            NEW.pro_id,
            NEW.stock,
            NEW.tal_id,
            NEW.col_id,
            'I',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
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
            NEW.inv_id,
            NEW.pro_id,
            NEW.stock,
            NEW.tal_id,
            NEW.col_id,
            'U',
            NOW(),
            CURRENT_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
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
            OLD.inv_id,
            OLD.pro_id,
            OLD.stock,
            OLD.tal_id,
            OLD.col_id,
            'D',
            NOW(),
            CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER tr_aud_inventarios
AFTER INSERT OR UPDATE OR DELETE ON inventarios
FOR EACH ROW
EXECUTE FUNCTION f_aud_inventarios();



-- =========================================================
-- AUDITORÍAS DEL SUPERADMINISTRADOR
-- =========================================================

-- =========================================================
-- AUDITORÍA ROLES
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_roles (
    aud_id SERIAL PRIMARY KEY,
    rol_id INT,
    nombre VARCHAR(25),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);


-- =========================================================
-- AUDITORÍA CATEGORÍAS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_categorias (
    aud_id SERIAL PRIMARY KEY,
    cat_id INT,
    nombre VARCHAR(100),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);


-- =========================================================
-- AUDITORÍA ESTILOS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_estilos (
    aud_id SERIAL PRIMARY KEY,
    est_id INT,
    nombre VARCHAR(50),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);


-- =========================================================
-- AUDITORÍA TALLAS
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_tallas (
    aud_id SERIAL PRIMARY KEY,
    tal_id INT,
    nombre VARCHAR(5),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);


-- =========================================================
-- AUDITORÍA COLORES
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_colores (
    aud_id SERIAL PRIMARY KEY,
    col_id INT,
    nombre VARCHAR(30),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);


-- =========================================================
-- AUDITORÍA MÉTODOS DE PAGO
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_metodos_pago (
    aud_id SERIAL PRIMARY KEY,
    met_id INT,
    nombre VARCHAR(50),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);


-- =========================================================
-- FUNCIÓN: AUDITORÍA DE CATÁLOGOS SIMPLES
-- =========================================================

CREATE OR REPLACE FUNCTION f_aud_catalogo_simple()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
    v_nombre TEXT;
BEGIN
    IF TG_TABLE_NAME = 'roles' THEN
        IF TG_OP = 'DELETE' THEN
            v_id := OLD.rol_id;
            v_nombre := OLD.nombre;
        ELSE
            v_id := NEW.rol_id;
            v_nombre := NEW.nombre;
        END IF;

        INSERT INTO aud_roles (
            rol_id,
            nombre,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            v_id,
            v_nombre,
            SUBSTRING(TG_OP, 1, 1),
            NOW(),
            CURRENT_USER
        );

    ELSIF TG_TABLE_NAME = 'categorias' THEN
        IF TG_OP = 'DELETE' THEN
            v_id := OLD.cat_id;
            v_nombre := OLD.nombre;
        ELSE
            v_id := NEW.cat_id;
            v_nombre := NEW.nombre;
        END IF;

        INSERT INTO aud_categorias (
            cat_id,
            nombre,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            v_id,
            v_nombre,
            SUBSTRING(TG_OP, 1, 1),
            NOW(),
            CURRENT_USER
        );

    ELSIF TG_TABLE_NAME = 'estilos' THEN
        IF TG_OP = 'DELETE' THEN
            v_id := OLD.est_id;
            v_nombre := OLD.nombre;
        ELSE
            v_id := NEW.est_id;
            v_nombre := NEW.nombre;
        END IF;

        INSERT INTO aud_estilos (
            est_id,
            nombre,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            v_id,
            v_nombre,
            SUBSTRING(TG_OP, 1, 1),
            NOW(),
            CURRENT_USER
        );

    ELSIF TG_TABLE_NAME = 'tallas' THEN
        IF TG_OP = 'DELETE' THEN
            v_id := OLD.tal_id;
            v_nombre := OLD.nombre;
        ELSE
            v_id := NEW.tal_id;
            v_nombre := NEW.nombre;
        END IF;

        INSERT INTO aud_tallas (
            tal_id,
            nombre,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            v_id,
            v_nombre,
            SUBSTRING(TG_OP, 1, 1),
            NOW(),
            CURRENT_USER
        );

    ELSIF TG_TABLE_NAME = 'colores' THEN
        IF TG_OP = 'DELETE' THEN
            v_id := OLD.col_id;
            v_nombre := OLD.nombre;
        ELSE
            v_id := NEW.col_id;
            v_nombre := NEW.nombre;
        END IF;

        INSERT INTO aud_colores (
            col_id,
            nombre,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            v_id,
            v_nombre,
            SUBSTRING(TG_OP, 1, 1),
            NOW(),
            CURRENT_USER
        );

    ELSIF TG_TABLE_NAME = 'metodos_pago' THEN
        IF TG_OP = 'DELETE' THEN
            v_id := OLD.met_id;
            v_nombre := OLD.nombre;
        ELSE
            v_id := NEW.met_id;
            v_nombre := NEW.nombre;
        END IF;

        INSERT INTO aud_metodos_pago (
            met_id,
            nombre,
            operacion,
            fecha_cambio,
            registrado_por
        )
        VALUES (
            v_id,
            v_nombre,
            SUBSTRING(TG_OP, 1, 1),
            NOW(),
            CURRENT_USER
        );
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;


-- =========================================================
-- TRIGGERS SUPERADMINISTRADOR
-- =========================================================

CREATE TRIGGER tr_aud_roles
AFTER INSERT OR UPDATE OR DELETE ON roles
FOR EACH ROW
EXECUTE FUNCTION f_aud_catalogo_simple();


CREATE TRIGGER tr_aud_categorias
AFTER INSERT OR UPDATE OR DELETE ON categorias
FOR EACH ROW
EXECUTE FUNCTION f_aud_catalogo_simple();


CREATE TRIGGER tr_aud_estilos
AFTER INSERT OR UPDATE OR DELETE ON estilos
FOR EACH ROW
EXECUTE FUNCTION f_aud_catalogo_simple();


CREATE TRIGGER tr_aud_tallas
AFTER INSERT OR UPDATE OR DELETE ON tallas
FOR EACH ROW
EXECUTE FUNCTION f_aud_catalogo_simple();


CREATE TRIGGER tr_aud_colores
AFTER INSERT OR UPDATE OR DELETE ON colores
FOR EACH ROW
EXECUTE FUNCTION f_aud_catalogo_simple();


CREATE TRIGGER tr_aud_metodos_pago
AFTER INSERT OR UPDATE OR DELETE ON metodos_pago
FOR EACH ROW
EXECUTE FUNCTION f_aud_catalogo_simple();