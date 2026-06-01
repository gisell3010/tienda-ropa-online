package com.tienda.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "colores")
public class Color {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "col_id")
    private Integer colId;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    // --- GETTERS Y SETTERS ---
    public Integer getColId() { return colId; }
    public void setColId(Integer colId) { this.colId = colId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}
