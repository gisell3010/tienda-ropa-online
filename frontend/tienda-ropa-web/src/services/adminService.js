const API_BASE_URL = "/api";

async function obtenerRespuestaJson(url, token, opciones = {}) {
  const respuesta = await fetch(url, {
    ...opciones,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
      ...(opciones.headers || {})
    }
  });

  const data = await respuesta.json().catch(() => null);

  if (!respuesta.ok || data?.exito === false) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        "No fue posible obtener la información."
    );
  }

  return data;
}

function extraerDatos(respuesta) {
  if (Array.isArray(respuesta)) return respuesta;
  if (Array.isArray(respuesta?.datos)) return respuesta.datos;
  if (Array.isArray(respuesta?.data)) return respuesta.data;
  return [];
}

function normalizarProducto(producto) {
  return {
    proId: producto.pro_id || producto.proId || producto.id,
    nombre: producto.producto || producto.nombre,
    precio: producto.precio,
    imagenUrl: producto.imagen_url || producto.imagenUrl,
    activo: producto.activo,
    catId: producto.cat_id || producto.catId,
    categoria: producto.categoria,
    estId: producto.est_id || producto.estId,
    estilo: producto.estilo
  };
}

function normalizarInventario(item) {
  return {
    invId: item.inv_id || item.invId,
    proId: item.pro_id || item.proId,
    producto: item.producto,
    precio: item.precio,
    talla: item.talla,
    talId: item.tal_id || item.talId,
    color: item.color,
    colId: item.col_id || item.colId,
    stock: Number(item.stock || 0),
    estado: item.estado_producto || item.estadoProducto
  };
}

export async function listarProductosAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/productos`, token);
  return extraerDatos(respuesta).map(normalizarProducto);
}

export async function listarInventarioAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/inventario`, token);
  return extraerDatos(respuesta).map(normalizarInventario);
}

export async function obtenerResumenAdmin(token) {
  const productos = await listarProductosAdmin(token);
  const inventario = await listarInventarioAdmin(token);
  const ventas = await listarVentasAdmin(token);
  const pagos = await listarPagosAdmin(token);
  const pedidos = await listarPedidosAdmin(token);

  const productosDisponibles = inventario.filter((item) => item.stock > 0).length;
  const productosAgotados = inventario.filter((item) => item.stock <= 0).length;

  return {
    totalProductos: productos.length,
    productosDisponibles,
    productosAgotados,
    pedidosRegistrados: pedidos.length,
    ventasRegistradas: ventas.length,
    pagosRegistrados: pagos.length
  };
}

export async function listarPedidosAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/pedidos`, token);
  return extraerDatos(respuesta);
}

export async function listarVentasAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/ventas`, token);
  return extraerDatos(respuesta);
}

export async function listarPagosAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/pagos`, token);
  return extraerDatos(respuesta);
}

export async function listarCategoriasAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/categorias`, token);
  return extraerDatos(respuesta);
}

export async function listarEstilosAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/estilos`, token);
  return extraerDatos(respuesta);
}

export async function listarTallasAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/tallas`, token);
  return extraerDatos(respuesta);
}

export async function listarColoresAdmin(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/admin/colores`, token);
  return extraerDatos(respuesta);
}

export async function crearProductoAdmin(producto, token) {
  return await obtenerRespuestaJson(`${API_BASE_URL}/admin/productos`, token, {
    method: "POST",
    body: JSON.stringify(producto)
  });
}

export async function editarProductoAdmin(productoId, producto, token) {
  return await obtenerRespuestaJson(
    `${API_BASE_URL}/admin/productos/${productoId}`,
    token,
    {
      method: "PUT",
      body: JSON.stringify(producto)
    }
  );
}

export async function cambiarEstadoProductoAdmin(productoId, activo, token) {
  return await obtenerRespuestaJson(
    `${API_BASE_URL}/admin/productos/${productoId}/estado`,
    token,
    {
      method: "PATCH",
      body: JSON.stringify({ activo })
    }
  );
}

export async function registrarInventarioAdmin(inventario, token) {
  return await obtenerRespuestaJson(`${API_BASE_URL}/admin/inventario`, token, {
    method: "POST",
    body: JSON.stringify(inventario)
  });
}

export async function actualizarInventarioAdmin(inventarioId, stock, token) {
  return await obtenerRespuestaJson(
    `${API_BASE_URL}/admin/inventario/${inventarioId}`,
    token,
    {
      method: "PUT",
      body: JSON.stringify({ stock })
    }
  );
}