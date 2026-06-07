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
    p.activo,
    c.nombre AS categoria,
    e.nombre AS estilo,
    i.inv_id,
    t.nombre AS talla,
    co.nombre AS color,
    i.stock,
    fn_estado_producto(i.stock) AS estado_producto,
    CASE
        WHEN i.stock = 0 THEN FALSE
        ELSE TRUE
    END AS permite_interaccion
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
-- =========================================================

CREATE OR REPLACE VIEW vw_catalogo_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    p.activo,
    c.nombre AS categoria,
    e.nombre AS estilo,
    COALESCE(SUM(i.stock), 0) AS stock_total,
    STRING_AGG(DISTINCT t.nombre, ', ') AS tallas_disponibles,
    STRING_AGG(DISTINCT co.nombre, ', ') AS colores_disponibles,
    fn_estado_producto(COALESCE(SUM(i.stock), 0)::INT) AS estado_producto,
    CASE
        WHEN COALESCE(SUM(i.stock), 0) = 0 THEN FALSE
        ELSE TRUE
    END AS permite_interaccion
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
    p.activo,
    c.nombre,
    e.nombre;

-- =========================================================
-- VISTA: ADMINISTRATIVA
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    p.activo,
    c.nombre AS categoria,
    e.nombre AS estilo
FROM productos p
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id;


-- =========================================================
-- VISTA: RESUMEN DE VENTAS
-- =========================================================

CREATE OR REPLACE VIEW vw_resumen_ventas AS
SELECT
    v.ven_id,
    p.nombre AS cliente,
    r.nombre AS rol,
    v.fecha,
    COALESCE(SUM(d.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_venta
FROM ventas v
INNER JOIN personas p ON p.per_id = v.per_id
INNER JOIN roles r ON r.rol_id = p.rol_id
LEFT JOIN detalle_ventas d ON d.ven_id = v.ven_id
GROUP BY
    v.ven_id,
    p.nombre,
    r.nombre,
    v.fecha;


-- =========================================================
-- VISTA MATERIALIZADA: RESUMEN DE VENTAS POR PRODUCTO
-- =========================================================

DROP MATERIALIZED VIEW IF EXISTS mv_resumen_ventas_productos;

CREATE MATERIALIZED VIEW mv_resumen_ventas_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    COUNT(d.det_id) AS veces_vendido,
    COALESCE(SUM(d.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_generado
FROM productos p
LEFT JOIN inventarios i ON i.pro_id = p.pro_id
LEFT JOIN detalle_ventas d ON d.inv_id = i.inv_id
GROUP BY
    p.pro_id,
    p.nombre;