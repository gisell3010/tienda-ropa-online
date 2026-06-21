package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService service;

    public UsuarioController(UsuarioService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<?> listarUsuarios() {

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Usuarios obtenidos correctamente",
                        service.listarUsuarios()
                )
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerUsuario(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Usuario obtenido correctamente",
                        service.obtenerUsuario(id)
                )
        );
    }

    @PatchMapping("/{id}/estado")
    public ResponseEntity<?> cambiarEstado(
        @PathVariable Integer id,
        @RequestBody Map<String, Object> body) {

     service.cambiarEstado(
            id,
            Boolean.valueOf(
                    body.get("activo").toString()
            )
    );

    return ResponseEntity.ok(
            new ApiResponse<>(
                    true,
                    "Estado actualizado correctamente",
                    null
            )
        );
    }
}