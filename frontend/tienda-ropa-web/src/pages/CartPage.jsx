import { useCart } from "../context/CartContext";
import "../styles/cart.css";

function CartPage({ irACatalogo, irACheckout }) {
  const {
    carrito,
    aumentarCantidad,
    disminuirCantidad,
    eliminarProducto,
    totalCompra
  } = useCart();

  const formatoCOP = (valor) => {
    return new Intl.NumberFormat("es-CO", {
      style: "currency",
      currency: "COP",
      maximumFractionDigits: 0
    }).format(valor);
  };

  if (carrito.length === 0) {
    return (
      <main className="cart-page">
        <section className="cart-empty">
          <span className="cart-empty__icon">🛒</span>
          <h1>Tu carrito está vacío</h1>
          <p>
            Agrega prendas desde el catálogo para revisar tu compra antes de finalizar el pedido.
          </p>

          <button className="cart-empty__button" onClick={irACatalogo}>
            Ver catálogo
          </button>
        </section>
      </main>
    );
  }

  return (
    <main className="cart-page">
      <section className="cart-header">
        <span className="cart-header__label">Carrito de compras</span>
        <h1>Revisa tus productos</h1>
        <p>
          Puedes modificar cantidades, eliminar prendas y revisar el total antes de continuar al pago.
        </p>
      </section>

      <section className="cart-layout">
        <div className="cart-list">
          {carrito.map((item) => (
            <article className="cart-item" key={item.itemId}>
              <div className="cart-item__image-box">
                <img src={item.imagen} alt={item.nombre} className="cart-item__image" />
              </div>

              <div className="cart-item__info">
                <h3>{item.nombre}</h3>

                <div className="cart-item__meta">
                  <span>
                    Talla: <strong>{item.talla}</strong>
                  </span>
                  <span>
                    Color: <strong>{item.color}</strong>
                  </span>
                  <span>
                    Stock disponible: <strong>{item.stockDisponible}</strong>
                  </span>
                </div>

                <p className="cart-item__price">
                  Precio unitario: {formatoCOP(item.precio)}
                </p>

                <button
                  className="cart-item__delete"
                  onClick={() => eliminarProducto(item.itemId)}
                >
                  Eliminar
                </button>
              </div>

              <div className="cart-item__actions">
                <div className="quantity-control">
                  <button onClick={() => disminuirCantidad(item.itemId)}>-</button>

                  <span>{item.cantidad}</span>

                  <button
                    onClick={() => aumentarCantidad(item.itemId)}
                    disabled={item.cantidad >= item.stockDisponible}
                  >
                    +
                  </button>
                </div>

                <p className="cart-item__subtotal">
                  Subtotal:
                  <strong>{formatoCOP(item.subtotal)}</strong>
                </p>
              </div>
            </article>
          ))}
        </div>

        <aside className="cart-summary">
          <h2>Pago del pedido</h2>

          <div className="summary-row summary-row--total summary-row--only">
            <span>Total a pagar</span>
            <strong>{formatoCOP(totalCompra)}</strong>
          </div>

          <button className="cart-summary__button" onClick={irACheckout}>
            Proceder al pago
          </button>

          <button className="cart-summary__secondary" onClick={irACatalogo}>
            Seguir comprando
          </button>
        </aside>
      </section>
    </main>
  );
}

export default CartPage;