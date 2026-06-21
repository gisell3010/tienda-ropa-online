-- SCRIPT COMPLETO – BASE TIENDA
-- =========================================
-- CREAR BASE DE DATOS
-- =========================================

CREATE DATABASE tienda_ropa_online;

-- Conectarse a la base
\c tienda_ropa_online

-- =========================================
-- TABLA ROLES
-- =========================================

CREATE TABLE roles (
    rol_id SERIAL PRIMARY KEY,
    nombre VARCHAR(25) NOT NULL UNIQUE
);

-- =========================================
-- TABLA DEPARTAMENTOS
-- =========================================

CREATE TABLE departamentos (
    dep_id CHAR(2) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================
-- TABLA MUNICIPIOS
-- =========================================

CREATE TABLE municipios (
    mun_id CHAR(5) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    dep_id CHAR(2) NOT NULL,
    CONSTRAINT uq_municipio_departamento UNIQUE (nombre, dep_id),
    FOREIGN KEY (dep_id) REFERENCES departamentos(dep_id)
);

-- =========================================
-- TABLA CATEGORIAS
-- =========================================

CREATE TABLE categorias (
    cat_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================
-- TABLA ESTILOS
-- =========================================

CREATE TABLE estilos (
    est_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- =========================================
-- TABLA METODOS_PAGO
-- =========================================

CREATE TABLE metodos_pago (
    met_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- =========================================
-- TABLA TALLAS
-- =========================================

CREATE TABLE tallas (
    tal_id SERIAL PRIMARY KEY,
    nombre VARCHAR(5) NOT NULL UNIQUE
);

-- =========================================
-- TABLA COLORES
-- =========================================

CREATE TABLE colores (
    col_id SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- =========================================
-- TABLA PERSONAS
-- =========================================

CREATE TABLE personas (
    per_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(50) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M', 'F', 'O')),
    fecha_nacimiento DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    rol_id INT NOT NULL,
    FOREIGN KEY (rol_id) REFERENCES roles(rol_id)
);

-- =========================================
-- TABLA DIRECCIONES
-- =========================================

CREATE TABLE direcciones (
    dir_id SERIAL PRIMARY KEY,
    mun_id CHAR(5) NOT NULL,
    linea VARCHAR(100) NOT NULL,
    FOREIGN KEY (mun_id) REFERENCES municipios(mun_id)
);

-- =========================================
-- TABLA PERSONAS_DIRECCIONES
-- =========================================

CREATE TABLE personas_direcciones (
    pdi_id SERIAL PRIMARY KEY,
    per_id INT NOT NULL,
    dir_id INT NOT NULL,
    CONSTRAINT uq_persona_direccion UNIQUE (per_id, dir_id),
    FOREIGN KEY (per_id) REFERENCES personas(per_id),
    FOREIGN KEY (dir_id) REFERENCES direcciones(dir_id)
);

-- =========================================
-- TABLA PRODUCTOS
-- =========================================

CREATE TABLE productos (
    pro_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio > 0),
    imagen_url TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    cat_id INT NOT NULL,
    est_id INT NOT NULL,

    CONSTRAINT uq_producto_categoria_estilo UNIQUE (nombre, cat_id, est_id),

    FOREIGN KEY (cat_id) REFERENCES categorias(cat_id),
    FOREIGN KEY (est_id) REFERENCES estilos(est_id)
);

-- =========================================
-- TABLA INVENTARIOS
-- =========================================

CREATE TABLE inventarios (
    inv_id SERIAL PRIMARY KEY,
    pro_id INT NOT NULL,
    tal_id INT NOT NULL,
    col_id INT NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),

    CONSTRAINT uq_producto_talla_color UNIQUE (pro_id, tal_id, col_id),

    FOREIGN KEY (pro_id) REFERENCES productos(pro_id),
    FOREIGN KEY (tal_id) REFERENCES tallas(tal_id),
    FOREIGN KEY (col_id) REFERENCES colores(col_id)
);

-- =========================================
-- TABLA VENTAS
-- =========================================

CREATE TABLE ventas (
    ven_id SERIAL PRIMARY KEY,
    per_id INT NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (per_id) REFERENCES personas(per_id)
);

-- =========================================
-- TABLA DETALLE_VENTAS
-- =========================================

CREATE TABLE detalle_ventas (
    det_id SERIAL PRIMARY KEY,
    ven_id INT NOT NULL,
    inv_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario > 0),
    FOREIGN KEY (ven_id) REFERENCES ventas(ven_id),
    FOREIGN KEY (inv_id) REFERENCES inventarios(inv_id)
);

-- =========================================
-- TABLA PAGOS
-- =========================================

CREATE TABLE pagos (
    pag_id SERIAL PRIMARY KEY,
    ven_id INT NOT NULL,
    met_id INT NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT uq_pago_venta UNIQUE (ven_id),
    FOREIGN KEY (ven_id) REFERENCES ventas(ven_id),
    FOREIGN KEY (met_id) REFERENCES metodos_pago(met_id)
);



