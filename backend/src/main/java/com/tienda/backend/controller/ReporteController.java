package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.service.ReporteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reportes")
public class ReporteController {

    private final ReporteService service;

    public ReporteController(
            ReporteService service) {

        this.service = service;
    }

    @GetMapping("/general")
    public ResponseEntity<?> reporteGeneral() {

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Reporte general obtenido correctamente",
                        service.reporteGeneral()
                )
        );
    }

    @GetMapping("/ventas-productos")
    public ResponseEntity<?> ventasPorProducto() {

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Reporte de ventas por producto obtenido correctamente",
                        service.ventasPorProducto()
                )
        );
    }
}