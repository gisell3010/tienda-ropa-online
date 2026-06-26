package com.tienda.backend.service;

import com.tienda.backend.dto.AuthResponseDTO;
import com.tienda.backend.dto.LoginRequestDTO;
import com.tienda.backend.dto.RegistroRequestDTO;
import com.tienda.backend.dto.RolDTO;
import com.tienda.backend.dto.UsuarioPerfilDTO;
import com.tienda.backend.model.Persona;
import com.tienda.backend.repository.PersonaRepository;
import com.tienda.backend.repository.RolRepository;
import com.tienda.backend.security.AuthTokenService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;
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

    @PersistenceContext
    private EntityManager entityManager;

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

    @Transactional
    public AuthResponseDTO registrarCliente(RegistroRequestDTO request) {
        String correoNormalizado = request.getCorreo().trim().toLowerCase();
        String contrasenaCifrada = passwordEncoder.encode(request.getPassword());

        try {
            Query query = entityManager.createNativeQuery("""
                    CALL registrar_cliente(
                        :nombre,
                        :telefono,
                        :correo,
                        :contrasenaHash,
                        :genero,
                        :fechaNacimiento
                    )
                    """);

            query.setParameter("nombre", request.getNombre());
            query.setParameter("telefono", request.getTelefono());
            query.setParameter("correo", correoNormalizado);
            query.setParameter("contrasenaHash", contrasenaCifrada);
            query.setParameter("genero", request.getGenero().trim().toUpperCase().substring(0, 1));
            query.setParameter("fechaNacimiento", LocalDate.parse(request.getFechaNacimiento()));

            query.executeUpdate();

            Persona guardada = personaRepository.findByCorreoIgnoreCase(correoNormalizado)
                    .orElseThrow(() -> new IllegalArgumentException("No se pudo consultar el cliente registrado"));

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

        } catch (Exception e) {
            return new AuthResponseDTO(
                    null,
                    null,
                    correoNormalizado,
                    null,
                    false,
                    false,
                    limpiarMensajeBaseDatos(e),
                    null
            );
        }
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

    private String limpiarMensajeBaseDatos(Exception exception) {
        String mensaje = exception.getMessage();

        if (mensaje == null || mensaje.isBlank()) {
            return "No se pudo completar la operación";
        }

        return mensaje
                .replace("org.hibernate.exception.GenericJDBCException: JDBC exception executing SQL", "")
                .replace("ERROR:", "")
                .replace("Call getNextException to see other errors in the batch.", "")
                .trim();
    }
}