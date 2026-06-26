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
-- VISTA ADMIN: STOCK BAJO
-- Muestra inventarios con stock menor o igual a 5
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_stock_bajo AS
SELECT
    i.inv_id,
    p.pro_id,
    p.nombre AS producto,
    c.nombre AS categoria,
    e.nombre AS estilo,
    t.nombre AS talla,
    co.nombre AS color,
    i.stock,
    i.activo,
    CASE
        WHEN i.stock = 0 THEN 'AGOTADO'
        WHEN i.stock <= 5 THEN 'BAJO STOCK'
        ELSE 'DISPONIBLE'
    END AS estado_stock
FROM inventarios i
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id
WHERE i.activo = TRUE
  AND p.activo = TRUE
  AND i.stock <= 5
ORDER BY i.stock ASC, p.nombre;


-- =========================================================
-- VISTA: RESUMEN DE VENTAS
-- Incluye método de pago y monto pagado
-- =========================================================

CREATE OR REPLACE VIEW vw_resumen_ventas AS
SELECT
    v.ven_id,
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
    p.nombre,
    r.nombre,
    v.fecha,
    mp.nombre,
    pa.monto;

    -- =========================================================
-- VISTA ADMIN: PEDIDOS
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_pedidos AS
SELECT
    v.ven_id,
    v.per_id,
    pe.nombre AS cliente,
    pe.correo,
    v.fecha,
    v.estado,
    COALESCE(mp.nombre, 'Sin método de pago') AS metodo_pago,
    COALESCE(pa.monto, fn_total_venta(v.ven_id)) AS total,
    COALESCE(SUM(d.cantidad), 0) AS unidades
FROM ventas v
INNER JOIN personas pe ON pe.per_id = v.per_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
LEFT JOIN metodos_pago mp ON mp.met_id = pa.met_id
LEFT JOIN detalle_ventas d ON d.ven_id = v.ven_id
GROUP BY
    v.ven_id,
    v.per_id,
    pe.nombre,
    pe.correo,
    v.fecha,
    v.estado,
    mp.nombre,
    pa.monto
ORDER BY v.fecha DESC, v.ven_id DESC;

-- =========================================================
-- VISTA ADMIN: PAGOS
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_pagos AS
SELECT
    pa.pag_id,
    pa.ven_id,
    v.per_id,
    pe.nombre AS cliente,
    pe.correo,
    pa.met_id,
    mp.nombre AS metodo_pago,
    pa.monto,
    pa.fecha,
    v.estado AS estado_pedido
FROM pagos pa
INNER JOIN ventas v ON v.ven_id = pa.ven_id
INNER JOIN personas pe ON pe.per_id = v.per_id
INNER JOIN metodos_pago mp ON mp.met_id = pa.met_id
ORDER BY pa.fecha DESC, pa.pag_id DESC;

-- =========================================================
-- VISTA ADMIN: VENTAS DEL DÍA
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_ventas_dia AS
SELECT
    CURRENT_DATE AS fecha,
    COUNT(DISTINCT v.ven_id) AS total_pedidos,
    COALESCE(SUM(pa.monto), 0) AS total_vendido
FROM ventas v
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
WHERE v.fecha = CURRENT_DATE;


-- =========================================================
-- VISTA ADMIN: VENTAS POR MÉTODO DE PAGO
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_ventas_metodo_pago AS
SELECT
    mp.met_id,
    mp.nombre AS metodo_pago,
    COUNT(pa.pag_id) AS cantidad_pagos,
    COALESCE(SUM(pa.monto), 0) AS total_recaudado
FROM metodos_pago mp
LEFT JOIN pagos pa ON pa.met_id = mp.met_id
GROUP BY mp.met_id, mp.nombre
ORDER BY total_recaudado DESC;


-- =========================================================
-- VISTA ADMIN: PEDIDOS POR ESTADO
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_pedidos_estado AS
SELECT
    estado,
    COUNT(*) AS cantidad_pedidos
FROM ventas
GROUP BY estado
ORDER BY estado;


-- =========================================================
-- VISTA ADMIN: PRODUCTOS AGOTADOS
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_productos_agotados AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    c.nombre AS categoria,
    e.nombre AS estilo,
    COALESCE(SUM(i.stock), 0) AS stock_total
FROM productos p
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
LEFT JOIN inventarios i ON i.pro_id = p.pro_id
                    AND i.activo = TRUE
WHERE p.activo = TRUE
GROUP BY p.pro_id, p.nombre, c.nombre, e.nombre
HAVING COALESCE(SUM(i.stock), 0) = 0
ORDER BY p.nombre;


