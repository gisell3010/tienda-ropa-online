package com.tienda.backend.service;

import com.tienda.backend.dto.CompraDetalleDTO;
import com.tienda.backend.dto.CompraRequestDTO;
import com.tienda.backend.dto.CompraResponseDTO;
import org.springframework.stereotype.Service;

@Service
public class CompraServiceImpl implements CompraService {

    @Override
    public CompraResponseDTO registrarCompra(CompraRequestDTO request) {
        // 1. Validar que la solicitud y los detalles no vengan vacíos
        if (request == null || request.getDetalles() == null || request.getDetalles().isEmpty()) {
            return new CompraResponseDTO(false, "El carrito de compras está vacío.", null);
        }

        // 2. Validar que las cantidades de cada producto sean mayores a cero
        for (CompraDetalleDTO detalle : request.getDetalles()) {
            if (detalle.getCantidad() == null || detalle.getCantidad() <= 0) {
                return new CompraResponseDTO(false, "La cantidad de los productos debe ser mayor a cero.", null);
            }
        }

        // Nota: En la siguiente tarea (TRO-49) conectaremos aquí el procedimiento de PostgreSQL
        return new CompraResponseDTO(true, "Validaciones locales exitosas. Pendiente integración con BD.", null);
    }
}

