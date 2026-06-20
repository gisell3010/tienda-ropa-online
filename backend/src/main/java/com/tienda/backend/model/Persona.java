package com.tienda.backend.model;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "personas")
public class Persona {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "per_id")
    private Integer perId;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "telefono")
    private String telefono;

    @Column(name = "correo")
    private String correo;

    @Column(name = "contrasena_hash")
    private String contrasenaHash;

    @Column(name = "genero")
    private Character genero;

    @Column(name = "fecha_nacimiento")
    private LocalDate fechaNacimiento;

    @ManyToOne
    @JoinColumn(name = "rol_id")
    private Rol rol;

    public Integer getPerId() {
        return perId;
    }

    public void setPerId(Integer perId) {
        this.perId = perId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getContrasenaHash() {
        return contrasenaHash;
    }

    public void setContrasenaHash(String contrasenaHash) {
        this.contrasenaHash = contrasenaHash;
    }

    public Character getGenero() {
        return genero;
    }

    public void setGenero(Character genero) {
        this.genero = genero;
    }

    public LocalDate getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(LocalDate fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol rol) {
        this.rol = rol;
    }
}
