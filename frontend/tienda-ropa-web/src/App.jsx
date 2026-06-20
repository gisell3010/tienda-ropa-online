import { useState } from "react";
import Navbar from "./components/Navbar";
import CatalogPage from "./pages/CatalogPage";
import CartPage from "./pages/CartPage";
import CheckoutPage from "./pages/CheckoutPage";
import LoginPage from "./pages/LoginPage";
import RegisterPage from "./pages/RegisterPage";
import AdminDashboardPage from "./pages/AdminDashboardPage";
import { useCart } from "./context/CartContext";
import { useAuth } from "./context/AuthContext";

import "./styles/global.css";
import "./styles/catalog.css";
import "./styles/cart.css";
import "./styles/checkout.css";
import "./styles/auth.css";
import "./styles/admin.css";

function App() {
  const [vistaActual, setVistaActual] = useState("login");

  const { notificacion } = useCart();
  const { usuario, estaAutenticado, rolUsuario, cerrarSesion } = useAuth();

  const irALogin = () => {
    setVistaActual("login");
  };

  const irARegistro = () => {
    setVistaActual("registro");
  };

  const irACatalogo = () => {
    setVistaActual("catalogo");
  };

  const irACarrito = () => {
    setVistaActual("carrito");
  };

  const irACheckout = () => {
    setVistaActual("checkout");
  };

  const irAAdmin = () => {
    setVistaActual("admin");
  };

  const irASuperadmin = () => {
    setVistaActual("superadmin");
  };

  const cerrarSesionUsuario = () => {
    cerrarSesion();
    setVistaActual("login");
  };

  const obtenerRol = (usuarioAutenticado) => {
    return (
      usuarioAutenticado?.rol ||
      usuarioAutenticado?.rolAplicacion ||
      usuarioAutenticado?.role ||
      ""
    ).toUpperCase();
  };

  const redirigirPorRol = (usuarioAutenticado) => {
    const rol = obtenerRol(usuarioAutenticado);

    if (rol === "CLIENTE") {
      setVistaActual("catalogo");
      return;
    }

    if (rol === "ADMIN") {
      setVistaActual("admin");
      return;
    }

    if (rol === "SUPERADMIN") {
      setVistaActual("superadmin");
      return;
    }

    setVistaActual("login");
  };

  const usuarioPuedeEntrar = (rolesPermitidos) => {
    if (!estaAutenticado) {
      return false;
    }

    return rolesPermitidos.includes(rolUsuario.toUpperCase());
  };

  const esError = notificacion.tipo === "error";

  const estiloOverlay = {
    position: "fixed",
    inset: 0,
    zIndex: 9999,
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    pointerEvents: "none",
    padding: "24px"
  };

  const estiloToast = {
    width: "min(520px, 90vw)",
    padding: "22px 26px",
    borderRadius: "24px",
    display: "flex",
    alignItems: "center",
    gap: "16px",
    background: esError
      ? "linear-gradient(135deg, #fff1f2, #ffffff)"
      : "linear-gradient(135deg, #ecfdf5, #ffffff)",
    color: esError ? "#991b1b" : "#14532d",
    border: esError ? "2px solid #fca5a5" : "2px solid #86efac",
    boxShadow:
      "0 30px 80px rgba(17, 17, 17, 0.26), 0 8px 24px rgba(17, 17, 17, 0.12)"
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
    background: esError
      ? "linear-gradient(135deg, #ef4444, #dc2626)"
      : "linear-gradient(135deg, #22c55e, #16a34a)",
    boxShadow: esError
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
    color: esError ? "#991b1b" : "#166534"
  };

  const estiloMensajeToast = {
    margin: 0,
    fontSize: "15px",
    fontWeight: "700",
    lineHeight: "1.45",
    color: "#374151"
  };

  if (vistaActual === "login") {
    return (
      <>
        <LoginPage irARegistro={irARegistro} redirigirPorRol={redirigirPorRol} />
      </>
    );
  }

  if (vistaActual === "registro") {
    return (
      <>
        <RegisterPage irALogin={irALogin} />
      </>
    );
  }

  if (!estaAutenticado) {
    return (
      <LoginPage irARegistro={irARegistro} redirigirPorRol={redirigirPorRol} />
    );
  }

  return (
    <>
      {["catalogo", "carrito", "checkout"].includes(vistaActual) &&
  usuarioPuedeEntrar(["CLIENTE"]) && (
    <Navbar
      irACatalogo={irACatalogo}
      irACarrito={irACarrito}
      irALogin={irALogin}
      cerrarSesionUsuario={cerrarSesionUsuario}
      usuario={usuario}
      rolUsuario={rolUsuario}
    />
  )}

      {notificacion.mensaje && (
        <div style={estiloOverlay}>
          <div style={estiloToast}>
            <div style={estiloIconoToast}>{esError ? "!" : "✓"}</div>

            <div style={estiloContenidoToast}>
              <p style={estiloTituloToast}>
                {esError ? "Atención" : "Producto agregado"}
              </p>

              <p style={estiloMensajeToast}>{notificacion.mensaje}</p>
            </div>
          </div>
        </div>
      )}

      {vistaActual === "catalogo" && usuarioPuedeEntrar(["CLIENTE"]) && (
        <CatalogPage />
      )}

      {vistaActual === "carrito" && usuarioPuedeEntrar(["CLIENTE"]) && (
        <CartPage irACatalogo={irACatalogo} irACheckout={irACheckout} />
      )}

      {vistaActual === "checkout" && usuarioPuedeEntrar(["CLIENTE"]) && (
        <CheckoutPage irACarrito={irACarrito} irACatalogo={irACatalogo} />
      )}

      {vistaActual === "admin" && usuarioPuedeEntrar(["ADMIN"]) && (
  <AdminDashboardPage
    usuario={usuario}
    cerrarSesionUsuario={cerrarSesionUsuario}
  />
)}

      {vistaActual === "superadmin" && usuarioPuedeEntrar(["SUPERADMIN"]) && (
        <main className="auth-page">
          <section className="auth-card auth-card--wide">
            <div className="auth-card__header">
              <span className="auth-card__label">Panel superadministrador</span>
              <h1>Bienvenido, superadministrador</h1>
              <p>
                Desde esta sección se gestionarán usuarios, roles, auditorías y
                reportes generales.
              </p>
            </div>

            <button className="auth-panel-button" onClick={cerrarSesionUsuario}>
              Cerrar sesión
            </button>
          </section>
        </main>
      )}

      {vistaActual === "catalogo" && !usuarioPuedeEntrar(["CLIENTE"]) && (
        <main className="auth-page">
          <section className="auth-card">
            <div className="auth-card__header">
              <span className="auth-card__label">Acceso no permitido</span>
              <h1>No tienes permiso</h1>
              <p>No puedes acceder a esta pantalla con tu rol actual.</p>
            </div>

            <button className="auth-panel-button" onClick={cerrarSesionUsuario}>
              Volver al login
            </button>
          </section>
        </main>
      )}
    </>
  );
}

export default App;