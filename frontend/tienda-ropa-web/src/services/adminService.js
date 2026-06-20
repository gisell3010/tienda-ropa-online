const API_BASE_URL = "/api";

async function obtenerRespuestaJson(url, opciones = {}) {
  const respuesta = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      ...(opciones.headers || {})
    },
    ...opciones
  });

  if (!respuesta.ok) {
    const error = await respuesta.json().catch(() => null);
    throw new Error(error?.mensaje || "No fue posible obtener la información.");
  }

  return await respuesta.json();
}

function obtenerTexto(valor) {
  if (valor === null || valor === undefined) return "";

  if (typeof valor === "string" || typeof valor === "number") {
    return valor.toString();
  }

  if (typeof valor === "object") {
    return valor.nombre || valor.name || valor.descripcion || "";
  }

  return "";
}

function obtenerInventarios(producto) {
  const inventarios =
    producto.inventarios ||
    producto.existencias ||
    producto.stockPorVariante ||
    [];

  if (!Array.isArray(inventarios)) {
    return [];
  }

  return inventarios.map((inventario) => ({
    inventarioId:
      inventario.inventarioId ||
      inventario.invId ||
      inventario.id ||
      inventario.inventario_id,
    talla: obtenerTexto(inventario.talla || inventario.nombreTalla),
    color: obtenerTexto(inventario.color || inventario.nombreColor),
    stock: Number(inventario.stock || inventario.cantidad || 0)
  }));
}

function obtenerListaUnica(lista, campo) {
  return [
    ...new Set(
      lista
        .map((item) => item[campo])
        .filter((valor) => valor !== "")
    )
  ];
}

function normalizarProducto(producto) {
  const inventarios = obtenerInventarios(producto);

  const stockTotal = inventarios.length > 0
    ? inventarios.reduce(
        (total, inventario) => total + Number(inventario.stock || 0),
        0
      )
    : Number(producto.stock || producto.cantidadDisponible || 0);

  const tallas = obtenerListaUnica(inventarios, "talla");
  const colores = obtenerListaUnica(inventarios, "color");

  return {
    id: producto.id || producto.proId || producto.pro_id || producto.productoId,
    nombre:
      producto.nombre ||
      producto.producto ||
      producto.nombreProducto ||
      "Producto sin nombre",
    precio: Number(producto.precio || 0),
    categoria:
      obtenerTexto(producto.categoria || producto.nombreCategoria) ||
      "Sin categoría",
    estilo:
      obtenerTexto(producto.estilo || producto.nombreEstilo) ||
      "Sin estilo",
    talla: tallas.length > 0 ? tallas.join(", ") : "No aplica",
    color: colores.length > 0 ? colores.join(", ") : "No aplica",
    stock: stockTotal,
    estado: stockTotal > 0 ? "DISPONIBLE" : "AGOTADO"
  };
}

export async function listarProductosAdmin() {
  try {
    const datos = await obtenerRespuestaJson(`${API_BASE_URL}/productos`);

    if (Array.isArray(datos)) {
      return datos.map(normalizarProducto);
    }

    if (Array.isArray(datos.productos)) {
      return datos.productos.map(normalizarProducto);
    }

    if (Array.isArray(datos.data)) {
      return datos.data.map(normalizarProducto);
    }

    return [];
  } catch (error) {
    console.error("Error al listar productos:", error.message);
    return [];
  }
}

export async function validarInventarioProducto(productoId, tallaId, colorId, cantidad) {
  try {
    const parametros = new URLSearchParams({
      productoId,
      tallaId,
      colorId,
      cantidad
    });

    return await obtenerRespuestaJson(
      `${API_BASE_URL}/inventarios/validar?${parametros.toString()}`
    );
  } catch (error) {
    console.error("Error al validar inventario:", error.message);
    return {
      disponible: false,
      mensaje: "No se pudo validar el inventario."
    };
  }
}

export async function obtenerResumenAdmin() {
  const productos = await listarProductosAdmin();

  const totalProductos = productos.length;
  const productosDisponibles = productos.filter(
    (producto) => Number(producto.stock) > 0
  ).length;
  const productosAgotados = productos.filter(
    (producto) => Number(producto.stock) === 0
  ).length;

  return {
    totalProductos,
    productosDisponibles,
    productosAgotados,
    pedidosRegistrados: 0,
    ventasRegistradas: 0,
    pagosRegistrados: 0
  };
}

export async function listarPedidosAdmin() {
  return {
    disponible: false,
    mensaje: "Pendiente endpoint backend para consultar pedidos."
  };
}

export async function listarVentasAdmin() {
  return {
    disponible: false,
    mensaje: "Pendiente endpoint backend para consultar ventas."
  };
}

export async function listarPagosAdmin() {
  return {
    disponible: false,
    mensaje: "Pendiente endpoint backend para consultar pagos."
  };
}