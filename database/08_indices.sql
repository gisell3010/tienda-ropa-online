-- =========================================================
-- SCRIPT 08 - ÍNDICES
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- ÍNDICES GENERALES DEL SISTEMA
-- Usados por cliente, administrador y superadministrador
-- =========================================================

-- =========================================================
-- 1. BÚSQUEDA DE USUARIOS POR CORREO
-- Se usa en registro, login, validaciones de usuarios y consultas
-- de administración/superadministración.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_correo_normalizado
ON personas (LOWER(TRIM(correo)));


-- =========================================================
-- 2. MUNICIPIOS POR DEPARTAMENTO
-- Se usa cuando el frontend carga municipios después de seleccionar
-- un departamento. Aplica principalmente al cliente, pero también
-- puede ser usado por otros formularios del sistema.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_municipios_departamento
ON municipios (dep_id);


-- =========================================================
-- 3. VENTAS POR FECHA
-- Se usa en reportes, consultas administrativas y estadísticas
-- generales del sistema.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_ventas_fecha
ON ventas (fecha);


-- =========================================================
-- 4. DETALLE DE VENTAS POR VENTA
-- Mejora los JOIN entre ventas y detalle_ventas.
-- Se usa en historial del cliente, pedidos del administrador
-- y reportes del superadministrador.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_ven_id
ON detalle_ventas (ven_id);


-- =========================================================
-- 5. DETALLE DE VENTAS POR INVENTARIO
-- Mejora consultas que relacionan productos vendidos con inventario.
-- Se usa en reportes, pedidos y análisis de productos vendidos.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_inv_id
ON detalle_ventas (inv_id);


-- =========================================================
-- ÍNDICES DEL CLIENTE
-- Catálogo, direcciones, compra e historial de pedidos
-- =========================================================

-- =========================================================
-- 6. CATÁLOGO DEL CLIENTE
-- Mejora la consulta de productos activos por categoría y estilo.
-- Se usa en vistas como vw_catalogo_productos y
-- vw_catalogo_productos_detalle.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_productos_catalogo_cliente
ON productos (activo, cat_id, est_id);


-- =========================================================
-- 7. BÚSQUEDA DE PRODUCTOS POR NOMBRE
-- Útil si el cliente busca productos por texto en el catálogo.
-- Ejemplo: buscar "camiseta", "jean", "hoodie".
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_productos_nombre_cliente
ON productos (LOWER(TRIM(nombre)));


-- =========================================================
-- 8. DIRECCIONES DEL CLIENTE
-- Evita direcciones físicas duplicadas para el mismo municipio.
-- Ejemplo: no permite registrar varias veces "Calle 8"
-- en el mismo municipio.
--
-- Esta regla complementa el procedimiento registrar_direccion_cliente,
-- que primero busca si la dirección ya existe antes de insertarla.
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS uq_direcciones_municipio_linea_cliente
ON direcciones (mun_id, LOWER(TRIM(linea)));


-- =========================================================
-- 9. RELACIÓN CLIENTE - DIRECCIÓN POR CLIENTE
-- Mejora la consulta de direcciones registradas por un cliente.
-- Se usa en vw_direcciones_cliente.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_direcciones_per_id
ON personas_direcciones (per_id);


-- =========================================================
-- 10. RELACIÓN CLIENTE - DIRECCIÓN POR DIRECCIÓN
-- Mejora validaciones de eliminación de direcciones y consultas
-- de relación entre personas y direcciones.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_direcciones_dir_id
ON personas_direcciones (dir_id);


-- =========================================================
-- 11. HISTORIAL DE PEDIDOS DEL CLIENTE
-- Mejora consultas como:
-- "ver mis pedidos ordenados por fecha".
-- Se usa en vw_pedidos_cliente.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_ventas_cliente_fecha
ON ventas (per_id, fecha DESC);


-- =========================================================
-- ÍNDICES DEL ADMINISTRADOR
-- Gestión de productos, inventario, pedidos y pagos
-- =========================================================

-- =========================================================
-- 12. INVENTARIO POR PRODUCTO
-- Mejora consultas administrativas para ver o actualizar
-- existencias de un producto.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_producto
ON inventarios (pro_id);


-- =========================================================
-- 13. INVENTARIO POR TALLA Y COLOR
-- Mejora búsquedas de combinaciones específicas de inventario.
-- Ejemplo: producto en talla M y color negro.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_talla_color
ON inventarios (tal_id, col_id);


-- =========================================================
-- 14. INVENTARIO POR STOCK
-- Ayuda a consultar productos agotados o con bajo stock.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_stock
ON inventarios (stock);


-- =========================================================
-- 15. PAGOS POR MÉTODO DE PAGO
-- Mejora consultas administrativas y reportes de pagos
-- agrupados por método.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pagos_met_id
ON pagos (met_id);


-- =========================================================
-- 16. PAGOS POR VENTA
-- Mejora consultas que relacionan ventas con pagos registrados.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pagos_ven_id
ON pagos (ven_id);


-- =========================================================
-- ÍNDICES DEL SUPERADMINISTRADOR
-- Usuarios, roles, auditoría y reportes generales
-- =========================================================

-- =========================================================
-- 17. USUARIOS POR ROL Y ESTADO
-- Mejora consultas del panel de superadministrador para listar
-- usuarios por rol y filtrar usuarios activos o inactivos.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_rol_activo
ON personas (rol_id, activo);


-- =========================================================
-- 18. USUARIOS POR ESTADO
-- Mejora reportes generales de usuarios activos/inactivos.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_activo
ON personas (activo);


-- =========================================================
-- 19. ROLES POR NOMBRE
-- Mejora validaciones y búsquedas de roles por nombre.
-- Ejemplo: CLIENTE, ADMIN, SUPERADMIN.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_roles_nombre_normalizado
ON roles (LOWER(TRIM(nombre)));