package com.tienda.backend.dto;

import java.util.List;

public class CompraRequestDTO {
    private Long personaId; // Se solicita temporalmente ya que no hay login en Sprint 2
    private Long metodoPagoId;
    private List<CompraDetalleDTO> detalles;

    // Constructores
    public CompraRequestDTO() {}

    public CompraRequestDTO(Long personaId, Long metodoPagoId, List<CompraDetalleDTO> detalles) {
        this.personaId = personaId;
        this.metodoPagoId = metodoPagoId;
        this.detalles = detalles;
    }

    // Getters y Setters
    public Long getPersonaId() {
        return personaId;
    }

    public void setPersonaId(Long personaId) {
        this.personaId = personaId;
    }

    public Long getMetodoPagoId() {
        return metodoPagoId;
    }

    public void setMetodoPagoId(Long metodoPagoId) {
        this.metodoPagoId = metodoPagoId;
    }

    public List<CompraDetalleDTO> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<CompraDetalleDTO> detalles) {
        this.detalles = detalles;
    }
}