package com.tienda.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "inventarios")
public class Inventario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inv_id")
    private Integer invId;

    @ManyToOne
    @JoinColumn(name = "pro_id", nullable = false)
    private Producto producto;

    @ManyToOne
    @JoinColumn(name = "tal_id", nullable = false)
    private Talla talla;

    @ManyToOne
    @JoinColumn(name = "col_id", nullable = false)
    private Color color;

    @Column(name = "stock", nullable = false)
    private Integer stock;

    // --- GETTERS Y SETTERS ---
    public Integer getInvId() { return invId; }
    public void setInvId(Integer invId) { this.invId = invId; }

    public Producto getProducto() { return producto; }
    public void setProducto(Producto producto) { this.producto = producto; }

    public Talla getTalla() { return talla; }
    public void setTalla(Talla talla) { this.talla = talla; }

    public Color getColor() { return color; }
    public void setColor(Color color) { this.color = color; }

    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
}
