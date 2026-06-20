import { useEffect, useState } from "react";
import {
  listarProductosAdmin,
  obtenerResumenAdmin,
  listarPedidosAdmin,
  listarVentasAdmin,
  listarPagosAdmin
} from "../services/adminService";
import "../styles/admin.css";

function AdminDashboardPage({ usuario, cerrarSesionUsuario }) {
  const [resumen, setResumen] = useState({
    totalProductos: 0,
    productosDisponibles: 0,
    productosAgotados: 0,
    pedidosRegistrados: 0,
    ventasRegistradas: 0,
    pagosRegistrados: 0
  });

  const [productos, setProductos] = useState([]);
  const [mensajePedidos, setMensajePedidos] = useState("");
  const [mensajeVentas, setMensajeVentas] = useState("");
  const [mensajePagos, setMensajePagos] = useState("");
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    cargarInformacionAdmin();
  }, []);

  const cargarInformacionAdmin = async () => {
    try {
      setCargando(true);

      const resumenAdmin = await obtenerResumenAdmin();
      const productosAdmin = await listarProductosAdmin();
      const pedidosAdmin = await listarPedidosAdmin();
      const ventasAdmin = await listarVentasAdmin();
      const pagosAdmin = await listarPagosAdmin();

      setResumen(resumenAdmin);
      setProductos(productosAdmin);

      setMensajePedidos(pedidosAdmin.mensaje || "");
      setMensajeVentas(ventasAdmin.mensaje || "");
      setMensajePagos(pagosAdmin.mensaje || "");
    } catch (error) {
      console.error("Error al cargar información administrativa:", error);
    } finally {
      setCargando(false);
    }
  };

  const formatearPrecio = (valor) => {
    return Number(valor || 0).toLocaleString("es-CO", {
      style: "currency",
      currency: "COP",
      minimumFractionDigits: 0
    });
  };

  return (
    <main className="admin-page">
      <section className="admin-hero">
        <div>
          <span className="admin-label">Panel administrativo</span>
          <h1>Gestión general de la tienda</h1>
          <p>
            Desde este módulo el administrador puede revisar productos,
            inventario, pedidos, ventas, pagos y reportes básicos del sistema.
          </p>
        </div>

        <div className="admin-user-card">
          <p>Sesión activa</p>
          <h3>{usuario?.nombre || usuario?.correo || "Administrador"}</h3>
          <span>{usuario?.rol || "ADMIN"}</span>

          <button type="button" onClick={cerrarSesionUsuario}>
            Cerrar sesión
          </button>
        </div>
      </section>

      <section className="admin-summary-grid">
        <article className="admin-summary-card">
          <p>Total productos</p>
          <h2>{resumen.totalProductos}</h2>
          <span>Productos registrados</span>
        </article>

        <article className="admin-summary-card">
          <p>Disponibles</p>
          <h2>{resumen.productosDisponibles}</h2>
          <span>Con stock activo</span>
        </article>

        <article className="admin-summary-card">
          <p>Agotados</p>
          <h2>{resumen.productosAgotados}</h2>
          <span>Sin unidades disponibles</span>
        </article>

        <article className="admin-summary-card">
          <p>Pedidos</p>
          <h2>{resumen.pedidosRegistrados}</h2>
          <span>Pendiente endpoint</span>
        </article>
      </section>

      <section className="admin-modules-grid">
        <article className="admin-module-card">
          <h3>Productos</h3>
          <p>
            Consulta general de productos registrados en el catálogo de la
            tienda.
          </p>
          <span>Conectado a /api/productos</span>
        </article>

        <article className="admin-module-card">
          <h3>Inventario</h3>
          <p>
            Revisión visual del stock disponible por producto, talla y color.
          </p>
          <span>Validación preparada</span>
        </article>

        <article className="admin-module-card">
          <h3>Pedidos y ventas</h3>
          <p>
            Módulo preparado para consultar compras realizadas por los clientes.
          </p>
          <span>{mensajePedidos || mensajeVentas || "Pendiente backend"}</span>
        </article>

        <article className="admin-module-card">
          <h3>Pagos y reportes</h3>
          <p>
            Sección destinada a revisar pagos registrados y resumen de ventas.
          </p>
          <span>{mensajePagos || "Pendiente backend"}</span>
        </article>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Productos registrados</h2>
            <p>Listado conectado al servicio disponible del backend.</p>
          </div>

          <button type="button" onClick={cargarInformacionAdmin}>
            Actualizar
          </button>
        </div>

        {cargando ? (
          <div className="admin-empty-state">
            <p>Cargando información del panel administrativo...</p>
          </div>
        ) : productos.length === 0 ? (
          <div className="admin-empty-state">
            <p>
              No se encontraron productos o el backend no respondió datos para
              esta sección.
            </p>
          </div>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Categoría</th>
                  <th>Estilo</th>
                  <th>Talla</th>
                  <th>Color</th>
                  <th>Stock</th>
                  <th>Precio</th>
                  <th>Estado</th>
                </tr>
              </thead>

              <tbody>
                {productos.map((producto, index) => (
                  <tr key={producto.id || index}>
                    <td>{producto.nombre}</td>
                    <td>{producto.categoria}</td>
                    <td>{producto.estilo}</td>
                    <td>{producto.talla}</td>
                    <td>{producto.color}</td>
                    <td>{producto.stock}</td>
                    <td>{formatearPrecio(producto.precio)}</td>
                    <td>
                      <span
                        className={
                          producto.stock > 0 ||
                          producto.estado === "DISPONIBLE"
                            ? "admin-status admin-status--active"
                            : "admin-status admin-status--inactive"
                        }
                      >
                        {producto.estado}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </main>
  );
}

export default AdminDashboardPage;