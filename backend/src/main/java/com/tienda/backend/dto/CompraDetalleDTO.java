package com.tienda.backend.dto;

public class CompraDetalleDTO {
    private Long inventarioId;
    private Integer cantidad;

    // Constructores
    public CompraDetalleDTO() {}

    public CompraDetalleDTO(Long inventarioId, Integer cantidad) {
        this.inventarioId = inventarioId;
        this.cantidad = cantidad;
    }

    // Getters y Setters
    public Long getInventarioId() {
        return inventarioId;
    }

    public void setInventarioId(Long inventarioId) {
        this.inventarioId = inventarioId;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }
}