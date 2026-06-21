import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import "../styles/auth.css";

function RegisterPage({ irALogin }) {
  const { registrarCliente } = useAuth();

  const [formulario, setFormulario] = useState({
    nombre: "",
    telefono: "",
    correo: "",
    genero: "",
    fechaNacimiento: "",
    password: "",
    confirmarPassword: ""
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
    if (!formulario.nombre.trim()) {
      return "Ingresa tu nombre completo.";
    }

    if (!formulario.telefono.trim()) {
      return "Ingresa tu teléfono.";
    }

    if (!formulario.correo.trim()) {
      return "Ingresa tu correo electrónico.";
    }

    if (!formulario.genero.trim()) {
      return "Selecciona tu género.";
    }

    if (!formulario.fechaNacimiento.trim()) {
      return "Ingresa tu fecha de nacimiento.";
    }

    if (!formulario.password.trim()) {
      return "Ingresa una contraseña.";
    }

    if (formulario.password.length < 6) {
      return "La contraseña debe tener mínimo 6 caracteres.";
    }

    if (formulario.password !== formulario.confirmarPassword) {
      return "Las contraseñas no coinciden.";
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

      const respuesta = await registrarCliente({
        nombre: formulario.nombre.trim(),
        telefono: formulario.telefono.trim(),
        correo: formulario.correo.trim().toLowerCase(),
        genero: formulario.genero,
        fechaNacimiento: formulario.fechaNacimiento,
        password: formulario.password
      });

      setMensaje(respuesta.mensaje || "Registro realizado correctamente.");
      setTipoMensaje("success");

      setFormulario({
        nombre: "",
        telefono: "",
        correo: "",
        genero: "",
        fechaNacimiento: "",
        password: "",
        confirmarPassword: ""
      });

      setTimeout(() => {
        irALogin();
      }, 1200);
    } catch (error) {
      setMensaje(error.message || "No fue posible registrar el cliente.");
      setTipoMensaje("error");
    } finally {
      setCargando(false);
    }
  };

  return (
    <main className="auth-page">
      <section className="auth-card auth-card--wide">
        <div className="auth-card__header">
          <span className="auth-card__label">ShopNMG</span>
          <h1>Crear cuenta</h1>
          <p>Regístrate como cliente para comprar y consultar tus pedidos.</p>
        </div>

        <form className="auth-form auth-form--grid" onSubmit={manejarSubmit}>
          <label>
            Nombre completo
            <input
              type="text"
              name="nombre"
              value={formulario.nombre}
              onChange={actualizarCampo}
              placeholder="Ej: Laura Gómez"
            />
          </label>

          <label>
            Teléfono
            <input
              type="tel"
              name="telefono"
              value={formulario.telefono}
              onChange={actualizarCampo}
              placeholder="Ej: 3001234567"
            />
          </label>

          <label className="auth-form__full">
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
            Género
            <select
              name="genero"
              value={formulario.genero}
              onChange={actualizarCampo}
            >
              <option value="">Selecciona</option>
              <option value="F">Femenino</option>
              <option value="M">Masculino</option>
              <option value="O">Otro</option>
            </select>
          </label>

          <label>
            Fecha de nacimiento
            <input
              type="date"
              name="fechaNacimiento"
              value={formulario.fechaNacimiento}
              onChange={actualizarCampo}
            />
          </label>

          <label>
            Contraseña
            <input
              type="password"
              name="password"
              value={formulario.password}
              onChange={actualizarCampo}
              placeholder="Mínimo 6 caracteres"
            />
          </label>

          <label>
            Confirmar contraseña
            <input
              type="password"
              name="confirmarPassword"
              value={formulario.confirmarPassword}
              onChange={actualizarCampo}
              placeholder="Repite tu contraseña"
            />
          </label>

          {mensaje && (
            <div
              className={`auth-message auth-message--${tipoMensaje} auth-form__full`}
            >
              {mensaje}
            </div>
          )}

          <button type="submit" disabled={cargando} className="auth-form__full">
            {cargando ? "Registrando..." : "Crear cuenta"}
          </button>
        </form>

        <div className="auth-card__footer">
          <p>¿Ya tienes cuenta?</p>
          <button type="button" onClick={irALogin}>
            Iniciar sesión
          </button>
        </div>
      </section>
    </main>
  );
}

export default RegisterPage;