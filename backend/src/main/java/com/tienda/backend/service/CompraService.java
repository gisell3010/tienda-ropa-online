package com.tienda.backend.service;

import com.tienda.backend.dto.CompraRequestDTO;
import com.tienda.backend.dto.CompraResponseDTO;

public interface CompraService {
    
    /**
     * Procesa la solicitud de compra, valida reglas de negocio
     * y registra la venta en el sistema.
     * * @param request Datos del cliente, método de pago y productos seleccionados.
     * @return Respuesta indicando el éxito o fallo de la operación.
     */
    CompraResponseDTO registrarCompra(CompraRequestDTO request);
}