const API_BASE_URL = "/api";

export async function listarDepartamentos() {
  const respuesta = await fetch(`${API_BASE_URL}/ubicaciones/departamentos`);
  return await respuesta.json();
}

export async function listarMunicipios(departamentoId) {
  const respuesta = await fetch(
    `${API_BASE_URL}/ubicaciones/municipios?departamentoId=${departamentoId}`
  );

  return await respuesta.json();
}