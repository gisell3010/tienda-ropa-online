package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.service.AuditoriaService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auditorias")
public class AuditoriaController {

    private final AuditoriaService service;

    public AuditoriaController(AuditoriaService service) {
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
            @PathVariable String tabla
    ) {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Auditoría obtenida correctamente",
                        service.auditoriaPorTabla(tabla)
                )
        );
    }

    @GetMapping("/filtro")
    public ResponseEntity<?> auditoriaConFiltros(
            @RequestParam(required = false) String tabla,
            @RequestParam(required = false) String operacion,
            @RequestParam(required = false) String registradoPor,
            @RequestParam(required = false) String desde,
            @RequestParam(required = false) String hasta
    ) {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Auditoría filtrada correctamente",
                        service.auditoriaConFiltros(
                                tabla,
                                operacion,
                                registradoPor,
                                desde,
                                hasta
                        )
                )
        );
    }
}