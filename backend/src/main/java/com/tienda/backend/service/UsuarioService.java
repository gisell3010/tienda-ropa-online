package com.tienda.backend.service;

import com.tienda.backend.dto.UsuarioAdminDTO;
import com.tienda.backend.dto.UsuarioCreateDTO;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class UsuarioService {

    private final JdbcTemplate jdbcTemplate;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(
            JdbcTemplate jdbcTemplate,
            PasswordEncoder passwordEncoder
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.passwordEncoder = passwordEncoder;
    }

    public UsuarioAdminDTO crearUsuario(UsuarioCreateDTO request) {
        String rolNombre = request.getRol().trim().toUpperCase();
        String contrasenaHash = passwordEncoder.encode(request.getPassword());

        if (rolNombre.equals("CLIENTE")) {
            jdbcTemplate.update(
                    "CALL registrar_cliente(?, ?, ?, ?, ?, ?)",
                    request.getNombre(),
                    request.getTelefono(),
                    request.getCorreo(),
                    contrasenaHash,
                    request.getGenero(),
                    java.sql.Date.valueOf(request.getFechaNacimiento())
            );
        } else if (rolNombre.equals("ADMIN") || rolNombre.equals("SUPERADMIN")) {
            Integer rolId = jdbcTemplate.queryForObject(
                    "SELECT rol_id FROM roles WHERE nombre = ?",
                    Integer.class,
                    rolNombre
            );

            jdbcTemplate.update(
                    "CALL registrar_usuario_admin(?, ?, ?, ?, ?, ?, ?)",
                    request.getNombre(),
                    request.getTelefono(),
                    request.getCorreo(),
                    contrasenaHash,
                    request.getGenero(),
                    java.sql.Date.valueOf(request.getFechaNacimiento()),
                    rolId
            );
        } else {
            throw new RuntimeException("Rol inválido");
        }

        return obtenerUsuarioPorCorreo(request.getCorreo());
    }

    public List<UsuarioAdminDTO> listarUsuarios() {
        return jdbcTemplate.queryForList(
                        "SELECT * FROM vw_usuarios_sistema_detalle ORDER BY per_id"
                )
                .stream()
                .map(this::convertirFilaUsuario)
                .collect(Collectors.toList());
    }

    public UsuarioAdminDTO obtenerUsuario(Integer id) {
        List<Map<String, Object>> resultado = jdbcTemplate.queryForList(
                "SELECT * FROM vw_usuarios_sistema_detalle WHERE per_id = ?",
                id
        );

        if (resultado.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }

        return convertirFilaUsuario(resultado.get(0));
    }

    public List<Map<String, Object>> listarRoles() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_roles_sistema ORDER BY rol_id"
        );
    }

    public void cambiarRol(Integer usuarioId, String nuevoRol) {
        String rolNombre = nuevoRol.trim().toUpperCase();

        if (!rolNombre.equals("CLIENTE")
                && !rolNombre.equals("ADMIN")
                && !rolNombre.equals("SUPERADMIN")) {
            throw new RuntimeException("Rol inválido");
        }

        Integer rolId = jdbcTemplate.queryForObject(
                "SELECT rol_id FROM roles WHERE nombre = ?",
                Integer.class,
                rolNombre
        );

        cambiarRolPorId(usuarioId, rolId);
    }

    public void cambiarRolPorId(Integer usuarioId, Integer rolId) {
        jdbcTemplate.update(
                "CALL cambiar_rol_persona(?, ?)",
                usuarioId,
                rolId
        );
    }

    public void cambiarEstado(Integer usuarioId, Boolean activo) {
        jdbcTemplate.update(
                "CALL cambiar_estado_persona(?, ?)",
                usuarioId,
                activo
        );
    }

    private UsuarioAdminDTO obtenerUsuarioPorCorreo(String correo) {
        Map<String, Object> row = jdbcTemplate.queryForMap(
                "SELECT * FROM vw_usuarios_sistema_detalle WHERE LOWER(correo) = LOWER(?)",
                correo
        );

        return convertirFilaUsuario(row);
    }

    private UsuarioAdminDTO convertirFilaUsuario(Map<String, Object> row) {
        return new UsuarioAdminDTO(
                ((Number) row.get("per_id")).intValue(),
                row.get("nombre").toString(),
                row.get("correo").toString(),
                row.get("telefono") == null ? null : row.get("telefono").toString(),
                row.get("rol").toString(),
                (Boolean) row.get("activo")
        );
    }
}