package com.tienda.backend.service;

import com.tienda.backend.dto.StockResponseDTO;

public interface InventarioService {

    StockResponseDTO validarStock(
            Integer inventarioId,
            Integer cantidad
    );
}