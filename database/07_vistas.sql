-- =========================================================
-- SCRIPT 07 - VISTAS
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- VISTA SIMPLE: INVENTARIO
-- =========================================================

CREATE OR REPLACE VIEW vw_inventario_simple AS
SELECT
    inv_id,
    pro_id,
    stock
FROM inventarios;


-- =========================================================
-- VISTA COMPLEJA: CATÁLOGO DETALLADO DE PRODUCTOS
-- Muestra producto por talla y color
-- =========================================================

CREATE OR REPLACE VIEW vw_catalogo_productos_detalle AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    p.imagen_url,
    p.activo,
    c.nombre AS categoria,
    e.nombre AS estilo,
    i.inv_id,
    t.nombre AS talla,
    co.nombre AS color,
    i.stock,
    fn_estado_producto(i.stock) AS estado_producto,
    CASE WHEN i.stock <= 0 THEN FALSE ELSE TRUE END AS permite_interaccion
FROM productos p
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
INNER JOIN inventarios i ON i.pro_id = p.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id
WHERE p.activo = TRUE;



-- =========================================================
-- VISTA COMPLEJA: CATÁLOGO GENERAL
-- Una fila por producto
-- Solo muestra tallas y colores con stock disponible
-- =========================================================

CREATE OR REPLACE VIEW vw_catalogo_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    p.imagen_url,
    p.activo,
    c.nombre AS categoria,
    e.nombre AS estilo,
    COALESCE(SUM(i.stock), 0) AS stock_total,
    COALESCE(
        STRING_AGG(DISTINCT t.nombre, ', ') FILTER (WHERE i.stock > 0),
        'Sin tallas disponibles'
    ) AS tallas_disponibles,
    COALESCE(
        STRING_AGG(DISTINCT co.nombre, ', ') FILTER (WHERE i.stock > 0),
        'Sin colores disponibles'
    ) AS colores_disponibles,
    fn_estado_producto(COALESCE(SUM(i.stock), 0)::INT) AS estado_producto,
    CASE WHEN COALESCE(SUM(i.stock), 0) <= 0 THEN FALSE ELSE TRUE END AS permite_interaccion
FROM productos p
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
LEFT JOIN inventarios i ON i.pro_id = p.pro_id
LEFT JOIN tallas t ON t.tal_id = i.tal_id
LEFT JOIN colores co ON co.col_id = i.col_id
WHERE p.activo = TRUE
GROUP BY
    p.pro_id,
    p.nombre,
    p.precio,
    p.imagen_url,
    p.activo,
    c.nombre,
    e.nombre;


-- =========================================================
-- VISTA ADMINISTRATIVA: PRODUCTOS
-- Muestra productos activos e inactivos
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    p.imagen_url,
    p.activo,
    p.cat_id,
    c.nombre AS categoria,
    p.est_id,
    e.nombre AS estilo
FROM productos p
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id;

-- =========================================================
-- VISTA ADMINISTRATIVA: INVENTARIO
-- Muestra stock, talla y color para el panel administrador
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_inventario AS
SELECT
    i.inv_id,
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    p.imagen_url,
    p.activo,
    p.cat_id,
    c.nombre AS categoria,
    p.est_id,
    e.nombre AS estilo,
    i.tal_id,
    t.nombre AS talla,
    i.col_id,
    co.nombre AS color,
    COALESCE(i.stock, 0) AS stock,
    fn_estado_producto(COALESCE(i.stock, 0)) AS estado_producto
FROM inventarios i
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id;


-- =========================================================
-- VISTA: RESUMEN DE VENTAS
-- Incluye método de pago y monto pagado
-- =========================================================

