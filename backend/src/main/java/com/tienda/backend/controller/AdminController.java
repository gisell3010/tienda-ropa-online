package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.service.AdminService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService service;

    public AdminController(AdminService service) {
        this.service = service;
    }

    @GetMapping("/productos")
    public ResponseEntity<?> productos() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Productos obtenidos correctamente",
                        service.productos()
                )
        );
    }

    @GetMapping("/inventario")
    public ResponseEntity<?> inventario() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Inventario obtenido correctamente",
                        service.inventario()
                )
        );
    }

    @GetMapping("/resumen")
    public ResponseEntity<?> resumen() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Resumen obtenido correctamente",
                        service.resumen()
                )
        );
    }

    @GetMapping("/ventas")
    public ResponseEntity<?> ventas() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Ventas obtenidas correctamente",
                        service.ventas()
                )
        );
    }

    @GetMapping("/pedidos")
    public ResponseEntity<?> pedidos() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Pedidos obtenidos correctamente",
                        service.pedidos()
                )
        );
    }

    @GetMapping("/pagos")
    public ResponseEntity<?> pagos() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Pagos obtenidos correctamente",
                        service.pagos()
                )
        );
    }

    @PostMapping("/productos")
    public ResponseEntity<?> registrarProducto(
            @RequestBody Map<String, Object> body) {

        service.registrarProducto(
                body.get("nombre").toString(),
                Double.valueOf(body.get("precio").toString()),
                body.get("imagenUrl") == null ? null : body.get("imagenUrl").toString(),
                Integer.valueOf(body.get("catId").toString()),
                Integer.valueOf(body.get("estId").toString())
        );

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
                        true,
                        "Producto registrado correctamente",
                        null
                ));
    }

    @PutMapping("/productos/{id}")
    public ResponseEntity<?> editarProducto(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body) {

        service.editarProducto(
                id,
                body.get("nombre").toString(),
                Double.valueOf(body.get("precio").toString()),
                body.get("imagenUrl") == null ? null : body.get("imagenUrl").toString(),
                Integer.valueOf(body.get("catId").toString()),
                Integer.valueOf(body.get("estId").toString())
        );

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Producto actualizado correctamente",
                        null
                )
        );
    }

    @PatchMapping("/productos/{id}/estado")
    public ResponseEntity<?> cambiarEstadoProducto(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body) {

        service.cambiarEstadoProducto(
                id,
                Boolean.valueOf(body.get("activo").toString())
        );

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Estado actualizado correctamente",
                        null
                )
        );
    }

    @PostMapping("/inventario")
    public ResponseEntity<?> registrarInventario(
            @RequestBody Map<String, Object> body) {

        service.registrarInventario(
                Integer.valueOf(body.get("proId").toString()),
                Integer.valueOf(body.get("stock").toString()),
                Integer.valueOf(body.get("talId").toString()),
                Integer.valueOf(body.get("colId").toString())
        );

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
                        true,
                        "Inventario registrado correctamente",
                        null
                ));
    }

    @PutMapping("/inventario/{id}")
    public ResponseEntity<?> actualizarInventario(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body) {

        service.actualizarInventario(
                id,
                Integer.valueOf(body.get("stock").toString())
        );

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Inventario actualizado correctamente",
                        null
                )
        );
    }

    @GetMapping("/categorias")
        public ResponseEntity<?> categorias() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Categorías obtenidas correctamente",
                        service.categorias()
                )
        );
        }

        @GetMapping("/estilos")
        public ResponseEntity<?> estilos() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Estilos obtenidos correctamente",
                        service.estilos()
                )
        );
        }

        @GetMapping("/tallas")
        public ResponseEntity<?> tallas() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Tallas obtenidas correctamente",
                        service.tallas()
                )
        );
        }

        @GetMapping("/colores")
        public ResponseEntity<?> colores() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Colores obtenidos correctamente",
                        service.colores()
                )
        );
        }
}