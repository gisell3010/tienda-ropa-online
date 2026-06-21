package com.tienda.backend.dto;

public class UsuarioPerfilDTO {

    private Long usuarioId;
    private String nombre;
    private String correo;
    private String rol;
    private boolean activo;

    public UsuarioPerfilDTO() {
    }

    public UsuarioPerfilDTO(Long usuarioId, String nombre, String correo, String rol, boolean activo) {
        this.usuarioId = usuarioId;
        this.nombre = nombre;
        this.correo = correo;
        this.rol = rol;
        this.activo = activo;
    }

    public Long getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(Long usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
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