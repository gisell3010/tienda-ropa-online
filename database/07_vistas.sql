-- =========================================================
-- SCRIPT 07 - VISTAS
-- Proyecto: Tienda de ropa online
-- =========================================================


-- =========================================================
-- VISTAS GENERALES
-- =========================================================

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


CREATE OR REPLACE VIEW vw_departamentos AS
SELECT
    dep_id,
    nombre
FROM departamentos
ORDER BY nombre;


CREATE OR REPLACE VIEW vw_municipios AS
SELECT
    mun_id,
    nombre,
    dep_id
FROM municipios
ORDER BY nombre;


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
-- VISTAS DEL CLIENTE
-- =========================================================

-- =========================================================
-- VISTA: CATÁLOGO DETALLADO DE PRODUCTOS
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
-- VISTA: CATÁLOGO GENERAL DE PRODUCTOS
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
-- VISTA: PERFIL DEL CLIENTE
-- =========================================================

CREATE OR REPLACE VIEW vw_perfil_cliente AS
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
INNER JOIN roles r ON r.rol_id = p.rol_id
WHERE r.nombre = 'CLIENTE';


-- =========================================================
-- VISTA: DIRECCIONES DEL CLIENTE
-- =========================================================

CREATE OR REPLACE VIEW vw_direcciones_cliente AS
SELECT DISTINCT ON (
    p.per_id,
    d.mun_id,
    LOWER(TRIM(d.linea))
)
    pd.pdi_id,
    p.per_id,
    p.nombre AS cliente,
    d.dir_id,
    d.linea,
    m.mun_id,
    m.nombre AS municipio,
    dep.dep_id,
    dep.nombre AS departamento
FROM personas_direcciones pd
INNER JOIN personas p ON p.per_id = pd.per_id
INNER JOIN roles r ON r.rol_id = p.rol_id
INNER JOIN direcciones d ON d.dir_id = pd.dir_id
INNER JOIN municipios m ON m.mun_id = d.mun_id
INNER JOIN departamentos dep ON dep.dep_id = m.dep_id
WHERE r.nombre = 'CLIENTE'
ORDER BY
    p.per_id,
    d.mun_id,
    LOWER(TRIM(d.linea)),
    d.dir_id DESC;


-- =========================================================
-- VISTA: PEDIDOS DEL CLIENTE
-- =========================================================

CREATE OR REPLACE VIEW vw_pedidos_cliente AS
SELECT
    v.ven_id,
    v.per_id,
    pe.nombre AS cliente,
    v.fecha,
    v.dir_id,
    COALESCE(dir.linea, 'Sin dirección registrada') AS direccion_entrega,
    COALESCE(m.nombre, 'Sin municipio') AS municipio,
    COALESCE(dep.nombre, 'Sin departamento') AS departamento,
    COALESCE(mp.nombre, 'Sin método de pago') AS metodo_pago,
    COALESCE(SUM(d.cantidad), 0) AS unidades_compradas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_venta,
    COALESCE(pa.monto, 0) AS total_pagado
FROM ventas v
INNER JOIN personas pe ON pe.per_id = v.per_id
LEFT JOIN detalle_ventas d ON d.ven_id = v.ven_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
LEFT JOIN metodos_pago mp ON mp.met_id = pa.met_id
LEFT JOIN direcciones dir ON dir.dir_id = v.dir_id
LEFT JOIN municipios m ON m.mun_id = dir.mun_id
LEFT JOIN departamentos dep ON dep.dep_id = m.dep_id
GROUP BY
    v.ven_id,
    v.per_id,
    pe.nombre,
    v.fecha,
    v.dir_id,
    dir.linea,
    m.nombre,
    dep.nombre,
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
    c.nombre AS categoria,
    e.nombre AS estilo,
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
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id;



-- =========================================================
-- VISTAS DEL ADMINISTRADOR
-- =========================================================

-- =========================================================
-- VISTA ADMINISTRATIVA: PRODUCTOS
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
-- VISTAS DEL SUPERADMINISTRADOR
-- =========================================================

-- =========================================================
-- VISTAS DE USUARIOS Y ROLES
-- =========================================================

CREATE OR REPLACE VIEW vw_roles_sistema AS
SELECT
    rol_id,
    nombre AS rol
