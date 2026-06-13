package com.tienda.backend.service;

import org.springframework.stereotype.Service;
import com.tienda.backend.dto.CompraRequestDTO;
import com.tienda.backend.dto.CompraResponseDTO;
import com.tienda.backend.dto.CompraDetalleDTO;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

@Service
public class CompraServiceImp implements CompraService {

    @PersistenceContext
    private EntityManager entityManager;

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

       
        
        try {

        ObjectMapper mapper = new ObjectMapper();

        ArrayNode itemsJson = mapper.createArrayNode();

        for (CompraDetalleDTO detalle : request.getDetalles()) {

            ObjectNode item = mapper.createObjectNode();

            item.put("inv_id", detalle.getInventarioId());
            item.put("cantidad", detalle.getCantidad());

            itemsJson.add(item);
        }

        String jsonItems = mapper.writeValueAsString(itemsJson);

        Query query = entityManager.createNativeQuery(
            "SELECT realizar_compra_carrito(?1, ?2, CAST(?3 AS jsonb))"
        );

        query.setParameter(1, request.getPersonaId());
        query.setParameter(2, request.getMetodoPagoId());
        query.setParameter(3, jsonItems);

        Integer ventaId = ((Number) query.getSingleResult()).intValue();

        return new CompraResponseDTO(
            true,
            "Compra registrada con éxito",
            ventaId
        );

    } catch (Exception e) {

        return new CompraResponseDTO(
            false,
            e.getMessage(),
            null
        );
    }
    }
}