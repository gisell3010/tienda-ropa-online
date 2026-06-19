const API_BASE_URL = "/api";

export async function obtenerProductos() {
  const respuesta = await fetch(`${API_BASE_URL}/productos`);

  if (!respuesta.ok) {
    throw new Error("No se pudo cargar el catálogo desde el backend.");
  }

  return await respuesta.json();
}