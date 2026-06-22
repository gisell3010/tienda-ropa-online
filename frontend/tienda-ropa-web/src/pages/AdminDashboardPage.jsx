import { useCallback, useEffect, useState } from "react";
import { useAuth } from "../context/AuthContext";
import {
  listarProductosAdmin,
  listarInventarioAdmin,
  listarPedidosAdmin,
  listarVentasAdmin,
  listarPagosAdmin,
  listarCategoriasAdmin,
  listarEstilosAdmin,
  listarTallasAdmin,
  listarColoresAdmin,
  crearProductoAdmin,
  editarProductoAdmin,
  cambiarEstadoProductoAdmin,
  registrarInventarioAdmin,
  actualizarInventarioAdmin
} from "../services/adminService";
import "../styles/admin.css";

const productoInicial = {
  nombre: "",
  precio: "",
  imagenUrl: "",
  catId: "",
  estId: ""
};

const inventarioInicial = {
  proId: "",
  talId: "",
  colId: "",
  stock: ""
};

function AdminDashboardPage({ usuario, cerrarSesionUsuario }) {
  const { token } = useAuth();

  const [resumen, setResumen] = useState({
    totalProductos: 0,
    productosDisponibles: 0,
    productosAgotados: 0,
    pedidosRegistrados: 0,
    ventasRegistradas: 0,
    pagosRegistrados: 0
  });

  const [productos, setProductos] = useState([]);
  const [inventario, setInventario] = useState([]);
  const [pedidos, setPedidos] = useState([]);
  const [ventas, setVentas] = useState([]);
  const [pagos, setPagos] = useState([]);

  const [categorias, setCategorias] = useState([]);
  const [estilos, setEstilos] = useState([]);
  const [tallas, setTallas] = useState([]);
  const [colores, setColores] = useState([]);

  const [productoForm, setProductoForm] = useState(productoInicial);
  const [inventarioForm, setInventarioForm] = useState(inventarioInicial);
  const [productoEditando, setProductoEditando] = useState(null);

  const [mensaje, setMensaje] = useState("");
  const [tipoMensaje, setTipoMensaje] = useState("");
  const [cargando, setCargando] = useState(true);

  const formatearPrecio = (valor) => {
    return Number(valor || 0).toLocaleString("es-CO", {
      style: "currency",
      currency: "COP",
      minimumFractionDigits: 0
    });
  };

  const cargarInformacionAdmin = useCallback(async () => {
    try {
      setCargando(true);
      setMensaje("");

      const [
        productosData,
        inventarioData,
        pedidosData,
        ventasData,
        pagosData,
        categoriasData,
        estilosData,
        tallasData,
        coloresData
      ] = await Promise.all([
        listarProductosAdmin(token),
        listarInventarioAdmin(token),
        listarPedidosAdmin(token),
        listarVentasAdmin(token),
        listarPagosAdmin(token),
        listarCategoriasAdmin(token),
        listarEstilosAdmin(token),
        listarTallasAdmin(token),
        listarColoresAdmin(token)
      ]);

      setProductos(productosData);
      setInventario(inventarioData);
      setPedidos(pedidosData);
      setVentas(ventasData);
      setPagos(pagosData);
      setCategorias(categoriasData);
      setEstilos(estilosData);
      setTallas(tallasData);
      setColores(coloresData);

      setResumen({
        totalProductos: productosData.length,
        productosDisponibles: inventarioData.filter((item) => item.stock > 0).length,
        productosAgotados: inventarioData.filter((item) => item.stock <= 0).length,
        pedidosRegistrados: pedidosData.length,
        ventasRegistradas: ventasData.length,
        pagosRegistrados: pagosData.length
      });
    } catch (error) {
      setMensaje(error.message || "No se pudo cargar la información administrativa.");
      setTipoMensaje("error");
    } finally {
      setCargando(false);
    }
  }, [token]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    cargarInformacionAdmin();
  }, [cargarInformacionAdmin]);

  const actualizarProductoForm = (evento) => {
    const { name, value } = evento.target;

    setProductoForm((datos) => ({
      ...datos,
      [name]: value
    }));
  };

  const actualizarInventarioForm = (evento) => {
    const { name, value } = evento.target;

    setInventarioForm((datos) => ({
      ...datos,
      [name]: value
    }));
  };

  const limpiarFormularioProducto = () => {
    setProductoForm(productoInicial);
    setProductoEditando(null);
  };

  const guardarProducto = async (evento) => {
    evento.preventDefault();

    try {
      setMensaje("");

      if (!productoForm.nombre.trim()) {
        throw new Error("El nombre del producto es obligatorio.");
      }

      if (!productoForm.precio || Number(productoForm.precio) <= 0) {
        throw new Error("El precio debe ser mayor que cero.");
      }

      if (!productoForm.catId) {
        throw new Error("Selecciona una categoría.");
      }

      if (!productoForm.estId) {
        throw new Error("Selecciona un estilo.");
      }

      const datosProducto = {
        nombre: productoForm.nombre.trim(),
        precio: Number(productoForm.precio),
        imagenUrl: productoForm.imagenUrl.trim(),
        catId: Number(productoForm.catId),
        estId: Number(productoForm.estId)
      };

      if (productoEditando) {
        await editarProductoAdmin(productoEditando.proId, datosProducto, token);
        setMensaje("Producto actualizado correctamente.");
      } else {
        await crearProductoAdmin(datosProducto, token);
        setMensaje("Producto registrado correctamente.");
      }

      setTipoMensaje("success");
      limpiarFormularioProducto();
      await cargarInformacionAdmin();
    } catch (error) {
      setMensaje(error.message || "No se pudo guardar el producto.");
      setTipoMensaje("error");
    }
  };

  const seleccionarProductoParaEditar = (producto) => {
    setProductoEditando(producto);

    setProductoForm({
      nombre: producto.nombre || "",
      precio: producto.precio || "",
      imagenUrl: producto.imagenUrl || "",
      catId: producto.catId || "",
      estId: producto.estId || ""
    });

    window.scrollTo({
      top: 0,
      behavior: "smooth"
    });
  };

  const cambiarEstadoProducto = async (producto) => {
    try {
      await cambiarEstadoProductoAdmin(
      producto.proId,
      producto.activo !== true,
      token
    );

      setMensaje("Estado del producto actualizado correctamente.");
      setTipoMensaje("success");

      await cargarInformacionAdmin();
    } catch (error) {
      setMensaje(error.message || "No se pudo cambiar el estado del producto.");
      setTipoMensaje("error");
    }
  };

  const guardarInventario = async (evento) => {
    evento.preventDefault();

    try {
      setMensaje("");

      if (!inventarioForm.proId) {
        throw new Error("Selecciona un producto.");
      }

      if (!inventarioForm.talId) {
        throw new Error("Selecciona una talla.");
      }

      if (!inventarioForm.colId) {
        throw new Error("Selecciona un color.");
      }

      if (inventarioForm.stock === "" || Number(inventarioForm.stock) < 0) {
        throw new Error("El stock no puede ser negativo.");
      }

      await registrarInventarioAdmin(
        {
          proId: Number(inventarioForm.proId),
          talId: Number(inventarioForm.talId),
          colId: Number(inventarioForm.colId),
          stock: Number(inventarioForm.stock)
        },
        token
      );

      setMensaje("Inventario registrado correctamente.");
      setTipoMensaje("success");
      setInventarioForm(inventarioInicial);

      await cargarInformacionAdmin();
    } catch (error) {
      setMensaje(error.message || "No se pudo registrar el inventario.");
      setTipoMensaje("error");
    }
  };

  const actualizarStock = async (item) => {
    const nuevoStock = window.prompt(
      `Nuevo stock para ${item.producto} - ${item.talla} - ${item.color}:`,
      item.stock
    );

    if (nuevoStock === null) {
      return;
    }

    if (nuevoStock.trim() === "" || Number(nuevoStock) < 0) {
      setMensaje("El stock no puede estar vacío ni ser negativo.");
      setTipoMensaje("error");
      return;
    }

    try {
      await actualizarInventarioAdmin(item.invId, Number(nuevoStock), token);

      setMensaje("Stock actualizado correctamente.");
      setTipoMensaje("success");

      await cargarInformacionAdmin();
    } catch (error) {
      setMensaje(error.message || "No se pudo actualizar el stock.");
      setTipoMensaje("error");
    }
  };

  return (
    <main className="admin-page">
      <section className="admin-hero">
        <div>
          <span className="admin-label">Panel administrativo</span>
          <h1>Gestión general de la tienda</h1>
          <p>
            Desde este módulo el administrador puede crear productos, gestionar
            inventario, actualizar stock, revisar ventas, pagos y pedidos.
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
          <span>Inventarios con stock</span>
        </article>

        <article className="admin-summary-card">
          <p>Agotados</p>
          <h2>{resumen.productosAgotados}</h2>
          <span>Inventarios sin stock</span>
        </article>

        <article className="admin-summary-card">
          <p>Ventas</p>
          <h2>{resumen.ventasRegistradas}</h2>
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
            <h2>{productoEditando ? "Editar producto" : "Crear producto"}</h2>
            <p>
              Registra productos del catálogo indicando categoría, estilo,
              precio e imagen.
            </p>
          </div>

          {productoEditando && (
            <button type="button" onClick={limpiarFormularioProducto}>
              Cancelar edición
            </button>
          )}
        </div>

        <form className="admin-form-grid" onSubmit={guardarProducto}>
          <label>
            Nombre del producto
            <input
              name="nombre"
              value={productoForm.nombre}
              onChange={actualizarProductoForm}
              placeholder="Ej: Camiseta oversize"
            />
          </label>

          <label>
            Precio
            <input
              type="number"
              name="precio"
              value={productoForm.precio}
              onChange={actualizarProductoForm}
              placeholder="Ej: 55000"
            />
          </label>

          <label>
            Imagen URL
            <input
              name="imagenUrl"
              value={productoForm.imagenUrl}
              onChange={actualizarProductoForm}
              placeholder="https://..."
            />
          </label>

          <label>
            Categoría
            <select
              name="catId"
              value={productoForm.catId}
              onChange={actualizarProductoForm}
            >
              <option value="">Selecciona</option>
              {categorias.map((categoria) => (
                <option key={categoria.id} value={categoria.id}>
                  {categoria.nombre}
                </option>
              ))}
            </select>
          </label>

          <label>
            Estilo
            <select
              name="estId"
              value={productoForm.estId}
              onChange={actualizarProductoForm}
            >
              <option value="">Selecciona</option>
              {estilos.map((estilo) => (
                <option key={estilo.id} value={estilo.id}>
                  {estilo.nombre}
                </option>
              ))}
            </select>
          </label>

          <button type="submit">
            {productoEditando ? "Actualizar producto" : "Crear producto"}
          </button>
        </form>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Registrar inventario</h2>
            <p>
              Asigna talla, color y stock a un producto. Si la combinación ya
              existe, el procedimiento suma el stock.
            </p>
          </div>
        </div>

        <form className="admin-form-grid" onSubmit={guardarInventario}>
          <label>
            Producto
            <select
              name="proId"
              value={inventarioForm.proId}
              onChange={actualizarInventarioForm}
            >
              <option value="">Selecciona</option>
              {productos.map((producto) => (
                <option key={producto.proId} value={producto.proId}>
                  {producto.nombre}
                </option>
              ))}
            </select>
          </label>

          <label>
            Talla
            <select
              name="talId"
              value={inventarioForm.talId}
              onChange={actualizarInventarioForm}
            >
              <option value="">Selecciona</option>
              {tallas.map((talla) => (
                <option key={talla.id} value={talla.id}>
                  {talla.nombre}
                </option>
              ))}
            </select>
          </label>

          <label>
            Color
            <select
              name="colId"
              value={inventarioForm.colId}
              onChange={actualizarInventarioForm}
            >
              <option value="">Selecciona</option>
              {colores.map((color) => (
                <option key={color.id} value={color.id}>
                  {color.nombre}
                </option>
              ))}
            </select>
          </label>

          <label>
            Stock
            <input
              type="number"
              name="stock"
              value={inventarioForm.stock}
              onChange={actualizarInventarioForm}
              placeholder="Ej: 10"
            />
          </label>

          <button type="submit">Registrar inventario</button>
        </form>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Productos registrados</h2>
            <p>Listado de productos para editar o activar/desactivar.</p>
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
            <p>No se encontraron productos registrados.</p>
          </div>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Categoría</th>
                  <th>Estilo</th>
                  <th>Precio</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>

              <tbody>
                {productos.map((producto) => (
                  <tr key={producto.proId}>
                    <td>{producto.nombre}</td>
                    <td>{producto.categoria}</td>
                    <td>{producto.estilo}</td>
                    <td>{formatearPrecio(producto.precio)}</td>
                    <td>
                      <span
                        className={
                          producto.activo
                            ? "admin-status admin-status--active"
                            : "admin-status admin-status--inactive"
                        }
                      >
                        {producto.activo ? "Activo" : "Inactivo"}
                      </span>
                    </td>
                    <td>
                      <div className="admin-actions">
                        <button
                          type="button"
                          onClick={() => seleccionarProductoParaEditar(producto)}
                        >
                          Editar
                        </button>

                        <button
                          type="button"
                          className="admin-button-secondary"
                          onClick={() => cambiarEstadoProducto(producto)}
                        >
                          {producto.activo ? "Desactivar" : "Activar"}
                        </button>
                      </div>
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
            <h2>Inventario</h2>
            <p>Stock disponible por producto, talla y color.</p>
          </div>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Producto</th>
                <th>Talla</th>
                <th>Color</th>
                <th>Stock</th>
                <th>Estado</th>
                <th>Acción</th>
              </tr>
            </thead>

            <tbody>
              {inventario.map((item) => (
                <tr key={item.invId}>
                  <td>{item.producto}</td>
                  <td>{item.talla}</td>
                  <td>{item.color}</td>
                  <td>{item.stock}</td>
                  <td>
                    <span
                      className={
                        item.stock > 0
                          ? "admin-status admin-status--active"
                          : "admin-status admin-status--inactive"
                      }
                    >
                      {item.estado || (item.stock > 0 ? "DISPONIBLE" : "AGOTADO")}
                    </span>
                  </td>
                  <td>
                    <button type="button" onClick={() => actualizarStock(item)}>
                      Actualizar stock
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Ventas y pedidos</h2>
            <p>Consulta de ventas, pedidos y pagos registrados.</p>
          </div>
        </div>

        <section className="admin-modules-grid">
          <article className="admin-module-card">
            <h3>Pedidos</h3>
            <p>{resumen.pedidosRegistrados} pedidos registrados.</p>
            <span>Consulta administrativa</span>
          </article>

          <article className="admin-module-card">
            <h3>Ventas</h3>
            <p>{resumen.ventasRegistradas} ventas registradas.</p>
            <span>Ventas del sistema</span>
          </article>

          <article className="admin-module-card">
            <h3>Pagos</h3>
            <p>{resumen.pagosRegistrados} pagos registrados.</p>
            <span>Pagos del sistema</span>
          </article>

          <article className="admin-module-card">
            <h3>Total generado</h3>
            <p>
              {formatearPrecio(
                ventas.reduce(
                  (total, venta) =>
                    total + Number(venta.subtotal || venta.total_venta || 0),
                  0
                )
              )}
            </p>
            <span>Resumen de ventas</span>
          </article>
        </section>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Venta</th>
                <th>Cliente</th>
                <th>Producto</th>
                <th>Cantidad</th>
                <th>Subtotal</th>
                <th>Método pago</th>
              </tr>
            </thead>

            <tbody>
              {ventas.slice(0, 20).map((venta, index) => (
                <tr key={`${venta.ven_id || venta.venId}-${index}`}>
                  <td>{venta.ven_id || venta.venId}</td>
                  <td>{venta.cliente}</td>
                  <td>{venta.producto}</td>
                  <td>{venta.cantidad}</td>
                  <td>{formatearPrecio(venta.subtotal)}</td>
                  <td>{venta.metodo_pago || venta.metodoPago || "N/A"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="admin-table-section">
        <div className="admin-section-header">
          <div>
            <h2>Pagos registrados</h2>
            <p>Últimos pagos guardados en el sistema.</p>
          </div>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Pago</th>
                <th>Venta</th>
                <th>Método</th>
                <th>Monto</th>
              </tr>
            </thead>

            <tbody>
              {pagos.slice(0, 20).map((pago) => (
                <tr key={pago.pag_id || pago.pagId}>
                  <td>{pago.pag_id || pago.pagId}</td>
                  <td>{pago.ven_id || pago.venId}</td>
                  <td>{pago.met_id || pago.metodo_pago || pago.metodoPago}</td>
                  <td>{formatearPrecio(pago.monto)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {pedidos.length > 0 && (
        <section className="admin-table-section">
          <div className="admin-section-header">
            <div>
              <h2>Pedidos</h2>
              <p>Ventas registradas como pedidos del sistema.</p>
            </div>
          </div>

          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Cliente</th>
                  <th>Fecha</th>
                </tr>
              </thead>

              <tbody>
                {pedidos.slice(0, 20).map((pedido) => (
                  <tr key={pedido.ven_id || pedido.venId}>
                    <td>{pedido.ven_id || pedido.venId}</td>
                    <td>{pedido.per_id || pedido.perId}</td>
                    <td>{pedido.fecha}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}
    </main>
  );
}

export default AdminDashboardPage;