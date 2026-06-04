import ProductCard from "../components/ProductCard";
import { productsMock } from "../data/productsMock";

function CatalogPage() {
  return (
    <main className="catalog-page">
      <section className="hero">
        <div className="hero__content">
          <span className="hero__label">Nueva colección</span>
          <h1>Estilo simple, moderno y auténtico</h1>
          <p>
            Prendas seleccionadas para vestir con comodidad, elegancia y personalidad.
          </p>
        </div>
      </section>

      <section className="catalog-page__grid">
        {productsMock.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </section>
    </main>
  );
}

export default CatalogPage;