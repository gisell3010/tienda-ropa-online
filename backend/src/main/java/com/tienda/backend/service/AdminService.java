package com.tienda.backend.service;

import com.tienda.backend.repository.AdminJdbcRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AdminService {

    private final AdminJdbcRepository repository;

    public AdminService(AdminJdbcRepository repository) {
        this.repository = repository;
    }

    public List<Map<String, Object>> productos() {
        return repository.obtenerProductos();
    }

    public List<Map<String, Object>> inventario() {
        return repository.obtenerInventario();
    }

    public List<Map<String, Object>> resumen() {
        return repository.obtenerResumenVentas();
    }

    public List<Map<String, Object>> ventas() {
        return repository.obtenerVentas();
    }

    public List<Map<String, Object>> pedidos() {
        return repository.obtenerPedidos();
    }

    public List<Map<String, Object>> pagos() {
        return repository.obtenerPagos();
    }

    

    public void registrarProducto(
        String nombre,
        Double precio,
        String imagenUrl,
        Integer catId,
        Integer estId) {

    if (nombre == null || nombre.isBlank())
        throw new RuntimeException("Nombre requerido");

    if (precio == null || precio <= 0)
        throw new RuntimeException("Precio inválido");

    if (catId == null)
        throw new RuntimeException("Categoría requerida");

    if (estId == null)
        throw new RuntimeException("Estilo requerido");

    repository.registrarProducto(
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
        Integer estId) {

    repository.editarProducto(
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
        Boolean activo) {

    repository.cambiarEstadoProducto(
            productoId,
            activo
    );
}

public void registrarInventario(
        Integer productoId,
        Integer stock,
        Integer tallaId,
        Integer colorId) {

    if (stock < 0)
        throw new RuntimeException("Stock inválido");

    repository.registrarInventario(
            productoId,
            stock,
            tallaId,
            colorId
    );
}

public void actualizarInventario(
        Integer inventarioId,
        Integer stock) {

    if (stock < 0)
        throw new RuntimeException("Stock inválido");

    repository.actualizarInventario(
            inventarioId,
            stock
        );
    }

    
}