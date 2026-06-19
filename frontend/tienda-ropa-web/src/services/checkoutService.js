const API_BASE_URL = "/api";

export async function finalizarCompra(datosCompra) {
  const respuesta = await fetch(`${API_BASE_URL}/compras`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(datosCompra)
  });

  const data = await respuesta.json().catch(() => null);

  if (!respuesta.ok || data?.exito === false) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        "No se pudo registrar la compra en el backend."
    );
  }

  return data;
}