import { useState } from "react";
import { useCart } from "../context/CartContext";
import "../styles/checkout.css";

function CheckoutPage({ irACarrito, irACatalogo }) {
  const { carrito, subtotalGeneral, costoEnvio, totalCompra, mostrarNotificacion } =
    useCart();

  const [formulario, setFormulario] = useState({
    nombreCompleto: "",
    correo: "",
    direccion: "",
    ciudad: "",
    telefono: "",
    metodoPago: "tarjeta",
    franquicia: "Visa",
    numeroTarjeta: "",
    titular: "",
    vencimiento: "",
    cvv: "",
    banco: "",
    tipoPersona: "Natural",
    correoPse: ""
  });

  const [mostrarPortalPse, setMostrarPortalPse] = useState(false);
  const [mensajeCheckout, setMensajeCheckout] = useState("");

  const formatoCOP = (valor) => {
    return new Intl.NumberFormat("es-CO", {
      style: "currency",
      currency: "COP",
      maximumFractionDigits: 0
    }).format(valor);
  };

  const actualizarCampo = (evento) => {
    const { name, value } = evento.target;

    setFormulario((datosActuales) => ({
      ...datosActuales,
      [name]: value
    }));
  };

  const validarDatosEnvio = () => {
    if (!formulario.nombreCompleto.trim()) {
      return "Ingresa el nombre completo.";
    }

    if (!formulario.correo.trim()) {
      return "Ingresa el correo electrónico.";
    }

    if (!formulario.direccion.trim()) {
      return "Ingresa la dirección de entrega.";
    }

    if (!formulario.ciudad.trim()) {
      return "Ingresa la ciudad.";
    }

    if (!formulario.telefono.trim()) {
      return "Ingresa el teléfono de contacto.";
    }

    return "";
  };

  const validarTarjeta = () => {
    if (!formulario.numeroTarjeta.trim()) {
      return "Ingresa el número de tarjeta.";
    }

    if (formulario.numeroTarjeta.replace(/\s/g, "").length !== 16) {
      return "El número de tarjeta debe tener 16 dígitos.";
    }

    if (!formulario.titular.trim()) {
      return "Ingresa el nombre del titular.";
    }

    if (!formulario.vencimiento.trim()) {
      return "Ingresa la fecha de vencimiento.";
    }

    if (!formulario.cvv.trim()) {
      return "Ingresa el código de seguridad CVV.";
    }

    if (formulario.cvv.length < 3) {
      return "El CVV debe tener mínimo 3 dígitos.";
    }

    return "";
  };

  const validarPse = () => {
    if (!formulario.banco.trim()) {
      return "Selecciona el banco para pagar con PSE.";
    }

    if (!formulario.correoPse.trim()) {
      return "Ingresa el correo asociado al pago PSE.";
    }

    return "";
  };

  const validarFormulario = () => {
    const errorEnvio = validarDatosEnvio();

    if (errorEnvio) {
      return errorEnvio;
    }

    if (formulario.metodoPago === "tarjeta") {
      return validarTarjeta();
    }

    return validarPse();
  };

  const manejarSubmit = (evento) => {
    evento.preventDefault();

    if (carrito.length === 0) {
      mostrarNotificacion("No hay productos en el carrito.", "error");
      return;
    }

    const error = validarFormulario();

    if (error) {
      mostrarNotificacion(error, "error");
      return;
    }

    if (formulario.metodoPago === "tarjeta") {
      if (formulario.titular.trim().toUpperCase() === "RECHAZADO") {
        setMensajeCheckout(
          "No se pudo procesar el pago. Por favor, verifica los datos de tu tarjeta o intenta con otro método de pago."
        );
        mostrarNotificacion("Pago rechazado por la simulación.", "error");
        return;
      }

      setMensajeCheckout(
        "Datos validados correctamente. En la siguiente tarea se conectará el checkout con el backend para registrar la compra."
      );
      mostrarNotificacion("Datos de compra validados correctamente.", "success");
      return;
    }

    setMostrarPortalPse(true);
  };

  const aprobarPse = () => {
    setMostrarPortalPse(false);
    setMensajeCheckout(
      "Transacción PSE aprobada en la simulación. En la siguiente tarea se conectará el checkout con el backend."
    );
    mostrarNotificacion("Transacción PSE aprobada.", "success");
  };

  const cancelarPse = () => {
    setMostrarPortalPse(false);
    setMensajeCheckout(
      "No se pudo procesar el pago. Por favor, verifica los datos o intenta con otro método de pago."
    );
    mostrarNotificacion("Transacción PSE cancelada.", "error");
  };

  if (carrito.length === 0) {
    return (
      <main className="checkout-page">
        <section className="checkout-empty">
          <span className="checkout-empty__icon">🛒</span>
          <h1>No tienes productos para pagar</h1>
          <p>
            Agrega productos al carrito antes de continuar con el proceso de compra.
          </p>

          <button onClick={irACatalogo}>Volver al catálogo</button>
        </section>
      </main>
    );
  }

  return (
    <main className="checkout-page">
      <section className="checkout-header">
        <span className="checkout-header__label">Finalizar compra</span>
        <h1>Datos de envío y pago</h1>
      </section>

      <section className="checkout-layout">
        <form className="checkout-form" onSubmit={manejarSubmit}>
          <div className="checkout-card">
            <h2>Información de envío</h2>

            <div className="checkout-grid">
              <label>
                Nombre completo
                <input
                  type="text"
                  name="nombreCompleto"
                  value={formulario.nombreCompleto}
                  onChange={actualizarCampo}
                  placeholder="Ej: Laura Gómez"
                />
              </label>

              <label>
                Correo electrónico
                <input
                  type="email"
                  name="correo"
                  value={formulario.correo}
                  onChange={actualizarCampo}
                  placeholder="correo@ejemplo.com"
                />
              </label>

              <label className="checkout-grid__full">
                Dirección de entrega
                <input
                  type="text"
                  name="direccion"
                  value={formulario.direccion}
                  onChange={actualizarCampo}
                  placeholder="Calle, carrera, número, barrio"
                />
              </label>

              <label>
                Ciudad
                <input
                  type="text"
                  name="ciudad"
                  value={formulario.ciudad}
                  onChange={actualizarCampo}
                  placeholder="Ej: Pamplona"
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
            </div>
          </div>

          <div className="checkout-card">
            <h2>Método de pago</h2>

            <div className="payment-options">
              <label
                className={
                  formulario.metodoPago === "tarjeta"
                    ? "payment-option payment-option--active"
                    : "payment-option"
                }
              >
                <input
                  type="radio"
                  name="metodoPago"
                  value="tarjeta"
                  checked={formulario.metodoPago === "tarjeta"}
                  onChange={actualizarCampo}
                />
                Tarjeta crédito / débito
              </label>

              <label
                className={
                  formulario.metodoPago === "pse"
                    ? "payment-option payment-option--active"
                    : "payment-option"
                }
              >
                <input
                  type="radio"
                  name="metodoPago"
                  value="pse"
                  checked={formulario.metodoPago === "pse"}
                  onChange={actualizarCampo}
                />
                PSE
              </label>
            </div>

            {formulario.metodoPago === "tarjeta" && (
              <div className="checkout-grid">
                <label>
                  Franquicia
                  <select
                    name="franquicia"
                    value={formulario.franquicia}
                    onChange={actualizarCampo}
                  >
                    <option value="Visa">Visa</option>
                    <option value="Mastercard">Mastercard</option>
                    <option value="Amex">Amex</option>
                  </select>
                </label>

                <label>
                  Número de tarjeta
                  <input
                    type="text"
                    name="numeroTarjeta"
                    value={formulario.numeroTarjeta}
                    onChange={actualizarCampo}
                    maxLength="16"
                    placeholder="1234567890123456"
                  />
                </label>

                <label className="checkout-grid__full">
                  Nombre del titular
                  <input
                    type="text"
                    name="titular"
                    value={formulario.titular}
                    onChange={actualizarCampo}
                    placeholder="Nombre como aparece en la tarjeta"
                  />
                </label>

                <label>
                  Vencimiento
                  <input
                    type="text"
                    name="vencimiento"
                    value={formulario.vencimiento}
                    onChange={actualizarCampo}
                    placeholder="MM/AA"
                    maxLength="5"
                  />
                </label>

                <label>
                  CVV
                  <input
                    type="password"
                    name="cvv"
                    value={formulario.cvv}
                    onChange={actualizarCampo}
                    placeholder="123"
                    maxLength="4"
                  />
                </label>
              </div>
            )}

            {formulario.metodoPago === "pse" && (
              <div className="checkout-grid">
                <label>
                  Banco
                  <select
                    name="banco"
                    value={formulario.banco}
                    onChange={actualizarCampo}
                  >
                    <option value="">Selecciona un banco</option>
                    <option value="Nequi">Nequi</option>
                    <option value="Daviplata">Daviplata</option>
                    <option value="Bancolombia">Bancolombia</option>
                    <option value="Banco de Bogotá">Banco de Bogotá</option>
                  </select>
                </label>

                <label>
                  Tipo de persona
                  <select
                    name="tipoPersona"
                    value={formulario.tipoPersona}
                    onChange={actualizarCampo}
                  >
                    <option value="Natural">Natural</option>
                    <option value="Jurídica">Jurídica</option>
                  </select>
                </label>

                <label className="checkout-grid__full">
                  Correo PSE
                  <input
                    type="email"
                    name="correoPse"
                    value={formulario.correoPse}
                    onChange={actualizarCampo}
                    placeholder="correo@ejemplo.com"
                  />
                </label>
              </div>
            )}
          </div>

          {mensajeCheckout && (
            <div className="checkout-banner">
              {mensajeCheckout}
            </div>
          )}

          <div className="checkout-actions">
            <button type="button" className="checkout-actions__back" onClick={irACarrito}>
              Volver al carrito
            </button>

            <button type="submit" className="checkout-actions__pay">
              Pagar ahora
            </button>
          </div>
        </form>

        <aside className="checkout-summary">
          <h2>Resumen del pedido</h2>

          <div className="checkout-summary__items">
            {carrito.map((item) => (
              <div className="checkout-summary__item" key={item.itemId}>
                <img src={item.imagen} alt={item.nombre} />

                <div>
                  <h3>{item.nombre}</h3>
                  <p>
                    {item.talla} / {item.color} / Cantidad: {item.cantidad}
                  </p>
                  <strong>{formatoCOP(item.subtotal)}</strong>
                </div>
              </div>
            ))}
          </div>

          <div className="checkout-summary__row">
            <span>Subtotal</span>
            <strong>{formatoCOP(subtotalGeneral)}</strong>
          </div>

          <div className="checkout-summary__row">
            <span>Envío</span>
            <strong>{formatoCOP(costoEnvio)}</strong>
          </div>

          <div className="checkout-summary__row checkout-summary__row--total">
            <span>Total</span>
            <strong>{formatoCOP(totalCompra)}</strong>
          </div>
        </aside>
      </section>

      {mostrarPortalPse && (
        <div className="pse-modal">
          <div className="pse-modal__content">
            <span className="pse-modal__label">Portal simulado PSE</span>
            <h2>{formulario.banco}</h2>
            <p>
              Estás simulando el pago desde el banco seleccionado. Elige una acción para continuar.
            </p>

            <div className="pse-modal__actions">
              <button className="pse-modal__approve" onClick={aprobarPse}>
                Aprobar transacción
              </button>

              <button className="pse-modal__cancel" onClick={cancelarPse}>
                Cancelar transacción
              </button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}

export default CheckoutPage;