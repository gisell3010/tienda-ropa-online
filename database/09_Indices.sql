-- =========================================================
-- SCRIPT 10 - ÍNDICES
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- ÍNDICE PARA PERSONAS
-- Login y búsqueda de usuario por correo
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_personas_correo
ON personas (correo);


-- =========================================================
-- ÍNDICES PARA PRODUCTOS
-- Filtros del catálogo por categoría y estilo
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_productos_cat_id
ON productos (cat_id);

CREATE INDEX IF NOT EXISTS idx_productos_est_id
ON productos (est_id);


-- =========================================================
-- ÍNDICES PARA INVENTARIOS
-- Consultas por producto, talla y color
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_inventarios_pro_id
ON inventarios (pro_id);

CREATE INDEX IF NOT EXISTS idx_inventarios_tal_id
ON inventarios (tal_id);

CREATE INDEX IF NOT EXISTS idx_inventarios_col_id
ON inventarios (col_id);


-- =========================================================
-- ÍNDICES PARA VENTAS
-- Consultas por cliente y fecha
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_ventas_per_id
ON ventas (per_id);

CREATE INDEX IF NOT EXISTS idx_ventas_fecha
ON ventas (fecha);


-- =========================================================
-- ÍNDICES PARA DETALLE_VENTAS
-- JOIN con ventas e inventarios
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_ven_id
ON detalle_ventas (ven_id);

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_inv_id
ON detalle_ventas (inv_id);


-- =========================================================
-- ÍNDICES PARA PAGOS
-- JOIN con ventas y métodos de pago
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_pagos_ven_id
ON pagos (ven_id);

CREATE INDEX IF NOT EXISTS idx_pagos_met_id
ON pagos (met_id);

-- =========================================================
-- ÍNDICES ADMINISTRATIVOS
-- Búsquedas, filtros, stock bajo, pedidos y pagos
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_productos_nombre_normalizado
ON productos (LOWER(TRIM(nombre)));

CREATE INDEX IF NOT EXISTS idx_productos_admin_filtros
ON productos (activo, cat_id, est_id);

CREATE INDEX IF NOT EXISTS idx_inventarios_stock
ON inventarios (stock);

CREATE INDEX IF NOT EXISTS idx_inventarios_activo_stock
ON inventarios (activo, stock);

CREATE INDEX IF NOT EXISTS idx_inventarios_producto_stock
ON inventarios (pro_id, stock);

CREATE INDEX IF NOT EXISTS idx_ventas_estado_fecha
ON ventas (estado, fecha);

CREATE INDEX IF NOT EXISTS idx_pagos_metodo_fecha
ON pagos (met_id, fecha);

CREATE INDEX IF NOT EXISTS idx_aud_catalogos_tabla_fecha
ON aud_catalogos_parametricos (tabla, fecha_cambio);