package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.service.AuditoriaService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auditorias")
public class AuditoriaController {

    private final AuditoriaService service;

    public AuditoriaController(
            AuditoriaService service) {

        this.service = service;
    }

    @GetMapping
    public ResponseEntity<?> listarAuditoria() {

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Auditoría obtenida correctamente",
                        service.auditoria()
                )
        );
    }

    @GetMapping("/tabla/{tabla}")
    public ResponseEntity<?> auditoriaPorTabla(
        @PathVariable String tabla) {

    return ResponseEntity.ok(
            new ApiResponse<>(
                    true,
                    "Auditoría obtenida correctamente",
                    service.auditoriaPorTabla(tabla)
            )
        );
    }

}