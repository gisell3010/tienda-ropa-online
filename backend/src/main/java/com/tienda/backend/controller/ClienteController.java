package com.tienda.backend.controller;

import com.tienda.backend.dto.ClientePerfilDTO;
import com.tienda.backend.dto.DireccionClienteDTO;
import com.tienda.backend.dto.PedidoClienteDTO;
import com.tienda.backend.dto.PedidoDetalleResponseDTO;
import com.tienda.backend.service.ClienteService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cliente")
public class ClienteController {

    private final ClienteService clienteService;

    public ClienteController(ClienteService clienteService) {
        this.clienteService = clienteService;
    }

    @GetMapping("/perfil")
    public ClientePerfilDTO obtenerPerfil(
            @RequestHeader(value = "X-Usuario-Id", defaultValue = "1") Long clienteId) {
        return clienteService.obtenerPerfil(clienteId);
    }

    @GetMapping("/direcciones")
    public List<DireccionClienteDTO> listarDirecciones(
            @RequestHeader(value = "X-Usuario-Id", defaultValue = "1") Long clienteId) {
        return clienteService.listarDirecciones(clienteId);
    }

    @PostMapping("/direcciones")
    public DireccionClienteDTO registrarDireccion(
            @RequestHeader(value = "X-Usuario-Id", defaultValue = "1") Long clienteId,
            @Valid @RequestBody DireccionClienteDTO request) {
        return clienteService.registrarDireccion(clienteId, request);
    }

    @PutMapping("/direcciones/{direccionId}")
    public DireccionClienteDTO actualizarDireccion(
            @RequestHeader(value = "X-Usuario-Id", defaultValue = "1") Long clienteId,
            @PathVariable Long direccionId,
            @Valid @RequestBody DireccionClienteDTO request) {
        return clienteService.actualizarDireccion(clienteId, direccionId, request);
    }

    @GetMapping("/pedidos")
    public List<PedidoClienteDTO> listarPedidos(
            @RequestHeader(value = "X-Usuario-Id", defaultValue = "1") Long clienteId) {
        return clienteService.listarPedidos(clienteId);
    }

    @GetMapping("/pedidos/{pedidoId}")
    public PedidoDetalleResponseDTO obtenerDetallePedido(
            @RequestHeader(value = "X-Usuario-Id", defaultValue = "1") Long clienteId,
            @PathVariable Long pedidoId) {
        return clienteService.obtenerDetallePedido(clienteId, pedidoId);
    }
}