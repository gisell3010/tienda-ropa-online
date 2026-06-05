package com.tienda.backend.repository;

import com.tienda.backend.model.Inventario;
import com.tienda.backend.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InventarioRepository extends JpaRepository<Inventario, Integer> {
    
    // Agrega esta línea si no la tiene para que el servicio pueda buscar por producto
    List<Inventario> findByProducto(Producto producto);
}