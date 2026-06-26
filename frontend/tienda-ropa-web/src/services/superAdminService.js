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
        "No fue posible realizar la operación."
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

function extraerObjeto(respuesta) {
  return respuesta?.datos || respuesta?.data || respuesta || {};
}

export async function crearUsuario(datosUsuario, token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/usuarios`,
    token,
    {
      method: "POST",
      body: JSON.stringify(datosUsuario)
    }
  );

  return extraerObjeto(respuesta);
}

export async function listarUsuarios(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/usuarios`, token);
  return extraerDatos(respuesta);
}

export async function listarRoles(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/usuarios/roles`,
    token
  );

  return extraerDatos(respuesta);
}

export async function cambiarEstadoUsuario(usuarioId, activo, token) {
  return await obtenerRespuestaJson(
    `${API_BASE_URL}/usuarios/${usuarioId}/estado`,
    token,
    {
      method: "PATCH",
      body: JSON.stringify({ activo })
    }
  );
}

export async function cambiarRolUsuario(usuarioId, rolId, token) {
  return await obtenerRespuestaJson(
    `${API_BASE_URL}/usuarios/${usuarioId}/rol`,
    token,
    {
      method: "PATCH",
      body: JSON.stringify({ rolId })
    }
  );
}

export async function listarAuditoria(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/auditorias`,
    token
  );

  return extraerDatos(respuesta);
}

export async function filtrarAuditoria(filtros, token) {
  const parametros = new URLSearchParams();

  Object.entries(filtros || {}).forEach(([clave, valor]) => {
    if (valor !== undefined && valor !== null && String(valor).trim() !== "") {
      parametros.append(clave, String(valor).trim());
    }
  });

  const query = parametros.toString();
  const url = query
    ? `${API_BASE_URL}/auditorias/filtro?${query}`
    : `${API_BASE_URL}/auditorias/filtro`;

  const respuesta = await obtenerRespuestaJson(url, token);
  return extraerDatos(respuesta);
}

export async function obtenerReporteGeneral(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/general`,
    token
  );

  return extraerObjeto(respuesta);
}

export async function obtenerVentasPorProducto(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/ventas-productos`,
    token
  );

  return extraerDatos(respuesta);
}

export async function obtenerVentasPorPeriodo(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/ventas-periodo`,
    token
  );

  return extraerDatos(respuesta);
}

export async function obtenerVentasPorMetodoPago(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/metodos-pago`,
    token
  );

  return extraerDatos(respuesta);
}

export async function obtenerTopProductos(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/top-productos`,
    token
  );

  return extraerDatos(respuesta);
}

export async function obtenerClientesMasCompras(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/clientes-compras`,
    token
  );

  return extraerDatos(respuesta);
}

export async function obtenerProductosBajoStock(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/bajo-stock`,
    token
  );

  return extraerDatos(respuesta);
}

export async function obtenerUsuariosPorRol(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/usuarios-rol`,
    token
  );

  return extraerDatos(respuesta);
}

export async function refrescarReportes(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/refrescar`,
    token,
    {
      method: "POST"
    }
  );

  return extraerObjeto(respuesta);
}