-- =========================================================
-- VISTA ADMIN: RESUMEN OPERATIVO
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_resumen_operativo AS
SELECT
    (SELECT COUNT(*) FROM productos WHERE activo = TRUE) AS productos_activos,
    (SELECT COUNT(*) FROM inventarios WHERE activo = TRUE AND stock = 0) AS inventarios_agotados,
    (SELECT COUNT(*) FROM inventarios WHERE activo = TRUE AND stock BETWEEN 1 AND 5) AS inventarios_bajo_stock,
    (SELECT COUNT(*) FROM ventas WHERE fecha = CURRENT_DATE) AS pedidos_hoy,
    (SELECT COALESCE(SUM(monto), 0) FROM pagos WHERE fecha = CURRENT_DATE) AS ventas_hoy;

-- =========================================================
-- VISTAS PARAMÉTRICAS
-- =========================================================

CREATE OR REPLACE VIEW vw_param_categorias AS
SELECT cat_id, nombre
FROM categorias
WHERE activo = TRUE
ORDER BY nombre;

CREATE OR REPLACE VIEW vw_param_estilos AS
SELECT est_id, nombre
FROM estilos
WHERE activo = TRUE
ORDER BY nombre;

CREATE OR REPLACE VIEW vw_param_tallas AS
SELECT tal_id, nombre
FROM tallas
WHERE activo = TRUE
ORDER BY tal_id;

CREATE OR REPLACE VIEW vw_param_colores AS
SELECT col_id, nombre
FROM colores
WHERE activo = TRUE
ORDER BY nombre;

CREATE OR REPLACE VIEW vw_param_metodos_pago AS
SELECT met_id, nombre
FROM metodos_pago
WHERE activo = TRUE
ORDER BY nombre;

-- =========================================================
-- VISTAS ADMIN: CATÁLOGOS PARAMÉTRICOS
-- =========================================================

CREATE OR REPLACE VIEW vw_admin_categorias AS
SELECT
    c.cat_id,
    c.nombre,
    c.activo,
    COUNT(p.pro_id) AS cantidad_productos
FROM categorias c
LEFT JOIN productos p ON p.cat_id = c.cat_id
GROUP BY c.cat_id, c.nombre, c.activo
ORDER BY c.nombre;


CREATE OR REPLACE VIEW vw_admin_estilos AS
SELECT
    e.est_id,
    e.nombre,
    e.activo,
    COUNT(p.pro_id) AS cantidad_productos
FROM estilos e
LEFT JOIN productos p ON p.est_id = e.est_id
GROUP BY e.est_id, e.nombre, e.activo
ORDER BY e.nombre;


CREATE OR REPLACE VIEW vw_admin_tallas AS
SELECT
    t.tal_id,
    t.nombre,
    t.activo,
    COUNT(i.inv_id) AS cantidad_inventarios
FROM tallas t
LEFT JOIN inventarios i ON i.tal_id = t.tal_id
GROUP BY t.tal_id, t.nombre, t.activo
ORDER BY t.tal_id;


CREATE OR REPLACE VIEW vw_admin_colores AS
SELECT
    c.col_id,
    c.nombre,
    c.activo,
    COUNT(i.inv_id) AS cantidad_inventarios
FROM colores c
LEFT JOIN inventarios i ON i.col_id = c.col_id
GROUP BY c.col_id, c.nombre, c.activo
ORDER BY c.nombre;


CREATE OR REPLACE VIEW vw_admin_metodos_pago AS
SELECT
    mp.met_id,
    mp.nombre,
    mp.activo,
    COUNT(p.pag_id) AS cantidad_pagos
FROM metodos_pago mp
LEFT JOIN pagos p ON p.met_id = mp.met_id
GROUP BY mp.met_id, mp.nombre, mp.activo
ORDER BY mp.nombre;


-- =========================================================
-- VISTA: DETALLE DE VENTAS PARA ADMIN
-- =========================================================

CREATE OR REPLACE VIEW vw_detalle_ventas_admin AS
SELECT
    v.ven_id,
    v.fecha,
    pe.nombre AS cliente,
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
INNER JOIN personas pe ON pe.per_id = v.per_id
INNER JOIN inventarios i ON i.inv_id = d.inv_id
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id;


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
    COALESCE(pa.monto, 0) AS total_pagado
FROM ventas v
INNER JOIN personas pe ON pe.per_id = v.per_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
LEFT JOIN metodos_pago mp ON mp.met_id = pa.met_id;


-- =========================================================
-- VISTA: DETALLE DEL PEDIDO DEL CLIENTE
-- =========================================================

CREATE OR REPLACE VIEW vw_detalle_pedido_cliente AS
SELECT
    v.ven_id,
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
FROM aud_pagos

UNION ALL
SELECT tabla, aud_id, operacion, fecha_cambio, registrado_por
FROM aud_catalogos_parametricos;

-- =========================================================
-- VISTA MATERIALIZADA: RESUMEN DE VENTAS POR PRODUCTO
-- =========================================================

DROP MATERIALIZED VIEW IF EXISTS mv_resumen_ventas_productos;

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

