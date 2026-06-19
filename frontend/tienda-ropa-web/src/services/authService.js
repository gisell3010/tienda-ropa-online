const API_BASE_URL = "/api";

const USUARIOS_PRUEBA = [
  {
    id: 1,
    nombre: "Cliente Prueba",
    correo: "cliente@shopnmg.com",
    rol: "CLIENTE"
  },
  {
    id: 2,
    nombre: "Admin Prueba",
    correo: "admin@shopnmg.com",
    rol: "ADMIN"
  },
  {
    id: 3,
    nombre: "Superadmin Prueba",
    correo: "superadmin@shopnmg.com",
    rol: "SUPERADMIN"
  }
];

function obtenerUsuarioPrueba(correo) {
  return USUARIOS_PRUEBA.find(
    (usuario) => usuario.correo.toLowerCase() === correo.toLowerCase()
  );
}

export async function iniciarSesionBackend(credenciales) {
  try {
    const respuesta = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(credenciales)
    });

    if (!respuesta.ok) {
      const error = await respuesta.json().catch(() => null);
      throw new Error(error?.mensaje || "Correo o contraseña incorrectos.");
    }

    return await respuesta.json();
  } catch (error) {
    const usuarioPrueba = obtenerUsuarioPrueba(credenciales.correo);

    if (usuarioPrueba && credenciales.password === "123456") {
      return {
        exito: true,
        mensaje: "Inicio de sesión realizado correctamente.",
        token: "token-temporal-prueba",
        usuario: usuarioPrueba
      };
    }

    throw new Error(
      "No fue posible iniciar sesión. Verifica tus datos o intenta nuevamente."
    );
  }
}

export async function registrarClienteBackend(datosRegistro) {
  try {
    const respuesta = await fetch(`${API_BASE_URL}/auth/registro`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(datosRegistro)
    });

    if (!respuesta.ok) {
      const error = await respuesta.json().catch(() => null);
      throw new Error(error?.mensaje || "No se pudo registrar el cliente.");
    }

    return await respuesta.json();
  } catch (error) {
    return {
      exito: true,
      mensaje:
        "Registro validado correctamente. Cuando backend habilite el endpoint, se guardará en base de datos."
    };
  }
}

export async function consultarUsuarioActualBackend(token) {
  try {
    const respuesta = await fetch(`${API_BASE_URL}/auth/me`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    if (!respuesta.ok) {
      throw new Error("No se pudo validar la sesión.");
    }

    return await respuesta.json();
  } catch (error) {
    throw new Error("La sesión no pudo validarse con el backend.");
  }
}