package com.tienda.backend.controller;

import com.tienda.backend.dto.ClientePerfilDTO;
import com.tienda.backend.dto.DireccionClienteDTO;
import com.tienda.backend.dto.PedidoClienteDTO;
import com.tienda.backend.dto.PedidoDetalleResponseDTO;
import com.tienda.backend.security.AuthTokenService;
import com.tienda.backend.service.ClienteService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cliente")
public class ClienteController {

    private final ClienteService clienteService;
    private final AuthTokenService authTokenService;

    public ClienteController(
            ClienteService clienteService,
            AuthTokenService authTokenService
    ) {
        this.clienteService = clienteService;
        this.authTokenService = authTokenService;
    }

    @GetMapping("/perfil")
    public ClientePerfilDTO obtenerPerfil(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        return clienteService.obtenerPerfil(clienteId);
    }

    @PutMapping("/perfil")
    public ClientePerfilDTO actualizarPerfil(
            @RequestHeader("Authorization") String authorizationHeader,
            @Valid @RequestBody ClientePerfilDTO request
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        return clienteService.actualizarPerfil(clienteId, request);
    }

    @GetMapping("/direcciones")
    public List<DireccionClienteDTO> listarDirecciones(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        return clienteService.listarDirecciones(clienteId);
    }

    @PostMapping("/direcciones")
    public DireccionClienteDTO registrarDireccion(
            @RequestHeader("Authorization") String authorizationHeader,
            @Valid @RequestBody DireccionClienteDTO request
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        return clienteService.registrarDireccion(clienteId, request);
    }

    @DeleteMapping("/direcciones/{direccionId}")
    public void eliminarDireccion(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long direccionId
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        clienteService.eliminarDireccion(clienteId, direccionId);
    }

    @GetMapping("/pedidos")
    public List<PedidoClienteDTO> listarPedidos(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        return clienteService.listarPedidos(clienteId);
    }

    @GetMapping("/pedidos/{pedidoId}")
    public PedidoDetalleResponseDTO obtenerDetallePedido(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long pedidoId
    ) {
        Long clienteId = obtenerClienteId(authorizationHeader);
        return clienteService.obtenerDetallePedido(clienteId, pedidoId);
    }

    private Long obtenerClienteId(String authorizationHeader) {
        return authTokenService.obtenerUsuarioDesdeHeader(authorizationHeader)
                .orElseThrow(() -> new IllegalArgumentException("Token inválido o no enviado"))
                .getUsuarioId();
    }
}