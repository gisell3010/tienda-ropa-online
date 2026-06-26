package com.tienda.backend.service;

import com.tienda.backend.dto.InventarioDTO;
import com.tienda.backend.dto.ProductoDTO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProductoService {

    @PersistenceContext
    private EntityManager entityManager;

    public List<ProductoDTO> obtenerCatalogo() {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    pro_id,
                    producto,
                    precio,
                    imagen_url,
                    categoria,
                    estilo,
                    inv_id,
                    talla,
                    color,
                    stock
                FROM vw_catalogo_productos_detalle
                ORDER BY producto, talla, color
                """);

        List<Object[]> filas = query.getResultList();

        Map<Integer, ProductoDTO> productos = new LinkedHashMap<>();
        Map<Integer, Integer> stockPorProducto = new LinkedHashMap<>();

        for (Object[] fila : filas) {
            Integer productoId = ((Number) fila[0]).intValue();

            ProductoDTO producto = productos.computeIfAbsent(productoId, id -> {
                ProductoDTO dto = new ProductoDTO();

                dto.setId(productoId);
                dto.setNombre((String) fila[1]);
                dto.setDescripcion(null);
                dto.setPrecio(convertirDouble(fila[2]));
                dto.setImagenUrl((String) fila[3]);
                dto.setCategoria((String) fila[4]);
                dto.setEstilo((String) fila[5]);
                dto.setExistencias(new ArrayList<>());
                dto.setAgotado(true);

                return dto;
            });

            Integer stock = ((Number) fila[9]).intValue();

            producto.getExistencias().add(new InventarioDTO(
                    ((Number) fila[6]).intValue(),
                    null,
                    (String) fila[7],
                    null,
                    (String) fila[8],
                    stock
            ));

            stockPorProducto.put(
                    productoId,
                    stockPorProducto.getOrDefault(productoId, 0) + stock
            );
        }

        for (ProductoDTO producto : productos.values()) {
            producto.setAgotado(stockPorProducto.getOrDefault(producto.getId(), 0) <= 0);
        }

        return new ArrayList<>(productos.values());
    }

    private Double convertirDouble(Object valor) {
        if (valor instanceof BigDecimal bigDecimal) {
            return bigDecimal.doubleValue();
        }

        if (valor instanceof Number number) {
            return number.doubleValue();
        }

        return 0.0;
    }
}