FROM roles
ORDER BY rol_id;


CREATE OR REPLACE VIEW vw_usuarios_sistema_detalle AS
SELECT
    p.per_id,
    p.nombre,
    p.correo,
    p.telefono,
    p.genero,
    p.fecha_nacimiento,
    p.activo,
    p.rol_id,
    r.nombre AS rol,
    (
        SELECT MAX(ap.fecha_cambio)
        FROM aud_personas ap
        WHERE ap.per_id = p.per_id
    ) AS ultima_modificacion
FROM personas p
INNER JOIN roles r ON r.rol_id = p.rol_id;


CREATE OR REPLACE VIEW vw_usuarios_sistema AS
SELECT
    per_id,
    nombre,
    telefono,
    correo,
    genero,
    fecha_nacimiento,
    activo,
    rol_id,
    rol
FROM vw_usuarios_sistema_detalle;


-- =========================================================
-- AUDITORÍA GENERAL AMPLIADA
-- =========================================================

CREATE OR REPLACE VIEW vw_auditoria_general AS
SELECT 'personas' AS tabla, per_id AS id_afectado, operacion, fecha_cambio, registrado_por,
       CONCAT('persona=', nombre, ', correo=', correo, ', rol_id=', rol_id, ', activo=', activo) AS datos_relevantes
FROM aud_personas
UNION ALL
SELECT 'productos', pro_id, operacion, fecha_cambio, registrado_por,
       CONCAT('producto=', nombre, ', precio=', precio, ', activo=', activo) AS datos_relevantes
FROM aud_productos
UNION ALL
SELECT 'inventarios', inv_id, operacion, fecha_cambio, registrado_por,
       CONCAT('pro_id=', pro_id, ', stock=', stock, ', tal_id=', tal_id, ', col_id=', col_id) AS datos_relevantes
FROM aud_inventarios
UNION ALL
SELECT 'ventas', ven_id, operacion, fecha_cambio, registrado_por,
       CONCAT('per_id=', per_id, ', fecha=', fecha) AS datos_relevantes
FROM aud_ventas
UNION ALL
SELECT 'detalle_ventas', det_id, operacion, fecha_cambio, registrado_por,
       CONCAT('ven_id=', ven_id, ', inv_id=', inv_id, ', cantidad=', cantidad, ', precio=', precio_unitario) AS datos_relevantes
FROM aud_detalle_ventas
UNION ALL
SELECT 'pagos', pag_id, operacion, fecha_cambio, registrado_por,
       CONCAT('ven_id=', ven_id, ', met_id=', met_id, ', monto=', monto) AS datos_relevantes
FROM aud_pagos
UNION ALL
SELECT 'roles', rol_id, operacion, fecha_cambio, registrado_por, CONCAT('rol=', nombre)
FROM aud_roles
UNION ALL
SELECT 'categorias', cat_id, operacion, fecha_cambio, registrado_por, CONCAT('categoria=', nombre)
FROM aud_categorias
UNION ALL
SELECT 'estilos', est_id, operacion, fecha_cambio, registrado_por, CONCAT('estilo=', nombre)
FROM aud_estilos
UNION ALL
SELECT 'tallas', tal_id, operacion, fecha_cambio, registrado_por, CONCAT('talla=', nombre)
FROM aud_tallas
UNION ALL
SELECT 'colores', col_id, operacion, fecha_cambio, registrado_por, CONCAT('color=', nombre)
FROM aud_colores
UNION ALL
SELECT 'metodos_pago', met_id, operacion, fecha_cambio, registrado_por, CONCAT('metodo=', nombre)
FROM aud_metodos_pago
UNION ALL
SELECT 'direcciones', dir_id, operacion, fecha_cambio, registrado_por, CONCAT('mun_id=', mun_id, ', linea=', linea)
FROM aud_direcciones
UNION ALL
SELECT 'personas_direcciones', pdi_id, operacion, fecha_cambio, registrado_por, CONCAT('per_id=', per_id, ', dir_id=', dir_id)
FROM aud_personas_direcciones;


CREATE OR REPLACE VIEW vw_tablas_auditoria AS
SELECT DISTINCT tabla
FROM vw_auditoria_general
ORDER BY tabla;


