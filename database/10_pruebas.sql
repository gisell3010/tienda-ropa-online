-- =========================================================
-- SCRIPT 10 - PRUEBAS
-- Proyecto: Tienda de ropa online
-- =========================================================

BEGIN;

-- =========================================================
-- DATOS DE PRUEBA: USUARIOS, PRODUCTOS, INVENTARIO Y VENTAS
-- =========================================================

-- 1. Registro de Cliente
CALL registrar_cliente(
    'Cliente Prueba',
    '3124567890',
    'cliente.prueba@gmail.com',
    'hash_cliente_123',
    'M',
    '2000-05-10'
);

-- 2. Registro de Admin
DO $$
DECLARE
    v_rol_id INT;
BEGIN
    SELECT rol_id INTO v_rol_id
    FROM roles
    WHERE nombre = 'ADMIN';

    CALL registrar_usuario_admin(
        'Admin Prueba',
        '3134567890',
        'admin.prueba@gmail.com',
        'hash_admin_123',
        'F',
        '1998-03-15',
        v_rol_id
    );
END;
$$;

-- 3. Registro de Superadmin
DO $$
DECLARE
    v_rol_id INT;
BEGIN
    SELECT rol_id INTO v_rol_id
    FROM roles
    WHERE nombre = 'SUPERADMIN';

    CALL registrar_usuario_admin(
        'Superadmin Prueba',
        '3144567890',
        'superadmin.prueba@gmail.com',
        'hash_superadmin_123',
        'O',
        '1995-08-20',
        v_rol_id
    );
END;
$$;

-- 4. Registro de Productos
DO $$
DECLARE
    v_cat_sup INT;
    v_est_dep INT;
    v_cat_inf INT;
    v_est_cas INT;
BEGIN
    SELECT cat_id INTO v_cat_sup FROM categorias WHERE nombre = 'Superior';
    SELECT est_id INTO v_est_dep FROM estilos WHERE nombre = 'Deportivo';
    SELECT cat_id INTO v_cat_inf FROM categorias WHERE nombre = 'Inferior';
    SELECT est_id INTO v_est_cas FROM estilos WHERE nombre = 'Casual';

    CALL registrar_producto(
        'Camiseta deportiva prueba',
        55000,
        'https://ejemplo.com/camiseta-deportiva.jpg',
        v_cat_sup,
        v_est_dep
    );

    CALL registrar_producto(
        'Jean clásico prueba',
        90000,
        'https://ejemplo.com/jean-clasico.jpg',
        v_cat_inf,
        v_est_cas
    );
END;
$$;

-- 5. Registro de Inventario
DO $$
DECLARE
    v_pro_camisa INT;
    v_pro_jean INT;
    v_tal_m INT;
    v_col_negro INT;
    v_tal_l INT;
    v_col_azul INT;
BEGIN
    SELECT pro_id INTO v_pro_camisa FROM productos WHERE nombre = 'Camiseta deportiva prueba';
    SELECT pro_id INTO v_pro_jean FROM productos WHERE nombre = 'Jean clásico prueba';
    SELECT tal_id INTO v_tal_m FROM tallas WHERE nombre = 'M';
    SELECT col_id INTO v_col_negro FROM colores WHERE nombre = 'Negro';
    SELECT tal_id INTO v_tal_l FROM tallas WHERE nombre = 'L';
    SELECT col_id INTO v_col_azul FROM colores WHERE nombre = 'Azul';

    CALL registrar_inventario(v_pro_camisa, 20, v_tal_m, v_col_negro);
    CALL registrar_inventario(v_pro_jean, 15, v_tal_l, v_col_azul);
END;
$$;

-- 6. Ediciones y Actualizaciones
DO $$
DECLARE
    v_pro_jean INT;
    v_inv_camisa INT;
    v_cat_inf INT;
    v_est_cas INT;
BEGIN
    SELECT pro_id INTO v_pro_jean
    FROM productos
    WHERE nombre = 'Jean clásico prueba';

    SELECT inv_id INTO v_inv_camisa
    FROM inventarios i
    INNER JOIN productos p ON p.pro_id = i.pro_id
    WHERE p.nombre = 'Camiseta deportiva prueba'
    LIMIT 1;

    SELECT cat_id INTO v_cat_inf
    FROM categorias
    WHERE nombre = 'Inferior';

    SELECT est_id INTO v_est_cas
    FROM estilos
    WHERE nombre = 'Casual';

    CALL editar_producto(
        v_pro_jean,
        'Jean clásico prueba actualizado',
        95000,
        'https://ejemplo.com/jean-clasico-actualizado.jpg',
        v_cat_inf,
        v_est_cas
    );

    CALL cambiar_estado_producto(v_pro_jean, TRUE);

    CALL actualizar_inventario(v_inv_camisa, 25);
END;
$$;

-- 7. Venta de prueba
DO $$
DECLARE
    v_per_id INT;
    v_met_id INT;
    v_inv_c INT;
    v_inv_j INT;
BEGIN
    SELECT per_id INTO v_per_id
    FROM personas
    WHERE correo = 'cliente.prueba@gmail.com';

    SELECT met_id INTO v_met_id
    FROM metodos_pago
    WHERE nombre = 'PSE';

    SELECT i.inv_id INTO v_inv_c
    FROM inventarios i
    INNER JOIN productos p ON p.pro_id = i.pro_id
    WHERE p.nombre = 'Camiseta deportiva prueba'
    LIMIT 1;

    SELECT i.inv_id INTO v_inv_j
    FROM inventarios i
    INNER JOIN productos p ON p.pro_id = i.pro_id
    WHERE p.nombre = 'Jean clásico prueba actualizado'
    LIMIT 1;

    PERFORM realizar_compra_carrito(
        v_per_id,
        v_met_id,
        jsonb_build_array(
            jsonb_build_object('inv_id', v_inv_c, 'cantidad', 2),
            jsonb_build_object('inv_id', v_inv_j, 'cantidad', 1)
        )
    );
END;
$$;

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

-- =========================================================
-- REFRESCAR Y CONSULTAR VISTA MATERIALIZADA
-- =========================================================

REFRESH MATERIALIZED VIEW mv_resumen_ventas_productos;
SELECT * FROM mv_resumen_ventas_productos;

ROLLBACK;