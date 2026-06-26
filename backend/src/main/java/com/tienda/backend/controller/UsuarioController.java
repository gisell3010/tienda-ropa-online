package com.tienda.backend.controller;

import com.tienda.backend.dto.ApiResponse;
import com.tienda.backend.dto.UsuarioCreateDTO;
import com.tienda.backend.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
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

    @PostMapping
    public ResponseEntity<?> crearUsuario(
            @Valid @RequestBody UsuarioCreateDTO request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
                        true,
                        "Usuario creado correctamente",
                        service.crearUsuario(request)
                ));
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
    public ResponseEntity<?> obtenerUsuario(@PathVariable Integer id) {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Usuario obtenido correctamente",
                        service.obtenerUsuario(id)
                )
        );
    }

    @GetMapping("/roles")
    public ResponseEntity<?> listarRoles() {
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Roles obtenidos correctamente",
                        service.listarRoles()
                )
        );
    }

    @PatchMapping("/{id}/estado")
    public ResponseEntity<?> cambiarEstado(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body
    ) {
        if (!body.containsKey("activo") || body.get("activo") == null) {
            throw new RuntimeException("Debe indicar el estado del usuario");
        }

        service.cambiarEstado(
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

    @PatchMapping("/{id}/rol")
    public ResponseEntity<?> cambiarRol(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body
    ) {
        if (body.containsKey("rolId") && body.get("rolId") != null) {
            service.cambiarRolPorId(
                    id,
                    Integer.valueOf(body.get("rolId").toString())
            );
        } else if (body.containsKey("rol") && body.get("rol") != null) {
            service.cambiarRol(
                    id,
                    body.get("rol").toString()
            );
        } else {
            throw new RuntimeException("Debe indicar el rol del usuario");
        }

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Rol actualizado correctamente",
                        null
                )
        );
    }
}