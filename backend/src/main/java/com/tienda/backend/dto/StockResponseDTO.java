package com.tienda.backend.dto;

public class StockResponseDTO {

    private boolean disponible;
    private Integer stockActual;
    private String mensaje;

    public StockResponseDTO() {
    }

    public StockResponseDTO(
            boolean disponible,
            Integer stockActual,
            String mensaje) {

        this.disponible = disponible;
        this.stockActual = stockActual;
        this.mensaje = mensaje;
    }

    public boolean isDisponible() {
        return disponible;
    }

    public void setDisponible(boolean disponible) {
        this.disponible = disponible;
    }

    public Integer getStockActual() {
        return stockActual;
    }

    public void setStockActual(Integer stockActual) {
        this.stockActual = stockActual;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }
}