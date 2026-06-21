package com.tienda.backend.service;

import com.tienda.backend.dto.AuthResponseDTO;
import com.tienda.backend.dto.LoginRequestDTO;
import com.tienda.backend.dto.RegistroRequestDTO;
import com.tienda.backend.dto.RolDTO;
import com.tienda.backend.dto.UsuarioPerfilDTO;
import com.tienda.backend.model.Persona;
import com.tienda.backend.model.Rol;
import com.tienda.backend.repository.PersonaRepository;
import com.tienda.backend.repository.RolRepository;
import com.tienda.backend.security.AuthTokenService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class AuthService {

    private final PasswordEncoder passwordEncoder;
    private final PersonaRepository personaRepository;
    private final RolRepository rolRepository;
    private final AuthTokenService authTokenService;

    public AuthService(
            PasswordEncoder passwordEncoder,
            PersonaRepository personaRepository,
            RolRepository rolRepository,
            AuthTokenService authTokenService
    ) {
        this.passwordEncoder = passwordEncoder;
        this.personaRepository = personaRepository;
        this.rolRepository = rolRepository;
        this.authTokenService = authTokenService;
    }

    public AuthResponseDTO registrarCliente(RegistroRequestDTO request) {

        if (personaRepository.existsByCorreoIgnoreCase(request.getCorreo())) {
            return new AuthResponseDTO(
                    null,
                    null,
                    request.getCorreo(),
                    null,
                    false,
                    false,
                    "El correo ya está registrado",
                    null
            );
        }

        Optional<Rol> rolCliente = rolRepository.findByNombreIgnoreCase("CLIENTE");

        if (rolCliente.isEmpty()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    null,
                    null,
                    false,
                    false,
                    "No existe el rol CLIENTE",
                    null
            );
        }

        if (request.getGenero() == null || request.getGenero().isBlank()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    request.getCorreo(),
                    null,
                    false,
                    false,
                    "El género es obligatorio",
                    null
            );
        }

        if (request.getFechaNacimiento() == null || request.getFechaNacimiento().isBlank()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    request.getCorreo(),
                    null,
                    false,
                    false,
                    "La fecha de nacimiento es obligatoria",
                    null
            );
        }

        Persona persona = new Persona();

        persona.setNombre(request.getNombre().trim());
        persona.setTelefono(request.getTelefono().trim());
        persona.setCorreo(request.getCorreo().trim().toLowerCase());
        persona.setContrasenaHash(passwordEncoder.encode(request.getPassword()));
        persona.setGenero(request.getGenero().trim().toUpperCase().charAt(0));
        persona.setFechaNacimiento(LocalDate.parse(request.getFechaNacimiento()));
        persona.setActivo(true);
        persona.setRol(rolCliente.get());

        Persona guardada = personaRepository.save(persona);

        String token = authTokenService.generarToken(guardada);

        return new AuthResponseDTO(
                guardada.getPerId().longValue(),
                guardada.getNombre(),
                guardada.getCorreo(),
                guardada.getRol().getNombre(),
                Boolean.TRUE.equals(guardada.getActivo()),
                true,
                "Cliente registrado correctamente",
                token
        );
    }

    public AuthResponseDTO login(LoginRequestDTO request) {

        Optional<Persona> persona =
                personaRepository.findByCorreoIgnoreCase(request.getCorreo().trim());

        if (persona.isEmpty()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    request.getCorreo(),
                    null,
                    false,
                    false,
                    "Correo no registrado",
                    null
            );
        }

        Persona usuario = persona.get();

        if (!Boolean.TRUE.equals(usuario.getActivo())) {
            return new AuthResponseDTO(
                    usuario.getPerId().longValue(),
                    usuario.getNombre(),
                    usuario.getCorreo(),
                    usuario.getRol().getNombre(),
                    false,
                    false,
                    "El usuario está inactivo",
                    null
            );
        }

        boolean passwordCorrecta =
                passwordEncoder.matches(
                        request.getPassword(),
                        usuario.getContrasenaHash()
                );

        if (!passwordCorrecta) {
            return new AuthResponseDTO(
                    usuario.getPerId().longValue(),
                    usuario.getNombre(),
                    usuario.getCorreo(),
                    usuario.getRol().getNombre(),
                    true,
                    false,
                    "Contraseña incorrecta",
                    null
            );
        }

        String token = authTokenService.generarToken(usuario);

        return new AuthResponseDTO(
                usuario.getPerId().longValue(),
                usuario.getNombre(),
                usuario.getCorreo(),
                usuario.getRol().getNombre(),
                true,
                true,
                "Inicio de sesión exitoso",
                token
        );
    }

    public UsuarioPerfilDTO obtenerUsuarioAutenticado(String authorizationHeader) {

        AuthTokenService.TokenData tokenData = authTokenService
                .obtenerUsuarioDesdeHeader(authorizationHeader)
                .orElseThrow(() -> new IllegalArgumentException("Token inválido o no enviado"));

        Persona persona = personaRepository.findById(tokenData.getUsuarioId().intValue())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        return new UsuarioPerfilDTO(
                persona.getPerId().longValue(),
                persona.getNombre(),
                persona.getCorreo(),
                persona.getRol().getNombre(),
                Boolean.TRUE.equals(persona.getActivo())
        );
    }

    public List<RolDTO> obtenerRoles() {

        return rolRepository.findAll()
                .stream()
                .map(rol -> new RolDTO(
                        rol.getRolId(),
                        rol.getNombre()
                ))
                .collect(Collectors.toList());
    }
}