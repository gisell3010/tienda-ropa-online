package com.tienda.backend.security;

import com.tienda.backend.model.Persona;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Optional;

@Service
public class AuthTokenService {

    public String generarToken(Persona persona) {
        String rol = persona.getRol().getNombre();

        String contenido = persona.getPerId() + ":" + rol + ":" + System.currentTimeMillis();

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(contenido.getBytes(StandardCharsets.UTF_8));
    }

    public Optional<TokenData> obtenerUsuarioDesdeHeader(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            return Optional.empty();
        }

        String token = authorizationHeader.substring(7);

        return obtenerUsuarioDesdeToken(token);
    }

    public Optional<TokenData> obtenerUsuarioDesdeToken(String token) {
        try {
            String contenido = new String(
                    Base64.getUrlDecoder().decode(token),
                    StandardCharsets.UTF_8
            );

            String[] partes = contenido.split(":");

            if (partes.length < 2) {
                return Optional.empty();
            }

            Long usuarioId = Long.valueOf(partes[0]);
            String rol = partes[1];

            return Optional.of(new TokenData(usuarioId, rol));

        } catch (Exception e) {
            return Optional.empty();
        }
    }

    public static class TokenData {

        private final Long usuarioId;
        private final String rol;

        public TokenData(Long usuarioId, String rol) {
            this.usuarioId = usuarioId;
            this.rol = rol;
        }

        public Long getUsuarioId() {
            return usuarioId;
        }

        public String getRol() {
            return rol;
        }
    }
}