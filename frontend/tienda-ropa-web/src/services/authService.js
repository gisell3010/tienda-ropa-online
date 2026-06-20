const API_BASE_URL = "/api";

export async function iniciarSesionBackend(credenciales) {
  const respuesta = await fetch(`${API_BASE_URL}/auth/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(credenciales)
  });

  const data = await respuesta.json().catch(() => null);

  if (!respuesta.ok || data?.exito === false) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        "Correo o contraseña incorrectos."
    );
  }

  return data;
}

export async function registrarClienteBackend(datosRegistro) {
  const respuesta = await fetch(`${API_BASE_URL}/auth/registro`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(datosRegistro)
  });

  const data = await respuesta.json().catch(() => null);

  if (!respuesta.ok || data?.exito === false) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        "No se pudo registrar el cliente."
    );
  }

  return data;
}

export async function consultarUsuarioActualBackend(token) {
  const respuesta = await fetch(`${API_BASE_URL}/auth/me`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  const data = await respuesta.json().catch(() => null);

  if (!respuesta.ok) {
    throw new Error(
      data?.mensaje ||
        data?.message ||
        "No se pudo validar la sesión."
    );
  }

  return data;
}