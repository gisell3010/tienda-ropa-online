package com.tienda.backend.service;

import org.springframework.stereotype.Service;
import com.tienda.backend.dto.CompraRequestDTO;
import com.tienda.backend.dto.CompraResponseDTO;
import com.tienda.backend.dto.CompraDetalleDTO;

@Service
public class CompraServiceImp implements CompraService {

    @Override
    public CompraResponseDTO registrarCompra(CompraRequestDTO request) {
        
        // 1. Validaciones de nulos solicitadas por Giss
        if (request.getPersonaId() == null) {
            return new CompraResponseDTO(false, "Debe indicar la persona asociada a la compra.", null);
        }

        if (request.getMetodoPagoId() == null) {
            return new CompraResponseDTO(false, "Debe seleccionar un método de pago.", null);
        }

        for (CompraDetalleDTO detalle : request.getDetalles()) {
            if (detalle.getInventarioId() == null) {
                return new CompraResponseDTO(false, "Debe indicar el inventario del producto seleccionado.", null);
            }
            if (detalle.getCantidad() == null || detalle.getCantidad() <= 0) {
                return new CompraResponseDTO(false, "La cantidad de los productos debe ser mayor a cero.", null);
            }
        }

       
        
        return new CompraResponseDTO(true, "Compra registrada con éxito", null);
    }
}