package com.tienda.backend.dto;

import java.util.List;

public class CompraRequestDTO {
    private Integer personaId;
    private Integer metodoPagoId;
    private Integer direccionId;
    private List<CompraDetalleDTO> detalles;

    // Constructores
    public CompraRequestDTO() {}

    public CompraRequestDTO(Integer personaId, Integer metodoPagoId, Integer direccionId, List<CompraDetalleDTO> detalles) {
        this.personaId = personaId;
        this.metodoPagoId = metodoPagoId;
        this.direccionId = direccionId;
        this.detalles = detalles;
    }

    // Getters y Setters
    public Integer getPersonaId() {
        return personaId;
    }

    public void setPersonaId(Integer personaId) {
        this.personaId = personaId;
    }

    public Integer getMetodoPagoId() {
        return metodoPagoId;
    }

    public void setMetodoPagoId(Integer metodoPagoId) {
        this.metodoPagoId = metodoPagoId;
    }

    public Integer getDireccionId() {
        return direccionId;
    }

    public void setDireccionId(Integer direccionId) {
        this.direccionId = direccionId;
    }

    public List<CompraDetalleDTO> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<CompraDetalleDTO> detalles) {
        this.detalles = detalles;
    }
}