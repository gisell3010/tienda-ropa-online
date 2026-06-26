import { useCart } from "../context/CartContext";

function Navbar({
  irACatalogo,
  irACarrito,
  irAPerfilCliente,
  irAPedidosCliente,
  cerrarSesionUsuario,
  usuario,
  vistaActual
}) {
  const { cantidadTotalProductos } = useCart();

  const nombreUsuario = usuario?.nombre || usuario?.correo || "Usuario";
  const primerNombre = nombreUsuario.trim().split(" ")[0] || "Usuario";
  const inicialUsuario = primerNombre.charAt(0).toUpperCase() || "U";

  return (
    <header className="navbar">
      <button
        type="button"
        className="navbar__brand"
        onClick={irACatalogo}
        aria-label="Ir al catálogo"
      >
        <h2>ShopNMG</h2>
        <p>Moda urbana y casual</p>
      </button>

      <div className="navbar__right">
        <nav className="navbar__links" aria-label="Navegación principal">
          <button
            type="button"
            onClick={irACatalogo}
            className={vistaActual === "catalogo" ? "navbar__link--active" : ""}
          >
            Catálogo
          </button>

          <button
            type="button"
            onClick={irACarrito}
            className={`navbar__cart-button ${
              vistaActual === "carrito" ? "navbar__link--active" : ""
            }`}
          >
            Carrito
            {cantidadTotalProductos > 0 && (
              <span className="navbar__cart-count">
                {cantidadTotalProductos}
              </span>
            )}
          </button>

          <button
            type="button"
            onClick={irAPedidosCliente}
            className={
              vistaActual === "pedidosCliente" ? "navbar__link--active" : ""
            }
          >
            Mis pedidos
          </button>

          <button
            type="button"
            onClick={irAPerfilCliente}
            className={
              vistaActual === "perfilCliente" ? "navbar__link--active" : ""
            }
          >
            Mi perfil
          </button>
        </nav>

        <div className="navbar__actions">
          {usuario && (
            <div
              className="navbar__account-summary"
              aria-label="Usuario autenticado"
            >
              <span className="navbar__avatar">{inicialUsuario}</span>
              <span className="navbar__account-name">{primerNombre}</span>
            </div>
          )}

          <button
            type="button"
            className="navbar__logout-button"
            onClick={cerrarSesionUsuario}
          >
            Cerrar sesión
          </button>
        </div>
      </div>
    </header>
  );
}

export default Navbar;