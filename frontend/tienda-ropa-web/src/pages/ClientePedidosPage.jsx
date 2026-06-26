import { useEffect, useMemo, useState } from "react";
import { useAuth } from "../context/AuthContext";
import {
  listarPedidosCliente,
  obtenerDetallePedidoCliente
} from "../services/clienteService";

function ClientePedidosPage() {
  const { token } = useAuth();

  const [pedidos, setPedidos] = useState([]);
  const [detallePedido, setDetallePedido] = useState(null);
  const [pedidoSeleccionado, setPedidoSeleccionado] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [cargandoDetalle, setCargandoDetalle] = useState(false);
  const [error, setError] = useState("");

  const formatoCOP = (valor) => {
    return new Intl.NumberFormat("es-CO", {
      style: "currency",
      currency: "COP",
      maximumFractionDigits: 0
    }).format(Number(valor) || 0);
  };

  const obtenerIdPedido = (pedido) => {
    return pedido?.pedidoId || pedido?.venId || pedido?.ven_id || pedido?.id;
  };

  const obtenerTotalPedido = (pedido) => {
    return (
      pedido?.total ||
      pedido?.totalVenta ||
      pedido?.total_venta ||
      pedido?.totalPagado ||
      pedido?.total_pagado ||
      0
    );
  };

  const obtenerFechaPedido = (pedido) => {
    return pedido?.fecha || pedido?.fechaPedido || pedido?.fecha_pedido || "";
  };

  const fechaATiempoLocal = (fecha) => {
    if (!fecha) return 0;

    const textoFecha = String(fecha);

    const fechaISO = textoFecha.match(/^(\d{4})-(\d{2})-(\d{2})/);

    if (fechaISO) {
      const anio = Number(fechaISO[1]);
      const mes = Number(fechaISO[2]);
      const dia = Number(fechaISO[3]);

      return new Date(anio, mes - 1, dia).getTime();
    }

    const fechaObjeto = new Date(textoFecha);

    if (Number.isNaN(fechaObjeto.getTime())) {
      return 0;
    }

    return fechaObjeto.getTime();
  };

  const formatoFecha = (fecha) => {
    if (!fecha) return "Sin fecha";

    const textoFecha = String(fecha);

    const fechaConHoraCero = textoFecha.match(
      /^(\d{4})-(\d{2})-(\d{2})(?:[T\s]00:00(?::00(?:\.0+)?)?(?:Z|[+-]\d{2}:?\d{2})?)?$/
    );

    if (fechaConHoraCero) {
      const anio = Number(fechaConHoraCero[1]);
      const mes = Number(fechaConHoraCero[2]);
      const dia = Number(fechaConHoraCero[3]);
      const fechaLocal = new Date(anio, mes - 1, dia);

      return fechaLocal.toLocaleDateString("es-CO", {
        year: "numeric",
        month: "long",
        day: "numeric"
      });
    }

    const fechaObjeto = new Date(textoFecha);

    if (Number.isNaN(fechaObjeto.getTime())) {
      return textoFecha;
    }

    return fechaObjeto.toLocaleString("es-CO", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    });
  };

  const pedidosOrdenados = useMemo(() => {
    return [...pedidos].sort((pedidoA, pedidoB) => {
      const tiempoA = fechaATiempoLocal(obtenerFechaPedido(pedidoA));
      const tiempoB = fechaATiempoLocal(obtenerFechaPedido(pedidoB));

      if (tiempoA !== tiempoB) {
        return tiempoB - tiempoA;
      }

      return Number(obtenerIdPedido(pedidoB)) - Number(obtenerIdPedido(pedidoA));
    });
  }, [pedidos]);

  const numeroPedidoClientePorId = useMemo(() => {
    const pedidosAscendentes = [...pedidos].sort((pedidoA, pedidoB) => {
      const tiempoA = fechaATiempoLocal(obtenerFechaPedido(pedidoA));
      const tiempoB = fechaATiempoLocal(obtenerFechaPedido(pedidoB));

      if (tiempoA !== tiempoB) {
        return tiempoA - tiempoB;
      }

      return Number(obtenerIdPedido(pedidoA)) - Number(obtenerIdPedido(pedidoB));
    });

    const mapa = new Map();

    pedidosAscendentes.forEach((pedido, index) => {
      const pedidoId = obtenerIdPedido(pedido);

      if (pedidoId !== undefined && pedidoId !== null) {
        mapa.set(String(pedidoId), index + 1);
      }
    });

    return mapa;
  }, [pedidos]);

  const obtenerNumeroPedidoCliente = (pedidoId) => {
    return numeroPedidoClientePorId.get(String(pedidoId)) || "";
  };

  useEffect(() => {
    async function cargarPedidos() {
      try {
        setCargando(true);

        const data = await listarPedidosCliente(token);
        setPedidos(data || []);
      } catch (error) {
        setError(error.message || "No se pudieron consultar los pedidos.");
      } finally {
        setCargando(false);
      }
    }

    cargarPedidos();
  }, [token]);

  const verDetalle = async (pedidoId) => {
    try {
      setCargandoDetalle(true);
      setPedidoSeleccionado(pedidoId);

      const data = await obtenerDetallePedidoCliente(pedidoId, token);
      setDetallePedido(data);
    } catch (error) {
      setError(error.message || "No se pudo consultar el detalle del pedido.");
    } finally {
      setCargandoDetalle(false);
    }
  };

  if (cargando) {
    return (
      <main className="cliente-page">
        <section className="cliente-card">
          <p>Cargando pedidos...</p>
        </section>
      </main>
    );
  }

  const detallePedidoId =
    detallePedido?.pedidoId ||
    detallePedido?.venId ||
    detallePedido?.ven_id ||
    pedidoSeleccionado;

  const numeroDetallePedido = obtenerNumeroPedidoCliente(detallePedidoId);

  return (
    <main className="cliente-page">
      <section className="cliente-header">
        <span className="cliente-header__label">Mis compras</span>
        <h1>Historial de pedidos</h1>
        <p>
          Consulta tus compras realizadas y revisa los productos incluidos en
          cada pedido.
        </p>
      </section>

      {error && (
        <div className="cliente-message cliente-message--error">{error}</div>
      )}

      <section className="cliente-layout cliente-layout--orders">
        <section className="cliente-card">
          <h2>Pedidos realizados</h2>

          {pedidosOrdenados.length === 0 ? (
            <p className="cliente-empty">Todavía no tienes pedidos registrados.</p>
          ) : (
            <div className="cliente-orders">
              {pedidosOrdenados.map((pedido) => {
                const pedidoId = obtenerIdPedido(pedido);
                const numeroPedidoCliente = obtenerNumeroPedidoCliente(pedidoId);

                return (
                  <article
                    className={`cliente-order ${
                      Number(pedidoSeleccionado) === Number(pedidoId)
                        ? "cliente-order--active"
                        : ""
                    }`}
                    key={pedidoId}
                  >
                    <div>
                      <h3>Pedido #{numeroPedidoCliente}</h3>
                      <p>{formatoFecha(obtenerFechaPedido(pedido))}</p>
                      <span>{pedido.estado || "CONFIRMADO"}</span>
                    </div>

                    <div>
                      <strong>{formatoCOP(obtenerTotalPedido(pedido))}</strong>

                      <button type="button" onClick={() => verDetalle(pedidoId)}>
                        Ver detalle
                      </button>
                    </div>
                  </article>
                );
              })}
            </div>
          )}
        </section>

        <section className="cliente-card">
          <h2>Detalle del pedido</h2>

          {cargandoDetalle && <p>Cargando detalle...</p>}

          {!cargandoDetalle && !detallePedido && (
            <p className="cliente-empty">
              Selecciona un pedido para ver los productos comprados.
            </p>
          )}

          {!cargandoDetalle && detallePedido && (
            <div className="cliente-order-detail">
              <div className="cliente-order-detail__header">
                <div>
                  <span>Pedido</span>
                  <strong>#{numeroDetallePedido}</strong>
                </div>

                <div>
                  <span>Fecha</span>
                  <strong>{formatoFecha(detallePedido.fecha)}</strong>
                </div>

                <div>
                  <span>Total</span>
                  <strong>{formatoCOP(detallePedido.total)}</strong>
                </div>
              </div>

              <div className="cliente-order-detail__items">
                {(detallePedido.detalles || []).map((item, index) => (
                  <article className="cliente-order-product" key={index}>
                    <div>
                      <h3>{item.producto}</h3>
                      <p>
                        Talla: {item.talla} / Color: {item.color}
                      </p>
                      <span>Cantidad: {item.cantidad}</span>
                    </div>

                    <div>
                      <span>{formatoCOP(item.precioUnitario)}</span>
                      <strong>{formatoCOP(item.subtotal)}</strong>
                    </div>
                  </article>
                ))}
              </div>
            </div>
          )}
        </section>
      </section>
    </main>
  );
}

export default ClientePedidosPage;