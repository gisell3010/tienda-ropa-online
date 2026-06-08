package com.tienda.backend.dto;

public class CompraResponseDTO {
    private boolean exito;
    private String mensaje;
    private Integer ventaId; // Nulo si la compra falla

    // Constructores
    public CompraResponseDTO() {}

    public CompraResponseDTO(boolean exito, String mensaje, Integer ventaId) {
        this.exito = exito;
        this.mensaje = mensaje;
        this.ventaId = ventaId;
    }

    // Getters y Setters
    public boolean isExito() {
        return exito;
    }

    public void setExito(boolean exito) {
        this.exito = exito;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public Integer getVentaId() {
        return ventaId;
    }

    public void setVentaId(Integer ventaId) {
        this.ventaId = ventaId;
    }
}