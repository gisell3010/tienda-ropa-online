const API_BASE_URL = "/api";

export async function obtenerProductosBackend() {
  const respuesta = await fetch(`${API_BASE_URL}/productos`);

  if (!respuesta.ok) {
    throw new Error("No se pudo consultar el catálogo desde el backend.");
  }

  return await respuesta.json();
}

export async function validarStockCarrito(carrito) {
  const productosBackend = await obtenerProductosBackend();

  for (const item of carrito) {
    const productoBackend = productosBackend.find(
      (producto) => Number(producto.id) === Number(item.productoId)
    );

    if (!productoBackend) {
      return {
        ok: false,
        mensaje: `No se encontró el producto ${item.nombre} en el backend.`
      };
    }

    const existencias = productoBackend.existencias || [];

    const existenciaSeleccionada = existencias.find(
      (existencia) =>
        existencia.talla === item.talla &&
        existencia.color === item.color
    );

    if (!existenciaSeleccionada) {
      return {
        ok: false,
        mensaje: `No se encontró inventario para ${item.nombre}, talla ${item.talla}, color ${item.color}.`
      };
    }

    if (Number(existenciaSeleccionada.stock) < Number(item.cantidad)) {
      return {
        ok: false,
        mensaje: `Lo sentimos, no hay stock suficiente para el producto ${item.nombre} en la combinación elegida. Inventario disponible: ${existenciaSeleccionada.stock}`
      };
    }
  }

  return {
    ok: true,
    mensaje: "Stock validado correctamente."
  };
}