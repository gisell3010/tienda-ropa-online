package com.tienda.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "productos")
public class Producto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "pro_id")
    private Integer proId;

    @Column(name = "nombre", nullable = false, length = 150)
    private String nombre;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    @Transient
    private String descripcion;
    @Column(name = "precio", nullable = false)
    private Double precio;

    @ManyToOne
    @JoinColumn(name = "cat_id", nullable = false)
    private Categoria categoria;

    @ManyToOne
    @JoinColumn(name = "est_id", nullable = false)
    private Estilo estilo;

    // --- GETTERS Y SETTERS ---
    public Integer getProId() { return proId; }
    public void setProId(Integer proId) { this.proId = proId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Double getPrecio() { return precio; }
    public void setPrecio(Double precio) { this.precio = precio; }

    public Categoria getCategoria() { return categoria; }
    public void setCategoria(Categoria categoria) { this.categoria = categoria; }

    public Estilo getEstilo() { return estilo; }
    public void setEstilo(Estilo estilo) { this.estilo = estilo; }
}