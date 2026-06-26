package com.tienda.backend.service;

import com.tienda.backend.repository.ReporteJdbcRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ReporteService {

    private final ReporteJdbcRepository repository;

    public ReporteService(ReporteJdbcRepository repository) {
        this.repository = repository;
    }

    public Map<String, Object> reporteGeneral() {
        return repository.reporteGeneral();
    }

    public List<Map<String, Object>> ventasPorProducto() {
        return repository.ventasPorProducto();
    }

    public List<Map<String, Object>> ventasPorPeriodo() {
        return repository.ventasPorPeriodo();
    }

    public List<Map<String, Object>> ventasPorMetodoPago() {
        return repository.ventasPorMetodoPago();
    }

    public List<Map<String, Object>> topProductos() {
        return repository.topProductos();
    }

    public List<Map<String, Object>> clientesMasCompras() {
        return repository.clientesMasCompras();
    }

    public List<Map<String, Object>> productosBajoStock() {
        return repository.productosBajoStock();
    }

    public List<Map<String, Object>> usuariosPorRol() {
        return repository.usuariosPorRol();
    }

    public void refrescarReportes() {
        repository.refrescarReportes();
    }
}