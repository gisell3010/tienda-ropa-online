package com.tienda.backend.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ubicaciones")
public class UbicacionController {

    private final JdbcTemplate jdbcTemplate;

    public UbicacionController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/departamentos")
    public List<Map<String, Object>> listarDepartamentos() {
        return jdbcTemplate.queryForList("""
            SELECT dep_id AS id, nombre
            FROM departamentos
            ORDER BY nombre
        """);
    }

    @GetMapping("/municipios")
    public List<Map<String, Object>> listarMunicipios(
            @RequestParam String departamentoId
    ) {
        return jdbcTemplate.queryForList("""
            SELECT mun_id AS id, nombre, dep_id
            FROM municipios
            WHERE dep_id = ?
            ORDER BY nombre
        """, departamentoId);
    }
}