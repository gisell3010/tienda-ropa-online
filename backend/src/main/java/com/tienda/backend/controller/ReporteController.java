package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.service.ReporteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reportes")
public class ReporteController {

    private final ReporteService service;

    public ReporteController(ReporteService service) {
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

    @GetMapping("/ventas-periodo")
    public ResponseEntity<?> ventasPorPeriodo() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Reporte de ventas por periodo obtenido correctamente",
                        service.ventasPorPeriodo()
                )
        );
    }

    @GetMapping("/metodos-pago")
    public ResponseEntity<?> ventasPorMetodoPago() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Reporte de ventas por método de pago obtenido correctamente",
                        service.ventasPorMetodoPago()
                )
        );
    }

    @GetMapping("/top-productos")
    public ResponseEntity<?> topProductos() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Top productos obtenido correctamente",
                        service.topProductos()
                )
        );
    }

    @GetMapping("/clientes-compras")
    public ResponseEntity<?> clientesMasCompras() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Clientes con más compras obtenidos correctamente",
                        service.clientesMasCompras()
                )
        );
    }

    @GetMapping("/bajo-stock")
    public ResponseEntity<?> productosBajoStock() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Productos con bajo stock obtenidos correctamente",
                        service.productosBajoStock()
                )
        );
    }

    @GetMapping("/usuarios-rol")
    public ResponseEntity<?> usuariosPorRol() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Usuarios por rol obtenidos correctamente",
                        service.usuariosPorRol()
                )
        );
    }

    @PostMapping("/refrescar")
    public ResponseEntity<?> refrescarReportes() {
        service.refrescarReportes();

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Reportes actualizados correctamente",
                        null
                )
        );
    }
}