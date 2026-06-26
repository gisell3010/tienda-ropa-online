-- =========================================================
-- SCRIPT 04 - VALIDACIONES Y PROCEDIMIENTOS
-- Proyecto: Tienda de ropa online
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
-- FUNCIÓN: TOTAL DE UNA VENTA
-- Calcula el total de una venta desde detalle_ventas
-- =========================================================

CREATE OR REPLACE FUNCTION fn_total_venta(
    p_ven_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(10,2);
BEGIN
    IF p_ven_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la venta';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM ventas
        WHERE ven_id = p_ven_id
    ) THEN
        RAISE EXCEPTION 'No existe la venta indicada';
    END IF;

    SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
    INTO v_total
    FROM detalle_ventas
    WHERE ven_id = p_ven_id;

    RETURN v_total;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: REGISTRAR INVENTARIO
-- Registra inventario validando producto, talla, color y stock
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_inventario(
    p_pro_id INT,
    p_stock INT,
    p_tal_id INT,
    p_col_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_valido BOOLEAN;
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

    SELECT fn_validar_stock(p_stock)
    INTO v_stock_valido;

    IF NOT EXISTS (
        SELECT 1
        FROM productos
        WHERE pro_id = p_pro_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No existe el producto indicado o está inactivo';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM tallas
        WHERE tal_id = p_tal_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No existe la talla indicada o está inactiva';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM colores
        WHERE col_id = p_col_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No existe el color indicado o está inactivo';
    END IF;

    INSERT INTO inventarios (
        pro_id,
        stock,
        tal_id,
        col_id,
        activo
    )
    VALUES (
        p_pro_id,
        p_stock,
        p_tal_id,
        p_col_id,
        TRUE
    )
    ON CONFLICT (pro_id, tal_id, col_id)
    DO UPDATE SET
        stock = inventarios.stock + EXCLUDED.stock,
        activo = TRUE;
END;
$$;


-- =========================================================
-- PROCEDIMIENTO: AUMENTAR STOCK
-- Aumenta stock solo si el inventario está activo
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

    IF NOT EXISTS (
        SELECT 1
        FROM inventarios
        WHERE inv_id = p_inv_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No existe el inventario indicado o está inactivo';
    END IF;

    UPDATE inventarios
    SET stock = stock + p_cantidad
    WHERE inv_id = p_inv_id;
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



-- Registro público: siempre crea CLIENTE
CREATE OR REPLACE PROCEDURE registrar_cliente(
    p_nombre VARCHAR,
    p_telefono VARCHAR,
    p_correo VARCHAR,
    p_contrasena_hash VARCHAR,
    p_genero CHAR,
    p_fecha_nacimiento DATE
)
LANGUAGE plpgsql
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
-- PROCEDIMIENTO: REALIZAR COMPRA CON CARRITO
-- Registra una venta con varios productos.
-- El cliente selecciona productos en el frontend,
-- el backend envía el carrito y la base de datos valida stock.
-- =========================================================

CREATE OR REPLACE FUNCTION realizar_compra_carrito(
    p_per_id INT,
    p_met_id INT,
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
    IF p_per_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la persona';
    END IF;

    IF p_met_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el método de pago';
    END IF;

    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'El carrito no puede estar vacío';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM personas p
        INNER JOIN roles r ON r.rol_id = p.rol_id
        WHERE p.per_id = p_per_id
          AND r.nombre = 'CLIENTE'
    ) THEN
        RAISE EXCEPTION 'Solo una persona con rol CLIENTE puede realizar compras';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM metodos_pago
        WHERE met_id = p_met_id
    ) THEN
        RAISE EXCEPTION 'No existe el método de pago indicado';
    END IF;

    -- Validación centralizada de inventario, cantidad y stock.
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

    -- La base crea la venta.
    INSERT INTO ventas(per_id)
    VALUES (p_per_id)
    RETURNING ven_id INTO v_ven_id;

    -- La base crea detalles y descuenta stock.
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_inv_id := (v_item ->> 'inv_id')::INT;
        v_cantidad := (v_item ->> 'cantidad')::INT;

        SELECT p.precio
        INTO v_precio
        FROM inventarios i
        INNER JOIN productos p ON p.pro_id = i.pro_id
        WHERE i.inv_id = v_inv_id;

        INSERT INTO detalle_ventas(
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

    -- La base crea el pago.
    INSERT INTO pagos(
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

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al realizar compra del carrito: %', SQLERRM;
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
-- Reemplaza el stock exacto de un inventario activo
-- =========================================================

CREATE OR REPLACE PROCEDURE actualizar_inventario(
    p_inv_id INT,
    p_stock INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_valido BOOLEAN;
BEGIN
    IF p_inv_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el inventario';
    END IF;

    SELECT fn_validar_stock(p_stock)
    INTO v_stock_valido;

    IF NOT EXISTS (
        SELECT 1
        FROM inventarios
        WHERE inv_id = p_inv_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No existe el inventario indicado o está inactivo';
    END IF;

    UPDATE inventarios
    SET stock = p_stock
    WHERE inv_id = p_inv_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO: ACTIVAR O DESACTIVAR INVENTARIO
-- No elimina inventario para conservar historial de ventas
-- =========================================================

CREATE OR REPLACE PROCEDURE eliminar_o_desactivar_inventario(
    p_inv_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_inv_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el inventario';
    END IF;

    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar si el inventario queda activo o inactivo';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM inventarios
        WHERE inv_id = p_inv_id
    ) THEN
        RAISE EXCEPTION 'No existe el inventario indicado';
    END IF;

    UPDATE inventarios
    SET activo = p_activo
    WHERE inv_id = p_inv_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTOS ADMIN: CATEGORÍAS
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_categoria(
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre de la categoría es obligatorio';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM categorias
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
    ) THEN
        RAISE EXCEPTION 'Ya existe una categoría con ese nombre';
    END IF;

    INSERT INTO categorias(nombre, activo)
    VALUES (TRIM(p_nombre), TRUE);
END;
$$;


CREATE OR REPLACE PROCEDURE editar_categoria(
    p_cat_id INT,
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_cat_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la categoría';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre de la categoría es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM categorias
        WHERE cat_id = p_cat_id
    ) THEN
        RAISE EXCEPTION 'No existe la categoría indicada';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM categorias
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND cat_id <> p_cat_id
    ) THEN
        RAISE EXCEPTION 'Ya existe otra categoría con ese nombre';
    END IF;

    UPDATE categorias
    SET nombre = TRIM(p_nombre)
    WHERE cat_id = p_cat_id;
END;
$$;


CREATE OR REPLACE PROCEDURE cambiar_estado_categoria(
    p_cat_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_cat_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la categoría';
    END IF;

    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado de la categoría';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM categorias
        WHERE cat_id = p_cat_id
    ) THEN
        RAISE EXCEPTION 'No existe la categoría indicada';
    END IF;

    IF p_activo = FALSE AND EXISTS (
        SELECT 1
        FROM productos
        WHERE cat_id = p_cat_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No se puede desactivar la categoría porque tiene productos activos asociados';
    END IF;

    UPDATE categorias
    SET activo = p_activo
    WHERE cat_id = p_cat_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTOS ADMIN: ESTILOS
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_estilo(
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del estilo es obligatorio';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM estilos
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
    ) THEN
        RAISE EXCEPTION 'Ya existe un estilo con ese nombre';
    END IF;

    INSERT INTO estilos(nombre, activo)
    VALUES (TRIM(p_nombre), TRUE);
END;
$$;


CREATE OR REPLACE PROCEDURE editar_estilo(
    p_est_id INT,
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_est_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estilo';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del estilo es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM estilos
        WHERE est_id = p_est_id
    ) THEN
        RAISE EXCEPTION 'No existe el estilo indicado';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM estilos
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND est_id <> p_est_id
    ) THEN
        RAISE EXCEPTION 'Ya existe otro estilo con ese nombre';
    END IF;

    UPDATE estilos
    SET nombre = TRIM(p_nombre)
    WHERE est_id = p_est_id;
END;
$$;


CREATE OR REPLACE PROCEDURE cambiar_estado_estilo(
    p_est_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_est_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estilo';
    END IF;

    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado del estilo';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM estilos
        WHERE est_id = p_est_id
    ) THEN
        RAISE EXCEPTION 'No existe el estilo indicado';
    END IF;

    IF p_activo = FALSE AND EXISTS (
        SELECT 1
        FROM productos
        WHERE est_id = p_est_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No se puede desactivar el estilo porque tiene productos activos asociados';
    END IF;

    UPDATE estilos
    SET activo = p_activo
    WHERE est_id = p_est_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTOS ADMIN: TALLAS
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_talla(
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre de la talla es obligatorio';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tallas
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
    ) THEN
        RAISE EXCEPTION 'Ya existe una talla con ese nombre';
    END IF;

    INSERT INTO tallas(nombre, activo)
    VALUES (TRIM(p_nombre), TRUE);
END;
$$;


CREATE OR REPLACE PROCEDURE editar_talla(
    p_tal_id INT,
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tal_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la talla';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre de la talla es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM tallas
        WHERE tal_id = p_tal_id
    ) THEN
        RAISE EXCEPTION 'No existe la talla indicada';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tallas
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND tal_id <> p_tal_id
    ) THEN
        RAISE EXCEPTION 'Ya existe otra talla con ese nombre';
    END IF;

    UPDATE tallas
    SET nombre = TRIM(p_nombre)
    WHERE tal_id = p_tal_id;
END;
$$;


CREATE OR REPLACE PROCEDURE cambiar_estado_talla(
    p_tal_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tal_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la talla';
    END IF;

    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado de la talla';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM tallas
        WHERE tal_id = p_tal_id
    ) THEN
        RAISE EXCEPTION 'No existe la talla indicada';
    END IF;

    IF p_activo = FALSE AND EXISTS (
        SELECT 1
        FROM inventarios
        WHERE tal_id = p_tal_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No se puede desactivar la talla porque tiene inventarios activos asociados';
    END IF;

    UPDATE tallas
    SET activo = p_activo
    WHERE tal_id = p_tal_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTOS ADMIN: COLORES
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_color(
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del color es obligatorio';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM colores
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
    ) THEN
        RAISE EXCEPTION 'Ya existe un color con ese nombre';
    END IF;

    INSERT INTO colores(nombre, activo)
    VALUES (TRIM(p_nombre), TRUE);
END;
$$;


CREATE OR REPLACE PROCEDURE editar_color(
    p_col_id INT,
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_col_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el color';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del color es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM colores
        WHERE col_id = p_col_id
    ) THEN
        RAISE EXCEPTION 'No existe el color indicado';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM colores
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND col_id <> p_col_id
    ) THEN
        RAISE EXCEPTION 'Ya existe otro color con ese nombre';
    END IF;

    UPDATE colores
    SET nombre = TRIM(p_nombre)
    WHERE col_id = p_col_id;
END;
$$;


CREATE OR REPLACE PROCEDURE cambiar_estado_color(
    p_col_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_col_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el color';
    END IF;

    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado del color';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM colores
        WHERE col_id = p_col_id
    ) THEN
        RAISE EXCEPTION 'No existe el color indicado';
    END IF;

    IF p_activo = FALSE AND EXISTS (
        SELECT 1
        FROM inventarios
        WHERE col_id = p_col_id
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'No se puede desactivar el color porque tiene inventarios activos asociados';
    END IF;

    UPDATE colores
    SET activo = p_activo
    WHERE col_id = p_col_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTOS ADMIN: MÉTODOS DE PAGO
-- =========================================================

CREATE OR REPLACE PROCEDURE registrar_metodo_pago(
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del método de pago es obligatorio';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM metodos_pago
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
    ) THEN
        RAISE EXCEPTION 'Ya existe un método de pago con ese nombre';
    END IF;

    INSERT INTO metodos_pago(nombre, activo)
    VALUES (TRIM(p_nombre), TRUE);
END;
$$;


CREATE OR REPLACE PROCEDURE editar_metodo_pago(
    p_met_id INT,
    p_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_met_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el método de pago';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del método de pago es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM metodos_pago
        WHERE met_id = p_met_id
    ) THEN
        RAISE EXCEPTION 'No existe el método de pago indicado';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM metodos_pago
        WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
          AND met_id <> p_met_id
    ) THEN
        RAISE EXCEPTION 'Ya existe otro método de pago con ese nombre';
    END IF;

    UPDATE metodos_pago
    SET nombre = TRIM(p_nombre)
    WHERE met_id = p_met_id;
END;
$$;


CREATE OR REPLACE PROCEDURE cambiar_estado_metodo_pago(
    p_met_id INT,
    p_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_met_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el método de pago';
    END IF;

    IF p_activo IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el estado del método de pago';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM metodos_pago
        WHERE met_id = p_met_id
    ) THEN
        RAISE EXCEPTION 'No existe el método de pago indicado';
    END IF;

    UPDATE metodos_pago
    SET activo = p_activo
    WHERE met_id = p_met_id;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO ADMIN: CAMBIAR ESTADO DE PEDIDO
-- =========================================================

CREATE OR REPLACE PROCEDURE cambiar_estado_pedido(
    p_ven_id INT,
    p_estado VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado VARCHAR(20);
BEGIN
    IF p_ven_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la venta o pedido';
    END IF;

    IF p_estado IS NULL OR TRIM(p_estado) = '' THEN
        RAISE EXCEPTION 'Debe indicar el estado del pedido';
    END IF;

    v_estado := UPPER(TRIM(p_estado));

    IF v_estado NOT IN ('PENDIENTE', 'PAGADO', 'ENVIADO', 'ENTREGADO', 'CANCELADO') THEN
        RAISE EXCEPTION 'Estado de pedido no válido';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM ventas
        WHERE ven_id = p_ven_id
    ) THEN
        RAISE EXCEPTION 'No existe el pedido indicado';
    END IF;

    UPDATE ventas
    SET estado = v_estado
    WHERE ven_id = p_ven_id;
END;
$$;