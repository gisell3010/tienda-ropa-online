package com.tienda.backend.controller;

import com.tienda.backend.dto.ProductoDTO;
import com.tienda.backend.service.ProductoService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
public class ProductoController {

    private final ProductoService productoService;

    // Inyectamos tu servicio para poder usar la lógica de stock
    public ProductoController(ProductoService productoService) {
        this.productoService = productoService;
    }

    /**
     * Endpoint para que el Frontend de Nicol consulte el catálogo completo
     * URL: GET http://localhost:8080/api/productos
     */
    @GetMapping
    public List<ProductoDTO> obtenerCatalogo() {
        return productoService.obtenerCatalogo();
    }
}

