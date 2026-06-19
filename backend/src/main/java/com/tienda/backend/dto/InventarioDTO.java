package com.tienda.backend.dto;

public class InventarioDTO {
    private Integer inventarioId;
    private Integer tallaId;
    private String talla;
    private Integer colorId;
    private String color;
    private Integer stock;

    public InventarioDTO() {}

    public InventarioDTO(Integer inventarioId, Integer tallaId, String talla, Integer colorId, String color, Integer stock) {
        this.inventarioId = inventarioId;
        this.tallaId = tallaId;
        this.talla = talla;
        this.colorId = colorId;
        this.color = color;
        this.stock = stock;
    }

    public Integer getInventarioId() {
        return inventarioId;
    }

    public void setInventarioId(Integer inventarioId) {
        this.inventarioId = inventarioId;
    }

    public Integer getTallaId() {
        return tallaId;
    }

    public void setTallaId(Integer tallaId) {
        this.tallaId = tallaId;
    }

    public String getTalla() {
        return talla;
    }

    public void setTalla(String talla) {
        this.talla = talla;
    }

    public Integer getColorId() {
        return colorId;
    }

    public void setColorId(Integer colorId) {
        this.colorId = colorId;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }
}