import { useState } from "react";
import Navbar from "./components/Navbar";
import CatalogPage from "./pages/CatalogPage";
import CartPage from "./pages/CartPage";
import { useCart } from "./context/CartContext";
import "./styles/global.css";
import "./styles/catalog.css";
import "./styles/cart.css";

function App() {
  const [vistaActual, setVistaActual] = useState("catalogo");
  const { notificacion } = useCart();

  const irACatalogo = () => {
    setVistaActual("catalogo");
  };

  const irACarrito = () => {
    setVistaActual("carrito");
  };

  const irACheckout = () => {
    setVistaActual("checkout");
  };

  const estiloOverlay = {
    position: "fixed",
    inset: 0,
    zIndex: 9999,
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    pointerEvents: "none"
  };

  const estiloToast = {
  width: "min(520px, 90vw)",
  padding: "22px 26px",
  borderRadius: "24px",
  display: "flex",
  alignItems: "center",
  gap: "16px",
  background:
    notificacion.tipo === "error"
      ? "linear-gradient(135deg, #fff1f2, #ffffff)"
      : "linear-gradient(135deg, #ecfdf5, #ffffff)",
  color: notificacion.tipo === "error" ? "#991b1b" : "#14532d",
  border:
    notificacion.tipo === "error"
      ? "2px solid #fca5a5"
      : "2px solid #86efac",
  boxShadow:
    "0 30px 80px rgba(17, 17, 17, 0.26), 0 8px 24px rgba(17, 17, 17, 0.12)",
  animation: "toastEntrada 0.25s ease"
};

const estiloIconoToast = {
  width: "50px",
  height: "50px",
  borderRadius: "50%",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  flexShrink: 0,
  color: "#ffffff",
  fontSize: "26px",
  fontWeight: "900",
  background:
    notificacion.tipo === "error"
      ? "linear-gradient(135deg, #ef4444, #dc2626)"
      : "linear-gradient(135deg, #22c55e, #16a34a)",
  boxShadow:
    notificacion.tipo === "error"
      ? "0 10px 22px rgba(239, 68, 68, 0.35)"
      : "0 10px 22px rgba(34, 197, 94, 0.35)"
};

const estiloContenidoToast = {
  textAlign: "left"
};

const estiloTituloToast = {
  margin: "0 0 4px",
  fontSize: "17px",
  fontWeight: "900",
  color: notificacion.tipo === "error" ? "#991b1b" : "#166534"
};

const estiloMensajeToast = {
  margin: 0,
  fontSize: "15px",
  fontWeight: "700",
  lineHeight: "1.45",
  color: "#374151"
};

  return (
    <>
      <Navbar irACatalogo={irACatalogo} irACarrito={irACarrito} />

      {notificacion.mensaje && (
  <div style={estiloOverlay}>
    <div style={estiloToast}>
      <div style={estiloIconoToast}>
        {notificacion.tipo === "error" ? "!" : "✓"}
      </div>

      <div style={estiloContenidoToast}>
        <p style={estiloTituloToast}>
          {notificacion.tipo === "error" ? "Atención" : "Producto agregado"}
        </p>

        <p style={estiloMensajeToast}>{notificacion.mensaje}</p>
      </div>
    </div>
  </div>
)}

      {vistaActual === "catalogo" && <CatalogPage />}

      {vistaActual === "carrito" && (
        <CartPage irACatalogo={irACatalogo} irACheckout={irACheckout} />
      )}

      {vistaActual === "checkout" && (
        <main className="cart-page">
          <section className="cart-empty">
            <span className="cart-empty__icon">💳</span>

            <h1>Checkout en construcción</h1>

            <p>
              Esta pantalla se realizará en la tarea TRO-52. Por ahora estamos
              conectando el carrito de compras.
            </p>

            <button className="cart-empty__button" onClick={irACarrito}>
              Volver al carrito
            </button>
          </section>
        </main>
      )}
    </>
  );
}

export default App;