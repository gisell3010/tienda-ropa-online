-- =========================================================
-- SCRIPT 09 - PERMISOS DIRECTOS EN BASE DE DATOS
-- Proyecto: Tienda de ropa online
-- =========================================================

-- Roles de PostgreSQL
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
-- CLIENTE
-- Consulta catálogo y compra mediante procedimiento
-- =========================================================

-- =========================================================
-- PERMISOS CLIENTE
-- =========================================================

-- Solo consulta catálogo y datos necesarios para comprar
GRANT SELECT ON
    vw_catalogo_productos,
    vw_catalogo_productos_detalle,
    metodos_pago,
    departamentos,
    municipios
TO rol_cliente;

-- Solo puede ejecutar registro y compra controlada
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
-- ADMIN
-- Administra la operación de la tienda
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
    pagos
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

-- =========================================================
-- SUPERADMIN
-- Supervisa y audita
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
    pagos
TO rol_superadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON roles
TO rol_superadmin;

GRANT SELECT ON
    aud_personas,
    aud_productos,
    aud_inventarios,
    aud_ventas,
    aud_detalle_ventas,
    aud_pagos
TO rol_superadmin;

-- =========================================================
-- SECUENCIAS
-- Necesarias para tablas con SERIAL
-- =========================================================

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_cliente;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO rol_admin;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO rol_superadmin;

-- =========================================================
-- PERMISOS SOBRE VISTAS
-- =========================================================

-- Cliente: solo consulta catálogo e información necesaria para comprar
GRANT SELECT ON
    vw_inventario_simple,
    vw_catalogo_productos_detalle,
    vw_catalogo_productos
TO rol_cliente;

-- Administrador: consulta vistas operativas y administrativas
GRANT SELECT ON
    vw_inventario_simple,
    vw_catalogo_productos_detalle,
    vw_catalogo_productos,
    vw_admin_productos,
    vw_admin_inventario,
    vw_resumen_ventas,
    mv_resumen_ventas_productos
TO rol_admin;

-- Superadmin: consulta vistas administrativas, reportes y auditoría
GRANT SELECT ON
    vw_inventario_simple,
    vw_catalogo_productos_detalle,
    vw_catalogo_productos,
    vw_admin_productos,
    vw_admin_inventario,
    vw_resumen_ventas,
    mv_resumen_ventas_productos
TO rol_superadmin;