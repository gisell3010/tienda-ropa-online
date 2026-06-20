package com.tienda.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PedidoClienteDTO {

    private Long pedidoId;
    private LocalDateTime fecha;
    private String estado;
    private BigDecimal total;

    public PedidoClienteDTO() {
    }

    public PedidoClienteDTO(Long pedidoId, LocalDateTime fecha, String estado, BigDecimal total) {
        this.pedidoId = pedidoId;
        this.fecha = fecha;
        this.estado = estado;
        this.total = total;
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
}