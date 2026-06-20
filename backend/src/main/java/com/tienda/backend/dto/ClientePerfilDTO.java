package com.tienda.backend.dto;

public class ClientePerfilDTO {

    private Long clienteId;
    private String nombre;
    private String telefono;
    private String correo;
    private String rol;
    private boolean activo;

    public ClientePerfilDTO() {
    }

    public ClientePerfilDTO(Long clienteId, String nombre, String telefono, String correo, String rol, boolean activo) {
        this.clienteId = clienteId;
        this.nombre = nombre;
        this.telefono = telefono;
        this.correo = correo;
        this.rol = rol;
        this.activo = activo;
    }

    public Long getClienteId() {
        return clienteId;
    }

    public void setClienteId(Long clienteId) {
        this.clienteId = clienteId;
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

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }
}