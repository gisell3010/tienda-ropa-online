-- =========================================================
-- SCRIPT 11 - MEJORAS MÓDULO SUPERADMINISTRADOR
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- AJUSTES EN PERSONAS
-- =========================================================

ALTER TABLE personas
ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE aud_personas
ADD COLUMN IF NOT EXISTS activo BOOLEAN;

-- =========================================================
-- PROCEDIMIENTO: CAMBIAR ESTADO DE PERSONA
-- No permite desactivar el último SUPERADMIN activo.
-- =========================================================

CREATE OR REPLACE PROCEDURE cambiar_estado_persona(
    p_per_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rol_actual VARCHAR;
    v_superadmin_activos INT;
BEGIN
    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado de la persona';
    END IF;

    SELECT r.nombre
    INTO v_rol_actual
    FROM personas p
    INNER JOIN roles r ON r.rol_id = p.rol_id
    WHERE p.per_id = p_per_id;

    IF v_rol_actual IS NULL THEN
        RAISE EXCEPTION 'No existe la persona indicada';
    END IF;

    IF v_rol_actual = 'SUPERADMIN' AND p_activo = FALSE THEN
        SELECT COUNT(*)
        INTO v_superadmin_activos
        FROM personas p
        INNER JOIN roles r ON r.rol_id = p.rol_id
        WHERE r.nombre = 'SUPERADMIN'
          AND p.activo = TRUE
          AND p.per_id <> p_per_id;

        IF v_superadmin_activos = 0 THEN
            RAISE EXCEPTION 'No se puede desactivar el último SUPERADMIN activo';
        END IF;
    END IF;

    UPDATE personas
    SET activo = p_activo
    WHERE per_id = p_per_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO: CAMBIAR ROL DE PERSONA
-- No permite dejar el sistema sin SUPERADMIN activo.
-- =========================================================

CREATE OR REPLACE PROCEDURE cambiar_rol_persona(
    p_per_id INT,
    p_rol_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rol_actual VARCHAR;
    v_rol_nuevo VARCHAR;
    v_superadmin_activos INT;
BEGIN
    SELECT r.nombre
    INTO v_rol_actual
    FROM personas p
    INNER JOIN roles r ON r.rol_id = p.rol_id
    WHERE p.per_id = p_per_id;

    IF v_rol_actual IS NULL THEN
        RAISE EXCEPTION 'No existe la persona indicada';
    END IF;

    SELECT nombre
    INTO v_rol_nuevo
    FROM roles
    WHERE rol_id = p_rol_id;

    IF v_rol_nuevo IS NULL THEN
        RAISE EXCEPTION 'No existe el rol indicado';
    END IF;

    IF v_rol_actual = 'SUPERADMIN' AND v_rol_nuevo <> 'SUPERADMIN' THEN
        SELECT COUNT(*)
        INTO v_superadmin_activos
        FROM personas p
        INNER JOIN roles r ON r.rol_id = p.rol_id
        WHERE r.nombre = 'SUPERADMIN'
          AND p.activo = TRUE
          AND p.per_id <> p_per_id;

        IF v_superadmin_activos = 0 THEN
            RAISE EXCEPTION 'No se puede cambiar el rol del último SUPERADMIN activo';
        END IF;
    END IF;

    UPDATE personas
    SET rol_id = p_rol_id
    WHERE per_id = p_per_id;
END;
$$;

-- =========================================================
-- VISTAS DE USUARIOS Y ROLES
-- =========================================================

CREATE OR REPLACE VIEW vw_roles_sistema AS
SELECT
    rol_id,
    nombre AS rol
FROM roles
ORDER BY rol_id;

CREATE OR REPLACE VIEW vw_usuarios_sistema_detalle AS
SELECT
    p.per_id,
    p.nombre,
    p.correo,
    p.telefono,
    p.genero,
    p.fecha_nacimiento,
    p.activo,
    p.rol_id,
    r.nombre AS rol,
    (
        SELECT MAX(ap.fecha_cambio)
        FROM aud_personas ap
        WHERE ap.per_id = p.per_id
    ) AS ultima_modificacion
FROM personas p
INNER JOIN roles r ON r.rol_id = p.rol_id;

CREATE OR REPLACE VIEW vw_usuarios_sistema AS
SELECT
    per_id,
    nombre,
    telefono,
    correo,
    genero,
    fecha_nacimiento,
    activo,
    rol_id,
    rol
FROM vw_usuarios_sistema_detalle;

-- =========================================================
-- AUDITORÍAS FALTANTES
-- =========================================================

CREATE TABLE IF NOT EXISTS aud_roles (
    aud_id SERIAL PRIMARY KEY,
    rol_id INT,
    nombre VARCHAR(25),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_categorias (
    aud_id SERIAL PRIMARY KEY,
    cat_id INT,
    nombre VARCHAR(100),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_estilos (
    aud_id SERIAL PRIMARY KEY,
    est_id INT,
    nombre VARCHAR(50),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_tallas (
    aud_id SERIAL PRIMARY KEY,
    tal_id INT,
    nombre VARCHAR(5),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_colores (
    aud_id SERIAL PRIMARY KEY,
    col_id INT,
    nombre VARCHAR(30),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_metodos_pago (
    aud_id SERIAL PRIMARY KEY,
    met_id INT,
    nombre VARCHAR(50),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_direcciones (
    aud_id SERIAL PRIMARY KEY,
    dir_id INT,
    mun_id CHAR(5),
    linea VARCHAR(100),
    operacion CHAR(1),
    fecha_cambio TIMESTAMP DEFAULT NOW(),
    registrado_por TEXT
);

CREATE TABLE IF NOT EXISTS aud_personas_direcciones (
    aud_id SERIAL PRIMARY KEY,
    pdi_id INT,
    per_id INT,
    dir_id INT,
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
        INSERT INTO aud_personas(per_id, nombre, telefono, correo, genero, fecha_nacimiento, rol_id, activo, operacion, fecha_cambio, registrado_por)
        VALUES (NEW.per_id, NEW.nombre, NEW.telefono, NEW.correo, NEW.genero, NEW.fecha_nacimiento, NEW.rol_id, NEW.activo, 'I', NOW(), CURRENT_USER);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO aud_personas(per_id, nombre, telefono, correo, genero, fecha_nacimiento, rol_id, activo, operacion, fecha_cambio, registrado_por)
        VALUES (NEW.per_id, NEW.nombre, NEW.telefono, NEW.correo, NEW.genero, NEW.fecha_nacimiento, NEW.rol_id, NEW.activo, 'U', NOW(), CURRENT_USER);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO aud_personas(per_id, nombre, telefono, correo, genero, fecha_nacimiento, rol_id, activo, operacion, fecha_cambio, registrado_por)
        VALUES (OLD.per_id, OLD.nombre, OLD.telefono, OLD.correo, OLD.genero, OLD.fecha_nacimiento, OLD.rol_id, OLD.activo, 'D', NOW(), CURRENT_USER);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION f_aud_catalogo_simple()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
    v_nombre TEXT;
BEGIN
    IF TG_TABLE_NAME = 'roles' THEN
        IF TG_OP = 'DELETE' THEN v_id := OLD.rol_id; v_nombre := OLD.nombre; ELSE v_id := NEW.rol_id; v_nombre := NEW.nombre; END IF;
        INSERT INTO aud_roles(rol_id, nombre, operacion, fecha_cambio, registrado_por) VALUES (v_id, v_nombre, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
    ELSIF TG_TABLE_NAME = 'categorias' THEN
        IF TG_OP = 'DELETE' THEN v_id := OLD.cat_id; v_nombre := OLD.nombre; ELSE v_id := NEW.cat_id; v_nombre := NEW.nombre; END IF;
        INSERT INTO aud_categorias(cat_id, nombre, operacion, fecha_cambio, registrado_por) VALUES (v_id, v_nombre, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
    ELSIF TG_TABLE_NAME = 'estilos' THEN
        IF TG_OP = 'DELETE' THEN v_id := OLD.est_id; v_nombre := OLD.nombre; ELSE v_id := NEW.est_id; v_nombre := NEW.nombre; END IF;
        INSERT INTO aud_estilos(est_id, nombre, operacion, fecha_cambio, registrado_por) VALUES (v_id, v_nombre, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
    ELSIF TG_TABLE_NAME = 'tallas' THEN
        IF TG_OP = 'DELETE' THEN v_id := OLD.tal_id; v_nombre := OLD.nombre; ELSE v_id := NEW.tal_id; v_nombre := NEW.nombre; END IF;
        INSERT INTO aud_tallas(tal_id, nombre, operacion, fecha_cambio, registrado_por) VALUES (v_id, v_nombre, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
    ELSIF TG_TABLE_NAME = 'colores' THEN
        IF TG_OP = 'DELETE' THEN v_id := OLD.col_id; v_nombre := OLD.nombre; ELSE v_id := NEW.col_id; v_nombre := NEW.nombre; END IF;
        INSERT INTO aud_colores(col_id, nombre, operacion, fecha_cambio, registrado_por) VALUES (v_id, v_nombre, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
    ELSIF TG_TABLE_NAME = 'metodos_pago' THEN
        IF TG_OP = 'DELETE' THEN v_id := OLD.met_id; v_nombre := OLD.nombre; ELSE v_id := NEW.met_id; v_nombre := NEW.nombre; END IF;
        INSERT INTO aud_metodos_pago(met_id, nombre, operacion, fecha_cambio, registrado_por) VALUES (v_id, v_nombre, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
    END IF;

    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION f_aud_direcciones()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO aud_direcciones(dir_id, mun_id, linea, operacion, fecha_cambio, registrado_por)
        VALUES (OLD.dir_id, OLD.mun_id, OLD.linea, 'D', NOW(), CURRENT_USER);
        RETURN OLD;
    ELSE
        INSERT INTO aud_direcciones(dir_id, mun_id, linea, operacion, fecha_cambio, registrado_por)
        VALUES (NEW.dir_id, NEW.mun_id, NEW.linea, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
        RETURN NEW;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION f_aud_personas_direcciones()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO aud_personas_direcciones(pdi_id, per_id, dir_id, operacion, fecha_cambio, registrado_por)
        VALUES (OLD.pdi_id, OLD.per_id, OLD.dir_id, 'D', NOW(), CURRENT_USER);
        RETURN OLD;
    ELSE
        INSERT INTO aud_personas_direcciones(pdi_id, per_id, dir_id, operacion, fecha_cambio, registrado_por)
        VALUES (NEW.pdi_id, NEW.per_id, NEW.dir_id, SUBSTRING(TG_OP, 1, 1), NOW(), CURRENT_USER);
        RETURN NEW;
    END IF;
END;
$$;

DROP TRIGGER IF EXISTS tr_aud_roles ON roles;
CREATE TRIGGER tr_aud_roles AFTER INSERT OR UPDATE OR DELETE ON roles FOR EACH ROW EXECUTE FUNCTION f_aud_catalogo_simple();
DROP TRIGGER IF EXISTS tr_aud_categorias ON categorias;
CREATE TRIGGER tr_aud_categorias AFTER INSERT OR UPDATE OR DELETE ON categorias FOR EACH ROW EXECUTE FUNCTION f_aud_catalogo_simple();
DROP TRIGGER IF EXISTS tr_aud_estilos ON estilos;
CREATE TRIGGER tr_aud_estilos AFTER INSERT OR UPDATE OR DELETE ON estilos FOR EACH ROW EXECUTE FUNCTION f_aud_catalogo_simple();
DROP TRIGGER IF EXISTS tr_aud_tallas ON tallas;
CREATE TRIGGER tr_aud_tallas AFTER INSERT OR UPDATE OR DELETE ON tallas FOR EACH ROW EXECUTE FUNCTION f_aud_catalogo_simple();
DROP TRIGGER IF EXISTS tr_aud_colores ON colores;
CREATE TRIGGER tr_aud_colores AFTER INSERT OR UPDATE OR DELETE ON colores FOR EACH ROW EXECUTE FUNCTION f_aud_catalogo_simple();
DROP TRIGGER IF EXISTS tr_aud_metodos_pago ON metodos_pago;
CREATE TRIGGER tr_aud_metodos_pago AFTER INSERT OR UPDATE OR DELETE ON metodos_pago FOR EACH ROW EXECUTE FUNCTION f_aud_catalogo_simple();
DROP TRIGGER IF EXISTS tr_aud_direcciones ON direcciones;
CREATE TRIGGER tr_aud_direcciones AFTER INSERT OR UPDATE OR DELETE ON direcciones FOR EACH ROW EXECUTE FUNCTION f_aud_direcciones();
DROP TRIGGER IF EXISTS tr_aud_personas_direcciones ON personas_direcciones;
CREATE TRIGGER tr_aud_personas_direcciones AFTER INSERT OR UPDATE OR DELETE ON personas_direcciones FOR EACH ROW EXECUTE FUNCTION f_aud_personas_direcciones();

-- =========================================================
-- AUDITORÍA GENERAL AMPLIADA
-- =========================================================

CREATE OR REPLACE VIEW vw_auditoria_general AS
SELECT 'personas' AS tabla, per_id AS id_afectado, operacion, fecha_cambio, registrado_por,
       CONCAT('persona=', nombre, ', correo=', correo, ', rol_id=', rol_id, ', activo=', activo) AS datos_relevantes
FROM aud_personas
UNION ALL
SELECT 'productos', pro_id, operacion, fecha_cambio, registrado_por,
       CONCAT('producto=', nombre, ', precio=', precio, ', activo=', activo) AS datos_relevantes
FROM aud_productos
UNION ALL
SELECT 'inventarios', inv_id, operacion, fecha_cambio, registrado_por,
       CONCAT('pro_id=', pro_id, ', stock=', stock, ', tal_id=', tal_id, ', col_id=', col_id) AS datos_relevantes
FROM aud_inventarios
UNION ALL
SELECT 'ventas', ven_id, operacion, fecha_cambio, registrado_por,
       CONCAT('per_id=', per_id, ', fecha=', fecha) AS datos_relevantes
FROM aud_ventas
UNION ALL
SELECT 'detalle_ventas', det_id, operacion, fecha_cambio, registrado_por,
       CONCAT('ven_id=', ven_id, ', inv_id=', inv_id, ', cantidad=', cantidad, ', precio=', precio_unitario) AS datos_relevantes
FROM aud_detalle_ventas
UNION ALL
SELECT 'pagos', pag_id, operacion, fecha_cambio, registrado_por,
       CONCAT('ven_id=', ven_id, ', met_id=', met_id, ', monto=', monto) AS datos_relevantes
FROM aud_pagos
UNION ALL
SELECT 'roles', rol_id, operacion, fecha_cambio, registrado_por, CONCAT('rol=', nombre)
FROM aud_roles
UNION ALL
SELECT 'categorias', cat_id, operacion, fecha_cambio, registrado_por, CONCAT('categoria=', nombre)
FROM aud_categorias
UNION ALL
SELECT 'estilos', est_id, operacion, fecha_cambio, registrado_por, CONCAT('estilo=', nombre)
FROM aud_estilos
UNION ALL
SELECT 'tallas', tal_id, operacion, fecha_cambio, registrado_por, CONCAT('talla=', nombre)
FROM aud_tallas
UNION ALL
SELECT 'colores', col_id, operacion, fecha_cambio, registrado_por, CONCAT('color=', nombre)
FROM aud_colores
UNION ALL
SELECT 'metodos_pago', met_id, operacion, fecha_cambio, registrado_por, CONCAT('metodo=', nombre)
FROM aud_metodos_pago
UNION ALL
SELECT 'direcciones', dir_id, operacion, fecha_cambio, registrado_por, CONCAT('mun_id=', mun_id, ', linea=', linea)
FROM aud_direcciones
UNION ALL
SELECT 'personas_direcciones', pdi_id, operacion, fecha_cambio, registrado_por, CONCAT('per_id=', per_id, ', dir_id=', dir_id)
FROM aud_personas_direcciones;

CREATE OR REPLACE VIEW vw_tablas_auditoria AS
SELECT DISTINCT tabla
FROM vw_auditoria_general
ORDER BY tabla;

-- =========================================================
-- REPORTES SUPERADMIN
-- =========================================================

CREATE OR REPLACE VIEW vw_reporte_general AS
SELECT
    (SELECT COUNT(*) FROM personas) AS total_usuarios,
    (SELECT COUNT(*) FROM personas WHERE activo = TRUE) AS usuarios_activos,
    (SELECT COUNT(*) FROM productos) AS total_productos,
    (SELECT COUNT(*) FROM productos WHERE activo = TRUE) AS productos_activos,
    (SELECT COUNT(*) FROM ventas) AS total_ventas,
    (SELECT COALESCE(SUM(monto), 0) FROM pagos) AS monto_ventas,
    (SELECT COUNT(*) FROM detalle_ventas) AS pedidos_registrados,
    (SELECT COUNT(*) FROM vw_auditoria_general) AS total_auditorias;

CREATE OR REPLACE VIEW vw_ventas_por_periodo AS
SELECT
    v.fecha,
    COUNT(v.ven_id) AS total_ventas,
    COALESCE(SUM(p.monto), 0) AS monto_total
FROM ventas v
LEFT JOIN pagos p ON p.ven_id = v.ven_id
GROUP BY v.fecha
ORDER BY v.fecha DESC;

CREATE OR REPLACE VIEW vw_ventas_por_metodo_pago AS
SELECT
    mp.met_id,
    mp.nombre AS metodo_pago,
    COUNT(p.pag_id) AS cantidad_pagos,
    COALESCE(SUM(p.monto), 0) AS total_pagado
FROM metodos_pago mp
LEFT JOIN pagos p ON p.met_id = mp.met_id
GROUP BY mp.met_id, mp.nombre
ORDER BY total_pagado DESC;

CREATE OR REPLACE VIEW vw_top_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    COALESCE(SUM(d.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_generado
FROM productos p
LEFT JOIN inventarios i ON i.pro_id = p.pro_id
LEFT JOIN detalle_ventas d ON d.inv_id = i.inv_id
GROUP BY p.pro_id, p.nombre, p.imagen_url
ORDER BY unidades_vendidas DESC;

CREATE OR REPLACE VIEW vw_clientes_mas_compras AS
SELECT
    pe.per_id,
    pe.nombre AS cliente,
    pe.correo,
    COUNT(v.ven_id) AS total_compras,
    COALESCE(SUM(pa.monto), 0) AS total_pagado
FROM personas pe
INNER JOIN roles r ON r.rol_id = pe.rol_id
LEFT JOIN ventas v ON v.per_id = pe.per_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
WHERE r.nombre = 'CLIENTE'
GROUP BY pe.per_id, pe.nombre, pe.correo
ORDER BY total_compras DESC;

CREATE OR REPLACE VIEW vw_productos_bajo_stock AS
SELECT
    i.inv_id,
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    t.nombre AS talla,
    c.nombre AS color,
    i.stock
FROM inventarios i
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores c ON c.col_id = i.col_id
WHERE i.stock <= 5
ORDER BY i.stock ASC;

CREATE OR REPLACE VIEW vw_usuarios_por_rol AS
SELECT
    r.rol_id,
    r.nombre AS rol,
    COUNT(p.per_id) AS total_usuarios,
    COUNT(p.per_id) FILTER (WHERE p.activo = TRUE) AS usuarios_activos,
    COUNT(p.per_id) FILTER (WHERE p.activo = FALSE) AS usuarios_inactivos
FROM roles r
LEFT JOIN personas p ON p.rol_id = r.rol_id
GROUP BY r.rol_id, r.nombre
ORDER BY r.rol_id;

CREATE OR REPLACE PROCEDURE refrescar_reportes()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_resumen_ventas_productos;
END;
$$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_resumen_ventas_productos_pro_id
ON mv_resumen_ventas_productos (pro_id);

-- =========================================================
-- ÍNDICES SUPERADMIN
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_rol_activo ON personas (rol_id, activo);
CREATE INDEX IF NOT EXISTS idx_pagos_met_id ON pagos (met_id);
CREATE INDEX IF NOT EXISTS idx_aud_personas_fecha ON aud_personas (fecha_cambio);
CREATE INDEX IF NOT EXISTS idx_aud_productos_fecha ON aud_productos (fecha_cambio);
CREATE INDEX IF NOT EXISTS idx_aud_inventarios_fecha ON aud_inventarios (fecha_cambio);
CREATE INDEX IF NOT EXISTS idx_aud_ventas_fecha ON aud_ventas (fecha_cambio);
CREATE INDEX IF NOT EXISTS idx_aud_detalle_ventas_fecha ON aud_detalle_ventas (fecha_cambio);
CREATE INDEX IF NOT EXISTS idx_aud_pagos_fecha ON aud_pagos (fecha_cambio);

-- =========================================================
-- PERMISOS Y USUARIOS POSTGRESQL DE PRUEBA
-- =========================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_cliente_demo') THEN
        CREATE USER usr_cliente_demo WITH PASSWORD 'ClienteDemo123';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_admin_demo') THEN
        CREATE USER usr_admin_demo WITH PASSWORD 'AdminDemo123';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_superadmin_demo') THEN
        CREATE USER usr_superadmin_demo WITH PASSWORD 'SuperadminDemo123';
    END IF;
END;
$$;

GRANT rol_cliente TO usr_cliente_demo;
GRANT rol_admin TO usr_admin_demo;
GRANT rol_superadmin TO usr_superadmin_demo;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

GRANT EXECUTE ON PROCEDURE cambiar_rol_persona(INT, INT) TO rol_superadmin;
GRANT EXECUTE ON PROCEDURE cambiar_estado_persona(INT, BOOLEAN) TO rol_superadmin;
GRANT EXECUTE ON PROCEDURE registrar_usuario_admin(VARCHAR, VARCHAR, VARCHAR, VARCHAR, CHAR, DATE, INT) TO rol_superadmin;
GRANT EXECUTE ON PROCEDURE refrescar_reportes() TO rol_superadmin;

GRANT SELECT ON
    vw_roles_sistema,
    vw_usuarios_sistema_detalle,
    vw_reporte_general,
    vw_ventas_por_periodo,
    vw_ventas_por_metodo_pago,
    vw_top_productos,
    vw_clientes_mas_compras,
    vw_productos_bajo_stock,
    vw_usuarios_por_rol,
    vw_tablas_auditoria
TO rol_superadmin;

GRANT SELECT ON vw_roles_sistema TO rol_admin;
GRANT SELECT ON vw_roles_sistema TO rol_cliente;
