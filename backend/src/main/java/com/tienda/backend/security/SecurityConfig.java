package com.tienda.backend.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.List;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .csrf(csrf -> csrf.disable())
                .cors(Customizer.withDefaults())
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint((request, response, authException) ->
                                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "No autenticado"))
                        .accessDeniedHandler((request, response, accessDeniedException) ->
                                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acceso denegado"))
                )
                .authorizeHttpRequests(auth -> auth

                        // Endpoints públicos
                        .requestMatchers(HttpMethod.POST, "/api/auth/registro").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/productos/**").permitAll()

                        // Endpoints para CLIENTE
                        .requestMatchers("/api/cliente/**").hasRole("CLIENTE")
                        .requestMatchers("/api/carrito/**").hasRole("CLIENTE")
                        .requestMatchers("/api/compras/**").hasRole("CLIENTE")
                        .requestMatchers("/api/pedidos/cliente/**").hasRole("CLIENTE")
                        .requestMatchers("/api/direcciones/**").hasRole("CLIENTE")
                        .requestMatchers(HttpMethod.GET, "/api/auth/me").hasAnyRole("CLIENTE", "ADMIN", "SUPERADMIN")

                        // Endpoints para ADMIN y SUPERADMIN
                        .requestMatchers("/api/admin/**").hasAnyRole("ADMIN", "SUPERADMIN")
                        .requestMatchers("/api/inventario/**").hasAnyRole("ADMIN", "SUPERADMIN")
                        .requestMatchers("/api/reportes/**").hasAnyRole("ADMIN", "SUPERADMIN")
                        .requestMatchers("/api/metodos-pago/**").hasAnyRole("ADMIN", "SUPERADMIN")

                        // Endpoints exclusivos para SUPERADMIN
                        .requestMatchers("/api/superadmin/**").hasRole("SUPERADMIN")
                        .requestMatchers("/api/usuarios/**").hasRole("SUPERADMIN")
                        .requestMatchers("/api/auditorias/**").hasRole("SUPERADMIN")

                        // Mientras se integra token real, el resto queda permitido temporalmente
                        .anyRequest().permitAll()
                )
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable());

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        return new CorsConfigurationSource() {
            @Override
            public CorsConfiguration getCorsConfiguration(HttpServletRequest request) {
                CorsConfiguration config = new CorsConfiguration();

                config.setAllowedOrigins(List.of("http://localhost:5173", "http://localhost:3000"));
                config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
                config.setAllowedHeaders(List.of("*"));
                config.setAllowCredentials(true);

                return config;
            }
        };
    }
}