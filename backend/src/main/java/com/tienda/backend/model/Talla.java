package com.tienda.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "tallas")
public class Talla {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tal_id")
    private Integer talId;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    // --- GETTERS Y SETTERS ---
    public Integer getTalId() { return talId; }
    public void setTalId(Integer talId) { this.talId = talId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}
