package com.tienda.backend.service;

import com.tienda.backend.dto.UsuarioAdminDTO;
import com.tienda.backend.dto.UsuarioCreateDTO;
import com.tienda.backend.model.Persona;
import com.tienda.backend.model.Rol;
import com.tienda.backend.repository.PersonaRepository;
import com.tienda.backend.repository.RolRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UsuarioService {

    private final PersonaRepository personaRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(
            PersonaRepository personaRepository,
            RolRepository rolRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.personaRepository = personaRepository;
        this.rolRepository = rolRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public UsuarioAdminDTO crearUsuario(UsuarioCreateDTO request) {
        String correo = request.getCorreo().trim().toLowerCase();
        String rolNombre = request.getRol().trim().toUpperCase();

        if (personaRepository.existsByCorreoIgnoreCase(correo)) {
            throw new RuntimeException("El correo ya está registrado");
        }

        if (!rolNombre.equals("CLIENTE")
                && !rolNombre.equals("ADMIN")
                && !rolNombre.equals("SUPERADMIN")) {
            throw new RuntimeException("Rol inválido");
        }

        Rol rol = rolRepository.findByNombreIgnoreCase(rolNombre)
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));

        Persona persona = new Persona();
        persona.setNombre(request.getNombre().trim());
        persona.setTelefono(request.getTelefono().trim());
        persona.setCorreo(correo);
        persona.setContrasenaHash(passwordEncoder.encode(request.getPassword()));
        persona.setGenero(request.getGenero().trim().toUpperCase().charAt(0));
        persona.setFechaNacimiento(LocalDate.parse(request.getFechaNacimiento()));
        persona.setActivo(true);
        persona.setRol(rol);

        Persona guardada = personaRepository.save(persona);

        return convertirADto(guardada);
    }

    public List<UsuarioAdminDTO> listarUsuarios() {
        return personaRepository.findAll()
                .stream()
                .map(this::convertirADto)
                .collect(Collectors.toList());
    }

    public UsuarioAdminDTO obtenerUsuario(Integer id) {
        Persona persona = personaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        return convertirADto(persona);
    }

    public void cambiarRol(Integer usuarioId, String nuevoRol) {
        String rolNombre = nuevoRol.trim().toUpperCase();

        if (!rolNombre.equals("CLIENTE")
                && !rolNombre.equals("ADMIN")
                && !rolNombre.equals("SUPERADMIN")) {
            throw new RuntimeException("Rol inválido");
        }

        Persona persona = personaRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Rol rol = rolRepository.findByNombreIgnoreCase(rolNombre)
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));

        persona.setRol(rol);
        personaRepository.save(persona);
    }

    public void cambiarEstado(Integer usuarioId, Boolean activo) {
        personaRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        personaRepository.cambiarEstadoPersona(usuarioId, activo);
    }

    private UsuarioAdminDTO convertirADto(Persona persona) {
        return new UsuarioAdminDTO(
                persona.getPerId(),
                persona.getNombre(),
                persona.getCorreo(),
                persona.getTelefono(),
                persona.getRol().getNombre(),
                persona.getActivo()
        );
    }
}