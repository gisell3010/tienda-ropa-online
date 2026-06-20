package com.tienda.backend.service;

import com.tienda.backend.dto.ClientePerfilDTO;
import com.tienda.backend.dto.DetallePedidoClienteDTO;
import com.tienda.backend.dto.DireccionClienteDTO;
import com.tienda.backend.dto.PedidoClienteDTO;
import com.tienda.backend.dto.PedidoDetalleResponseDTO;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class ClienteService {

    public ClientePerfilDTO obtenerPerfil(Long clienteId) {
        return new ClientePerfilDTO(
                clienteId,
                "Cliente Prueba",
                "3124567890",
                "cliente.prueba@gmail.com",
                "CLIENTE",
                true
        );
    }

    public List<DireccionClienteDTO> listarDirecciones(Long clienteId) {
        return List.of(
                new DireccionClienteDTO(
                        1L,
                        "Calle 10 # 20-30",
                        "Pamplona",
                        "Norte de Santander",
                        "Casa color blanco",
                        true
                )
        );
    }

    public DireccionClienteDTO registrarDireccion(Long clienteId, DireccionClienteDTO request) {
        request.setDireccionId(2L);
        return request;
    }

    public DireccionClienteDTO actualizarDireccion(Long clienteId, Long direccionId, DireccionClienteDTO request) {
        request.setDireccionId(direccionId);
        return request;
    }

    public List<PedidoClienteDTO> listarPedidos(Long clienteId) {
        return List.of(
                new PedidoClienteDTO(
                        1L,
                        LocalDateTime.now(),
                        "CONFIRMADO",
                        new BigDecimal("140000")
                )
        );
    }

    public PedidoDetalleResponseDTO obtenerDetallePedido(Long clienteId, Long pedidoId) {
        List<DetallePedidoClienteDTO> detalles = List.of(
                new DetallePedidoClienteDTO(
                        1L,
                        "Camiseta básica",
                        "M",
                        "Negro",
                        2,
                        new BigDecimal("45000"),
                        new BigDecimal("90000")
                ),
                new DetallePedidoClienteDTO(
                        2L,
                        "Gorra urbana",
                        "Única",
                        "Blanco",
                        1,
                        new BigDecimal("50000"),
                        new BigDecimal("50000")
                )
        );

        return new PedidoDetalleResponseDTO(
                pedidoId,
                LocalDateTime.now(),
                "CONFIRMADO",
                new BigDecimal("140000"),
                detalles
        );
    }
}