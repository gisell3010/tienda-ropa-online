package com.tienda.backend.dto;

public class InventarioDTO {
    private String talla;
    private String color;
    private Integer stock;

    // Constructor vacío
    public InventarioDTO() {}

    // Constructor con parámetros
    public InventarioDTO(String talla, String color, Integer stock) {
        this.talla = talla;
        this.color = color;
        this.stock = stock;
    }

    // --- GETTERS Y SETTERS ---
    public String getTalla() { return talla; }
    public void setTalla(String talla) { this.talla = talla; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
}