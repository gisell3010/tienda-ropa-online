package com.tienda.backend.controller;

import com.tienda.backend.dto.StockResponseDTO;
import com.tienda.backend.service.InventarioService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InventarioController {

    private final InventarioService inventarioService;

    public InventarioController(
            InventarioService inventarioService) {

        this.inventarioService = inventarioService;
    }

    @GetMapping("/api/inventarios/validar")
    public StockResponseDTO validarStock(
            @RequestParam Integer productoId,
            @RequestParam Integer tallaId,
            @RequestParam Integer colorId,
            @RequestParam Integer cantidad) {

        return inventarioService.validarStock(
            productoId,
            tallaId,
            colorId,
            cantidad
        );
    }
}