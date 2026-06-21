package com.tienda.backend.controller;

import com.tienda.backend.dto.CompraRequestDTO;
import com.tienda.backend.dto.CompraResponseDTO;
import com.tienda.backend.security.AuthTokenService;
import com.tienda.backend.service.CompraService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/compras")
public class CompraController {

    private final CompraService compraService;
    private final AuthTokenService authTokenService;

    public CompraController(CompraService compraService, AuthTokenService authTokenService) {
        this.compraService = compraService;
        this.authTokenService = authTokenService;
    }

    @PostMapping
    public ResponseEntity<CompraResponseDTO> registrarCompra(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody CompraRequestDTO request
    ) {
        Long clienteId = authTokenService.obtenerUsuarioDesdeHeader(authorizationHeader)
                .orElseThrow(() -> new IllegalArgumentException("Token inválido o no enviado"))
                .getUsuarioId();

        request.setPersonaId(clienteId.intValue());

        CompraResponseDTO response = compraService.registrarCompra(request);

        if (response.isExito()) {
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.badRequest().body(response);
    }
}