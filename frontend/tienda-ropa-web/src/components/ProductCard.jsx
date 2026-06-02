function ProductCard({ product }) {
  const agotado = product.stock === 0;

  const precioCOP = new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0
  }).format(product.precio);

  const obtenerColorHex = (color) => {
    const colores = {
      Negro: "#111827",
      Blanco: "#ffffff",
      Gris: "#9ca3af",
      Azul: "#1d4ed8",
      Oliva: "#708238",
      Verde: "#16a34a",
      Rojo: "#dc2626"
    };

    return colores[color] || "#d1d5db";
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
                {product.tallas.map((talla) => (
                  <span className="chip" key={talla} translate="no">
                    {talla}
                  </span>
                ))}
              </div>
            </div>

            <div className="details-item">
              <span className="details-item__label">Colores</span>

              <div className="color-list">
                {product.colores.map((color) => (
                  <span
                    key={color}
                    className="color-dot"
                    title={color}
                    data-color={color}
                    style={{ backgroundColor: obtenerColorHex(color) }}
                  ></span>
                ))}
              </div>
            </div>

            <div className={agotado ? "stock-card stock-card--off" : "stock-card stock-card--on"}>
              <span>Disponible:</span>
              <strong>{agotado ? "Sin stock" : `${product.stock} unidades`}</strong>
            </div>
          </div>
        </div>
      </div>
    </article>
  );
}

export default ProductCard;