-- =========================================================
-- VISTA SIMPLE: INVENTARIO
-- =========================================================

CREATE OR REPLACE VIEW vw_inventario_simple AS
SELECT
|    inv_id,
    pro_id,
    stock
FROM inventarios;

-- Llamado
SELECT * FROM vw_inventario_simple;


-- =========================================================
-- VISTA COMPLEJA: CATÁLOGO DE PRODUCTOS
-- =========================================================

CREATE OR REPLACE VIEW vw_catalogo_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
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
INNER JOIN colores co ON co.col_id = i.col_id;

-- Llamados
SELECT * FROM vw_catalogo_productos;

SELECT *
FROM vw_catalogo_productos
WHERE estado_producto = 'AGOTADO';

SELECT *
FROM vw_catalogo_productos
WHERE permite_interaccion = TRUE;


-- =========================================================
-- VISTA DE SEGURIDAD: VENTAS
-- =========================================================

CREATE OR REPLACE VIEW vw_seguridad_ventas AS
SELECT
    v.ven_id,
    p.nombre AS cliente,
    r.nombre AS rol,
    v.fecha,
    COUNT(d.det_id) AS cantidad_productos,
    SUM(d.cantidad * d.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN personas p ON p.per_id = v.per_id
INNER JOIN roles r ON r.rol_id = p.rol_id
INNER JOIN detalle_ventas d ON d.ven_id = v.ven_id
GROUP BY
    v.ven_id,
    p.nombre,
    r.nombre,
    v.fecha;

-- Llamados
SELECT * FROM vw_seguridad_ventas;

SELECT *
FROM vw_seguridad_ventas
ORDER BY total_venta DESC;


-- =========================================================
-- VISTA MATERIALIZADA: RESUMEN DE VENTAS POR PRODUCTO
-- =========================================================

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

-- Llamados
SELECT * FROM mv_resumen_ventas_productos;

REFRESH MATERIALIZED VIEW mv_resumen_ventas_productos;