package com.tienda.backend.dto;

import jakarta.validation.constraints.NotBlank;

public class DireccionClienteDTO {

    private Long direccionId;

    @NotBlank(message = "La dirección es obligatoria")
    private String direccion;

    @NotBlank(message = "El municipio es obligatorio")
    private String municipio;

    @NotBlank(message = "El departamento es obligatorio")
    private String departamento;

    private String referencia;
    private boolean principal;

    public DireccionClienteDTO() {
    }

    public DireccionClienteDTO(Long direccionId, String direccion, String municipio, String departamento,
                               String referencia, boolean principal) {
        this.direccionId = direccionId;
        this.direccion = direccion;
        this.municipio = municipio;
        this.departamento = departamento;
        this.referencia = referencia;
        this.principal = principal;
    }

    public Long getDireccionId() {
        return direccionId;
    }

    public void setDireccionId(Long direccionId) {
        this.direccionId = direccionId;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getMunicipio() {
        return municipio;
    }

    public void setMunicipio(String municipio) {
        this.municipio = municipio;
    }

    public String getDepartamento() {
        return departamento;
    }

    public void setDepartamento(String departamento) {
        this.departamento = departamento;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }

    public boolean isPrincipal() {
        return principal;
    }

    public void setPrincipal(boolean principal) {
        this.principal = principal;
    }
}