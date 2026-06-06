-- =========================================================
-- LLAMADOS A FUNCIONES
-- =========================================================

SELECT fn_validar_correo('cliente@gmail.com');

SELECT fn_validar_telefono('3124567890');

SELECT fn_validar_stock(0);

SELECT fn_estado_producto(0);

SELECT fn_estado_producto(10);


-- =========================================================
-- LLAMADOS A PROCEDIMIENTOS
-- =========================================================

CALL registrar_inventario(1, 10, 1, 1);

CALL aumentar_stock(1, 5);

CALL realizar_compra(1, 1, 1, 1);


-- =========================================================
-- PRUEBAS DE TRIGGERS DE AUDITORÍA
-- Los triggers no se llaman manualmente.
-- Se ejecutan automáticamente cuando haces INSERT, UPDATE o DELETE.
-- =========================================================

UPDATE productos
SET precio = precio + 1000
WHERE pro_id = 1;

SELECT * FROM aud_productos;

UPDATE inventarios
SET stock = stock + 1
WHERE inv_id = 1;

SELECT * FROM aud_inventarios;


-- =========================================================
-- LLAMADOS A VISTAS
-- =========================================================

SELECT * FROM vw_inventario_simple;

SELECT * FROM vw_catalogo_productos_detalle;

SELECT * FROM vw_catalogo_productos;

SELECT * FROM vw_resumen_ventas;

SELECT * FROM mv_resumen_ventas_productos;

REFRESH MATERIALIZED VIEW mv_resumen_ventas_productos;