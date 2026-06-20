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

    public AuthService(
            PasswordEncoder passwordEncoder,
            PersonaRepository personaRepository,
            RolRepository rolRepository) {

        this.passwordEncoder = passwordEncoder;
        this.personaRepository = personaRepository;
        this.rolRepository = rolRepository;
    }

    public AuthResponseDTO registrarCliente(RegistroRequestDTO request) {

        Optional<Persona> existente =
                personaRepository.findByCorreo(request.getCorreo());

        if (existente.isPresent()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    request.getCorreo(),
                    null,
                    false,
                    "El correo ya está registrado"
            );
        }

        Optional<Rol> rolCliente =
                rolRepository.findByNombre("CLIENTE");

        if (rolCliente.isEmpty()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    null,
                    null,
                    false,
                    "No existe el rol CLIENTE"
            );
        }

        Persona persona = new Persona();

        persona.setNombre(request.getNombre());
        persona.setTelefono(request.getTelefono());
        persona.setCorreo(request.getCorreo());

        persona.setContrasenaHash(
                passwordEncoder.encode(request.getPassword())
        );

        if (request.getGenero() != null &&
                !request.getGenero().isBlank()) {

            persona.setGenero(
                    request.getGenero().charAt(0)
            );
        }

        if (request.getFechaNacimiento() != null &&
                !request.getFechaNacimiento().isBlank()) {

            persona.setFechaNacimiento(
                    LocalDate.parse(request.getFechaNacimiento())
            );
        }

        persona.setRol(rolCliente.get());

        System.out.println("ENTRO AL METODO REGISTRAR CLIENTE");

        Persona guardada = personaRepository.save(persona);

        System.out.println("ID GUARDADO: " + guardada.getPerId());

        return new AuthResponseDTO(
                guardada.getPerId().longValue(),
                guardada.getNombre(),
                guardada.getCorreo(),
                guardada.getRol().getNombre(),
                true,
                "Cliente registrado correctamente"
        );
    }

    public AuthResponseDTO login(LoginRequestDTO request) {

        Optional<Persona> persona =
                personaRepository.findByCorreo(request.getCorreo());

        if (persona.isEmpty()) {
            return new AuthResponseDTO(
                    null,
                    null,
                    request.getCorreo(),
                    null,
                    false,
                    "Correo no registrado"
            );
        }

        Persona usuario = persona.get();

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
                    false,
                    "Contraseña incorrecta"
            );
        }

        return new AuthResponseDTO(
                usuario.getPerId().longValue(),
                usuario.getNombre(),
                usuario.getCorreo(),
                usuario.getRol().getNombre(),
                true,
                "Inicio de sesión exitoso"
        );
    }

    public UsuarioPerfilDTO obtenerUsuarioAutenticado() {

        return new UsuarioPerfilDTO(
                1L,
                "Usuario de prueba",
                "cliente.prueba@gmail.com",
                "CLIENTE",
                true
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