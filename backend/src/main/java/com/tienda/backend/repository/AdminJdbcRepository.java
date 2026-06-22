package com.tienda.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class AdminJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public AdminJdbcRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> obtenerProductos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_admin_productos ORDER BY pro_id"
        );
    }

    public List<Map<String, Object>> obtenerInventario() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_admin_inventario ORDER BY producto, talla, color"
        );
    }

    public List<Map<String, Object>> obtenerResumenVentas() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_resumen_ventas ORDER BY fecha DESC"
        );
    }

    public List<Map<String, Object>> obtenerVentas() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_detalle_ventas_admin ORDER BY fecha DESC"
        );
    }

    public List<Map<String, Object>> obtenerPedidos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_pedidos_cliente ORDER BY fecha DESC"
        );
    }

    public List<Map<String, Object>> obtenerPagos() {
        return jdbcTemplate.queryForList(
                """
                SELECT
                    p.pag_id,
                    p.ven_id,
                    p.met_id,
                    mp.nombre AS metodo_pago,
                    p.monto
                FROM pagos p
                INNER JOIN metodos_pago mp ON mp.met_id = p.met_id
                ORDER BY p.pag_id DESC
                """
        );
    }

    public void registrarProducto(
            String nombre,
            Double precio,
            String imagenUrl,
            Integer catId,
            Integer estId
    ) {
        jdbcTemplate.update(
                "CALL registrar_producto(?, CAST(? AS NUMERIC), ?, ?, ?)",
                nombre,
                precio,
                imagenUrl,
                catId,
                estId
        );
    }

    public void editarProducto(
            Integer productoId,
            String nombre,
            Double precio,
            String imagenUrl,
            Integer catId,
            Integer estId
    ) {
        jdbcTemplate.update(
                "CALL editar_producto(?, ?, CAST(? AS NUMERIC), ?, ?, ?)",
                productoId,
                nombre,
                precio,
                imagenUrl,
                catId,
                estId
        );
    }

    public void cambiarEstadoProducto(
            Integer productoId,
            Boolean activo
    ) {
        jdbcTemplate.update(
                "CALL cambiar_estado_producto(?, ?)",
                productoId,
                activo
        );
    }

    public void registrarInventario(
            Integer productoId,
            Integer stock,
            Integer tallaId,
            Integer colorId
    ) {
        jdbcTemplate.update(
                "CALL registrar_inventario(?, ?, ?, ?)",
                productoId,
                stock,
                tallaId,
                colorId
        );
    }

    public void actualizarInventario(
            Integer inventarioId,
            Integer stock
    ) {
        jdbcTemplate.update(
                "CALL actualizar_inventario(?, ?)",
                inventarioId,
                stock
        );
    }

    public List<Map<String, Object>> obtenerCategorias() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_categorias ORDER BY nombre"
        );
    }

    public List<Map<String, Object>> obtenerEstilos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_estilos ORDER BY nombre"
        );
    }

    public List<Map<String, Object>> obtenerTallas() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_tallas ORDER BY id"
        );
    }

    public List<Map<String, Object>> obtenerColores() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_colores ORDER BY nombre"
        );
    }
}