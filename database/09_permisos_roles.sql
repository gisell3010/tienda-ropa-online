-- =========================================================
-- SCRIPT 09 - PERMISOS DIRECTOS EN BASE DE DATOS
-- Proyecto: Tienda de ropa online
-- =========================================================


-- =========================================================
-- CREACIÓN DE ROLES DE POSTGRESQL
-- =========================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_cliente') THEN
        CREATE ROLE rol_cliente;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_admin') THEN
        CREATE ROLE rol_admin;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_superadmin') THEN
        CREATE ROLE rol_superadmin;
    END IF;
END;
$$;


-- =========================================================
-- USUARIOS POSTGRESQL DE PRUEBA
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


-- =========================================================
-- ASIGNACIÓN DE ROLES
-- =========================================================

GRANT rol_admin TO rol_superadmin;

GRANT rol_cliente TO usr_cliente_demo;
GRANT rol_admin TO usr_admin_demo;
GRANT rol_superadmin TO usr_superadmin_demo;


-- =========================================================
-- REVOCACIÓN DE PERMISOS PÚBLICOS
-- =========================================================

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;



-- =========================================================
-- PERMISOS CLIENTE
-- Consulta por vistas y acciones controladas por procedimientos/funciones
-- =========================================================

GRANT SELECT ON
    vw_catalogo_productos,
    vw_catalogo_productos_detalle,
    vw_perfil_cliente,
    vw_direcciones_cliente,
    vw_pedidos_cliente,
    vw_detalle_pedido_cliente,
    vw_categorias,
    vw_estilos,
    vw_tallas,
    vw_colores,
    vw_metodos_pago,
    vw_departamentos,
    vw_municipios,
    vw_roles_sistema
TO rol_cliente;


GRANT EXECUTE ON PROCEDURE registrar_cliente(
    VARCHAR,
    VARCHAR,
    VARCHAR,
    VARCHAR,
    CHAR,
    DATE
) TO rol_cliente;


GRANT EXECUTE ON PROCEDURE actualizar_perfil_cliente(
    INT,
    VARCHAR,
    VARCHAR,
    CHAR,
    DATE
) TO rol_cliente;


GRANT EXECUTE ON PROCEDURE registrar_direccion_cliente(
    INT,
    CHAR(5),
    VARCHAR
) TO rol_cliente;


GRANT EXECUTE ON PROCEDURE eliminar_direccion_cliente(
    INT,
    INT
) TO rol_cliente;


GRANT EXECUTE ON FUNCTION fn_es_cliente_activo(
    INT
) TO rol_cliente;


GRANT EXECUTE ON FUNCTION fn_total_compras_cliente(
    INT
) TO rol_cliente;


GRANT EXECUTE ON FUNCTION realizar_compra_carrito(
    INT,
    INT,
    INT,
    JSONB
) TO rol_cliente;



-- =========================================================
-- PERMISOS ADMINISTRADOR
-- Administra productos, inventario y operación de la tienda
-- =========================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON
    productos,
    inventarios,
    categorias,
    estilos,
    tallas,
    colores,
    metodos_pago
TO rol_admin;


GRANT SELECT, INSERT, UPDATE ON
    personas,
    direcciones,
    personas_direcciones
TO rol_admin;


GRANT SELECT ON
    departamentos,
    municipios,
    ventas,
    detalle_ventas,
    pagos,
    vw_inventario_simple,
    vw_catalogo_productos_detalle,
    vw_catalogo_productos,
    vw_admin_productos,
    vw_admin_inventario,
    vw_resumen_ventas,
    vw_detalle_ventas_admin,
    vw_usuarios_sistema,
    vw_roles_sistema,
    vw_categorias,
    vw_estilos,
    vw_tallas,
    vw_colores,
    vw_metodos_pago,
    mv_resumen_ventas_productos
TO rol_admin;


GRANT EXECUTE ON PROCEDURE registrar_inventario(
    INT,
    INT,
    INT,
    INT
) TO rol_admin;


GRANT EXECUTE ON PROCEDURE aumentar_stock(
    INT,
    INT
) TO rol_admin;


GRANT EXECUTE ON PROCEDURE registrar_producto(
    VARCHAR,
    NUMERIC,
    TEXT,
    INT,
    INT
) TO rol_admin;


GRANT EXECUTE ON PROCEDURE editar_producto(
    INT,
    VARCHAR,
    NUMERIC,
    TEXT,
    INT,
    INT
) TO rol_admin;


GRANT EXECUTE ON PROCEDURE cambiar_estado_producto(
    INT,
    BOOLEAN
) TO rol_admin;


GRANT EXECUTE ON PROCEDURE actualizar_inventario(
    INT,
    INT
) TO rol_admin;



-- =========================================================
-- PERMISOS SUPERADMINISTRADOR
-- Supervisa, audita, consulta reportes y controla usuarios/roles
-- =========================================================

GRANT SELECT ON
    productos,
    inventarios,
    categorias,
    estilos,
    tallas,
    colores,
    metodos_pago,
    personas,
    direcciones,
    personas_direcciones,
    departamentos,
    municipios,
    ventas,
    detalle_ventas,
    pagos,
    aud_personas,
    aud_productos,
    aud_inventarios,
    aud_ventas,
    aud_detalle_ventas,
    aud_pagos,
    aud_roles,
    aud_categorias,
    aud_estilos,
    aud_tallas,
    aud_colores,
    aud_metodos_pago,
    aud_direcciones,
    aud_personas_direcciones,
    vw_inventario_simple,
    vw_catalogo_productos_detalle,
    vw_catalogo_productos,
    vw_admin_productos,
    vw_admin_inventario,
    vw_resumen_ventas,
    vw_detalle_ventas_admin,
    vw_pedidos_cliente,
    vw_detalle_pedido_cliente,
    vw_roles_sistema,
    vw_usuarios_sistema,
    vw_usuarios_sistema_detalle,
    vw_auditoria_general,
    vw_tablas_auditoria,
    vw_reporte_general,
    vw_ventas_por_periodo,
    vw_ventas_por_metodo_pago,
    vw_top_productos,
    vw_clientes_mas_compras,
    vw_productos_bajo_stock,
    vw_usuarios_por_rol,
    vw_categorias,
    vw_estilos,
    vw_tallas,
    vw_colores,
    vw_metodos_pago,
    mv_resumen_ventas_productos
TO rol_superadmin;


GRANT SELECT, INSERT, UPDATE, DELETE ON
    roles
TO rol_superadmin;


GRANT EXECUTE ON PROCEDURE registrar_usuario_admin(
    VARCHAR,
    VARCHAR,
    VARCHAR,
    VARCHAR,
    CHAR,
    DATE,
    INT
) TO rol_superadmin;


GRANT EXECUTE ON PROCEDURE cambiar_estado_persona(
    INT,
    BOOLEAN
) TO rol_superadmin;


GRANT EXECUTE ON PROCEDURE cambiar_rol_persona(
    INT,
    INT
) TO rol_superadmin;


GRANT EXECUTE ON PROCEDURE refrescar_reportes()
TO rol_superadmin;



-- =========================================================
-- PERMISOS SOBRE SECUENCIAS
-- Necesarios para tablas con SERIAL
-- =========================================================

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public
TO rol_cliente;


GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public
TO rol_admin;


GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public
TO rol_superadmin;