-- =========================================================
-- SCRIPT 04 - VALIDACIONES Y PROCEDIMIENTOS
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- FUNCIONES DEL CLIENTE
-- =========================================================

-- =========================================================
-- FUNCIÓN: VALIDAR CORREO
-- =========================================================

CREATE OR REPLACE FUNCTION fn_validar_correo(
    p_correo VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_correo VARCHAR;
BEGIN
    v_correo := LOWER(TRIM(p_correo));

    IF v_correo IS NULL OR v_correo = '' THEN
        RAISE EXCEPTION 'El correo es obligatorio';
    END IF;

    IF v_correo !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El formato del correo no es válido';
    END IF;

    RETURN TRUE;
END;
$$;


-- =========================================================
-- FUNCIÓN: VALIDAR TELÉFONO
-- =========================================================

CREATE OR REPLACE FUNCTION fn_validar_telefono(
    p_telefono VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_telefono VARCHAR;
BEGIN
    v_telefono := NULLIF(TRIM(p_telefono), '');

    IF v_telefono IS NULL THEN
        RETURN TRUE;
    END IF;

    IF v_telefono !~ '^3[0-9]{9}$' THEN
        RAISE EXCEPTION 'El teléfono debe iniciar en 3 y tener 10 dígitos numéricos';
    END IF;

    RETURN TRUE;
END;
$$;


-- =========================================================
-- FUNCIÓN: VALIDAR STOCK
-- =========================================================

CREATE OR REPLACE FUNCTION fn_validar_stock(
    p_stock INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_stock IS NULL THEN
        RAISE EXCEPTION 'El stock es obligatorio';
    END IF;

    IF p_stock < 0 THEN
        RAISE EXCEPTION 'El stock no puede ser negativo';
    END IF;

    RETURN TRUE;
END;
$$;


-- =========================================================
-- FUNCIÓN: ESTADO DEL PRODUCTO
-- =========================================================

CREATE OR REPLACE FUNCTION fn_estado_producto(
    p_stock INT
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_stock IS NULL OR p_stock <= 0 THEN
        RETURN 'AGOTADO';
    ELSE
        RETURN 'DISPONIBLE';
    END IF;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: REGISTRAR INVENTARIO
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_inventario(
    p_pro_id INT,
    p_stock INT,
    p_tal_id INT,
    p_col_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_pro_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el producto';
    END IF;

    IF p_tal_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la talla';
    END IF;

    IF p_col_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el color';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM productos WHERE pro_id = p_pro_id) THEN
        RAISE EXCEPTION 'No existe el producto indicado';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tallas WHERE tal_id = p_tal_id) THEN
        RAISE EXCEPTION 'No existe la talla indicada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM colores WHERE col_id = p_col_id) THEN
        RAISE EXCEPTION 'No existe el color indicado';
    END IF;

    PERFORM fn_validar_stock(p_stock);

    INSERT INTO inventarios (
        pro_id,
        stock,
        tal_id,
        col_id
    )
    VALUES (
        p_pro_id,
        p_stock,
        p_tal_id,
        p_col_id
    )
    ON CONFLICT (pro_id, tal_id, col_id)
    DO UPDATE SET
        stock = inventarios.stock + EXCLUDED.stock;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al registrar inventario: %', SQLERRM;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: AUMENTAR STOCK
-- =========================================================

CREATE OR REPLACE PROCEDURE aumentar_stock(
    p_inv_id INT,
    p_cantidad INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_inv_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el inventario';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad a aumentar debe ser mayor que cero';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM inventarios WHERE inv_id = p_inv_id) THEN
        RAISE EXCEPTION 'No existe el inventario indicado';
    END IF;

    UPDATE inventarios
    SET stock = stock + p_cantidad
    WHERE inv_id = p_inv_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al aumentar stock: %', SQLERRM;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO: ACTIVAR/DESACTIVAR USUSARIO
-- =========================================================
CREATE OR REPLACE PROCEDURE cambiar_estado_persona(
    p_per_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado de la persona';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM personas WHERE per_id = p_per_id) THEN
        RAISE EXCEPTION 'No existe la persona indicada';
    END IF;

    UPDATE personas
    SET activo = p_activo
    WHERE per_id = p_per_id;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: REGISTRAR PERSONA
-- Usa validaciones de correo y teléfono
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_persona(
    p_nombre VARCHAR,
    p_telefono VARCHAR,
    p_correo VARCHAR,
    p_contrasena_hash VARCHAR,
    p_genero CHAR,
    p_fecha_nacimiento DATE,
    p_rol_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_correo VARCHAR;
    v_telefono VARCHAR;
    v_genero CHAR;
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre es obligatorio';
    END IF;

    IF p_contrasena_hash IS NULL OR TRIM(p_contrasena_hash) = '' THEN
        RAISE EXCEPTION 'La contraseña cifrada es obligatoria';
    END IF;

    v_correo := LOWER(TRIM(p_correo));
    v_telefono := NULLIF(TRIM(p_telefono), '');
    v_genero := UPPER(TRIM(p_genero::TEXT));

    PERFORM fn_validar_correo(v_correo);
    PERFORM fn_validar_telefono(v_telefono);

    IF EXISTS (
        SELECT 1
        FROM personas
        WHERE LOWER(TRIM(correo)) = v_correo
    ) THEN
        RAISE EXCEPTION 'El correo ya se encuentra registrado';
    END IF;

    IF v_genero NOT IN ('M', 'F', 'O') THEN
        RAISE EXCEPTION 'El género debe ser M, F u O';
    END IF;

    IF p_fecha_nacimiento IS NULL OR p_fecha_nacimiento >= CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de nacimiento no es válida';
    END IF;

    IF p_rol_id IS NULL OR NOT EXISTS (
        SELECT 1 FROM roles WHERE rol_id = p_rol_id
    ) THEN
        RAISE EXCEPTION 'No existe el rol indicado';
    END IF;

    INSERT INTO personas (
        nombre,
        telefono,
        correo,
        contrasena_hash,
        genero,
        fecha_nacimiento,
        rol_id
    )
    VALUES (
        TRIM(p_nombre),
        v_telefono,
        v_correo,
        p_contrasena_hash,
        v_genero,
        p_fecha_nacimiento,
        p_rol_id
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al registrar persona: %', SQLERRM;
END;
$$;



-- =========================================================
-- FUNCIONES Y PROCEDIMIENTOS DEL CLIENTE
-- =========================================================

-- =========================================================
-- FUNCIÓN CLIENTE: VALIDAR CLIENTE ACTIVO
-- =========================================================

CREATE OR REPLACE FUNCTION fn_es_cliente_activo(
    p_per_id INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM personas p
        INNER JOIN roles r ON r.rol_id = p.rol_id
        WHERE p.per_id = p_per_id
          AND p.activo = TRUE
          AND r.nombre = 'CLIENTE'
    );
END;
$$;


-- =========================================================
-- FUNCIÓN CLIENTE: TOTAL COMPRADO POR CLIENTE
-- =========================================================

CREATE OR REPLACE FUNCTION fn_total_compras_cliente(
    p_per_id INT
)
RETURNS NUMERIC(10,2)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_total NUMERIC(10,2);
BEGIN
    IF NOT fn_es_cliente_activo(p_per_id) THEN
        RAISE EXCEPTION 'No existe un cliente activo con el identificador indicado';
    END IF;

    SELECT COALESCE(SUM(d.cantidad * d.precio_unitario), 0)
    INTO v_total
    FROM ventas v
    INNER JOIN detalle_ventas d ON d.ven_id = v.ven_id
    WHERE v.per_id = p_per_id;

    RETURN v_total;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO CLIENTE: REGISTRAR CLIENTE
-- REEMPLAZA el registrar_cliente(...) que ya tienes.
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_cliente(
    p_nombre VARCHAR,
    p_telefono VARCHAR,
    p_correo VARCHAR,
    p_contrasena_hash VARCHAR,
    p_genero CHAR,
    p_fecha_nacimiento DATE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_rol_cliente INT;
BEGIN
    SELECT rol_id
    INTO v_rol_cliente
    FROM roles
    WHERE nombre = 'CLIENTE';

    IF v_rol_cliente IS NULL THEN
        RAISE EXCEPTION 'No existe el rol CLIENTE';
    END IF;

    CALL registrar_persona(
        p_nombre,
        p_telefono,
        p_correo,
        p_contrasena_hash,
        p_genero,
        p_fecha_nacimiento,
        v_rol_cliente
    );
END;
$$;


-- =========================================================
-- PROCEDIMIENTO CLIENTE: ACTUALIZAR PERFIL
-- No permite cambiar correo, contraseña ni rol desde el perfil.
-- =========================================================

CREATE OR REPLACE PROCEDURE actualizar_perfil_cliente(
    p_per_id INT,
    p_nombre VARCHAR,
    p_telefono VARCHAR,
    p_genero CHAR,
    p_fecha_nacimiento DATE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_telefono VARCHAR;
    v_genero CHAR;
    v_valida BOOLEAN;
BEGIN
    IF NOT fn_es_cliente_activo(p_per_id) THEN
        RAISE EXCEPTION 'No existe un cliente activo con el identificador indicado';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre es obligatorio';
    END IF;

    v_telefono := NULLIF(TRIM(p_telefono), '');

    SELECT fn_validar_telefono(v_telefono)
    INTO v_valida;

    IF p_genero IS NULL OR UPPER(TRIM(p_genero::TEXT)) NOT IN ('M', 'F', 'O') THEN
        RAISE EXCEPTION 'El género debe ser M, F u O';
    END IF;

    v_genero := UPPER(TRIM(p_genero::TEXT))::CHAR;

    IF p_fecha_nacimiento IS NULL OR p_fecha_nacimiento >= CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de nacimiento no es válida';
    END IF;

    UPDATE personas
    SET nombre = TRIM(p_nombre),
        telefono = v_telefono,
        genero = v_genero,
        fecha_nacimiento = p_fecha_nacimiento
    WHERE per_id = p_per_id;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO CLIENTE: REGISTRAR DIRECCIÓN
-- La base valida cliente, municipio y evita duplicar la misma dirección.
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_direccion_cliente(
    p_per_id INT,
    p_mun_id CHAR(5),
    p_linea VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_dir_id INT;
    v_linea VARCHAR;
BEGIN
    IF NOT fn_es_cliente_activo(p_per_id) THEN
        RAISE EXCEPTION 'No existe un cliente activo con el identificador indicado';
    END IF;

    IF p_mun_id IS NULL OR NOT EXISTS (
        SELECT 1
        FROM municipios
        WHERE mun_id = p_mun_id
    ) THEN
        RAISE EXCEPTION 'No existe el municipio indicado';
    END IF;

    v_linea := NULLIF(TRIM(p_linea), '');

    IF v_linea IS NULL THEN
        RAISE EXCEPTION 'La dirección es obligatoria';
    END IF;

    SELECT dir_id
    INTO v_dir_id
    FROM direcciones
    WHERE mun_id = p_mun_id
      AND LOWER(TRIM(linea)) = LOWER(v_linea)
    LIMIT 1;

    IF v_dir_id IS NULL THEN
        INSERT INTO direcciones (mun_id, linea)
        VALUES (p_mun_id, v_linea)
        RETURNING dir_id INTO v_dir_id;
    END IF;

    INSERT INTO personas_direcciones (per_id, dir_id)
    VALUES (p_per_id, v_dir_id)
    ON CONFLICT (per_id, dir_id) DO NOTHING;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO CLIENTE: ELIMINAR DIRECCIÓN DEL CLIENTE
-- No borra la dirección física si ya fue usada en ventas.
-- Solo elimina la relación persona-dirección.
-- =========================================================

CREATE OR REPLACE PROCEDURE eliminar_direccion_cliente(
    p_per_id INT,
    p_dir_id INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT fn_es_cliente_activo(p_per_id) THEN
        RAISE EXCEPTION 'No existe un cliente activo con el identificador indicado';
    END IF;

    IF p_dir_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la dirección';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM personas_direcciones
        WHERE per_id = p_per_id
          AND dir_id = p_dir_id
    ) THEN
        RAISE EXCEPTION 'La dirección indicada no está asociada al cliente';
    END IF;

    DELETE FROM personas_direcciones
    WHERE per_id = p_per_id
      AND dir_id = p_dir_id;
END;
$$;


-- =========================================================
-- FUNCIÓN CLIENTE: REALIZAR COMPRA CON CARRITO
-- =========================================================
CREATE OR REPLACE FUNCTION realizar_compra_carrito(
    p_per_id INT,
    p_met_id INT,
    p_dir_id INT,
    p_items JSONB
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_ven_id INT;
    v_item JSONB;
    v_inv_id INT;
    v_cantidad INT;
    v_stock INT;
    v_precio NUMERIC(10,2);
    v_total NUMERIC(10,2) := 0;
BEGIN
    IF NOT fn_es_cliente_activo(p_per_id) THEN
        RAISE EXCEPTION 'Solo un cliente activo puede realizar compras';
    END IF;

    IF p_met_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el método de pago';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM metodos_pago
        WHERE met_id = p_met_id
    ) THEN
        RAISE EXCEPTION 'No existe el método de pago indicado';
    END IF;

    IF p_dir_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la dirección de entrega';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM personas_direcciones
        WHERE per_id = p_per_id
          AND dir_id = p_dir_id
    ) THEN
        RAISE EXCEPTION 'La dirección indicada no pertenece al cliente';
    END IF;

    IF p_items IS NULL
       OR jsonb_typeof(p_items) <> 'array'
       OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'El carrito no puede estar vacío';
    END IF;

    -- Validación centralizada de inventario, producto activo, cantidad y stock.
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_inv_id := (v_item ->> 'inv_id')::INT;
        v_cantidad := (v_item ->> 'cantidad')::INT;

        IF v_inv_id IS NULL THEN
            RAISE EXCEPTION 'Uno de los productos no tiene inventario indicado';
        END IF;

        IF v_cantidad IS NULL OR v_cantidad <= 0 THEN
            RAISE EXCEPTION 'La cantidad de cada producto debe ser mayor que cero';
        END IF;

        SELECT i.stock, p.precio
        INTO v_stock, v_precio
        FROM inventarios i
        INNER JOIN productos p ON p.pro_id = i.pro_id
        WHERE i.inv_id = v_inv_id
          AND p.activo = TRUE
        FOR UPDATE OF i;

        IF v_stock IS NULL THEN
            RAISE EXCEPTION 'No existe el inventario % o el producto está inactivo', v_inv_id;
        END IF;

        IF v_stock <= 0 THEN
            RAISE EXCEPTION 'El producto con inventario % está agotado', v_inv_id;
        END IF;

        IF v_stock < v_cantidad THEN
            RAISE EXCEPTION 'Stock insuficiente para el inventario %', v_inv_id;
        END IF;

        v_total := v_total + (v_cantidad * v_precio);
    END LOOP;

    INSERT INTO ventas (per_id, dir_id)
    VALUES (p_per_id, p_dir_id)
    RETURNING ven_id INTO v_ven_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_inv_id := (v_item ->> 'inv_id')::INT;
        v_cantidad := (v_item ->> 'cantidad')::INT;

        SELECT p.precio
        INTO v_precio
        FROM inventarios i
        INNER JOIN productos p ON p.pro_id = i.pro_id
        WHERE i.inv_id = v_inv_id;

        INSERT INTO detalle_ventas (
            ven_id,
            inv_id,
            cantidad,
            precio_unitario
        )
        VALUES (
            v_ven_id,
            v_inv_id,
            v_cantidad,
            v_precio
        );

        UPDATE inventarios
        SET stock = stock - v_cantidad
        WHERE inv_id = v_inv_id;
    END LOOP;

    INSERT INTO pagos (
        ven_id,
        met_id,
        monto
    )
    VALUES (
        v_ven_id,
        p_met_id,
        v_total
    );

    RETURN v_ven_id;
END;
$$;





-- Solo para uso administrativo
CREATE OR REPLACE PROCEDURE registrar_usuario_admin(
    p_nombre VARCHAR,
    p_telefono VARCHAR,
    p_correo VARCHAR,
    p_contrasena_hash VARCHAR,
    p_genero CHAR,
    p_fecha_nacimiento DATE,
    p_rol_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nombre_rol VARCHAR;
BEGIN
    SELECT nombre
    INTO v_nombre_rol
    FROM roles
    WHERE rol_id = p_rol_id;

    IF v_nombre_rol IS NULL THEN
        RAISE EXCEPTION 'No existe el rol indicado';
    END IF;

    IF v_nombre_rol NOT IN ('ADMIN', 'SUPERADMIN') THEN
        RAISE EXCEPTION 'Este procedimiento solo permite registrar ADMIN o SUPERADMIN';
    END IF;

    CALL registrar_persona(
        p_nombre,
        p_telefono,
        p_correo,
        p_contrasena_hash,
        p_genero,
        p_fecha_nacimiento,
        p_rol_id
    );
END;
$$;






-- =========================================================
-- PROCEDIMIENTO: REGISTRAR PRODUCTO
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_producto(
    p_nombre VARCHAR,
    p_precio NUMERIC,
    p_imagen_url TEXT,
    p_cat_id INT,
    p_est_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del producto es obligatorio';
    END IF;

    IF p_precio IS NULL OR p_precio <= 0 THEN
        RAISE EXCEPTION 'El precio debe ser mayor que cero';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM categorias WHERE cat_id = p_cat_id) THEN
        RAISE EXCEPTION 'No existe la categoría indicada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM estilos WHERE est_id = p_est_id) THEN
        RAISE EXCEPTION 'No existe el estilo indicado';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM productos
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND cat_id = p_cat_id
          AND est_id = p_est_id
    ) THEN
        RAISE EXCEPTION 'El producto ya existe con esa categoría y estilo';
    END IF;

    INSERT INTO productos(nombre, precio, imagen_url, cat_id, est_id)
    VALUES (
        TRIM(p_nombre),
        p_precio,
        NULLIF(TRIM(p_imagen_url), ''),
        p_cat_id,
        p_est_id
    );
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: EDITAR PRODUCTO
-- =========================================================

CREATE OR REPLACE PROCEDURE editar_producto(
    p_pro_id INT,
    p_nombre VARCHAR,
    p_precio NUMERIC,
    p_imagen_url TEXT,
    p_cat_id INT,
    p_est_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM productos WHERE pro_id = p_pro_id) THEN
        RAISE EXCEPTION 'No existe el producto indicado';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del producto es obligatorio';
    END IF;

    IF p_precio IS NULL OR p_precio <= 0 THEN
        RAISE EXCEPTION 'El precio debe ser mayor que cero';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM categorias WHERE cat_id = p_cat_id) THEN
        RAISE EXCEPTION 'No existe la categoría indicada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM estilos WHERE est_id = p_est_id) THEN
        RAISE EXCEPTION 'No existe el estilo indicado';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM productos
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND cat_id = p_cat_id
          AND est_id = p_est_id
          AND pro_id <> p_pro_id
    ) THEN
        RAISE EXCEPTION 'Ya existe otro producto con ese nombre, categoría y estilo';
    END IF;

    UPDATE productos
    SET nombre = TRIM(p_nombre),
        precio = p_precio,
        imagen_url = NULLIF(TRIM(p_imagen_url), ''),
        cat_id = p_cat_id,
        est_id = p_est_id
    WHERE pro_id = p_pro_id;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: CAMBIAR ESTADO PRODUCTO
-- =========================================================

CREATE OR REPLACE PROCEDURE cambiar_estado_producto(
    p_pro_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado del producto';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM productos WHERE pro_id = p_pro_id) THEN
        RAISE EXCEPTION 'No existe el producto indicado';
    END IF;

    UPDATE productos
    SET activo = p_activo
    WHERE pro_id = p_pro_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO: ACTUALIZAR INVENTARIO
-- Reemplaza el stock exacto de un inventario existente
-- =========================================================

CREATE OR REPLACE PROCEDURE actualizar_inventario(
    p_inv_id INT,
    p_stock INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventarios WHERE inv_id = p_inv_id) THEN
        RAISE EXCEPTION 'No existe el inventario indicado';
    END IF;

    PERFORM fn_validar_stock(p_stock);

    UPDATE inventarios
    SET stock = p_stock
    WHERE inv_id = p_inv_id;
END;
$$; 
