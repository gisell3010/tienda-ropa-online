const API_BASE_URL = "/api";

export async function finalizarCompra(datosCompra, token) {
  const respuesta = await fetch(`${API_BASE_URL}/compras`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`
    },
    body: JSON.stringify(datosCompra)
  });

  const textoRespuesta = await respuesta.text();

  let data = null;

  try {
    data = textoRespuesta ? JSON.parse(textoRespuesta) : null;
  } catch {
    // La respuesta no venía en formato JSON.
  }

  if (!respuesta.ok || data?.exito === false) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        textoRespuesta ||
        "No se pudo registrar la compra en el backend."
    );
  }

  return data;
}

export async function registrarDireccionCliente(direccion, token) {
  const respuesta = await fetch(`${API_BASE_URL}/cliente/direcciones`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`
    },
    body: JSON.stringify(direccion)
  });

  const data = await respuesta.json().catch(() => null);

  if (!respuesta.ok) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        "No se pudo registrar la dirección de entrega."
    );
  }

  return data;
}