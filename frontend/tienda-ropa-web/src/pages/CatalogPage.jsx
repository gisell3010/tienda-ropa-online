import { useEffect, useState } from "react";
import ProductCard from "../components/ProductCard";
import { obtenerProductos } from "../services/productService";
import { productsMock } from "../data/productsMock";

function CatalogPage() {
  const [productos, setProductos] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  const normalizarTexto = (texto) => {
    return texto
      ?.toString()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .trim();
  };

  const obtenerTexto = (valor) => {
    if (valor === null || valor === undefined) return "";

    if (typeof valor === "string" || typeof valor === "number") {
      return valor.toString();
    }

    if (Array.isArray(valor)) {
      const primerTexto = valor.map(obtenerTexto).find((texto) => texto !== "");
      return primerTexto || "";
    }

    if (typeof valor === "object") {
      return (
        valor.nombre ||
        valor.name ||
        valor.descripcion ||
        valor.categoria ||
        valor.estilo ||
        valor.talla ||
        valor.color ||
        valor.nombreCategoria ||
        valor.nombreEstilo ||
        valor.nombreTalla ||
        valor.nombreColor ||
        valor.catNombre ||
        valor.estNombre ||
        valor.talNombre ||
        valor.colNombre ||
        ""
      );
    }

    return "";
  };

  const obtenerNumero = (valor) => {
    if (valor === null || valor === undefined) return null;

    if (typeof valor === "number") return valor;

    if (typeof valor === "string") {
      const numero = Number(valor);
      return Number.isNaN(numero) ? null : numero;
    }

    if (Array.isArray(valor)) {
      return valor.reduce((total, item) => {
        const numero = obtenerNumero(item);
        return total + (numero || 0);
      }, 0);
    }

    if (typeof valor === "object") {
      return obtenerNumero(
        valor.stock ||
          valor.cantidad ||
          valor.existencias ||
          valor.stockDisponible
      );
    }

    return null;
  };

  const convertirAListaTexto = (valor) => {
    if (!valor) return [];

    if (Array.isArray(valor)) {
      return [
        ...new Set(
          valor
            .map((item) => obtenerTexto(item))
            .filter((item) => item !== "")
        )
      ];
    }

    if (typeof valor === "string" && valor.includes(",")) {
      return [
        ...new Set(
          valor
            .split(",")
            .map((item) => item.trim())
            .filter((item) => item !== "")
        )
      ];
    }

    const texto = obtenerTexto(valor);
    return texto ? [texto] : [];
  };

  const obtenerInventarios = (productoBackend) => {
    if (Array.isArray(productoBackend.existencias)) {
      return productoBackend.existencias;
    }

    if (Array.isArray(productoBackend.inventarios)) {
      return productoBackend.inventarios;
    }

    if (Array.isArray(productoBackend.inventario)) {
      return productoBackend.inventario;
    }

    if (Array.isArray(productoBackend.stock)) {
      return productoBackend.stock;
    }

    if (Array.isArray(productoBackend.detallesInventario)) {
      return productoBackend.detallesInventario;
    }

    return [];
  };

  const obtenerTallasDesdeInventario = (inventarios) => {
    return [
      ...new Set(
        inventarios
          .map((inventario) =>
            obtenerTexto(
              inventario.talla ||
                inventario.tallas ||
                inventario.nombreTalla ||
                inventario.talNombre ||
                inventario.tallaNombre
            )
          )
          .filter((talla) => talla !== "")
      )
    ];
  };

  const obtenerColoresDesdeInventario = (inventarios) => {
    return [
      ...new Set(
        inventarios
          .map((inventario) =>
            obtenerTexto(
              inventario.color ||
                inventario.colores ||
                inventario.nombreColor ||
                inventario.colNombre ||
                inventario.colorNombre
            )
          )
          .filter((color) => color !== "")
      )
    ];
  };

  const obtenerStockDesdeInventario = (inventarios) => {
    if (!Array.isArray(inventarios) || inventarios.length === 0) return null;

    return inventarios.reduce((total, inventario) => {
      const stock = obtenerNumero(
        inventario.stock ||
          inventario.cantidad ||
          inventario.existencias ||
          inventario.stockDisponible
      );

      return total + (stock || 0);
    }, 0);
  };

  const buscarImagenLocal = (productoBackend, index) => {
    const nombreBackend = normalizarTexto(
      productoBackend.nombre ||
        productoBackend.proNombre ||
        productoBackend.pro_nombre
    );

    const productoConImagen = productsMock.find(
      (productoMock) => normalizarTexto(productoMock.nombre) === nombreBackend
    );

    return productoConImagen || productsMock[index % productsMock.length];
  };

  const adaptarProducto = (productoBackend, index) => {
    const imagenLocal = buscarImagenLocal(productoBackend, index);
    const inventarios = obtenerInventarios(productoBackend);

    const tallasInventario = obtenerTallasDesdeInventario(inventarios);
    const coloresInventario = obtenerColoresDesdeInventario(inventarios);
    const stockInventario = obtenerStockDesdeInventario(inventarios);

    const tallasBackend = convertirAListaTexto(
      productoBackend.tallas ||
        productoBackend.talla ||
        productoBackend.tallasDisponibles ||
        productoBackend.nombreTalla
    );

    const coloresBackend = convertirAListaTexto(
      productoBackend.colores ||
        productoBackend.color ||
        productoBackend.coloresDisponibles ||
        productoBackend.nombreColor
    );

    const stockBackend = obtenerNumero(
      productoBackend.stock ||
        productoBackend.existencias ||
        productoBackend.stockDisponible ||
        productoBackend.cantidad
    );

    return {
      id:
        productoBackend.id ||
        productoBackend.proId ||
        productoBackend.pro_id ||
        index + 1,

      inventarios,

      nombre:
        productoBackend.nombre ||
        productoBackend.proNombre ||
        productoBackend.pro_nombre ||
        imagenLocal.nombre ||
        "Producto sin nombre",

      precio:
        obtenerNumero(
          productoBackend.precio ||
            productoBackend.proPrecio ||
            productoBackend.pro_precio
        ) ||
        imagenLocal.precio ||
        0,

      categoria:
        obtenerTexto(
          productoBackend.categoria ||
            productoBackend.categorias ||
            productoBackend.categoriaNombre ||
            productoBackend.nombreCategoria ||
            productoBackend.catNombre
        ) ||
        imagenLocal.categoria ||
        "Sin categoría",

      estilo:
        obtenerTexto(
          productoBackend.estilo ||
            productoBackend.estilos ||
            productoBackend.estiloNombre ||
            productoBackend.nombreEstilo ||
            productoBackend.estNombre
        ) ||
        imagenLocal.estilo ||
        "Sin estilo",

      tallas:
        tallasInventario.length > 0
          ? tallasInventario
          : tallasBackend.length > 0
            ? tallasBackend
            : imagenLocal.tallas || [],

      colores:
        coloresInventario.length > 0
          ? coloresInventario
          : coloresBackend.length > 0
            ? coloresBackend
            : imagenLocal.colores || [],

      stock:
        stockInventario !== null
          ? stockInventario
          : stockBackend !== null
            ? stockBackend
            : imagenLocal.stock || 0,

      imagen:
        productoBackend.imagenUrl ||
        productoBackend.imagen_url ||
        productoBackend.imagen ||
        productoBackend.urlImagen ||
        imagenLocal.imagen,
    };
  };

  useEffect(() => {
    async function cargarProductos() {
      try {
        const productosBackend = await obtenerProductos();

        console.log("Productos recibidos del backend:", productosBackend);

        const productosAdaptados = productosBackend.map((producto, index) =>
          adaptarProducto(producto, index)
        );

        console.log("Productos adaptados para React:", productosAdaptados);

        setProductos(productosAdaptados);
      } catch (error) {
        console.error(error);
        setError("No se pudieron cargar los productos desde el backend.");
      } finally {
        setCargando(false);
      }
    }

    cargarProductos();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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

      {cargando && (
        <p className="catalog-message">
          Cargando productos desde la base de datos...
        </p>
      )}

      {error && (
        <div className="catalog-error">
          <strong>Error al cargar el catálogo</strong>
          <p>{error}</p>
          <small>
            Verifica que el backend esté corriendo en el puerto 8080.
          </small>
        </div>
      )}

      {!cargando && !error && productos.length === 0 && (
        <p className="catalog-message">
          No hay productos registrados en la base de datos.
        </p>
      )}

      {!cargando && !error && productos.length > 0 && (
        <section className="catalog-page__grid">
          {productos.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </section>
      )}
    </main>
  );
}

export default CatalogPage;