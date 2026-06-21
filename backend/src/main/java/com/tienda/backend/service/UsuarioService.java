package com.tienda.backend.service;

import com.tienda.backend.dto.UsuarioAdminDTO;
import com.tienda.backend.model.Persona;
import com.tienda.backend.model.Rol;
import com.tienda.backend.repository.PersonaRepository;
import com.tienda.backend.repository.RolRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UsuarioService {

    private final PersonaRepository personaRepository;
    private final RolRepository rolRepository;

    public UsuarioService(
            PersonaRepository personaRepository,
            RolRepository rolRepository) {

        this.personaRepository = personaRepository;
        this.rolRepository = rolRepository;
    }

    public List<UsuarioAdminDTO> listarUsuarios() {

        return personaRepository.findAll()
                .stream()
                .map(p -> new UsuarioAdminDTO(
                        p.getPerId(),
                        p.getNombre(),
                        p.getCorreo(),
                        p.getTelefono(),
                        p.getRol().getNombre(),
                        p.getActivo()
                ))
                .collect(Collectors.toList());
    }

    public UsuarioAdminDTO obtenerUsuario(Integer id) {

        Persona p = personaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        return new UsuarioAdminDTO(
                p.getPerId(),
                p.getNombre(),
                p.getCorreo(),
                p.getTelefono(),
                p.getRol().getNombre(),
                p.getActivo()
        );
    }

    public void cambiarRol(Integer usuarioId, String nuevoRol) {

        

        if (!nuevoRol.equalsIgnoreCase("CLIENTE")
                && !nuevoRol.equalsIgnoreCase("ADMIN")
                && !nuevoRol.equalsIgnoreCase("SUPERADMIN")) {

            throw new RuntimeException("Rol inválido");
        }

        Persona persona = personaRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Rol rol = rolRepository.findByNombreIgnoreCase(nuevoRol)
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));

        persona.setRol(rol);

        personaRepository.save(persona);
    }

    public void cambiarEstado(
            Integer usuarioId,
            Boolean activo) {

        personaRepository.findById(usuarioId)
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        personaRepository.cambiarEstadoPersona(
            usuarioId,
            activo
        );
    }
}