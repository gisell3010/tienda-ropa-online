-- =========================================================
-- SCRIPT 10 - PRUEBAS
-- Proyecto: Tienda de ropa online
-- =========================================================

BEGIN;

-- =========================================================
-- DATOS DE PRUEBA: CLIENTE, ADMIN Y SUPERADMIN
-- =========================================================

CALL registrar_cliente(
    'Cliente Prueba',
    '3124567890',
    'cliente.prueba@gmail.com',
    'hash_cliente_123',
    'M',
    '2000-05-10'
);

CALL registrar_usuario_admin(
    'Admin Prueba',
    '3134567890',
    'admin.prueba@gmail.com',
    'hash_admin_123',
    'F',
    '1998-03-15',
    (SELECT rol_id FROM roles WHERE nombre = 'ADMIN')
);

CALL registrar_usuario_admin(
    'Superadmin Prueba',
    '3144567890',
    'superadmin.prueba@gmail.com',
    'hash_superadmin_123',
    'O',
    '1995-08-20',
    (SELECT rol_id FROM roles WHERE nombre = 'SUPERADMIN')
);


-- =========================================================
-- DATOS DE PRUEBA: PRODUCTOS
-- =========================================================

CALL registrar_producto(
    'Camiseta deportiva prueba',
    55000,
    'https://ejemplo.com/camiseta-deportiva.jpg',
    (SELECT cat_id FROM categorias WHERE nombre = 'Superior'),
    (SELECT est_id FROM estilos WHERE nombre = 'Deportivo')
);

CALL registrar_producto(
    'Jean clásico prueba',
    90000,
    'https://ejemplo.com/jean-clasico.jpg',
    (SELECT cat_id FROM categorias WHERE nombre = 'Inferior'),
    (SELECT est_id FROM estilos WHERE nombre = 'Casual')
);



-- =========================================================
-- DATOS DE PRUEBA: INVENTARIO
-- =========================================================

CALL registrar_inventario(
    (SELECT pro_id FROM productos WHERE nombre = 'Camiseta deportiva prueba'),
    20,
    (SELECT tal_id FROM tallas WHERE nombre = 'M'),
    (SELECT col_id FROM colores WHERE nombre = 'Negro')
);

CALL registrar_inventario(
    (SELECT pro_id FROM productos WHERE nombre = 'Jean clásico prueba'),
    15,
    (SELECT tal_id FROM tallas WHERE nombre = 'L'),
    (SELECT col_id FROM colores WHERE nombre = 'Azul')
);


-- =========================================================
-- PRUEBA: EDITAR PRODUCTO, CAMBIAR ESTADO Y ACTUALIZAR INVENTARIO
-- =========================================================

CALL editar_producto(
    (SELECT pro_id FROM productos WHERE nombre = 'Jean clásico prueba'),
    'Jean clásico prueba actualizado',
    95000,
    'https://ejemplo.com/jean-clasico-actualizado.jpg',
    (SELECT cat_id FROM categorias WHERE nombre = 'Inferior'),
    (SELECT est_id FROM estilos WHERE nombre = 'Casual')
);

CALL cambiar_estado_producto(
    (SELECT pro_id FROM productos WHERE nombre = 'Jean clásico prueba actualizado'),
    TRUE
);

CALL actualizar_inventario(
    (
        SELECT i.inv_id
        FROM inventarios i
        INNER JOIN productos p ON p.pro_id = i.pro_id
        WHERE p.nombre = 'Camiseta deportiva prueba'
        LIMIT 1
    ),
    25
);


-- =========================================================
-- DATOS DE PRUEBA: VENTA, DETALLE Y PAGO
-- Se crean mediante la función de carrito
-- =========================================================

SELECT realizar_compra_carrito(
    (SELECT per_id FROM personas WHERE correo = 'cliente.prueba@gmail.com'),
    (SELECT met_id FROM metodos_pago WHERE nombre = 'PSE'),
    jsonb_build_array(
        jsonb_build_object(
            'inv_id',
            (
                SELECT i.inv_id
                FROM inventarios i
                INNER JOIN productos p ON p.pro_id = i.pro_id
                WHERE p.nombre = 'Camiseta deportiva prueba'
                LIMIT 1
            ),
            'cantidad',
            2
        ),
        jsonb_build_object(
            'inv_id',
            (
                SELECT i.inv_id
                FROM inventarios i
                INNER JOIN productos p ON p.pro_id = i.pro_id
                WHERE p.nombre = 'Jean clásico prueba actualizado'
                LIMIT 1
            ),
            'cantidad',
            1
        )
    )
);


-- =========================================================
-- LLAMADOS A FUNCIONES
-- =========================================================

SELECT fn_validar_correo('cliente@gmail.com');
SELECT fn_validar_telefono('3124567890');
SELECT fn_validar_stock(0);
SELECT fn_estado_producto(0);
SELECT fn_estado_producto(10);


