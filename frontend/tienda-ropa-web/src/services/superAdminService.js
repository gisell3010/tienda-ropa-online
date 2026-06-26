import { useCallback, useEffect, useState } from "react";
import { useAuth } from "../context/AuthContext";
import {
  crearUsuario,
  listarUsuarios,
  cambiarEstadoUsuario,
  cambiarRolUsuario,
  listarAuditoria,
  obtenerReporteGeneral
} from "../services/superAdminService";
import "../styles/admin.css";

function SuperAdminDashboardPage({ usuario, cerrarSesionUsuario }) {
  const { token } = useAuth();

  const [usuarios, setUsuarios] = useState([]);
  const [auditorias, setAuditorias] = useState([]);
  const [reporte, setReporte] = useState({});
  const [mensaje, setMensaje] = useState("");
  const [tipoMensaje, setTipoMensaje] = useState("");
  const [cargando, setCargando] = useState(true);

  const [nuevoUsuario, setNuevoUsuario] = useState({
    nombre: "",
    telefono: "",
    correo: "",
    password: "",
    genero: "",
    fechaNacimiento: "",
    rol: "ADMIN"
  });

  const cargarInformacion = useCallback(async () => {
    try {
      setCargando(true);
      setMensaje("");

      const usuariosData = await listarUsuarios(token);
      const auditoriaData = await listarAuditoria(token);
      const reporteData = await obtenerReporteGeneral(token);

      setUsuarios(usuariosData);
      setAuditorias(auditoriaData);
      setReporte(reporteData);
    } catch (error) {
      setMensaje(error.message || "No se pudo cargar la información.");
      setTipoMensaje("error");
    } finally {
      setCargando(false);
    }
  }, [token]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    cargarInformacion();
  }, [cargarInformacion]);

  const actualizarCampo = (evento) => {
    const { name, value } = evento.target;

    setNuevoUsuario((datos) => ({
      ...datos,
      [name]: value
    }));
  };

  const registrarUsuario = async (evento) => {
    evento.preventDefault();

    try {
      setMensaje("");

      await crearUsuario(
        {
          nombre: nuevoUsuario.nombre.trim(),
          telefono: nuevoUsuario.telefono.trim(),
          correo: nuevoUsuario.correo.trim().toLowerCase(),
          password: nuevoUsuario.password,
          genero: nuevoUsuario.genero,
          fechaNacimiento: nuevoUsuario.fechaNacimiento,
          rol: nuevoUsuario.rol
        },
        token
      );

      setMensaje("Usuario creado correctamente.");
      setTipoMensaje("success");

      setNuevoUsuario({
        nombre: "",
        telefono: "",
        correo: "",
        password: "",
        genero: "",
        fechaNacimiento: "",
        rol: "ADMIN"
      });

      await cargarInformacion();
    } catch (error) {
      setMensaje(error.message || "No se pudo crear el usuario.");
      setTipoMensaje("error");
    }
  };

  const actualizarEstado = async (usuarioItem) => {
    try {
      await cambiarEstadoUsuario(usuarioItem.id, !usuarioItem.activo, token);
      await cargarInformacion();
    } catch (error) {
      setMensaje(error.message || "No se pudo cambiar el estado del usuario.");
      setTipoMensaje("error");
    }
  };

  const actualizarRol = async (usuarioId, rol) => {
    try {
      await cambiarRolUsuario(usuarioId, rol, token);
      await cargarInformacion();
    } catch (error) {
      setMensaje(error.message || "No se pudo cambiar el rol del usuario.");
      setTipoMensaje("error");
    }
  };

  return (
    <main className="admin-page">
      <section className="admin-hero">
        <div>
          <span className="admin-label">Panel superadministrador</span>
          <h1>Control general del sistema</h1>
          <p>
            Desde este módulo se crean administradores, se gestionan usuarios,
            roles, estados y auditorías del sistema.
          </p>
        </div>

        <div className="admin-user-card">
          <p>Sesión activa</p>
          <h3>{usuario?.nombre || usuario?.correo || "Superadministrador"}</h3>
          <span>{usuario?.rol || "SUPERADMIN"}</span>

          <button type="button" onClick={cerrarSesionUsuario}>
            Cerrar sesión
          </button>
        </div>
      </section>

      <section className="admin-summary-grid">
        <article className="admin-summary-card">
          <p>Usuarios</p>
          <h2>{usuarios.length}</h2>
          <span>Registrados en el sistema</span>
        </article>

        <article className="admin-summary-card">
          <p>Auditorías</p>
          <h2>{auditorias.length}</h2>
          <span>Movimientos registrados</span>
        </article>

        <article className="admin-summary-card">
          <p>Productos</p>
          <h2>{reporte.totalProductos || reporte.total_productos || 0}</h2>
          <span>Productos del catálogo</span>
        </article>

        <article className="admin-summary-card">
          <p>Ventas</p>
          <h2>{reporte.totalVentas || reporte.total_ventas || 0}</h2>
          <span>Ventas registradas</span>
        </article>
      </section>

      {mensaje && (
        <div className={`admin-message admin-message--${tipoMensaje}`}>
          {mensaje}
        </div>
      )}

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Crear usuario administrativo</h2>
            <p>Desde aquí el superadministrador puede crear administradores.</p>
          </div>
        </div>

        <form className="admin-form-grid" onSubmit={registrarUsuario}>
          <label>
            Nombre
            <input
              name="nombre"
              value={nuevoUsuario.nombre}
              onChange={actualizarCampo}
              placeholder="Nombre completo"
            />
          </label>

          <label>
            Teléfono
            <input
              name="telefono"
              value={nuevoUsuario.telefono}
              onChange={actualizarCampo}
              placeholder="3001234567"
            />
          </label>

          <label>
            Correo
            <input
              type="email"
              name="correo"
              value={nuevoUsuario.correo}
              onChange={actualizarCampo}
              placeholder="admin@correo.com"
            />
          </label>

          <label>
            Contraseña
            <input
              type="password"
              name="password"
              value={nuevoUsuario.password}
              onChange={actualizarCampo}
              placeholder="Mínimo 6 caracteres"
            />
          </label>

          <label>
            Género
            <select
              name="genero"
              value={nuevoUsuario.genero}
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
              value={nuevoUsuario.fechaNacimiento}
              onChange={actualizarCampo}
            />
          </label>

          <label>
            Rol
            <select
              name="rol"
              value={nuevoUsuario.rol}
              onChange={actualizarCampo}
            >
              <option value="ADMIN">ADMIN</option>
              <option value="SUPERADMIN">SUPERADMIN</option>
              <option value="CLIENTE">CLIENTE</option>
            </select>
          </label>

          <button type="submit">Crear usuario</button>
        </form>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Usuarios del sistema</h2>
            <p>Gestión de estado y rol de usuarios.</p>
          </div>

          <button type="button" onClick={cargarInformacion}>
            Actualizar
          </button>
        </div>

        {cargando ? (
          <div className="admin-empty-state">
            <p>Cargando información del superadministrador...</p>
          </div>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Nombre</th>
                  <th>Correo</th>
                  <th>Teléfono</th>
                  <th>Rol</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>

              <tbody>
                {usuarios.map((usuarioItem) => (
                  <tr key={usuarioItem.id}>
                    <td>{usuarioItem.nombre}</td>
                    <td>{usuarioItem.correo}</td>
                    <td>{usuarioItem.telefono}</td>
                    <td>
                      <select
                        value={usuarioItem.rol}
                        onChange={(evento) =>
                          actualizarRol(usuarioItem.id, evento.target.value)
                        }
                      >
                        <option value="CLIENTE">CLIENTE</option>
                        <option value="ADMIN">ADMIN</option>
                        <option value="SUPERADMIN">SUPERADMIN</option>
                      </select>
                    </td>
                    <td>{usuarioItem.activo ? "Activo" : "Inactivo"}</td>
                    <td>
                      <button
                        type="button"
                        onClick={() => actualizarEstado(usuarioItem)}
                      >
                        {usuarioItem.activo ? "Desactivar" : "Activar"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Auditoría general</h2>
            <p>Últimos movimientos registrados en la base de datos.</p>
          </div>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Tabla</th>
                <th>Operación</th>
                <th>Fecha</th>
                <th>Usuario BD</th>
              </tr>
            </thead>

            <tbody>
              {auditorias.slice(0, 20).map((auditoria, index) => (
                <tr key={index}>
                  <td>{auditoria.tabla}</td>
                  <td>{auditoria.operacion}</td>
                  <td>{auditoria.fecha_cambio || auditoria.fechaCambio}</td>
                  <td>{auditoria.registrado_por || auditoria.registradoPor}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </main>
  );
}

export default SuperAdminDashboardPage;