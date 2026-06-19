-- =========================================================
-- SCRIPT 08 - PERMISOS DIRECTOS EN BASE DE DATOS
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
-- PERMISOS CLIENTE
-- Consulta catálogo, datos paramétricos y compra controlada
-- =========================================================

GRANT SELECT ON
    vw_catalogo_productos,
    vw_catalogo_productos_detalle,
    vw_pedidos_cliente,
    vw_detalle_pedido_cliente,
    vw_categorias,
    vw_estilos,
    vw_tallas,
    vw_colores,
    vw_metodos_pago,
    vw_param_categorias,
    vw_param_estilos,
    vw_param_tallas,
    vw_param_colores,
    vw_param_metodos_pago,
    metodos_pago,
    departamentos,
    municipios
TO rol_cliente;

GRANT EXECUTE ON PROCEDURE registrar_cliente(
    VARCHAR,
    VARCHAR,
    VARCHAR,
    VARCHAR,
    CHAR,
    DATE
) TO rol_cliente;

GRANT EXECUTE ON FUNCTION realizar_compra_carrito(
    INT,
    INT,
    JSONB
) TO rol_cliente;


-- =========================================================
-- PERMISOS ADMIN
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
    vw_categorias,
    vw_estilos,
    vw_tallas,
    vw_colores,
    vw_metodos_pago,
    vw_param_categorias,
    vw_param_estilos,
    vw_param_tallas,
    vw_param_colores,
    vw_param_metodos_pago,
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
-- PERMISOS SUPERADMIN
-- Supervisa, audita y controla roles
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
    vw_inventario_simple,
    vw_catalogo_productos_detalle,
    vw_catalogo_productos,
    vw_admin_productos,
    vw_admin_inventario,
    vw_resumen_ventas,
    vw_detalle_ventas_admin,
    vw_pedidos_cliente,
    vw_detalle_pedido_cliente,
    vw_usuarios_sistema,
    vw_auditoria_general,
    vw_categorias,
    vw_estilos,
    vw_tallas,
    vw_colores,
    vw_metodos_pago,
    vw_param_categorias,
    vw_param_estilos,
    vw_param_tallas,
    vw_param_colores,
    vw_param_metodos_pago,
    mv_resumen_ventas_productos
TO rol_superadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON
    roles
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