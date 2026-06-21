import { useState } from "react";
import { useCart } from "../context/CartContext";

function ProductCard({ product }) {
  const { agregarProducto, mostrarNotificacion } = useCart();

  const obtenerTexto = (valor) => {
    if (valor === null || valor === undefined) return "";

    if (typeof valor === "string" || typeof valor === "number") {
      return valor.toString();
    }

    if (typeof valor === "object") {
      return valor.nombre || valor.name || valor.descripcion || "";
    }

    return "";
  };

  const obtenerListaTexto = (lista) => {
    if (!Array.isArray(lista)) return [];

    return [
      ...new Set(
        lista
          .map((item) => obtenerTexto(item))
          .filter((item) => item !== "")
      )
    ];
  };

  const tallas = obtenerListaTexto(product.tallas);
  const colores = obtenerListaTexto(product.colores);

  const stock = Number(product.stock) || 0;
  const agotado = stock === 0;

  const [tallaSeleccionada, setTallaSeleccionada] = useState("");
  const [colorSeleccionado, setColorSeleccionado] = useState("");
  const [cantidad, setCantidad] = useState(1);

  const inventarioSeleccionado = product.inventarios?.find(
    (inventario) =>
      obtenerTexto(inventario.talla) === tallaSeleccionada &&
      obtenerTexto(inventario.color) === colorSeleccionado
  );

  const stockSeleccionado = inventarioSeleccionado
    ? Number(inventarioSeleccionado.stock)
    : 0;

  const precioCOP = new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0
  }).format(Number(product.precio) || 0);

  const obtenerColorHex = (color) => {
  const coloresHex = {
    Negro: "#111827",
    Blanco: "#ffffff",
    Gris: "#9ca3af",
    Azul: "#1d4ed8",
    Oliva: "#708238",
    Verde: "#16a34a",
    Rojo: "#dc2626",
    Beige: "#d6b98c",
    Amarillo: "#facc15",
    Morado: "#7c3aed",
    Rosado: "#f9a8d4",
    "Café": "#8b5e34",
    "CafÃ©": "#8b5e34",
    Cafe: "#8b5e34",
    Naranja: "#f97316",
    Vinotinto: "#7f1d1d",
    Fucsia: "#d946ef",
    Lila: "#c084fc",
    Crema: "#f5e6c8",
    Mostaza: "#ca8a04",
    Coral: "#fb7185"
  };

    return coloresHex[color] || "#d1d5db";
  };

  const manejarSeleccionTalla = (talla) => {
    setTallaSeleccionada(talla);
    setCantidad(1);
  };

  const manejarSeleccionColor = (color) => {
    setColorSeleccionado(color);
    setCantidad(1);
  };

  const aumentarCantidad = () => {
    if (agotado) {
      mostrarNotificacion("Este producto está agotado.", "error");
      return;
    }

    if (!tallaSeleccionada || !colorSeleccionado) {
      mostrarNotificacion(
        "Selecciona una talla y un color antes de aumentar la cantidad.",
        "error"
      );
      return;
    }

    if (!inventarioSeleccionado) {
      mostrarNotificacion(
        "La talla y el color seleccionados no están disponibles para este producto.",
        "error"
      );
      return;
    }

    if (stockSeleccionado <= 0) {
      mostrarNotificacion(
        "Este producto está agotado en la talla y color seleccionados.",
        "error"
      );
      return;
    }

    if (cantidad < stockSeleccionado) {
      setCantidad(cantidad + 1);
    } else {
      mostrarNotificacion(
        `Solo hay ${stockSeleccionado} unidad(es) disponibles para esta combinación.`,
        "error"
      );
    }
  };

  const disminuirCantidad = () => {
    if (cantidad > 1) {
      setCantidad(cantidad - 1);
    }
  };

  const manejarAgregarCarrito = () => {
    if (agotado) {
      mostrarNotificacion("Este producto está agotado.", "error");
      return;
    }

    if (!tallaSeleccionada && !colorSeleccionado) {
      mostrarNotificacion(
        "Selecciona una talla y un color antes de agregar el producto.",
        "error"
      );
      return;
    }

    if (!tallaSeleccionada) {
      mostrarNotificacion(
        "Selecciona una talla antes de agregar el producto.",
        "error"
      );
      return;
    }

    if (!colorSeleccionado) {
      mostrarNotificacion(
        "Selecciona un color antes de agregar el producto.",
        "error"
      );
      return;
    }

    if (!inventarioSeleccionado) {
      mostrarNotificacion(
        "La talla y el color seleccionados no están disponibles para este producto.",
        "error"
      );
      return;
    }

    if (stockSeleccionado <= 0) {
      mostrarNotificacion(
        "Este producto está agotado en la talla y color seleccionados.",
        "error"
      );
      return;
    }

    if (cantidad > stockSeleccionado) {
      mostrarNotificacion(
        `Actualmente solo contamos con ${stockSeleccionado} unidad(es) disponibles para esta combinación.`,
        "error"
      );
      return;
    }

    const resultado = agregarProducto(
      product,
      tallaSeleccionada,
      colorSeleccionado,
      cantidad,
      inventarioSeleccionado
    );

    if (resultado.ok) {
      mostrarNotificacion("Producto agregado al carrito correctamente.", "success");
      setCantidad(1);
    } else {
      mostrarNotificacion(resultado.mensaje, "error");
    }
  };

  return (
    <article className={`product-card ${agotado ? "product-card--agotado" : ""}`}>
      <div className="product-card__image-container">
        <img
          src={product.imagen}
          alt={product.nombre}
          className="product-card__image product-card__image--main"
        />

        <img
          src={product.imagenHover || product.imagen}
          alt={`${product.nombre} vista secundaria`}
          className="product-card__image product-card__image--hover"
        />

        <span className="product-card__style">
          {product.estilo || "Sin estilo"}
        </span>

        {agotado && <span className="product-card__badge">AGOTADO</span>}
      </div>

      <div className="product-card__content">
        <p className="product-card__category">
          {product.categoria || "Sin categoría"}
        </p>

        <h3 className="product-card__title">
          {product.nombre || "Producto sin nombre"}
        </h3>

        <p className="product-card__price">{precioCOP}</p>

        <div className="product-card__details">
          <div className="details-panel">
            <p className="details-panel__title">Detalles del producto:</p>

            <div className="details-item">
              <span className="details-item__label">Tallas</span>

              <div className="chip-list">
                {tallas.length > 0 ? (
                  tallas.map((talla) => (
                    <button
                      type="button"
                      className={`chip chip-button ${
                        tallaSeleccionada === talla ? "chip-button--active" : ""
                      }`}
                      key={talla}
                      translate="no"
                      onClick={() => manejarSeleccionTalla(talla)}
                      disabled={agotado}
                    >
                      {talla}
                    </button>
                  ))
                ) : (
                  <span className="details-empty">Sin tallas</span>
                )}
              </div>
            </div>

            <div className="details-item">
              <span className="details-item__label">Colores</span>

              <div className="color-list">
                {colores.length > 0 ? (
                  colores.map((color) => (
                    <button
                      type="button"
                      key={color}
                      className={`color-dot color-dot-button ${
                        colorSeleccionado === color
                          ? "color-dot-button--active"
                          : ""
                      }`}
                      title={color}
                      data-color={color}
                      style={{ backgroundColor: obtenerColorHex(color) }}
                      onClick={() => manejarSeleccionColor(color)}
                      disabled={agotado}
                    ></button>
                  ))
                ) : (
                  <span className="details-empty">Sin colores</span>
                )}
              </div>
            </div>

            <div
              className={
                agotado
                  ? "stock-card stock-card--off"
                  : "stock-card stock-card--on"
              }
            >
              <span>Disponible:</span>
              <strong>{agotado ? "Sin stock" : `${stock} unidades`}</strong>
            </div>

            <div className="product-card__cart-actions">
              <div className="product-card__quantity">
                <button
                  type="button"
                  onClick={disminuirCantidad}
                  disabled={agotado || cantidad === 1}
                >
                  -
                </button>

                <span>{cantidad}</span>

                <button
                  type="button"
                  onClick={aumentarCantidad}
                  disabled={agotado}
                >
                  +
                </button>
              </div>

              <button
                type="button"
                className="product-card__add-button"
                onClick={manejarAgregarCarrito}
                disabled={agotado}
              >
                Agregar al carrito
              </button>
            </div>
          </div>
        </div>
      </div>
    </article>
  );
}

export default ProductCard;