-- =========================================================
-- LLAMADOS A VISTAS PRINCIPALES
-- =========================================================

SELECT * FROM vw_admin_productos;
SELECT * FROM vw_admin_inventario;
SELECT * FROM vw_resumen_ventas;
SELECT * FROM vw_detalle_ventas_admin;
SELECT * FROM vw_pedidos_cliente;
SELECT * FROM vw_detalle_pedido_cliente;
SELECT * FROM vw_usuarios_sistema;
SELECT * FROM vw_auditoria_general;


-- =========================================================
-- LLAMADOS A VISTAS PARAMÉTRICAS
-- =========================================================

SELECT * FROM vw_categorias;
SELECT * FROM vw_estilos;
SELECT * FROM vw_tallas;
SELECT * FROM vw_colores;
SELECT * FROM vw_metodos_pago;

SELECT * FROM vw_param_categorias;
SELECT * FROM vw_param_estilos;
SELECT * FROM vw_param_tallas;
SELECT * FROM vw_param_colores;
SELECT * FROM vw_param_metodos_pago;


-- =========================================================
-- REFRESCAR Y CONSULTAR VISTA MATERIALIZADA
-- =========================================================

REFRESH MATERIALIZED VIEW mv_resumen_ventas_productos;
SELECT * FROM mv_resumen_ventas_productos;

-- =========================================================
-- PRUEBAS ADMIN: CATÁLOGOS PARAMÉTRICOS
-- =========================================================

CALL registrar_categoria('Accesorios prueba');

CALL editar_categoria(
    (SELECT cat_id FROM categorias WHERE nombre = 'Accesorios prueba'),
    'Accesorios prueba actualizado'
);

CALL registrar_estilo('Minimalista prueba');

CALL editar_estilo(
    (SELECT est_id FROM estilos WHERE nombre = 'Minimalista prueba'),
    'Minimalista prueba actualizado'
);

CALL registrar_talla('XXL');

CALL registrar_color('Menta prueba');

CALL registrar_metodo_pago('Transferencia prueba');

CALL cambiar_estado_metodo_pago(
    (SELECT met_id FROM metodos_pago WHERE nombre = 'Transferencia prueba'),
    FALSE
);


-- =========================================================
-- PRUEBAS ADMIN: PRODUCTO E INVENTARIO
-- =========================================================

CALL registrar_producto(
    'Bolso accesorio prueba',
    75000,
    'https://ejemplo.com/bolso.jpg',
    (SELECT cat_id FROM categorias WHERE nombre = 'Accesorios prueba actualizado'),
    (SELECT est_id FROM estilos WHERE nombre = 'Minimalista prueba actualizado')
);

CALL registrar_inventario(
    (SELECT pro_id FROM productos WHERE nombre = 'Bolso accesorio prueba'),
    3,
    (SELECT tal_id FROM tallas WHERE nombre = 'XXL'),
    (SELECT col_id FROM colores WHERE nombre = 'Menta prueba')
);

SELECT * FROM vw_admin_stock_bajo;

CALL actualizar_inventario(
    (
        SELECT i.inv_id
        FROM inventarios i
        INNER JOIN productos p ON p.pro_id = i.pro_id
        WHERE p.nombre = 'Bolso accesorio prueba'
        LIMIT 1
    ),
    8
);

CALL eliminar_o_desactivar_inventario(
    (
        SELECT i.inv_id
        FROM inventarios i
        INNER JOIN productos p ON p.pro_id = i.pro_id
        WHERE p.nombre = 'Bolso accesorio prueba'
        LIMIT 1
    ),
    FALSE
);


-- =========================================================
-- PRUEBAS ADMIN: PEDIDOS Y PAGOS
-- =========================================================

SELECT * FROM vw_admin_pedidos;
SELECT * FROM vw_admin_pagos;
SELECT * FROM vw_admin_ventas_dia;
SELECT * FROM vw_admin_ventas_metodo_pago;
SELECT * FROM vw_admin_pedidos_estado;
SELECT * FROM vw_admin_productos_agotados;
SELECT * FROM vw_admin_resumen_operativo;

CALL cambiar_estado_pedido(
    (
        SELECT ven_id
        FROM ventas
        ORDER BY ven_id DESC
        LIMIT 1
    ),
    'ENVIADO'
);

SELECT * FROM vw_admin_pedidos;


-- =========================================================
-- PRUEBAS ADMIN: AUDITORÍA
-- =========================================================

SELECT *
FROM vw_auditoria_general
WHERE tabla IN ('categorias', 'estilos', 'tallas', 'colores', 'metodos_pago', 'inventarios', 'ventas')
ORDER BY fecha_cambio DESC;

ROLLBACK;