-- =========================================================
-- REPORTES SUPERADMIN
-- =========================================================

CREATE OR REPLACE VIEW vw_reporte_general AS
SELECT
    (SELECT COUNT(*) FROM personas) AS total_usuarios,
    (SELECT COUNT(*) FROM personas WHERE activo = TRUE) AS usuarios_activos,
    (SELECT COUNT(*) FROM productos) AS total_productos,
    (SELECT COUNT(*) FROM productos WHERE activo = TRUE) AS productos_activos,
    (SELECT COUNT(*) FROM ventas) AS total_ventas,
    (SELECT COALESCE(SUM(monto), 0) FROM pagos) AS monto_ventas,
    (SELECT COUNT(*) FROM detalle_ventas) AS pedidos_registrados,
    (SELECT COUNT(*) FROM vw_auditoria_general) AS total_auditorias;


CREATE OR REPLACE VIEW vw_ventas_por_periodo AS
SELECT
    v.fecha,
    COUNT(v.ven_id) AS total_ventas,
    COALESCE(SUM(p.monto), 0) AS monto_total
FROM ventas v
LEFT JOIN pagos p ON p.ven_id = v.ven_id
GROUP BY v.fecha
ORDER BY v.fecha DESC;


CREATE OR REPLACE VIEW vw_ventas_por_metodo_pago AS
SELECT
    mp.met_id,
    mp.nombre AS metodo_pago,
    COUNT(p.pag_id) AS cantidad_pagos,
    COALESCE(SUM(p.monto), 0) AS total_pagado
FROM metodos_pago mp
LEFT JOIN pagos p ON p.met_id = mp.met_id
GROUP BY mp.met_id, mp.nombre
ORDER BY total_pagado DESC;


CREATE OR REPLACE VIEW vw_top_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    COALESCE(SUM(d.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_generado
FROM productos p
LEFT JOIN inventarios i ON i.pro_id = p.pro_id
LEFT JOIN detalle_ventas d ON d.inv_id = i.inv_id
GROUP BY p.pro_id, p.nombre, p.imagen_url
ORDER BY unidades_vendidas DESC;


CREATE OR REPLACE VIEW vw_clientes_mas_compras AS
SELECT
    pe.per_id,
    pe.nombre AS cliente,
    pe.correo,
    COUNT(v.ven_id) AS total_compras,
    COALESCE(SUM(pa.monto), 0) AS total_pagado
FROM personas pe
INNER JOIN roles r ON r.rol_id = pe.rol_id
LEFT JOIN ventas v ON v.per_id = pe.per_id
LEFT JOIN pagos pa ON pa.ven_id = v.ven_id
WHERE r.nombre = 'CLIENTE'
GROUP BY pe.per_id, pe.nombre, pe.correo
ORDER BY total_compras DESC;


CREATE OR REPLACE VIEW vw_productos_bajo_stock AS
SELECT
    i.inv_id,
    p.pro_id,
    p.nombre AS producto,
    p.imagen_url,
    t.nombre AS talla,
    c.nombre AS color,
    i.stock
FROM inventarios i
INNER JOIN productos p ON p.pro_id = i.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores c ON c.col_id = i.col_id
WHERE i.stock <= 5
ORDER BY i.stock ASC;


CREATE OR REPLACE VIEW vw_usuarios_por_rol AS
SELECT
    r.rol_id,
    r.nombre AS rol,
    COUNT(p.per_id) AS total_usuarios,
    COUNT(p.per_id) FILTER (WHERE p.activo = TRUE) AS usuarios_activos,
    COUNT(p.per_id) FILTER (WHERE p.activo = FALSE) AS usuarios_inactivos
FROM roles r
LEFT JOIN personas p ON p.rol_id = r.rol_id
GROUP BY r.rol_id, r.nombre
ORDER BY r.rol_id;


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


-- =========================================================
-- PROCEDIMIENTO: REFRESCAR REPORTES
-- =========================================================

CREATE OR REPLACE PROCEDURE refrescar_reportes()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_resumen_ventas_productos;
END;
$$;


CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_resumen_ventas_productos_pro_id
ON mv_resumen_ventas_productos (pro_id);