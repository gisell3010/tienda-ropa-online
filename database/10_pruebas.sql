-- =========================================================
-- SCRIPT 10 - PRUEBAS
-- Proyecto: Tienda de ropa online
-- =========================================================

BEGIN;


-- =========================================================
-- DATOS DE PRUEBA: USUARIOS
-- =========================================================

-- =========================================================
-- 1. REGISTRO DE CLIENTE
-- =========================================================

CALL registrar_cliente(
    'Cliente Prueba',
    '3124567890',
    'cliente.prueba@gmail.com',
    'hash_cliente_123',
    'M',
    '2000-05-10'
);


-- =========================================================
-- 2. REGISTRO DE ADMINISTRADOR
-- =========================================================

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


-- =========================================================
-- 3. REGISTRO DE SUPERADMINISTRADOR
-- =========================================================

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



-- =========================================================
-- PRUEBAS DEL ADMINISTRADOR
-- Productos, inventario y gestión operativa
-- =========================================================

-- =========================================================
-- 4. REGISTRO DE PRODUCTOS
-- =========================================================

DO $$
DECLARE
    v_cat_sup INT;
    v_est_dep INT;
    v_cat_inf INT;
    v_est_cas INT;
BEGIN
    SELECT cat_id INTO v_cat_sup
    FROM categorias
    WHERE nombre = 'Superior';

    SELECT est_id INTO v_est_dep
    FROM estilos
    WHERE nombre = 'Deportivo';

    SELECT cat_id INTO v_cat_inf
    FROM categorias
    WHERE nombre = 'Inferior';

    SELECT est_id INTO v_est_cas
    FROM estilos
    WHERE nombre = 'Casual';

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


-- =========================================================
-- 5. REGISTRO DE INVENTARIO
-- =========================================================

DO $$
DECLARE
    v_pro_camisa INT;
    v_pro_jean INT;
    v_tal_m INT;
    v_col_negro INT;
    v_tal_l INT;
    v_col_azul INT;
BEGIN
    SELECT pro_id INTO v_pro_camisa
    FROM productos
    WHERE nombre = 'Camiseta deportiva prueba';

    SELECT pro_id INTO v_pro_jean
    FROM productos
    WHERE nombre = 'Jean clásico prueba';

    SELECT tal_id INTO v_tal_m
    FROM tallas
    WHERE nombre = 'M';

    SELECT col_id INTO v_col_negro
    FROM colores
    WHERE nombre = 'Negro';

    SELECT tal_id INTO v_tal_l
    FROM tallas
    WHERE nombre = 'L';

    SELECT col_id INTO v_col_azul
    FROM colores
    WHERE nombre = 'Azul';

    CALL registrar_inventario(v_pro_camisa, 20, v_tal_m, v_col_negro);
    CALL registrar_inventario(v_pro_jean, 15, v_tal_l, v_col_azul);
END;
$$;


-- =========================================================
-- 6. EDICIÓN DE PRODUCTO Y ACTUALIZACIÓN DE INVENTARIO
-- =========================================================

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



-- =========================================================
-- PRUEBAS DEL CLIENTE
-- Perfil, direcciones, compra e historial
-- =========================================================

-- =========================================================
-- 7. ACTUALIZAR PERFIL Y REGISTRAR DIRECCIÓN
-- =========================================================

DO $$
DECLARE
    v_per_id INT;
    v_mun_id CHAR(5);
BEGIN
    SELECT per_id INTO v_per_id
    FROM personas
    WHERE correo = 'cliente.prueba@gmail.com';

    SELECT mun_id INTO v_mun_id
    FROM municipios
    WHERE nombre = 'PAMPLONA'
      AND dep_id = '54'
    LIMIT 1;

    IF v_mun_id IS NULL THEN
        SELECT mun_id INTO v_mun_id
        FROM municipios
        LIMIT 1;
    END IF;

    CALL actualizar_perfil_cliente(
        v_per_id,
        'Cliente Prueba Actualizado',
        '3124567890',
        'M',
        '2000-05-10'
    );

    CALL registrar_direccion_cliente(
        v_per_id,
        v_mun_id,
        'Carrera 20 No. 11-78'
    );
END;
$$;


-- =========================================================
-- 8. VENTA DE PRUEBA
-- =========================================================

DO $$
DECLARE
    v_per_id INT;
    v_met_id INT;
    v_inv_c INT;
    v_inv_j INT;
    v_dir_id INT;
    v_venta_id INT;
