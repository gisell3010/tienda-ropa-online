package com.tienda.backend.service;

import com.tienda.backend.dto.ClientePerfilDTO;
import com.tienda.backend.dto.DetallePedidoClienteDTO;
import com.tienda.backend.dto.DireccionClienteDTO;
import com.tienda.backend.dto.PedidoClienteDTO;
import com.tienda.backend.dto.PedidoDetalleResponseDTO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class ClienteService {

    @PersistenceContext
    private EntityManager entityManager;

    public ClientePerfilDTO obtenerPerfil(Long clienteId) {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    per_id,
                    nombre,
                    telefono,
                    correo,
                    genero,
                    fecha_nacimiento,
                    rol,
                    activo
                FROM vw_perfil_cliente
                WHERE per_id = :clienteId
                """);

        query.setParameter("clienteId", clienteId.intValue());

        List<Object[]> filas = query.getResultList();

        if (filas.isEmpty()) {
            throw new IllegalArgumentException("Cliente no encontrado");
        }

        Object[] fila = filas.get(0);

        return new ClientePerfilDTO(
                ((Number) fila[0]).longValue(),
                (String) fila[1],
                (String) fila[2],
                (String) fila[3],
                fila[4] == null ? null : fila[4].toString(),
                convertirLocalDate(fila[5]),
                (String) fila[6],
                Boolean.TRUE.equals(fila[7])
        );
    }

    @Transactional
    public ClientePerfilDTO actualizarPerfil(Long clienteId, ClientePerfilDTO request) {
        Query query = entityManager.createNativeQuery("""
                CALL actualizar_perfil_cliente(
                    :clienteId,
                    :nombre,
                    :telefono,
                    :genero,
                    :fechaNacimiento
                )
                """);

        query.setParameter("clienteId", clienteId.intValue());
        query.setParameter("nombre", request.getNombre());
        query.setParameter("telefono", request.getTelefono());
        query.setParameter("genero", request.getGenero());
        query.setParameter("fechaNacimiento", request.getFechaNacimiento());

        query.executeUpdate();

        return obtenerPerfil(clienteId);
    }

    public List<DireccionClienteDTO> listarDirecciones(Long clienteId) {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    dir_id,
                    linea,
                    mun_id,
                    municipio,
                    dep_id,
                    departamento
                FROM (
                    SELECT
                        dir_id,
                        linea,
                        mun_id,
                        municipio,
                        dep_id,
                        departamento,
                        ROW_NUMBER() OVER (
                            PARTITION BY mun_id, LOWER(TRIM(linea))
                            ORDER BY dir_id DESC
                        ) AS numero
                    FROM vw_direcciones_cliente
                    WHERE per_id = :clienteId
                ) direcciones_cliente
                WHERE numero = 1
                ORDER BY dir_id DESC
                """);

        query.setParameter("clienteId", clienteId.intValue());

        List<Object[]> filas = query.getResultList();
        List<DireccionClienteDTO> direcciones = new ArrayList<>();

        for (Object[] fila : filas) {
            direcciones.add(mapearDireccion(fila));
        }

        return direcciones;
    }

    @Transactional
    public DireccionClienteDTO registrarDireccion(Long clienteId, DireccionClienteDTO request) {
        String municipioId = obtenerMunicipioId(request);

        Query query = entityManager.createNativeQuery("""
                CALL registrar_direccion_cliente(
                    :clienteId,
                    :municipioId,
                    :linea
                )
                """);

        query.setParameter("clienteId", clienteId.intValue());
        query.setParameter("municipioId", municipioId);
        query.setParameter("linea", request.getDireccion());

        query.executeUpdate();

        return obtenerDireccionRegistrada(
                clienteId,
                municipioId,
                request.getDireccion()
        );
    }

    @Transactional
    public void eliminarDireccion(Long clienteId, Long direccionId) {
        Query query = entityManager.createNativeQuery("""
                CALL eliminar_direccion_cliente(
                    :clienteId,
                    :direccionId
                )
                """);

        query.setParameter("clienteId", clienteId.intValue());
        query.setParameter("direccionId", direccionId.intValue());

        query.executeUpdate();
    }

    public List<PedidoClienteDTO> listarPedidos(Long clienteId) {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    ven_id,
                    fecha,
                    COALESCE(total_venta, 0) AS total_venta
                FROM vw_pedidos_cliente
                WHERE per_id = :clienteId
                ORDER BY fecha DESC
                """);

        query.setParameter("clienteId", clienteId.intValue());

        List<Object[]> filas = query.getResultList();
        List<PedidoClienteDTO> pedidos = new ArrayList<>();

        for (Object[] fila : filas) {
            pedidos.add(new PedidoClienteDTO(
                    ((Number) fila[0]).longValue(),
                    convertirFecha(fila[1]),
                    "CONFIRMADO",
                    convertirBigDecimal(fila[2])
            ));
        }

        return pedidos;
    }

    public PedidoDetalleResponseDTO obtenerDetallePedido(Long clienteId, Long pedidoId) {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    ven_id,
                    fecha,
                    pro_id,
                    producto,
                    talla,
                    color,
                    cantidad,
                    precio_unitario,
                    subtotal
                FROM vw_detalle_pedido_cliente
                WHERE per_id = :clienteId
                  AND ven_id = :pedidoId
                ORDER BY producto
                """);

        query.setParameter("clienteId", clienteId.intValue());
        query.setParameter("pedidoId", pedidoId.intValue());

        List<Object[]> filas = query.getResultList();

        if (filas.isEmpty()) {
            throw new IllegalArgumentException("Pedido no encontrado para el cliente");
        }

        List<DetallePedidoClienteDTO> detalles = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;
        LocalDateTime fecha = null;

        for (Object[] fila : filas) {
            fecha = convertirFecha(fila[1]);

            BigDecimal subtotal = convertirBigDecimal(fila[8]);
            total = total.add(subtotal);

            detalles.add(new DetallePedidoClienteDTO(
                    ((Number) fila[2]).longValue(),
                    (String) fila[3],
                    (String) fila[4],
                    (String) fila[5],
                    ((Number) fila[6]).intValue(),
                    convertirBigDecimal(fila[7]),
                    subtotal
            ));
        }

        return new PedidoDetalleResponseDTO(
                pedidoId,
                fecha,
                "CONFIRMADO",
                total,
                detalles
        );
    }

    private DireccionClienteDTO obtenerDireccionRegistrada(
            Long clienteId,
            String municipioId,
            String direccion
    ) {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    dir_id,
                    linea,
                    mun_id,
                    municipio,
                    dep_id,
                    departamento
                FROM vw_direcciones_cliente
                WHERE per_id = :clienteId
                  AND mun_id = :municipioId
                  AND LOWER(TRIM(linea)) = LOWER(TRIM(:direccion))
                ORDER BY dir_id DESC
                LIMIT 1
                """);

        query.setParameter("clienteId", clienteId.intValue());
        query.setParameter("municipioId", municipioId);
        query.setParameter("direccion", direccion);

        List<Object[]> filas = query.getResultList();

        if (filas.isEmpty()) {
            throw new IllegalArgumentException("La dirección fue registrada, pero no se pudo consultar");
        }

        return mapearDireccion(filas.get(0));
    }

    private DireccionClienteDTO mapearDireccion(Object[] fila) {
        return new DireccionClienteDTO(
                ((Number) fila[0]).longValue(),
                (String) fila[1],
                (String) fila[2],
                (String) fila[3],
                (String) fila[4],
                (String) fila[5],
                "",
                false
        );
    }

    private String obtenerMunicipioId(DireccionClienteDTO request) {
        if (request.getMunicipioId() != null && !request.getMunicipioId().isBlank()) {
            return request.getMunicipioId();
        }

        if (request.getMunicipio() == null || request.getMunicipio().isBlank()) {
            throw new IllegalArgumentException("Debe indicar el municipio");
        }

        if (request.getDepartamento() == null || request.getDepartamento().isBlank()) {
            throw new IllegalArgumentException("Debe indicar el departamento");
        }

        Query query = entityManager.createNativeQuery("""
                SELECT m.mun_id
                FROM vw_municipios m
                INNER JOIN vw_departamentos d ON d.dep_id = m.dep_id
                WHERE LOWER(m.nombre) = LOWER(:municipio)
                  AND LOWER(d.nombre) = LOWER(:departamento)
                LIMIT 1
                """);

        query.setParameter("municipio", request.getMunicipio());
        query.setParameter("departamento", request.getDepartamento());

        List<?> resultados = query.getResultList();

        if (resultados.isEmpty()) {
            throw new IllegalArgumentException("No se encontró el municipio indicado");
        }

        return resultados.get(0).toString();
    }

    private LocalDateTime convertirFecha(Object valor) {
        if (valor instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }

        if (valor instanceof Date date) {
            return date.toLocalDate().atStartOfDay();
        }

        return null;
    }

    private LocalDate convertirLocalDate(Object valor) {
        if (valor instanceof Date date) {
            return date.toLocalDate();
        }

        if (valor instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime().toLocalDate();
        }

        if (valor instanceof LocalDate localDate) {
            return localDate;
        }

        return null;
    }

    private BigDecimal convertirBigDecimal(Object valor) {
        if (valor instanceof BigDecimal bigDecimal) {
            return bigDecimal;
        }

        if (valor instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }

        return BigDecimal.ZERO;
    }
}