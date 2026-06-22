package com.tienda.backend.dto;

public class UsuarioAdminDTO {

    private Integer id;
    private String nombre;
    private String correo;
    private String telefono;
    private String rol;
    private Boolean activo;

    public UsuarioAdminDTO(
            Integer id,
            String nombre,
            String correo,
            String telefono,
            String rol,
            Boolean activo) {

        this.id = id;
        this.nombre = nombre;
        this.correo = correo;
        this.telefono = telefono;
        this.rol = rol;
        this.activo = activo;
    }

    public Integer getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getCorreo() {
        return correo;
    }

    public String getTelefono() {
        return telefono;
    }

    public String getRol() {
        return rol;
    }

    public Boolean getActivo() {
        return activo;
    }
}