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
BEGIN
    IF p_correo IS NULL OR TRIM(p_correo) = '' THEN
        RAISE EXCEPTION 'El correo es obligatorio';
    END IF;

    IF p_correo !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
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
BEGIN
    IF p_telefono IS NULL OR TRIM(p_telefono) = '' THEN
        RETURN TRUE;
    END IF;

    IF p_telefono !~ '^3[0-9]{9}$' THEN
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
    IF p_stock IS NULL OR p_stock = 0 THEN
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
        stock = EXCLUDED.stock;

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
-- PROCEDIMIENTO: REALIZAR COMPRA
-- =========================================================

CREATE OR REPLACE PROCEDURE realizar_compra(
    p_per_id INT,
    p_inv_id INT,
    p_cantidad INT,
    p_met_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ven_id INT;
    v_stock INT;
    v_precio NUMERIC(10,2);
    v_total NUMERIC(10,2);
BEGIN
    IF p_per_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar la persona';
    END IF;

    IF p_inv_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el inventario';
    END IF;

    IF p_met_id IS NULL THEN
        RAISE EXCEPTION 'Debe indicar el método de pago';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor que cero';
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

    IF NOT EXISTS (SELECT 1 FROM metodos_pago WHERE met_id = p_met_id) THEN
        RAISE EXCEPTION 'No existe el método de pago indicado';
    END IF;

    SELECT i.stock, p.precio
    INTO v_stock, v_precio
    FROM inventarios i
    INNER JOIN productos p ON p.pro_id = i.pro_id
    WHERE i.inv_id = p_inv_id
      AND p.activo = TRUE
    FOR UPDATE OF i;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'No existe el inventario indicado o el producto está inactivo';
    END IF;

    IF v_stock = 0 THEN
        RAISE EXCEPTION 'Producto agotado. No se permite realizar compra';
    END IF;

    IF v_stock < p_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente';
    END IF;

    v_total := p_cantidad * v_precio;

    INSERT INTO ventas(per_id)
    VALUES (p_per_id)
    RETURNING ven_id INTO v_ven_id;

    INSERT INTO detalle_ventas(ven_id, inv_id, cantidad, precio_unitario)
    VALUES (v_ven_id, p_inv_id, p_cantidad, v_precio);

    UPDATE inventarios
    SET stock = stock - p_cantidad
    WHERE inv_id = p_inv_id;

    INSERT INTO pagos(ven_id, met_id, monto)
    VALUES (v_ven_id, p_met_id, v_total);

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al realizar compra: %', SQLERRM;
END;
$$;