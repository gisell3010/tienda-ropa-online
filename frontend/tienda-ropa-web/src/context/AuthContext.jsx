import { createContext, useContext, useState } from "react";
import {
  iniciarSesionBackend,
  registrarClienteBackend
} from "../services/authService";

const AuthContext = createContext();

const AUTH_STORAGE_KEY = "shopnmg_auth";

const obtenerSesionInicial = () => {
  const sesionGuardada = localStorage.getItem(AUTH_STORAGE_KEY);

  if (!sesionGuardada) {
    return {
      usuario: null,
      token: ""
    };
  }

  try {
    const datosSesion = JSON.parse(sesionGuardada);

    return {
      usuario: datosSesion.usuario || null,
      token: datosSesion.token || ""
    };
  } catch {
    localStorage.removeItem(AUTH_STORAGE_KEY);

    return {
      usuario: null,
      token: ""
    };
  }
};

export function AuthProvider({ children }) {
  const sesionInicial = obtenerSesionInicial();

  const [usuario, setUsuario] = useState(sesionInicial.usuario);
  const [token, setToken] = useState(sesionInicial.token);
  const [cargandoAuth] = useState(false);

  const guardarSesion = (datosSesion) => {
    const usuarioAutenticado = datosSesion.usuario || datosSesion;

    const tokenSesion =
      datosSesion.token || datosSesion.accessToken || "token-temporal";

    setUsuario(usuarioAutenticado);
    setToken(tokenSesion);

    localStorage.setItem(
      AUTH_STORAGE_KEY,
      JSON.stringify({
        usuario: usuarioAutenticado,
        token: tokenSesion
      })
    );
  };

  const iniciarSesion = async (credenciales) => {
    const respuesta = await iniciarSesionBackend(credenciales);
    guardarSesion(respuesta);

    return respuesta;
  };

  const registrarCliente = async (datosRegistro) => {
    return await registrarClienteBackend(datosRegistro);
  };

  const cerrarSesion = () => {
    setUsuario(null);
    setToken("");
    localStorage.removeItem(AUTH_STORAGE_KEY);
  };

  const estaAutenticado = Boolean(usuario && token);

  const rolUsuario = usuario?.rol || usuario?.rolAplicacion || usuario?.role || "";

  const value = {
    usuario,
    token,
    cargandoAuth,
    estaAutenticado,
    rolUsuario,
    iniciarSesion,
    registrarCliente,
    cerrarSesion
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error("useAuth debe usarse dentro de AuthProvider");
  }

  return context;
}