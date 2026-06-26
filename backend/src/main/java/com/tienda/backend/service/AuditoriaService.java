package com.tienda.backend.service;

import com.tienda.backend.repository.AuditoriaJdbcRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AuditoriaService {

    private final AuditoriaJdbcRepository repository;

    public AuditoriaService(AuditoriaJdbcRepository repository) {
        this.repository = repository;
    }

    public List<Map<String, Object>> auditoria() {
        return repository.obtenerAuditoria();
    }

    public List<Map<String, Object>> auditoriaPorTabla(String tabla) {
        return repository.obtenerAuditoriaPorTabla(tabla);
    }

    public List<Map<String, Object>> auditoriaConFiltros(
            String tabla,
            String operacion,
            String registradoPor,
            String desde,
            String hasta
    ) {
        return repository.obtenerAuditoriaConFiltros(
                tabla,
                operacion,
                registradoPor,
                desde,
                hasta
        );
    }
}