package com.tienda.backend.service;

import com.tienda.backend.repository.ReporteJdbcRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ReporteService {

    private final ReporteJdbcRepository repository;

    public ReporteService(
            ReporteJdbcRepository repository) {

        this.repository = repository;
    }

    public Map<String, Object> reporteGeneral() {
        return repository.reporteGeneral();
    }

    public List<Map<String, Object>> ventasPorProducto() {
        return repository.ventasPorProducto();
    }
}