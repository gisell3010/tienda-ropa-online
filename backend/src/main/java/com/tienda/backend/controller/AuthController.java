package com.tienda.backend.controller;

import com.tienda.backend.dto.AuthResponseDTO;
import com.tienda.backend.dto.LoginRequestDTO;
import com.tienda.backend.dto.RegistroRequestDTO;
import com.tienda.backend.dto.UsuarioPerfilDTO;
import com.tienda.backend.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import com.tienda.backend.dto.RolDTO;
import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/registro")
    public AuthResponseDTO registrarCliente(@Valid @RequestBody RegistroRequestDTO request) {
        return authService.registrarCliente(request);
    }

    @PostMapping("/login")
    public AuthResponseDTO login(@Valid @RequestBody LoginRequestDTO request) {
        return authService.login(request);
    }

    @GetMapping("/me")
    public UsuarioPerfilDTO obtenerUsuarioAutenticado() {
        return authService.obtenerUsuarioAutenticado();
    }

    @GetMapping("/roles")
    public List<RolDTO> obtenerRoles() {
        return authService.obtenerRoles();
    }
    
}