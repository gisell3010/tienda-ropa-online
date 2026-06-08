package com.tienda.backend.dto;

public class CompraResponseDTO {
    private boolean exito;
    private String mensaje;
    private Long ventaId; // Nulo si la compra falla

    // Constructores
    public CompraResponseDTO() {}

    public CompraResponseDTO(boolean exito, String mensaje, Long ventaId) {
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

    public Long getVentaId() {
        return ventaId;
    }

    public void setVentaId(Long ventaId) {
        this.ventaId = ventaId;
    }
}