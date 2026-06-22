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

export async function crearUsuario(datosUsuario, token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/usuarios`,
    token,
    {
      method: "POST",
      body: JSON.stringify(datosUsuario)
    }
  );

  return respuesta?.datos || respuesta?.data || respuesta;
}

export async function listarUsuarios(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/usuarios`, token);
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

export async function cambiarRolUsuario(usuarioId, rol, token) {
  return await obtenerRespuestaJson(
    `${API_BASE_URL}/usuarios/${usuarioId}/rol`,
    token,
    {
      method: "PATCH",
      body: JSON.stringify({ rol })
    }
  );
}

export async function listarAuditoria(token) {
  const respuesta = await obtenerRespuestaJson(`${API_BASE_URL}/auditorias`, token);
  return extraerDatos(respuesta);
}

export async function obtenerReporteGeneral(token) {
  const respuesta = await obtenerRespuestaJson(
    `${API_BASE_URL}/reportes/general`,
    token
  );

  return respuesta?.datos || respuesta?.data || {};
}