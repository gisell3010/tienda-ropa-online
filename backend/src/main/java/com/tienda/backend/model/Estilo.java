package com.tienda.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "estilos")
public class Estilo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "est_id")
    private Integer estId;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    // --- GETTERS Y SETTERS ---
    public Integer getEstId() { return estId; }
    public void setEstId(Integer estId) { this.estId = estId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}