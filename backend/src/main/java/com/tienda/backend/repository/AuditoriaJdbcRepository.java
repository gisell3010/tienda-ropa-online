package com.tienda.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Repository
public class AuditoriaJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public AuditoriaJdbcRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> obtenerAuditoria() {
        return jdbcTemplate.queryForList(
                """
                SELECT *
                FROM vw_auditoria_general
                ORDER BY fecha_cambio DESC
                """
        );
    }

    public List<Map<String, Object>> obtenerAuditoriaPorTabla(String tabla) {
        return jdbcTemplate.queryForList(
                """
                SELECT *
                FROM vw_auditoria_general
                WHERE tabla = ?
                ORDER BY fecha_cambio DESC
                """,
                tabla
        );
    }

    public List<Map<String, Object>> obtenerAuditoriaConFiltros(
            String tabla,
            String operacion,
            String registradoPor,
            String desde,
            String hasta
    ) {
        StringBuilder sql = new StringBuilder(
                """
                SELECT *
                FROM vw_auditoria_general
                WHERE 1 = 1
                """
        );

        List<Object> params = new ArrayList<>();

        if (tabla != null && !tabla.isBlank()) {
            sql.append(" AND tabla = ?");
            params.add(tabla);
        }

        if (operacion != null && !operacion.isBlank()) {
            sql.append(" AND operacion = ?");
            params.add(operacion);
        }

        if (registradoPor != null && !registradoPor.isBlank()) {
            sql.append(" AND registrado_por = ?");
            params.add(registradoPor);
        }

        if (desde != null && !desde.isBlank()) {
            sql.append(" AND fecha_cambio >= ?::timestamp");
            params.add(desde);
        }

        if (hasta != null && !hasta.isBlank()) {
            sql.append(" AND fecha_cambio <= ?::timestamp");
            params.add(hasta);
        }

        sql.append(" ORDER BY fecha_cambio DESC");

        return jdbcTemplate.queryForList(
                sql.toString(),
                params.toArray()
        );
    }
}