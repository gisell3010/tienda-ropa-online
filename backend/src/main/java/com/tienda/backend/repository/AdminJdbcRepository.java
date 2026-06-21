package com.tienda.backend.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import java.util.HashMap;

@Repository
public class AdminJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public AdminJdbcRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> obtenerProductos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_admin_productos"
        );
    }

    public List<Map<String, Object>> obtenerInventario() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_admin_inventario"
        );
    }

    public List<Map<String, Object>> obtenerResumenVentas() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_resumen_ventas"
        );
    }

    public List<Map<String, Object>> obtenerVentas() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM vw_detalle_ventas_admin"
        );
    }

    public List<Map<String, Object>> obtenerPedidos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM ventas"
        );
    }

    public List<Map<String, Object>> obtenerPagos() {
        return jdbcTemplate.queryForList(
                "SELECT * FROM pagos"
        );
    }

    public void registrarInventario(
        Integer productoId,
        Integer stock,
        Integer tallaId,
        Integer colorId) {

    SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
            .withProcedureName("registrar_inventario");

    Map<String, Object> params = new HashMap<>();

    params.put("p_pro_id", productoId);
    params.put("p_stock", stock);
    params.put("p_tal_id", tallaId);
    params.put("p_col_id", colorId);

    call.execute(params);
}

public void actualizarInventario(
            Integer inventarioId,
        Integer stock) {

        SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
            .withProcedureName("actualizar_inventario");

        Map<String, Object> params = new HashMap<>();

        params.put("p_inv_id", inventarioId);
        params.put("p_stock", stock);

        call.execute(params);
    }

    public void registrarProducto(
        String nombre,
        Double precio,
        String imagenUrl,
        Integer catId,
        Integer estId) {

    SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
            .withProcedureName("registrar_producto");

    Map<String, Object> params = new HashMap<>();

    params.put("p_nombre", nombre);
    params.put("p_precio", precio);
    params.put("p_imagen_url", imagenUrl);
    params.put("p_cat_id", catId);
    params.put("p_est_id", estId);

    call.execute(params);
}

public void editarProducto(
        Integer productoId,
        String nombre,
        Double precio,
        String imagenUrl,
        Integer catId,
        Integer estId) {

    SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
            .withProcedureName("editar_producto");

    Map<String, Object> params = new HashMap<>();

        
    params.put("p_pro_id", productoId);
    params.put("p_nombre", nombre);
    params.put("p_precio", precio);
    params.put("p_imagen_url", imagenUrl);
    params.put("p_cat_id", catId);
    params.put("p_est_id", estId);

    call.execute(params);
 }

    public void cambiarEstadoProducto(
            Integer productoId,
            Boolean activo) {

        SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("cambiar_estado_producto");

        Map<String, Object> params = new HashMap<>();

        params.put("p_pro_id", productoId);
        params.put("p_activo", activo);

        call.execute(params);
    }
}