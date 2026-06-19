-- =========================================================
-- SCRIPT 10 - ÍNDICES 
-- Proyecto: Tienda de ropa online
-- =========================================================

-- Login y búsqueda de usuario
CREATE INDEX IF NOT EXISTS idx_personas_correo
ON personas (correo);

-- Catálogo por categoría y estilo
CREATE INDEX IF NOT EXISTS idx_productos_cat_id
ON productos (cat_id);

CREATE INDEX IF NOT EXISTS idx_productos_est_id
ON productos (est_id);

-- Inventario por producto, talla y color
CREATE INDEX IF NOT EXISTS idx_inventarios_pro_id
ON inventarios (pro_id);

CREATE INDEX IF NOT EXISTS idx_inventarios_tal_id
ON inventarios (tal_id);

CREATE INDEX IF NOT EXISTS idx_inventarios_col_id
ON inventarios (col_id);

-- Ventas por cliente y fecha
CREATE INDEX IF NOT EXISTS idx_ventas_per_id
ON ventas (per_id);

CREATE INDEX IF NOT EXISTS idx_ventas_fecha
ON ventas (fecha);

-- Detalle de ventas para JOIN con ventas e inventarios
CREATE INDEX IF NOT EXISTS idx_detalle_ventas_ven_id
ON detalle_ventas (ven_id);

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_inv_id
ON detalle_ventas (inv_id);

-- Pagos por venta
CREATE INDEX IF NOT EXISTS idx_pagos_ven_id
ON pagos (ven_id);