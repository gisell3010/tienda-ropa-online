-- =========================================================
-- SCRIPT 02 - CATÁLOGO E INVENTARIO
-- Proyecto: Tienda de ropa online
-- Responsable: Base de datos
-- =========================================================

-- Este script contiene las tablas necesarias para manejar
-- el catálogo de productos y el inventario inicial del Sprint 1.

-- =========================================================
-- TABLA CATEGORIAS
-- =========================================================

CREATE TABLE IF NOT EXISTS categorias (
    cat_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA ESTILOS
-- =========================================================

CREATE TABLE IF NOT EXISTS estilos (
    est_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA TALLAS
-- =========================================================

CREATE TABLE IF NOT EXISTS tallas (
    tal_id SERIAL PRIMARY KEY,
    nombre VARCHAR(5) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA COLORES
-- =========================================================

CREATE TABLE IF NOT EXISTS colores (
    col_id SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- =========================================================
-- TABLA PRODUCTOS
-- =========================================================

CREATE TABLE IF NOT EXISTS productos (
    pro_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    cat_id INT NOT NULL,
    est_id INT NOT NULL,

    FOREIGN KEY (cat_id) REFERENCES categorias(cat_id),
    FOREIGN KEY (est_id) REFERENCES estilos(est_id)
);

-- =========================================================
-- TABLA INVENTARIOS
-- =========================================================

CREATE TABLE IF NOT EXISTS inventarios (
    inv_id SERIAL PRIMARY KEY,
    pro_id INT NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    tal_id INT NOT NULL,
    col_id INT NOT NULL,

    CONSTRAINT uq_producto_talla_color UNIQUE (pro_id, tal_id, col_id),

    FOREIGN KEY (pro_id) REFERENCES productos(pro_id),
    FOREIGN KEY (tal_id) REFERENCES tallas(tal_id),
    FOREIGN KEY (col_id) REFERENCES colores(col_id)
);