-- =========================================================
-- SCRIPT 05 - PRODUCTOS E INVENTARIO INICIAL
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- INSERT PRODUCTOS
-- =========================================================

INSERT INTO productos (nombre, precio, imagen_url, cat_id, est_id)
VALUES (
    'Camiseta básica',
    45000,
    'https://ejemplo.com/camiseta-basica.jpg',
    (SELECT cat_id FROM categorias WHERE nombre = 'Superior'),
    (SELECT est_id FROM estilos WHERE nombre = 'Casual')
)
ON CONFLICT (nombre, cat_id, est_id) DO NOTHING;


-- =========================================================
-- INSERT INVENTARIO
-- =========================================================

DO $$
DECLARE
    v_pro_id INT;
    v_tal_id INT;
    v_col_id INT;
BEGIN
    SELECT pro_id
    INTO v_pro_id
    FROM productos
    WHERE nombre = 'Camiseta básica'
    LIMIT 1;

    SELECT tal_id
    INTO v_tal_id
    FROM tallas
    WHERE nombre = 'M'
    LIMIT 1;

    SELECT col_id
    INTO v_col_id
    FROM colores
    WHERE nombre = 'Negro'
    LIMIT 1;

    CALL registrar_inventario(
        v_pro_id,
        10,
        v_tal_id,
        v_col_id
    );
END;
$$;