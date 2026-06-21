package com.tienda.backend.dto;

public class AuthResponseDTO {

    private Long usuarioId;
    private String nombre;
    private String correo;
    private String rol;
    private boolean activo;
    private boolean exito;
    private String mensaje;
    private String token;

    public AuthResponseDTO() {
    }

    public AuthResponseDTO(
            Long usuarioId,
            String nombre,
            String correo,
            String rol,
            boolean activo,
            boolean exito,
            String mensaje,
            String token
    ) {
        this.usuarioId = usuarioId;
        this.nombre = nombre;
        this.correo = correo;
        this.rol = rol;
        this.activo = activo;
        this.exito = exito;
        this.mensaje = mensaje;
        this.token = token;
    }

    public AuthResponseDTO(
            Long usuarioId,
            String nombre,
            String correo,
            String rol,
            boolean activo,
            String mensaje
    ) {
        this(usuarioId, nombre, correo, rol, activo, activo, mensaje, null);
    }

    public Long getId() {
        return usuarioId;
    }

    public Long getUsuarioId() {
        return usuarioId;
    }

    public Long getPersonaId() {
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

    public boolean isExito() {
        return exito;
    }

    public void setExito(boolean exito) {
        this.exito = exito;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}