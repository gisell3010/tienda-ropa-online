function ProductCard({ product }) {
  const obtenerTexto = (valor) => {
    if (valor === null || valor === undefined) return "";

    if (typeof valor === "string" || typeof valor === "number") {
      return valor.toString();
    }

    if (typeof valor === "object") {
      return valor.nombre || valor.name || "";
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
      Rosado: "#f9a8d4"
    };

    return coloresHex[color] || "#d1d5db";
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

        <span className="product-card__style">{product.estilo}</span>

        {agotado && <span className="product-card__badge">AGOTADO</span>}
      </div>

      <div className="product-card__content">
        <p className="product-card__category">{product.categoria}</p>

        <h3 className="product-card__title">{product.nombre}</h3>

        <p className="product-card__price">{precioCOP}</p>

        <div className="product-card__details">
          <div className="details-panel">
            <p className="details-panel__title">Detalles del producto:</p>

            <div className="details-item">
              <span className="details-item__label">Tallas</span>

              <div className="chip-list">
                {tallas.length > 0 ? (
                  tallas.map((talla) => (
                    <span className="chip" key={talla} translate="no">
                      {talla}
                    </span>
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
                    <span
                      key={color}
                      className="color-dot"
                      title={color}
                      data-color={color}
                      style={{ backgroundColor: obtenerColorHex(color) }}
                    ></span>
                  ))
                ) : (
                  <span className="details-empty">Sin colores</span>
                )}
              </div>
            </div>

            <div className={agotado ? "stock-card stock-card--off" : "stock-card stock-card--on"}>
              <span>Disponible:</span>
              <strong>{agotado ? "Sin stock" : `${stock} unidades`}</strong>
            </div>
          </div>
        </div>
      </div>
    </article>
  );
}

export default ProductCard;