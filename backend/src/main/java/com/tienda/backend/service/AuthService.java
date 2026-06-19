package com.tienda.backend.service;

import com.tienda.backend.dto.AuthResponseDTO;
import com.tienda.backend.dto.LoginRequestDTO;
import com.tienda.backend.dto.RegistroRequestDTO;
import com.tienda.backend.dto.UsuarioPerfilDTO;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final PasswordEncoder passwordEncoder;

    public AuthService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    public AuthResponseDTO registrarCliente(RegistroRequestDTO request) {

        String passwordHash = passwordEncoder.encode(request.getPassword());

        // Pendiente conectar con procedimiento o tabla de PostgreSQL.
        // Por ahora se deja preparada la respuesta segura para el frontend.
        return new AuthResponseDTO(
                1L,
                request.getNombre(),
                request.getCorreo(),
                "CLIENTE",
                true,
                "Cliente registrado correctamente"
        );
    }

    public AuthResponseDTO login(LoginRequestDTO request) {

        // Pendiente validar contra PostgreSQL.
        // Por ahora se deja estructura base del flujo de login.
        return new AuthResponseDTO(
                1L,
                "Usuario de prueba",
                request.getCorreo(),
                "CLIENTE",
                true,
                "Inicio de sesión exitoso"
        );
    }

    public UsuarioPerfilDTO obtenerUsuarioAutenticado() {

        // Pendiente leer usuario desde sesión/token.
        return new UsuarioPerfilDTO(
                1L,
                "Usuario de prueba",
                "cliente.prueba@gmail.com",
                "CLIENTE",
                true
        );
    }
}