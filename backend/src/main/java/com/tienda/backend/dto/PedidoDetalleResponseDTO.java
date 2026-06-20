package com.tienda.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class PedidoDetalleResponseDTO {

    private Long pedidoId;
    private LocalDateTime fecha;
    private String estado;
    private BigDecimal total;
    private List<DetallePedidoClienteDTO> detalles;

    public PedidoDetalleResponseDTO() {
    }

    public PedidoDetalleResponseDTO(Long pedidoId, LocalDateTime fecha, String estado,
                                    BigDecimal total, List<DetallePedidoClienteDTO> detalles) {
        this.pedidoId = pedidoId;
        this.fecha = fecha;
        this.estado = estado;
        this.total = total;
        this.detalles = detalles;
    }

    public Long getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Long pedidoId) {
        this.pedidoId = pedidoId;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public List<DetallePedidoClienteDTO> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetallePedidoClienteDTO> detalles) {
        this.detalles = detalles;
    }
}