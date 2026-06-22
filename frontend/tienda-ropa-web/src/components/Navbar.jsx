import { useCart } from "../context/CartContext";

function Navbar({ irACatalogo, irACarrito, cerrarSesionUsuario, usuario, rolUsuario }) {
  const { cantidadTotalProductos } = useCart();

  return (
    <header className="navbar">
      <div className="navbar__brand" onClick={irACatalogo}>
        <h2>ShopNMG</h2>
        <p>Moda urbana y casual</p>
      </div>

      <nav className="navbar__links">
        <button type="button" onClick={irACatalogo}>
          Catálogo
        </button>

        <button type="button" onClick={irACarrito} className="navbar__cart-button">
          Carrito
          {cantidadTotalProductos > 0 && (
            <span className="navbar__cart-count">{cantidadTotalProductos}</span>
          )}
        </button>

        {usuario && (
          <div className="navbar__session">
            <span className="navbar__session-name">
              {usuario.nombre || usuario.correo}
            </span>

            <span className="navbar__session-role">
              {rolUsuario}
            </span>
          </div>
        )}

        <button
          type="button"
          className="navbar__logout-button"
          onClick={cerrarSesionUsuario}
        >
          Cerrar sesión
        </button>
      </nav>
    </header>
  );
}

export default Navbar;