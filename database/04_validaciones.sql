--VALIDACIONES BASICAS--
-- Validar correo de persona
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

-- Validar teléfono de persona
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

-- Validar stock
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

    -- Se permite stock = 0 para mostrar AGOTADO
    IF p_stock < 0 THEN
        RAISE EXCEPTION 'El stock no puede ser negativo';
    END IF;

    RETURN TRUE;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO: REGISTRAR INVENTARIO
-- Permite stock = 0 para mostrar AGOTADO
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

    IF EXISTS (
        SELECT 1
        FROM inventarios
        WHERE pro_id = p_pro_id
          AND tal_id = p_tal_id
          AND col_id = p_col_id
    ) THEN
        UPDATE inventarios
        SET stock = stock + p_stock
        WHERE pro_id = p_pro_id
          AND tal_id = p_tal_id
          AND col_id = p_col_id;
    ELSE
        INSERT INTO inventarios(pro_id, stock, tal_id, col_id)
        VALUES (p_pro_id, p_stock, p_tal_id, p_col_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al registrar inventario: %', SQLERRM;
END;
$$;

-- =========================================================
-- PROCEDIMIENTO: REALIZAR COMPRA
-- No permite comprar productos agotados
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
    IF NOT EXISTS (SELECT 1 FROM personas WHERE per_id = p_per_id) THEN
        RAISE EXCEPTION 'No existe la persona indicada';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM metodos_pago WHERE met_id = p_met_id) THEN
        RAISE EXCEPTION 'No existe el método de pago indicado';
    END IF;

    IF p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor que cero';
    END IF;

    SELECT i.stock, p.precio
    INTO v_stock, v_precio
    FROM inventarios i
    INNER JOIN productos p ON p.pro_id = i.pro_id
    WHERE i.inv_id = p_inv_id;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'No existe el inventario indicado';
    END IF;

    IF v_stock = 0 THEN
        RAISE EXCEPTION 'Producto agotado. No se permite realizar compra';
    END IF;

    IF v_stock < p_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente';
    END IF;

    v_total := p_cantidad * v_precio;

    INSERT INTO ventas(per_id, fecha)
    VALUES (p_per_id, CURRENT_DATE)
    RETURNING ven_id INTO v_ven_id;

    INSERT INTO detalle_ventas(ven_id, inv_id, cantidad, precio_unitario)
    VALUES (v_ven_id, p_inv_id, p_cantidad, v_precio);

    UPDATE inventarios
    SET stock = stock - p_cantidad
    WHERE inv_id = p_inv_id;

    INSERT INTO pagos(ven_id, met_id, monto, fecha)
    VALUES (v_ven_id, p_met_id, v_total, CURRENT_DATE);

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al realizar compra: %', SQLERRM;
END;
$$;



-- Estado del producto para el catálogo
CREATE OR REPLACE FUNCTION fn_estado_producto(
    p_stock INT
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_stock = 0 THEN
        RETURN 'AGOTADO';
    ELSE
        RETURN 'DISPONIBLE';
    END IF;
END;
$$;

CREATE OR REPLACE VIEW vw_catalogo_productos AS
SELECT
    p.pro_id,
    p.nombre AS producto,
    p.precio,
    c.nombre AS categoria,
    e.nombre AS estilo,
    i.inv_id,
    t.nombre AS talla,
    co.nombre AS color,
    i.stock,
    fn_estado_producto(i.stock) AS estado_producto,
    CASE
        WHEN i.stock = 0 THEN FALSE
        ELSE TRUE
    END AS permite_interaccion
FROM productos p
INNER JOIN categorias c ON c.cat_id = p.cat_id
INNER JOIN estilos e ON e.est_id = p.est_id
INNER JOIN inventarios i ON i.pro_id = p.pro_id
INNER JOIN tallas t ON t.tal_id = i.tal_id
INNER JOIN colores co ON co.col_id = i.col_id;
