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
            Integer productoId,
            Integer tallaId,
            Integer colorId,
            Integer cantidad) {

        if (cantidad == null || cantidad <= 0) {
            return new StockResponseDTO(
                    false,
                    0,
                    "La cantidad debe ser mayor que cero"
            );
        }

        Optional<Inventario> inventario =
                inventarioRepository
                        .findByProductoProIdAndTallaTalIdAndColorColId(
                                productoId,
                                tallaId,
                                colorId
                        );

        if (inventario.isEmpty()) {
            return new StockResponseDTO(
                    false,
                    0,
                    "No existe la combinación producto-talla-color"
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