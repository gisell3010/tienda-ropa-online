package com.tienda.backend.service;

import com.tienda.backend.dto.InventarioDTO;
import com.tienda.backend.dto.ProductoDTO;
import com.tienda.backend.model.Inventario;
import com.tienda.backend.model.Producto;
import com.tienda.backend.repository.InventarioRepository;
import com.tienda.backend.repository.ProductoRepository;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductoService {

    private final ProductoRepository productoRepository;
    private final InventarioRepository inventarioRepository;

    // Inyección de dependencias por constructor para los repositorios
    public ProductoService(ProductoRepository productoRepository, InventarioRepository inventarioRepository) {
        this.productoRepository = productoRepository;
        this.inventarioRepository = inventarioRepository;
    }

    /**
     * Obtiene todos los productos mapeados a DTO con su stock validado
     */
    public List<ProductoDTO> obtenerCatalogo() {
        List<Producto> productos = productoRepository.findAll();
        
        return productos.stream().map(this::convertirADto).collect(Collectors.toList());
    }

    /**
     * Método auxiliar que convierte la Entidad a DTO y aplica la regla de negocio del stock
     */
    private ProductoDTO convertirADto(Producto producto) {
        ProductoDTO dto = new ProductoDTO();
        dto.setId(producto.getProId());
        dto.setNombre(producto.getNombre());
        dto.setDescripcion(producto.getDescripcion());
        dto.setPrecio(producto.getPrecio());
        
        // Mapeamos los nombres directamente de las relaciones (evitamos IDs sueltos)
        dto.setCategoria(producto.getCategoria().getNombre());
        dto.setEstilo(producto.getEstilo().getNombre());

        // 1. Buscamos el inventario disponible de este producto específico
        List<Inventario> inventarios = inventarioRepository.findByProducto(producto);

        // 2. Convertimos las existencias de la BD al formato del molde de Nicol (InventarioDTO)
        List<InventarioDTO> existenciasDto = new ArrayList<>();
        int stockTotal = 0;

        for (Inventario inv : inventarios) {
            InventarioDTO invDto = new InventarioDTO(
                inv.getTalla().getNombre(), // Nombre de la talla (ej: M, L, 39)
                inv.getColor().getNombre(), // Nombre del color (ej: Negro)
                inv.getStock()
            );
            existenciasDto.add(invDto);
            stockTotal += inv.getStock(); // Vamos sumando las existencias
        }

        dto.setExistencias(existenciasDto);

        // 3. Regla de Negocio: Si el stock global es 0, se marca como AGOTADO (true)
        // pero NO se oculta del catálogo, tal como pide el MVP
        if (stockTotal == 0) {
            dto.setAgotado(true);
        } else {
            dto.setAgotado(false);
        }

        return dto;
    }
}