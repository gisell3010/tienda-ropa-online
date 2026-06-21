package com.tienda.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class AuditoriaJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public AuditoriaJdbcRepository(
            JdbcTemplate jdbcTemplate) {

        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> obtenerAuditoria() {

        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_auditoria_general"
        );
    }
    
    public List<Map<String, Object>> obtenerAuditoriaPorTabla(
        String tabla) {

    return jdbcTemplate.queryForList(
            """
            SELECT *
            FROM vw_auditoria_general
            WHERE tabla_afectada = ?
            ORDER BY fecha DESC
            """,
            tabla
        );
    }

}