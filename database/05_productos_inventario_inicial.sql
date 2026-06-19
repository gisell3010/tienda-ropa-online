-- =========================================================
-- SCRIPT 05 - PRODUCTOS E INVENTARIO INICIAL
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- INSERT PRODUCTOS
-- =========================================================

INSERT INTO productos (nombre, precio, imagen_url, cat_id, est_id)
VALUES
('Camiseta básica', 45000, 'https://ejemplo.com/camiseta-basica.jpg',
 (SELECT cat_id FROM categorias WHERE nombre = 'Superior'),
 (SELECT est_id FROM estilos WHERE nombre = 'Casual')
)
ON CONFLICT (nombre, cat_id, est_id) DO NOTHING;


-- =========================================================
-- INSERT INVENTARIO
-- =========================================================

CALL registrar_inventario(
    (SELECT pro_id FROM productos WHERE nombre = 'Camiseta básica'),
    10,
    (SELECT tal_id FROM tallas WHERE nombre = 'M'),
    (SELECT col_id FROM colores WHERE nombre = 'Negro')
);