BEGIN
    SELECT per_id INTO v_per_id
    FROM personas
    WHERE correo = 'cliente.prueba@gmail.com';

    SELECT met_id INTO v_met_id
    FROM metodos_pago
    WHERE nombre = 'PSE';

    SELECT dir_id INTO v_dir_id
    FROM vw_direcciones_cliente
    WHERE per_id = v_per_id
      AND linea = 'Carrera 20 No. 11-78'
    LIMIT 1;

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

    SELECT realizar_compra_carrito(
        v_per_id,
        v_met_id,
        v_dir_id,
        jsonb_build_array(
            jsonb_build_object('inv_id', v_inv_c, 'cantidad', 2),
            jsonb_build_object('inv_id', v_inv_j, 'cantidad', 1)
        )
    )
    INTO v_venta_id;

    RAISE NOTICE 'Venta registrada con ID: %', v_venta_id;
END;
$$;



-- =========================================================
-- PRUEBAS DE FUNCIONES GENERALES Y CLIENTE
-- =========================================================

SELECT fn_validar_correo('cliente@gmail.com');

SELECT fn_validar_telefono('3124567890');

SELECT fn_validar_stock(0);

SELECT fn_estado_producto(0);

SELECT fn_estado_producto(10);

SELECT fn_es_cliente_activo(
    (SELECT per_id FROM personas WHERE correo = 'cliente.prueba@gmail.com')
);

SELECT fn_total_compras_cliente(
    (SELECT per_id FROM personas WHERE correo = 'cliente.prueba@gmail.com')
);



-- =========================================================
-- CONSULTAS A VISTAS GENERALES
-- =========================================================

SELECT * FROM vw_categorias;

SELECT * FROM vw_estilos;

SELECT * FROM vw_tallas;

SELECT * FROM vw_colores;

SELECT * FROM vw_metodos_pago;

SELECT * FROM vw_departamentos;

SELECT * FROM vw_municipios LIMIT 20;

SELECT * FROM vw_catalogo_productos;

SELECT * FROM vw_catalogo_productos_detalle;



-- =========================================================
-- CONSULTAS A VISTAS DEL CLIENTE
-- =========================================================

SELECT * FROM vw_perfil_cliente;

SELECT * FROM vw_direcciones_cliente;

SELECT * FROM vw_pedidos_cliente;

SELECT * FROM vw_detalle_pedido_cliente;



-- =========================================================
-- CONSULTAS A VISTAS DEL ADMINISTRADOR
-- =========================================================

SELECT * FROM vw_admin_productos;

SELECT * FROM vw_admin_inventario;

SELECT * FROM vw_resumen_ventas;

SELECT * FROM vw_detalle_ventas_admin;



-- =========================================================
-- CONSULTAS A VISTAS DEL SUPERADMINISTRADOR
-- =========================================================

SELECT * FROM vw_roles_sistema;

SELECT * FROM vw_usuarios_sistema;

SELECT * FROM vw_usuarios_sistema_detalle;

SELECT * FROM vw_auditoria_general
ORDER BY fecha_cambio DESC
LIMIT 20;

SELECT * FROM vw_tablas_auditoria;

SELECT * FROM vw_reporte_general;

SELECT * FROM vw_ventas_por_periodo;

SELECT * FROM vw_ventas_por_metodo_pago;

SELECT * FROM vw_top_productos
LIMIT 10;

SELECT * FROM vw_clientes_mas_compras
LIMIT 10;

SELECT * FROM vw_productos_bajo_stock;

SELECT * FROM vw_usuarios_por_rol;



-- =========================================================
-- PRUEBAS DE PROCEDIMIENTOS DEL SUPERADMINISTRADOR
-- =========================================================

DO $$
DECLARE
    v_usuario INT;
    v_rol_admin INT;
BEGIN
    SELECT per_id INTO v_usuario
    FROM personas
    WHERE correo = 'cliente.prueba@gmail.com';

    SELECT rol_id INTO v_rol_admin
    FROM roles
    WHERE nombre = 'ADMIN';

    IF v_usuario IS NOT NULL AND v_rol_admin IS NOT NULL THEN
        CALL cambiar_rol_persona(v_usuario, v_rol_admin);
        CALL cambiar_estado_persona(v_usuario, TRUE);
    END IF;
END;
$$;



-- =========================================================
-- REFRESCAR Y CONSULTAR VISTA MATERIALIZADA
-- =========================================================

CALL refrescar_reportes();

SELECT * FROM mv_resumen_ventas_productos;



ROLLBACK;