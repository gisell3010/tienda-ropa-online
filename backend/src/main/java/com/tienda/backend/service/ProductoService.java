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

    public ProductoService(ProductoRepository productoRepository, InventarioRepository inventarioRepository) {
        this.productoRepository = productoRepository;
        this.inventarioRepository = inventarioRepository;
    }

    public List<ProductoDTO> obtenerCatalogo() {
        List<Producto> productos = productoRepository.findByActivoTrue();

        return productos.stream()
                .map(this::convertirADto)
                .collect(Collectors.toList());
    }

    private ProductoDTO convertirADto(Producto producto) {
        ProductoDTO dto = new ProductoDTO();

        dto.setId(producto.getProId());
        dto.setNombre(producto.getNombre());
        dto.setDescripcion(producto.getDescripcion());
        dto.setPrecio(producto.getPrecio());
        dto.setImagenUrl(producto.getImagenUrl());
        dto.setCategoria(producto.getCategoria().getNombre());
        dto.setEstilo(producto.getEstilo().getNombre());

        List<Inventario> inventarios = inventarioRepository.findByProducto(producto);

        List<InventarioDTO> existenciasDto = new ArrayList<>();
        int stockTotal = 0;

        for (Inventario inv : inventarios) {
            InventarioDTO invDto = new InventarioDTO(
                    inv.getInvId(),
                    inv.getTalla().getTalId(),
                    inv.getTalla().getNombre(),
                    inv.getColor().getColId(),
                    inv.getColor().getNombre(),
                    inv.getStock()
            );

            existenciasDto.add(invDto);
            stockTotal += inv.getStock();
        }

        dto.setExistencias(existenciasDto);
        dto.setAgotado(stockTotal == 0);

        return dto;
    }
}