CREATE OR REPLACE VIEW vw_resumen_ventas AS
SELECT
    v.ven_id,
    p.per_id,
    p.nombre AS cliente,
    r.nombre AS rol,
    v.fecha,
    COALESCE(mp.nombre, 'Sin método de pago') AS metodo_pago,
    COALESCE(pa.monto, 0) AS monto_pagado,
    COALESCE(SUM(d.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_venta
FROM ventas v
INNER JOIN personas p ON p.per_id = v.per_id
INNER JOIN roles r ON r.rol_id = p.rol_id
LEFT JOIN detalle_ventas d ON d.ven_id = v.ven_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
LEFT JOIN metodos_pago mp ON mp.met_id = pa.met_id
GROUP BY
    v.ven_id,
    p.per_id,
    p.nombre,
    r.nombre,
    v.fecha,
    mp.nombre,
    pa.monto;

-- =========================================================
-- VISTAS PARAMÉTRICAS
-- =========================================================

CREATE OR REPLACE VIEW vw_categorias AS
SELECT
    cat_id AS id,
    nombre
FROM categorias
ORDER BY nombre;

CREATE OR REPLACE VIEW vw_estilos AS
SELECT
    est_id AS id,
    nombre
FROM estilos
ORDER BY nombre;

CREATE OR REPLACE VIEW vw_tallas AS
SELECT
    tal_id AS id,
    nombre
FROM tallas
ORDER BY tal_id;

CREATE OR REPLACE VIEW vw_colores AS
SELECT
    col_id AS id,
    nombre
FROM colores
ORDER BY nombre;

CREATE OR REPLACE VIEW vw_metodos_pago AS
SELECT
    met_id AS id,
    nombre
FROM metodos_pago
ORDER BY nombre;

-- =========================================================
-- VISTA: DETALLE DE VENTAS PARA ADMIN
-- =========================================================

CREATE OR REPLACE VIEW vw_detalle_ventas_admin AS
SELECT
    v.ven_id,
    v.fecha,
    pe.per_id,
    pe.nombre AS cliente,
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    i.inv_id,
    t.nombre AS talla,
    co.nombre AS color,
    d.cantidad,
    d.precio_unitario,
    d.cantidad * d.precio_unitario AS subtotal,
    COALESCE(mp.nombre, 'Sin método de pago') AS metodo_pago,
    COALESCE(pa.monto, 0) AS monto_pagado
FROM detalle_ventas d
INNER JOIN ventas v ON v.ven_id = d.ven_id
INNER JOIN personas pe ON pe.per_id = v.per_id
INNER JOIN inventarios i ON i.inv_id = d.inv_id
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
LEFT JOIN metodos_pago mp ON mp.met_id = pa.met_id;


-- =========================================================
-- VISTA: PEDIDOS DEL CLIENTE
-- =========================================================

CREATE OR REPLACE VIEW vw_pedidos_cliente AS
SELECT
    v.ven_id,
    v.per_id,
    pe.nombre AS cliente,
    v.fecha,
    COALESCE(mp.nombre, 'Sin método de pago') AS metodo_pago,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_venta,
    COALESCE(pa.monto, 0) AS total_pagado
FROM ventas v
INNER JOIN personas pe ON pe.per_id = v.per_id
LEFT JOIN detalle_ventas d ON d.ven_id = v.ven_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
LEFT JOIN metodos_pago mp ON mp.met_id = pa.met_id
GROUP BY
    v.ven_id,
    v.per_id,
    pe.nombre,
    v.fecha,
    mp.nombre,
    pa.monto;


-- =========================================================
-- VISTA: DETALLE DEL PEDIDO DEL CLIENTE
-- =========================================================

CREATE OR REPLACE VIEW vw_detalle_pedido_cliente AS
SELECT
    v.ven_id,
    v.fecha,
    v.per_id,
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    i.inv_id,
    t.nombre AS talla,
    co.nombre AS color,
    d.cantidad,
    d.precio_unitario,
    d.cantidad * d.precio_unitario AS subtotal
FROM detalle_ventas d
INNER JOIN ventas v ON v.ven_id = d.ven_id
INNER JOIN inventarios i ON i.inv_id = d.inv_id
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id;




-- =========================================================
-- VISTA: USUARIOS DEL SISTEMA
-- =========================================================

CREATE OR REPLACE VIEW vw_usuarios_sistema AS
SELECT
    p.per_id,
    p.nombre,
    p.telefono,
    p.correo,
    p.genero,
    p.fecha_nacimiento,
    p.activo,
    r.nombre AS rol
FROM personas p
INNER JOIN roles r ON r.rol_id = p.rol_id;


-- =========================================================
-- VISTA: AUDITORÍA GENERAL
-- =========================================================

CREATE OR REPLACE VIEW vw_auditoria_general AS
SELECT 'personas' AS tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_personas
UNION ALL
SELECT 'productos' AS tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_productos
UNION ALL
SELECT 'inventarios' AS tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_inventarios
UNION ALL
SELECT 'ventas' AS tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_ventas
UNION ALL
SELECT 'detalle_ventas' AS tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_detalle_ventas
UNION ALL
SELECT 'pagos' AS tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_pagos;

-- =========================================================
-- VISTA MATERIALIZADA: RESUMEN DE VENTAS POR PRODUCTO
-- =========================================================

CREATE MATERIALIZED VIEW mv_resumen_ventas_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    COUNT(d.det_id) AS veces_vendido,
    COALESCE(SUM(d.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_generado
FROM productos p
LEFT JOIN inventarios i ON i.pro_id = p.pro_id
LEFT JOIN detalle_ventas d ON d.inv_id = i.inv_id
GROUP BY
    p.pro_id,
    p.nombre,
    p.imagen_url;
