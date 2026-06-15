package com.tienda.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tienda.backend.dto.CompraRequestDTO;
import com.tienda.backend.dto.CompraResponseDTO;
import com.tienda.backend.service.CompraService;

@RestController
@RequestMapping("/api/compras")
@CrossOrigin(origins = "*")
public class CompraController {

    @Autowired
    private CompraService compraService;

    @PostMapping
    public ResponseEntity<CompraResponseDTO> registrarCompra(
            @RequestBody CompraRequestDTO request) {

        CompraResponseDTO response =
                compraService.registrarCompra(request);

        if (response.isExito()) {
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.badRequest().body(response);
    }
}