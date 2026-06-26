package com.tienda.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class ReporteJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public ReporteJdbcRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> reporteGeneral() {
        return jdbcTemplate.queryForMap(
                "SELECT * FROM vw_reporte_general"
        );
    }

    public List<Map<String, Object>> ventasPorProducto() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM mv_resumen_ventas_productos"
        );
    }

    public List<Map<String, Object>> ventasPorPeriodo() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_ventas_por_periodo"
        );
    }

    public List<Map<String, Object>> ventasPorMetodoPago() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_ventas_por_metodo_pago"
        );
    }

    public List<Map<String, Object>> topProductos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_top_productos"
        );
    }

    public List<Map<String, Object>> clientesMasCompras() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_clientes_mas_compras"
        );
    }

    public List<Map<String, Object>> productosBajoStock() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_productos_bajo_stock"
        );
    }

    public List<Map<String, Object>> usuariosPorRol() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_usuarios_por_rol"
        );
    }

    public void refrescarReportes() {
        jdbcTemplate.update(
                "CALL refrescar_reportes()"
        );
    }
}