package com.tienda.backend.dto;

public class DireccionClienteDTO {

    private Long direccionId;
    private String direccion;

    private String municipioId;
    private String municipio;

    private String departamentoId;
    private String departamento;

    private String referencia;
    private boolean principal;

    public DireccionClienteDTO() {
    }

    public DireccionClienteDTO(
            Long direccionId,
            String direccion,
            String municipioId,
            String municipio,
            String departamentoId,
            String departamento,
            String referencia,
            boolean principal
    ) {
        this.direccionId = direccionId;
        this.direccion = direccion;
        this.municipioId = municipioId;
        this.municipio = municipio;
        this.departamentoId = departamentoId;
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

    public String getMunicipioId() {
        return municipioId;
    }

    public void setMunicipioId(String municipioId) {
        this.municipioId = municipioId;
    }

    public String getMunicipio() {
        return municipio;
    }

    public void setMunicipio(String municipio) {
        this.municipio = municipio;
    }

    public String getDepartamentoId() {
        return departamentoId;
    }

    public void setDepartamentoId(String departamentoId) {
        this.departamentoId = departamentoId;
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