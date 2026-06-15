package com.tienda.backend.service;

import com.tienda.backend.dto.StockResponseDTO;
import com.tienda.backend.model.Inventario;
import com.tienda.backend.repository.InventarioRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class InventarioServiceImp implements InventarioService {

    private final InventarioRepository inventarioRepository;

    public InventarioServiceImp(
            InventarioRepository inventarioRepository) {

        this.inventarioRepository = inventarioRepository;
    }

    @Override
    public StockResponseDTO validarStock(
            Integer inventarioId,
            Integer cantidad) {

        Optional<Inventario> inventario =
                inventarioRepository.findById(inventarioId);

        if (inventario.isEmpty()) {
            return new StockResponseDTO(
                    false,
                    0,
                    "Inventario no encontrado"
            );
        }

        Integer stockActual = inventario.get().getStock();

        if (stockActual >= cantidad) {
            return new StockResponseDTO(
                    true,
                    stockActual,
                    "Stock disponible"
            );
        }

        return new StockResponseDTO(
                false,
                stockActual,
                "Stock insuficiente"
        );
    }
}