package com.tienda.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class ReporteJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public ReporteJdbcRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> reporteGeneral() {

        Map<String, Object> reporte = new HashMap<>();

        Integer totalUsuarios = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM vw_usuarios_sistema",
                Integer.class
        );

        Integer usuariosActivos = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM vw_usuarios_sistema WHERE activo = true",
                Integer.class
        );

        Integer totalVentas = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM ventas",
                Integer.class
        );

        Double montoVentas = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(total_venta),0) FROM vw_resumen_ventas",
                Double.class
        );

        reporte.put("totalUsuarios", totalUsuarios);
        reporte.put("usuariosActivos", usuariosActivos);
        reporte.put("totalVentas", totalVentas);
        reporte.put("montoVentas", montoVentas);

        return reporte;
    }

    public List<Map<String, Object>> ventasPorProducto() {

        return jdbcTemplate.queryForList(
                "SELECT * FROM mv_resumen_ventas_productos"
        );
    }
}