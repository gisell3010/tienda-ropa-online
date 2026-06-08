package com.tienda.backend.dto;

public class CompraDetalleDTO {
    private Integer inventarioId;
    private Integer cantidad;

    // Constructores
    public CompraDetalleDTO() {}

    public CompraDetalleDTO(Integer inventarioId, Integer cantidad) {
        this.inventarioId = inventarioId;
        this.cantidad = cantidad;
    }

    // Getters y Setters
    public Integer getInventarioId() {
        return inventarioId;
    }

    public void setInventarioId(Integer inventarioId) {
        this.inventarioId = inventarioId;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }
}