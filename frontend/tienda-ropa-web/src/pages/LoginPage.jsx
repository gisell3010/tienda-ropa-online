import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import "../styles/auth.css";

function LoginPage({ irARegistro, redirigirPorRol }) {
  const { iniciarSesion } = useAuth();

  const [formulario, setFormulario] = useState({
    correo: "",
    password: ""
  });

  const [mensaje, setMensaje] = useState("");
  const [tipoMensaje, setTipoMensaje] = useState("");
  const [cargando, setCargando] = useState(false);

  const actualizarCampo = (evento) => {
    const { name, value } = evento.target;

    setFormulario((datosActuales) => ({
      ...datosActuales,
      [name]: value
    }));
  };

  const validarFormulario = () => {
    if (!formulario.correo.trim()) {
      return "Ingresa tu correo electrónico.";
    }

    if (!formulario.password.trim()) {
      return "Ingresa tu contraseña.";
    }

    return "";
  };

  const manejarSubmit = async (evento) => {
    evento.preventDefault();

    const error = validarFormulario();

    if (error) {
      setMensaje(error);
      setTipoMensaje("error");
      return;
    }

    try {
      setCargando(true);
      setMensaje("");

      const respuesta = await iniciarSesion({
        correo: formulario.correo,
        password: formulario.password
      });

      setMensaje(respuesta.mensaje || "Inicio de sesión exitoso.");
      setTipoMensaje("success");

      redirigirPorRol(respuesta.usuario);
    } catch (error) {
      setMensaje(error.message || "No fue posible iniciar sesión.");
      setTipoMensaje("error");
    } finally {
      setCargando(false);
    }
  };

  return (
    <main className="auth-page">
      <section className="auth-card">
        <div className="auth-card__header">
          <span className="auth-card__label">ShopNMG</span>
          <h1>Iniciar sesión</h1>
          <p>Accede a tu cuenta para continuar en la tienda.</p>
        </div>

        <form className="auth-form" onSubmit={manejarSubmit}>
          <label>
            Correo electrónico
            <input
              type="email"
              name="correo"
              value={formulario.correo}
              onChange={actualizarCampo}
              placeholder="correo@ejemplo.com"
            />
          </label>

          <label>
            Contraseña
            <input
              type="password"
              name="password"
              value={formulario.password}
              onChange={actualizarCampo}
              placeholder="Ingresa tu contraseña"
            />
          </label>

          {mensaje && (
            <div className={`auth-message auth-message--${tipoMensaje}`}>
              {mensaje}
            </div>
          )}

          <button type="submit" disabled={cargando}>
            {cargando ? "Ingresando..." : "Iniciar sesión"}
          </button>
        </form>

        <div className="auth-card__footer">
          <p>¿No tienes cuenta?</p>
          <button type="button" onClick={irARegistro}>
            Crear cuenta
          </button>
        </div>

        <div className="auth-test">
          <p>Usuarios temporales de prueba:</p>
          <span>cliente@shopnmg.com / 123456</span>
          <span>admin@shopnmg.com / 123456</span>
          <span>superadmin@shopnmg.com / 123456</span>
        </div>
      </section>
    </main>
  );
}

export default LoginPage;