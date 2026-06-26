import { useEffect, useState } from "react";
import { useCart } from "../context/CartContext";
import { useAuth } from "../context/AuthContext";
import { validarStockCarrito } from "../services/productosService";
import { finalizarCompra } from "../services/checkoutService";
import {
  listarDireccionesCliente,
  registrarDireccionCliente
} from "../services/clienteService";
import {
  listarDepartamentos,
  listarMunicipios
} from "../services/ubicacionService";
import "../styles/checkout.css";

function CheckoutPage({ irACarrito, irACatalogo }) {
  const {
    carrito,
    totalCompra,
    mostrarNotificacion,
    vaciarCarrito
  } = useCart();

  const { usuario, token } = useAuth();

  const [formulario, setFormulario] = useState({
    direccionModo: "existente",
    direccionGuardadaId: "",
    departamentoId: "",
    municipioId: "",
    direccion: "",
    metodoPago: "tarjeta",
    franquicia: "Visa",
    numeroTarjeta: "",
    titular: "",
    vencimiento: "",
    cvv: "",
    banco: "",
    tipoPersona: "Natural"
  });

  const [mostrarPortalPse, setMostrarPortalPse] = useState(false);
  const [mensajeCheckout, setMensajeCheckout] = useState("");
  const [procesandoCompra, setProcesandoCompra] = useState(false);
  const [compraFinalizada, setCompraFinalizada] = useState(false);
  const [departamentos, setDepartamentos] = useState([]);
  const [municipios, setMunicipios] = useState([]);
  const [direcciones, setDirecciones] = useState([]);

  const formatoCOP = (valor) => {
    return new Intl.NumberFormat("es-CO", {
      style: "currency",
      currency: "COP",
      maximumFractionDigits: 0
    }).format(Number(valor) || 0);
  };

  const obtenerDepartamentoId = (departamento) => {
    return departamento.id || departamento.depId || departamento.dep_id;
  };

  const obtenerMunicipioId = (municipio) => {
    return municipio.id || municipio.munId || municipio.mun_id;
  };

  const obtenerDireccionId = (direccion) => {
    return (
      direccion.direccionId ||
      direccion.dirId ||
      direccion.dir_id ||
      direccion.id
    );
  };

  const obtenerNombreCliente = () => {
    return usuario?.nombre || usuario?.name || "Cliente";
  };

  const obtenerCorreoCliente = () => {
    return usuario?.correo || usuario?.email || "Correo no disponible";
  };

  useEffect(() => {
    async function cargarDatosIniciales() {
      try {
        const [departamentosData, direccionesData] = await Promise.all([
          listarDepartamentos(),
          listarDireccionesCliente(token)
        ]);

        setDepartamentos(departamentosData || []);
        setDirecciones(direccionesData || []);

        if (!direccionesData || direccionesData.length === 0) {
          setFormulario((datosActuales) => ({
            ...datosActuales,
            direccionModo: "nueva"
          }));
        }
      } catch (error) {
        setMensajeCheckout(
          error.message || "No se pudieron cargar los datos del checkout."
        );
      }
    }

    cargarDatosIniciales();
  }, [token]);

  useEffect(() => {
    async function cargarMunicipios() {
      if (!formulario.departamentoId) {
        setMunicipios([]);
        return;
      }

      const data = await listarMunicipios(formulario.departamentoId);
      setMunicipios(data || []);
    }

    cargarMunicipios();
  }, [formulario.departamentoId]);

  const actualizarCampo = (evento) => {
    const { name, value } = evento.target;

    setFormulario((datosActuales) => {
      if (name === "departamentoId") {
        return {
          ...datosActuales,
          departamentoId: value,
          municipioId: ""
        };
      }

      return {
        ...datosActuales,
        [name]: value
      };
    });
  };

  const validarDatosEntrega = () => {
    if (formulario.direccionModo === "existente") {
      if (!formulario.direccionGuardadaId) {
        return "Selecciona una dirección guardada.";
      }

      return "";
    }

    if (!formulario.direccion.trim()) {
      return "Ingresa la dirección de entrega.";
    }

    if (!formulario.departamentoId) {
      return "Selecciona el departamento.";
    }

    if (!formulario.municipioId) {
      return "Selecciona el municipio.";
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
      return "Ingresa el nombre del titular de la tarjeta.";
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
      return "Selecciona el banco para continuar con el pago";
    }

    if (!formulario.tipoPersona.trim()) {
      return "Selecciona el tipo de persona";
    }

    return "";
  };

  const validarFormulario = () => {
    const errorEntrega = validarDatosEntrega();

    if (errorEntrega) {
      return errorEntrega;
    }

    if (formulario.metodoPago === "tarjeta") {
      return validarTarjeta();
    }

    return validarPse();
  };

  const obtenerPersonaId = () => {
    return (
      usuario?.id ||
      usuario?.usuarioId ||
      usuario?.clienteId ||
      usuario?.perId ||
      usuario?.per_id ||
      usuario?.personaId
    );
  };

  const obtenerDireccionParaCompra = async () => {
    if (formulario.direccionModo === "existente") {
      return Number(formulario.direccionGuardadaId);
    }

    const departamentoSeleccionado = departamentos.find(
      (departamento) =>
        String(obtenerDepartamentoId(departamento)) ===
        String(formulario.departamentoId)
    );

    const municipioSeleccionado = municipios.find(
      (municipio) =>
        String(obtenerMunicipioId(municipio)) ===
        String(formulario.municipioId)
    );

    if (!departamentoSeleccionado || !municipioSeleccionado) {
      throw new Error("Selecciona una dirección de entrega válida.");
    }

    const normalizarTexto = (texto) => {
      return String(texto || "")
        .trim()
        .toLowerCase()
        .replace(/\s+/g, " ");
    };

    const direccionNueva = normalizarTexto(formulario.direccion);
    const municipioNuevo = String(formulario.municipioId || "").trim();

    const direccionExistente = direcciones.find((direccion) => {
      const textoExistente = normalizarTexto(
        direccion.direccion || direccion.linea
      );

      const municipioExistente = String(
        direccion.municipioId ||
          direccion.munId ||
          direccion.mun_id ||
          ""
      ).trim();

      return (
        textoExistente === direccionNueva &&
        municipioExistente === municipioNuevo
      );
    });

    if (direccionExistente) {
      return Number(obtenerDireccionId(direccionExistente));
    }

    const direccionRegistrada = await registrarDireccionCliente(
      {
        direccion: formulario.direccion.trim(),
        departamentoId: formulario.departamentoId,
        municipioId: formulario.municipioId,
        departamento: departamentoSeleccionado.nombre,
        municipio: municipioSeleccionado.nombre
      },
      token
    );

    const direccionId = obtenerDireccionId(direccionRegistrada);

    if (!direccionId) {
      throw new Error("No se pudo obtener la dirección registrada.");
    }

    return Number(direccionId);
  };

  const finalizarCompraConBackend = async () => {
    try {
      setProcesandoCompra(true);

      const productosSinInventario = carrito.filter(
        (item) => !item.inventarioId
      );

      if (productosSinInventario.length > 0) {
        const mensaje =
          "Hay productos en el carrito sin inventario asociado. Vuelve al catálogo y agrégalos nuevamente.";

        setMensajeCheckout(mensaje);
        mostrarNotificacion(mensaje, "error");
        return;
      }

      const validacionStock = await validarStockCarrito(carrito);

      if (!validacionStock.ok) {
        setMensajeCheckout(validacionStock.mensaje);
        mostrarNotificacion(validacionStock.mensaje, "error");
        return;
      }

      const personaId = obtenerPersonaId();

      if (!personaId) {
        const mensaje =
          "No se encontró el usuario autenticado para registrar la compra.";

        setMensajeCheckout(mensaje);
        mostrarNotificacion(mensaje, "error");
        return;
      }

      const direccionId = await obtenerDireccionParaCompra();

      const datosCompra = {
        personaId: Number(personaId),
        direccionId: Number(direccionId),
        metodoPagoId: formulario.metodoPago === "tarjeta" ? 1 : 3,
        detalles: carrito.map((item) => ({
          inventarioId: item.inventarioId,
          cantidad: item.cantidad
        }))
      };

      const respuestaCompra = await finalizarCompra(datosCompra, token);

      const compraRegistrada =
        respuestaCompra?.ventaId ||
        respuestaCompra?.venId ||
        respuestaCompra?.ven_id ||
        respuestaCompra?.datos;

      if (!compraRegistrada) {
        throw new Error(
          respuestaCompra?.mensaje ||
            "La compra se procesó, pero el backend no confirmó el registro del pedido."
        );
      }

      setMensajeCheckout(
        "¡Gracias por tu compra! Tu pedido fue registrado correctamente."
      );

      setCompraFinalizada(true);
      mostrarNotificacion("Compra registrada correctamente.", "success");
      vaciarCarrito();
    } catch (error) {
      setMensajeCheckout(
        error.message || "No se pudo registrar la compra en el backend."
      );

      mostrarNotificacion(
        error.message || "No se pudo registrar la compra en el backend.",
        "error"
      );
    } finally {
      setProcesandoCompra(false);
    }
  };

  const manejarSubmit = async (evento) => {
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

      await finalizarCompraConBackend();
      return;
    }

    setMostrarPortalPse(true);
  };

  const aprobarPse = async () => {
    setMostrarPortalPse(false);
    await finalizarCompraConBackend();
  };

  const cancelarPse = () => {
    setMostrarPortalPse(false);
    setMensajeCheckout(
      "No se pudo procesar el pago. Por favor, verifica los datos o intenta con otro método de pago."
    );
    mostrarNotificacion("Transacción PSE cancelada.", "error");
  };

  if (compraFinalizada) {
    return (
      <main className="checkout-page">
        <section className="checkout-empty">
          <span className="checkout-empty__icon">✅</span>

          <h1>Compra procesada con éxito</h1>

          <p>
            Tu pedido fue registrado correctamente. Puedes consultar el detalle en
            la sección <strong>Mis pedidos</strong>.
          </p>

          <button onClick={irACatalogo}>Volver al catálogo</button>
        </section>
      </main>
    );
  }

  if (carrito.length === 0) {
    return (
      <main className="checkout-page">
        <section className="checkout-empty">
          <span className="checkout-empty__icon">🛒</span>

          <h1>No tienes productos para pagar</h1>

          <p>
            Agrega productos al carrito antes de continuar con el proceso de
            compra.
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
        <h1>Entrega y pago</h1>
        <p>
          Confirma la dirección de entrega y selecciona el método de pago para
          registrar tu pedido.
        </p>
      </section>

      <section className="checkout-layout">
        <form className="checkout-form" onSubmit={manejarSubmit}>
          <div className="checkout-card checkout-card--compact">
            <div className="checkout-card__header">
              <div>
                <span>Comprador</span>
                <h2>Datos de contacto</h2>
              </div>
            </div>

            <div className="checkout-account-info">
              <div>
                <span>Nombre</span>
                <strong>{obtenerNombreCliente()}</strong>
              </div>

              <div>
                <span>Correo electrónico</span>
                <strong>{obtenerCorreoCliente()}</strong>
              </div>
            </div>
          </div>

          <div className="checkout-card">
            <h2>Dirección de entrega</h2>

            <div className="checkout-address-mode">
              <label>
                <input
                  type="radio"
                  name="direccionModo"
                  value="existente"
                  checked={formulario.direccionModo === "existente"}
                  onChange={actualizarCampo}
                  disabled={direcciones.length === 0}
                />
                Usar dirección guardada
              </label>

              <label>
                <input
                  type="radio"
                  name="direccionModo"
                  value="nueva"
                  checked={formulario.direccionModo === "nueva"}
                  onChange={actualizarCampo}
                />
                Registrar nueva dirección
              </label>
            </div>

            {formulario.direccionModo === "existente" && (
              <div className="checkout-grid">
                <label className="checkout-grid__full">
                  Dirección guardada
                  <select
                    name="direccionGuardadaId"
                    value={formulario.direccionGuardadaId}
                    onChange={actualizarCampo}
                  >
                    <option value="">Selecciona una dirección</option>

                    {direcciones.map((direccion) => {
                      const direccionId = obtenerDireccionId(direccion);

                      return (
                        <option key={direccionId} value={direccionId}>
                          {direccion.direccion || direccion.linea} -{" "}
                          {direccion.municipio}, {direccion.departamento}
                        </option>
                      );
                    })}
                  </select>
                </label>
              </div>
            )}

            {formulario.direccionModo === "nueva" && (
              <div className="checkout-grid">
                <label className="checkout-grid__full">
                  Dirección
                  <input
                    type="text"
                    name="direccion"
                    value={formulario.direccion}
                    onChange={actualizarCampo}
                    placeholder="Ej: Carrera 20 No. 11-78"
                  />
                </label>

                <label>
                  Departamento
                  <select
                    name="departamentoId"
                    value={formulario.departamentoId}
                    onChange={actualizarCampo}
                  >
                    <option value="">Selecciona un departamento</option>

                    {departamentos.map((departamento) => {
                      const departamentoId =
                        obtenerDepartamentoId(departamento);

                      return (
                        <option key={departamentoId} value={departamentoId}>
                          {departamento.nombre}
                        </option>
                      );
                    })}
                  </select>
                </label>

                <label>
                  Municipio
                  <select
                    name="municipioId"
                    value={formulario.municipioId}
                    onChange={actualizarCampo}
                    disabled={!formulario.departamentoId}
                  >
                    <option value="">
                      {formulario.departamentoId
                        ? "Selecciona un municipio"
                        : "Primero selecciona un departamento"}
                    </option>

                    {municipios.map((municipio) => {
                      const municipioId = obtenerMunicipioId(municipio);

                      return (
                        <option key={municipioId} value={municipioId}>
                          {municipio.nombre}
                        </option>
                      );
                    })}
                  </select>
                </label>
              </div>
            )}
          </div>

          <div className="checkout-card">
            <h2>Método de pago</h2>

            <div className="payment-options">
              <label
                className={`payment-option ${
                  formulario.metodoPago === "tarjeta"
                    ? "payment-option--active"
                    : ""
                }`}
              >
                <input
                  type="radio"
                  name="metodoPago"
                  value="tarjeta"
                  checked={formulario.metodoPago === "tarjeta"}
                  onChange={actualizarCampo}
                />
                Tarjeta
              </label>

              <label
                className={`payment-option ${
                  formulario.metodoPago === "pse" ? "payment-option--active" : ""
                }`}
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
                    <option value="American Express">American Express</option>
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
              </div>
            )}
          </div>

          {mensajeCheckout && (
            <div className="checkout-banner">{mensajeCheckout}</div>
          )}

          <div className="checkout-actions">
            <button
              type="button"
              className="checkout-actions__back"
              onClick={irACarrito}
              disabled={procesandoCompra}
            >
              Volver al carrito
            </button>

            <button
              type="submit"
              className="checkout-actions__pay"
              disabled={procesandoCompra}
            >
              {procesandoCompra ? "Procesando compra..." : "Pagar ahora"}
            </button>
          </div>
        </form>

        <aside className="checkout-summary">
          <h2>Tu pedido</h2>

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

          <div className="checkout-summary__row checkout-summary__row--total checkout-summary__row--only">
            <span>Total a pagar</span>
            <strong>{formatoCOP(totalCompra)}</strong>
          </div>
        </aside>
      </section>

      {mostrarPortalPse && (
        <div className="pse-modal">
          <div className="pse-modal__content">
            <span className="pse-modal__label">Pago PSE</span>

            <h2>{formulario.banco}</h2>

            <p>
              Confirma la información para continuar con el pago de tu pedido.
            </p>

            <div className="pse-modal__summary">
              <div>
                <span>Comprador</span>
                <strong>{obtenerNombreCliente()}</strong>
              </div>

              <div>
                <span>Total a pagar</span>
                <strong>{formatoCOP(totalCompra)}</strong>
              </div>
            </div>

            <div className="pse-modal__actions">
              <button className="pse-modal__approve" onClick={aprobarPse}>
                Confirmar pago
              </button>

              <button className="pse-modal__cancel" onClick={cancelarPse}>
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}

export default CheckoutPage;