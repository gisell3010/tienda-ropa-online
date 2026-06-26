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
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_correo_normalizado
ON personas (LOWER(TRIM(correo)));


-- =========================================================
-- 2. MUNICIPIOS POR DEPARTAMENTO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_municipios_departamento
ON municipios (dep_id);


-- =========================================================
-- 3. VENTAS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_ventas_fecha
ON ventas (fecha);


-- =========================================================
-- 4. DETALLE DE VENTAS POR VENTA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_ven_id
ON detalle_ventas (ven_id);


-- =========================================================
-- 5. DETALLE DE VENTAS POR INVENTARIO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_inv_id
ON detalle_ventas (inv_id);



-- =========================================================
-- ÍNDICES DEL CLIENTE
-- Catálogo, direcciones, compra e historial de pedidos
-- =========================================================

-- =========================================================
-- 6. CATÁLOGO DEL CLIENTE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_productos_catalogo_cliente
ON productos (activo, cat_id, est_id);


-- =========================================================
-- 7. BÚSQUEDA DE PRODUCTOS POR NOMBRE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_productos_nombre_cliente
ON productos (LOWER(TRIM(nombre)));


-- =========================================================
-- 8. DIRECCIONES DEL CLIENTE
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS uq_direcciones_municipio_linea_cliente
ON direcciones (mun_id, LOWER(TRIM(linea)));


-- =========================================================
-- 9. RELACIÓN CLIENTE - DIRECCIÓN POR CLIENTE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_direcciones_per_id
ON personas_direcciones (per_id);


-- =========================================================
-- 10. RELACIÓN CLIENTE - DIRECCIÓN POR DIRECCIÓN
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_direcciones_dir_id
ON personas_direcciones (dir_id);


-- =========================================================
-- 11. HISTORIAL DE PEDIDOS DEL CLIENTE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_ventas_cliente_fecha
ON ventas (per_id, fecha DESC);



-- =========================================================
-- ÍNDICES DEL ADMINISTRADOR
-- Gestión de productos, inventario, pedidos y pagos
-- =========================================================

-- =========================================================
-- 12. INVENTARIO POR PRODUCTO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_producto
ON inventarios (pro_id);


-- =========================================================
-- 13. INVENTARIO POR TALLA Y COLOR
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_talla_color
ON inventarios (tal_id, col_id);


-- =========================================================
-- 14. INVENTARIO POR STOCK
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_stock
ON inventarios (stock);


-- =========================================================
-- 15. PAGOS POR MÉTODO DE PAGO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pagos_met_id
ON pagos (met_id);


-- =========================================================
-- 16. PAGOS POR VENTA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pagos_ven_id
ON pagos (ven_id);



-- =========================================================
-- ÍNDICES DEL SUPERADMINISTRADOR
-- Usuarios, roles, auditoría y reportes generales
-- =========================================================

-- =========================================================
-- 17. USUARIOS POR ROL Y ESTADO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_rol_activo
ON personas (rol_id, activo);


-- =========================================================
-- 18. USUARIOS POR ESTADO
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_activo
ON personas (activo);


-- =========================================================
-- 19. ROLES POR NOMBRE
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_roles_nombre_normalizado
ON roles (LOWER(TRIM(nombre)));


-- =========================================================
-- 20. AUDITORÍA DE PERSONAS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_aud_personas_fecha
ON aud_personas (fecha_cambio);


-- =========================================================
-- 21. AUDITORÍA DE PRODUCTOS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_aud_productos_fecha
ON aud_productos (fecha_cambio);


-- =========================================================
-- 22. AUDITORÍA DE INVENTARIOS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_aud_inventarios_fecha
ON aud_inventarios (fecha_cambio);


-- =========================================================
-- 23. AUDITORÍA DE VENTAS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_aud_ventas_fecha
ON aud_ventas (fecha_cambio);


-- =========================================================
-- 24. AUDITORÍA DE DETALLE DE VENTAS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_aud_detalle_ventas_fecha
ON aud_detalle_ventas (fecha_cambio);


-- =========================================================
-- 25. AUDITORÍA DE PAGOS POR FECHA
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_aud_pagos_fecha
ON aud_pagos (fecha_cambio);