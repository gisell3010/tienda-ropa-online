import { createContext, useContext, useEffect, useMemo, useRef, useState } from "react";

const CartContext = createContext();

const CART_STORAGE_KEY = "tienda_carrito";

export function CartProvider({ children }) {
  const timeoutRef = useRef(null);

  const [carrito, setCarrito] = useState(() => {
    const carritoGuardado = localStorage.getItem(CART_STORAGE_KEY);

    if (carritoGuardado) {
      return JSON.parse(carritoGuardado);
    }

    return [];
  });

  const [notificacion, setNotificacion] = useState({
    mensaje: "",
    tipo: ""
  });

  useEffect(() => {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(carrito));
  }, [carrito]);

  const mostrarNotificacion = (mensaje, tipo = "success") => {
    setNotificacion({
      mensaje,
      tipo
    });

    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    timeoutRef.current = setTimeout(() => {
      setNotificacion({
        mensaje: "",
        tipo: ""
      });
    }, 3000);
  };

  const agregarProducto = (producto, talla, color, cantidad = 1) => {
    const cantidadNumerica = Number(cantidad);

    if (!producto || !talla || !color || cantidadNumerica <= 0) {
      return {
        ok: false,
        mensaje: "Debe seleccionar talla, color y una cantidad válida."
      };
    }

    const productoId = producto.id || producto.proId || producto.pro_id;
    const itemId = `${productoId}-${talla}-${color}`;

    setCarrito((carritoActual) => {
      const productoExistente = carritoActual.find((item) => item.itemId === itemId);

      if (productoExistente) {
        return carritoActual.map((item) =>
          item.itemId === itemId
            ? {
                ...item,
                cantidad: item.cantidad + cantidadNumerica,
                subtotal: (item.cantidad + cantidadNumerica) * item.precio
              }
            : item
        );
      }

      const nuevoItem = {
        itemId,
        productoId,
        nombre: producto.nombre,
        precio: Number(producto.precio) || 0,
        imagen: producto.imagen,
        talla,
        color,
        cantidad: cantidadNumerica,
        stockDisponible: Number(producto.stock) || 0,
        subtotal: (Number(producto.precio) || 0) * cantidadNumerica
      };

      return [...carritoActual, nuevoItem];
    });

    return {
      ok: true,
      mensaje: "Producto agregado al carrito correctamente."
    };
  };

  const aumentarCantidad = (itemId) => {
    setCarrito((carritoActual) =>
      carritoActual.map((item) =>
        item.itemId === itemId
          ? {
              ...item,
              cantidad: item.cantidad + 1,
              subtotal: (item.cantidad + 1) * item.precio
            }
          : item
      )
    );
  };

  const disminuirCantidad = (itemId) => {
    setCarrito((carritoActual) =>
      carritoActual
        .map((item) =>
          item.itemId === itemId
            ? {
                ...item,
                cantidad: item.cantidad - 1,
                subtotal: (item.cantidad - 1) * item.precio
              }
            : item
        )
        .filter((item) => item.cantidad > 0)
    );
  };

  const eliminarProducto = (itemId) => {
    setCarrito((carritoActual) =>
      carritoActual.filter((item) => item.itemId !== itemId)
    );

    mostrarNotificacion("Producto eliminado del carrito.", "error");
  };

  const vaciarCarrito = () => {
    setCarrito([]);
  };

  const subtotalGeneral = useMemo(() => {
    return carrito.reduce((total, item) => total + item.subtotal, 0);
  }, [carrito]);

  const costoEnvio = carrito.length > 0 ? 10000 : 0;

  const totalCompra = subtotalGeneral + costoEnvio;

  const cantidadTotalProductos = useMemo(() => {
    return carrito.reduce((total, item) => total + item.cantidad, 0);
  }, [carrito]);

  const value = {
    carrito,
    agregarProducto,
    aumentarCantidad,
    disminuirCantidad,
    eliminarProducto,
    vaciarCarrito,
    subtotalGeneral,
    costoEnvio,
    totalCompra,
    cantidadTotalProductos,
    notificacion,
    mostrarNotificacion
  };

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

export function useCart() {
  const context = useContext(CartContext);

  if (!context) {
    throw new Error("useCart debe usarse dentro de CartProvider");
  }

  return context;
}