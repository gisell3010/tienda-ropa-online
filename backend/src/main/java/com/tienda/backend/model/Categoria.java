package com.tienda.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "categorias")
public class Categoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cat_id")
    private Integer catId;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    // --- GETTERS Y SETTERS ---
    public Integer getCatId() { return catId; }
    public void setCatId(Integer catId) { this.catId = catId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}

