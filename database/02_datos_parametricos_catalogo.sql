-- =========================================================
-- SCRIPT 02 - DATOS PARAMÉTRICOS DEL CATÁLOGO
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- INSERT CATEGORÍAS
-- =========================================================

INSERT INTO categorias (nombre) VALUES
('Superior'),
('Inferior'),
('Calzado')
ON CONFLICT (nombre) DO NOTHING;


-- =========================================================
-- INSERT ESTILOS
-- =========================================================

INSERT INTO estilos (nombre) VALUES
('Deportivo'),
('Elegante'),
('Urban'),
('Casual')
ON CONFLICT (nombre) DO NOTHING;


-- =========================================================
-- INSERT MÉTODOS DE PAGO
-- =========================================================

INSERT INTO metodos_pago (nombre) VALUES
('Tarjeta de crédito'),
('Tarjeta de débito'),
('PSE')
ON CONFLICT (nombre) DO NOTHING;


-- =========================================================
-- INSERT TALLAS
-- =========================================================

INSERT INTO tallas (nombre) VALUES
('XS'),
('S'),
('M'),
('L'),
('XL'),
('35'),
('36'),
('37'),
('38'),
('39'),
('40'),
('41'),
('42'),
('43'),
('44')
ON CONFLICT (nombre) DO NOTHING;


-- =========================================================
-- INSERT COLORES
-- =========================================================

INSERT INTO colores (nombre) VALUES
('Negro'),
('Blanco'),
('Rojo'),
('Azul'),
('Verde'),
('Amarillo'),
('Naranja'),
('Morado'),
('Rosado'),
('Gris'),
('Café'),
('Beige'),
('Vinotinto'),
('Turquesa'),
('Dorado'),
('Plateado'),
('Fucsia'),
('Lila'),
('Azul marino'),
('Celeste'),
('Oliva'),
('Mostaza'),
('Coral'),
('Terracota'),
('Crema')
ON CONFLICT (nombre) DO NOTHING;

-- =========================================================
-- INSERT ROLES
-- =========================================================

INSERT INTO roles (nombre) VALUES
('CLIENTE'),
('ADMIN'),
('SUPERADMIN')
ON CONFLICT (nombre) DO NOTHING;

