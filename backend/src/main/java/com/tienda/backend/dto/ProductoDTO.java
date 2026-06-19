package com.tienda.backend.dto;

import java.util.List;

public class ProductoDTO {
    private Integer id;
    private String nombre;
    private String descripcion;
    private Double precio;
    private String categoria;
    private String estilo;
    private List<InventarioDTO> existencias;
    private boolean agotado;

    public ProductoDTO() {}

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Double getPrecio() {
        return precio;
    }

    public void setPrecio(Double precio) {
        this.precio = precio;
    }

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public String getEstilo() {
        return estilo;
    }

    public void setEstilo(String estilo) {
        this.estilo = estilo;
    }

    public List<InventarioDTO> getExistencias() {
        return existencias;
    }

    public void setExistencias(List<InventarioDTO> existencias) {
        this.existencias = existencias;
    }

    public boolean isAgotado() {
        return agotado;
    }

    public void setAgotado(boolean agotado) {
        this.agotado = agotado;
    }
}