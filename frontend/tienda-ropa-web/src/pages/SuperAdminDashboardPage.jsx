import { useCallback, useEffect, useMemo, useState } from "react";
import { useAuth } from "../context/AuthContext";
import {
  crearUsuario,
  listarUsuarios,
  listarRoles,
  cambiarEstadoUsuario,
  cambiarRolUsuario,
  listarAuditoria,
  filtrarAuditoria,
  obtenerReporteGeneral,
  obtenerVentasPorProducto,
  obtenerVentasPorPeriodo,
  obtenerVentasPorMetodoPago,
  obtenerTopProductos,
  obtenerClientesMasCompras,
  obtenerProductosBajoStock,
  obtenerUsuariosPorRol,
  refrescarReportes
} from "../services/superAdminService";
import "../styles/admin.css";

function obtenerIdUsuario(usuarioItem) {
  return usuarioItem.per_id || usuarioItem.perId || usuarioItem.id;
}

function obtenerRolId(usuarioItem, roles) {
  const rolId = usuarioItem.rol_id || usuarioItem.rolId;

  if (rolId) {
    return rolId;
  }

  const rol = roles.find(
    (item) => (item.rol || item.nombre) === usuarioItem.rol
  );

  return rol?.rol_id || rol?.rolId || "";
}

function mostrarOperacion(operacion) {
  if (operacion === "I") return "Insertó";
  if (operacion === "U") return "Actualizó";
  if (operacion === "D") return "Eliminó";
  return operacion || "Sin operación";
}

function obtenerValor(objeto, ...claves) {
  for (const clave of claves) {
    if (objeto?.[clave] !== undefined && objeto?.[clave] !== null) {
      return objeto[clave];
    }
  }

  return "";
}

