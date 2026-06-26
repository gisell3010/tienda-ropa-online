const API_BASE_URL = "/api";

async function procesarRespuesta(respuesta, mensajeDefault) {
  const textoRespuesta = await respuesta.text();

  let data = null;

  try {
    data = textoRespuesta ? JSON.parse(textoRespuesta) : null;
  } catch {
    // La respuesta no venía en JSON.
  }

  if (!respuesta.ok) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        textoRespuesta ||
        mensajeDefault
    );
  }

  return data;
}

function crearHeaders(token) {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`
  };
}

export async function obtenerPerfilCliente(token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/perfil`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  return await procesarRespuesta(
    respuesta,
    "No se pudo consultar el perfil del cliente."
  );
}

export async function actualizarPerfilCliente(datosPerfil, token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/perfil`, {
    method: "PUT",
    headers: crearHeaders(token),
    body: JSON.stringify(datosPerfil)
  });

  return await procesarRespuesta(
    respuesta,
    "No se pudo actualizar el perfil del cliente."
  );
}

export async function listarDireccionesCliente(token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/direcciones`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  return await procesarRespuesta(
    respuesta,
    "No se pudieron consultar las direcciones del cliente."
  );
}

export async function registrarDireccionCliente(datosDireccion, token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/direcciones`, {
    method: "POST",
    headers: crearHeaders(token),
    body: JSON.stringify(datosDireccion)
  });

  return await procesarRespuesta(
    respuesta,
    "No se pudo registrar la dirección del cliente."
  );
}

export async function eliminarDireccionCliente(direccionId, token) {
  const respuesta = await fetch(
    `${API_BASE_URL}/cliente/direcciones/${direccionId}`,
    {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${token}`
      }
    }
  );

  if (respuesta.status === 204 || respuesta.status === 200) {
    return true;
  }

  return await procesarRespuesta(
    respuesta,
    "No se pudo eliminar la dirección del cliente."
  );
}

export async function listarPedidosCliente(token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/pedidos`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  return await procesarRespuesta(
    respuesta,
    "No se pudieron consultar los pedidos del cliente."
  );
}

export async function obtenerDetallePedidoCliente(pedidoId, token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/pedidos/${pedidoId}`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  return await procesarRespuesta(
    respuesta,
    "No se pudo consultar el detalle del pedido."
  );
}