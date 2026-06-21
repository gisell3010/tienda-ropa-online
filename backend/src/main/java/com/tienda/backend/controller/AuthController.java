package com.tienda.backend.controller;

import com.tienda.backend.dto.AuthResponseDTO;
import com.tienda.backend.dto.LoginRequestDTO;
import com.tienda.backend.dto.RegistroRequestDTO;
import com.tienda.backend.dto.RolDTO;
import com.tienda.backend.dto.UsuarioPerfilDTO;
import com.tienda.backend.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/registro")
    public ResponseEntity<AuthResponseDTO> registrarCliente(@Valid @RequestBody RegistroRequestDTO request) {
        AuthResponseDTO response = authService.registrarCliente(request);

        if (response.isExito()) {
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDTO> login(@Valid @RequestBody LoginRequestDTO request) {
        AuthResponseDTO response = authService.login(request);

        if (response.isExito()) {
            return ResponseEntity.ok(response);
        }

        return ResponseEntity.badRequest().body(response);
    }

    @GetMapping("/me")
    public UsuarioPerfilDTO obtenerUsuarioAutenticado(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        return authService.obtenerUsuarioAutenticado(authorizationHeader);
    }

    @GetMapping("/roles")
    public List<RolDTO> obtenerRoles() {
        return authService.obtenerRoles();
    }
}