function SuperAdminDashboardPage({ usuario, cerrarSesionUsuario }) {
  const { token } = useAuth();

  const [usuarios, setUsuarios] = useState([]);
  const [roles, setRoles] = useState([]);
  const [auditorias, setAuditorias] = useState([]);
  const [reporte, setReporte] = useState({});
  const [ventasProductos, setVentasProductos] = useState([]);
  const [ventasPeriodo, setVentasPeriodo] = useState([]);
  const [ventasMetodoPago, setVentasMetodoPago] = useState([]);
  const [topProductos, setTopProductos] = useState([]);
  const [clientesCompras, setClientesCompras] = useState([]);
  const [productosBajoStock, setProductosBajoStock] = useState([]);
  const [usuariosPorRol, setUsuariosPorRol] = useState([]);

  const [mensaje, setMensaje] = useState("");
  const [tipoMensaje, setTipoMensaje] = useState("");
  const [cargando, setCargando] = useState(true);

  const [filtrosAuditoria, setFiltrosAuditoria] = useState({
    tabla: "",
    operacion: "",
    registradoPor: "",
    desde: "",
    hasta: ""
  });

  const [nuevoUsuario, setNuevoUsuario] = useState({
    nombre: "",
    telefono: "",
    correo: "",
    password: "",
    genero: "",
    fechaNacimiento: "",
    rol: "ADMIN"
  });

  const tablasAuditoria = useMemo(() => {
    const tablas = auditorias
      .map((item) => item.tabla)
      .filter(Boolean);

    return [...new Set(tablas)];
  }, [auditorias]);

  const cargarInformacion = useCallback(async () => {
    try {
      setCargando(true);
      setMensaje("");

      const [
        usuariosData,
        rolesData,
        auditoriaData,
        reporteData,
        ventasProductoData,
        ventasPeriodoData,
        ventasMetodoPagoData,
        topProductosData,
        clientesComprasData,
        productosBajoStockData,
        usuariosPorRolData
      ] = await Promise.all([
        listarUsuarios(token),
        listarRoles(token),
        listarAuditoria(token),
        obtenerReporteGeneral(token),
        obtenerVentasPorProducto(token),
        obtenerVentasPorPeriodo(token),
        obtenerVentasPorMetodoPago(token),
        obtenerTopProductos(token),
        obtenerClientesMasCompras(token),
        obtenerProductosBajoStock(token),
        obtenerUsuariosPorRol(token)
      ]);

      setUsuarios(usuariosData);
      setRoles(rolesData);
      setAuditorias(auditoriaData);
      setReporte(reporteData);
      setVentasProductos(ventasProductoData);
      setVentasPeriodo(ventasPeriodoData);
      setVentasMetodoPago(ventasMetodoPagoData);
      setTopProductos(topProductosData);
      setClientesCompras(clientesComprasData);
      setProductosBajoStock(productosBajoStockData);
      setUsuariosPorRol(usuariosPorRolData);
    } catch (error) {
      setMensaje(error.message || "No se pudo cargar la información.");
      setTipoMensaje("error");
    } finally {
      setCargando(false);
    }
  }, [token]);

  useEffect(() => {
    cargarInformacion();
  }, [cargarInformacion]);

  const actualizarCampo = (evento) => {
    const { name, value } = evento.target;

    setNuevoUsuario((datos) => ({
      ...datos,
      [name]: value
    }));
  };

  const actualizarFiltroAuditoria = (evento) => {
    const { name, value } = evento.target;

    setFiltrosAuditoria((filtros) => ({
      ...filtros,
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
      const usuarioId = obtenerIdUsuario(usuarioItem);

      await cambiarEstadoUsuario(usuarioId, !usuarioItem.activo, token);
      setMensaje("Estado del usuario actualizado.");
      setTipoMensaje("success");
      await cargarInformacion();
    } catch (error) {
      setMensaje(error.message || "No se pudo cambiar el estado del usuario.");
      setTipoMensaje("error");
    }
  };

  const actualizarRol = async (usuarioItem, rolId) => {
    try {
      const usuarioId = obtenerIdUsuario(usuarioItem);

      await cambiarRolUsuario(usuarioId, rolId, token);
      setMensaje("Rol actualizado correctamente.");
      setTipoMensaje("success");
      await cargarInformacion();
    } catch (error) {
      setMensaje(error.message || "No se pudo cambiar el rol del usuario.");
      setTipoMensaje("error");
    }
  };

  const aplicarFiltrosAuditoria = async (evento) => {
    evento.preventDefault();

    try {
      const auditoriaFiltrada = await filtrarAuditoria(
        filtrosAuditoria,
        token
      );

      setAuditorias(auditoriaFiltrada);
      setMensaje("Auditoría filtrada correctamente.");
      setTipoMensaje("success");
    } catch (error) {
      setMensaje(error.message || "No se pudo filtrar la auditoría.");
      setTipoMensaje("error");
    }
  };

  const limpiarFiltrosAuditoria = async () => {
    setFiltrosAuditoria({
      tabla: "",
      operacion: "",
      registradoPor: "",
      desde: "",
      hasta: ""
    });

    await cargarInformacion();
  };

  const actualizarReportes = async () => {
    try {
      await refrescarReportes(token);
      setMensaje("Reportes actualizados correctamente.");
      setTipoMensaje("success");
      await cargarInformacion();
    } catch (error) {
      setMensaje(error.message || "No se pudieron actualizar los reportes.");
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
            roles, auditorías, seguridad y reportes generales.
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
          <h2>{obtenerValor(reporte, "total_usuarios", "totalUsuarios") || usuarios.length}</h2>
          <span>Registrados en el sistema</span>
        </article>

        <article className="admin-summary-card">
          <p>Usuarios activos</p>
          <h2>{obtenerValor(reporte, "usuarios_activos", "usuariosActivos") || 0}</h2>
          <span>Usuarios habilitados</span>
        </article>

        <article className="admin-summary-card">
          <p>Productos</p>
          <h2>{obtenerValor(reporte, "total_productos", "totalProductos") || 0}</h2>
          <span>Productos del catálogo</span>
        </article>

        <article className="admin-summary-card">
          <p>Ventas</p>
          <h2>{obtenerValor(reporte, "total_ventas", "totalVentas") || 0}</h2>
          <span>Ventas registradas</span>
        </article>

        <article className="admin-summary-card">
          <p>Monto vendido</p>
          <h2>${Number(obtenerValor(reporte, "monto_ventas", "montoVentas") || 0).toLocaleString("es-CO")}</h2>
          <span>Total vendido</span>
        </article>

        <article className="admin-summary-card">
          <p>Auditorías</p>
          <h2>{obtenerValor(reporte, "total_auditorias", "totalAuditorias") || auditorias.length}</h2>
          <span>Movimientos registrados</span>
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
            <h2>Crear usuario</h2>
            <p>
              El superadministrador puede crear usuarios usando los
              procedimientos centralizados en PostgreSQL.
            </p>
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
              {roles.map((rol) => (
                <option
                  key={rol.rol_id || rol.rolId}
                  value={rol.rol || rol.nombre}
                >
                  {rol.rol || rol.nombre}
                </option>
              ))}
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
        ) : usuarios.length === 0 ? (
          <div className="admin-empty-state">
            <p>No hay usuarios registrados.</p>
          </div>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
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
                  <tr key={obtenerIdUsuario(usuarioItem)}>
                    <td>{obtenerIdUsuario(usuarioItem)}</td>
                    <td>{usuarioItem.nombre}</td>
                    <td>{usuarioItem.correo}</td>
                    <td>{usuarioItem.telefono || "Sin teléfono"}</td>
                    <td>
                      <select
                        value={obtenerRolId(usuarioItem, roles)}
                        onChange={(evento) =>
                          actualizarRol(usuarioItem, evento.target.value)
                        }
                      >
                        {roles.map((rol) => (
                          <option
                            key={rol.rol_id || rol.rolId}
                            value={rol.rol_id || rol.rolId}
                          >
                            {rol.rol || rol.nombre}
                          </option>
                        ))}
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
            <p>Filtra movimientos registrados automáticamente en PostgreSQL.</p>
          </div>
        </div>

        <form className="admin-form-grid" onSubmit={aplicarFiltrosAuditoria}>
          <label>
            Tabla
            <select
              name="tabla"
              value={filtrosAuditoria.tabla}
              onChange={actualizarFiltroAuditoria}
            >
              <option value="">Todas</option>
              {tablasAuditoria.map((tabla) => (
                <option key={tabla} value={tabla}>
                  {tabla}
                </option>
              ))}
            </select>
          </label>

          <label>
            Operación
            <select
              name="operacion"
              value={filtrosAuditoria.operacion}
              onChange={actualizarFiltroAuditoria}
            >
              <option value="">Todas</option>
              <option value="I">Insertó</option>
              <option value="U">Actualizó</option>
              <option value="D">Eliminó</option>
            </select>
          </label>

          <label>
            Usuario BD
            <input
              name="registradoPor"
              value={filtrosAuditoria.registradoPor}
              onChange={actualizarFiltroAuditoria}
              placeholder="postgres"
            />
          </label>

          <label>
            Desde
            <input
              type="date"
              name="desde"
              value={filtrosAuditoria.desde}
              onChange={actualizarFiltroAuditoria}
            />
          </label>

          <label>
            Hasta
            <input
              type="date"
              name="hasta"
              value={filtrosAuditoria.hasta}
              onChange={actualizarFiltroAuditoria}
            />
          </label>

          <button type="submit">Filtrar auditoría</button>
          <button type="button" onClick={limpiarFiltrosAuditoria}>
            Limpiar filtros
          </button>
        </form>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Tabla</th>
                <th>ID afectado</th>
                <th>Operación</th>
                <th>Fecha</th>
                <th>Usuario BD</th>
                <th>Detalle</th>
              </tr>
            </thead>

            <tbody>
              {auditorias.slice(0, 50).map((auditoria, index) => (
                <tr key={index}>
                  <td>{auditoria.tabla}</td>
                  <td>{auditoria.id_afectado || auditoria.idAfectado || "-"}</td>
                  <td>{mostrarOperacion(auditoria.operacion)}</td>
                  <td>{auditoria.fecha_cambio || auditoria.fechaCambio}</td>
                  <td>{auditoria.registrado_por || auditoria.registradoPor}</td>
                  <td>{auditoria.detalle || "-"}</td>
                </tr>
              ))}

              {auditorias.length === 0 && (
                <tr>
                  <td colSpan="6">No hay registros de auditoría.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Reportes generales</h2>
            <p>Indicadores del sistema consultados desde vistas de PostgreSQL.</p>
          </div>

          <button type="button" onClick={actualizarReportes}>
            Refrescar reportes
          </button>
        </div>

        <div className="admin-report-grid">
          <div className="admin-report-card">
            <h3>Ventas por producto</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Unidades</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {ventasProductos.slice(0, 5).map((item, index) => (
                  <tr key={index}>
                    <td>{item.producto}</td>
                    <td>{item.unidades_vendidas}</td>
                    <td>${Number(item.total_generado || 0).toLocaleString("es-CO")}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="admin-report-card">
            <h3>Ventas por periodo</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Fecha</th>
                  <th>Ventas</th>
                  <th>Monto</th>
                </tr>
              </thead>
              <tbody>
                {ventasPeriodo.slice(0, 5).map((item, index) => (
                  <tr key={index}>
                    <td>{item.fecha}</td>
                    <td>{item.total_ventas}</td>
                    <td>${Number(item.monto_total || 0).toLocaleString("es-CO")}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="admin-report-card">
            <h3>Ventas por método de pago</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Método</th>
                  <th>Cantidad</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {ventasMetodoPago.map((item, index) => (
                  <tr key={index}>
                    <td>{item.metodo_pago}</td>
                    <td>{item.cantidad_pagos}</td>
                    <td>${Number(item.total_pagado || 0).toLocaleString("es-CO")}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="admin-report-card">
            <h3>Productos bajo stock</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Talla</th>
                  <th>Color</th>
                  <th>Stock</th>
                </tr>
              </thead>
              <tbody>
                {productosBajoStock.slice(0, 8).map((item, index) => (
                  <tr key={index}>
                    <td>{item.producto}</td>
                    <td>{item.talla}</td>
                    <td>{item.color}</td>
                    <td>{item.stock}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="admin-report-card">
            <h3>Usuarios por rol</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Rol</th>
                  <th>Total</th>
                  <th>Activos</th>
                  <th>Inactivos</th>
                </tr>
              </thead>
              <tbody>
                {usuariosPorRol.map((item, index) => (
                  <tr key={index}>
                    <td>{item.rol}</td>
                    <td>{item.total_usuarios}</td>
                    <td>{item.usuarios_activos}</td>
                    <td>{item.usuarios_inactivos}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="admin-report-card">
            <h3>Clientes con más compras</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Cliente</th>
                  <th>Compras</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {clientesCompras.slice(0, 5).map((item, index) => (
                  <tr key={index}>
                    <td>{item.cliente}</td>
                    <td>{item.total_compras}</td>
                    <td>${Number(item.total_pagado || 0).toLocaleString("es-CO")}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="admin-report-card">
            <h3>Top productos</h3>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Unidades</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {topProductos.slice(0, 5).map((item, index) => (
                  <tr key={index}>
                    <td>{item.producto}</td>
                    <td>{item.unidades_vendidas}</td>
                    <td>${Number(item.total_generado || 0).toLocaleString("es-CO")}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>
    </main>
  );
}

export default SuperAdminDashboardPage;