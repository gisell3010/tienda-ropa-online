package com.tienda.backend.service;

import com.tienda.backend.dto.ClientePerfilDTO;
import com.tienda.backend.dto.DetallePedidoClienteDTO;
import com.tienda.backend.dto.DireccionClienteDTO;
import com.tienda.backend.dto.PedidoClienteDTO;
import com.tienda.backend.dto.PedidoDetalleResponseDTO;
import com.tienda.backend.model.Persona;
import com.tienda.backend.repository.PersonaRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class ClienteService {

    private final PersonaRepository personaRepository;

    @PersistenceContext
    private EntityManager entityManager;

    public ClienteService(PersonaRepository personaRepository) {
        this.personaRepository = personaRepository;
    }

    public ClientePerfilDTO obtenerPerfil(Long clienteId) {
        Persona persona = personaRepository.findById(clienteId.intValue())
                .orElseThrow(() -> new IllegalArgumentException("Cliente no encontrado"));

        return new ClientePerfilDTO(
                persona.getPerId().longValue(),
                persona.getNombre(),
                persona.getTelefono(),
                persona.getCorreo(),
                persona.getRol().getNombre(),
                Boolean.TRUE.equals(persona.getActivo())
        );
    }

    public List<DireccionClienteDTO> listarDirecciones(Long clienteId) {
        Query query = entityManager.createNativeQuery("""
                SELECT
                    d.dir_id,
                    d.linea,
                    m.nombre AS municipio,
                    dep.nombre AS departamento
                FROM personas_direcciones pd
                INNER JOIN direcciones d ON d.dir_id = pd.dir_id
                INNER JOIN municipios m ON m.mun_id = d.mun_id
                INNER JOIN departamentos dep ON dep.dep_id = m.dep_id
                WHERE pd.per_id = :clienteId
                ORDER BY d.dir_id
                """);

        query.setParameter("clienteId", clienteId.intValue());

        List<Object[]> filas = query.getResultList();
        List<DireccionClienteDTO> direcciones = new ArrayList<>();

        for (Object[] fila : filas) {
            direcciones.add(new DireccionClienteDTO(
                    ((Number) fila[0]).longValue(),
                    (String) fila[1],
                    (String) fila[2],
                    (String) fila[3],
                    "",
                    false
            ));
        }

        return direcciones;
    }

    @Transactional
    public DireccionClienteDTO registrarDireccion(Long clienteId, DireccionClienteDTO request) {
        String munId = obtenerMunicipioId(request.getMunicipio(), request.getDepartamento());

        Query insertarDireccion = entityManager.createNativeQuery("""
                INSERT INTO direcciones (mun_id, linea)
                VALUES (:munId, :linea)
                RETURNING dir_id
                """);

        insertarDireccion.setParameter("munId", munId);
        insertarDireccion.setParameter("linea", request.getDireccion());

        Number dirId = (Number) insertarDireccion.getSingleResult();

        Query relacion = entityManager.createNativeQuery("""
                INSERT INTO personas_direcciones (per_id, dir_id)
                VALUES (:perId, :dirId)
                ON CONFLICT (per_id, dir_id) DO NOTHING
                """);

        relacion.setParameter("perId", clienteId.intValue());
        relacion.setParameter("dirId", dirId.intValue());
        relacion.executeUpdate();

        request.setDireccionId(dirId.longValue());

        return request;
    }

    @Transactional
    public DireccionClienteDTO actualizarDireccion(Long clienteId, Long direccionId, DireccionClienteDTO request) {
        String munId = obtenerMunicipioId(request.getMunicipio(), request.getDepartamento());

        Query validarRelacion = entityManager.createNativeQuery("""
                SELECT COUNT(*)
                FROM personas_direcciones
                WHERE per_id = :perId
                  AND dir_id = :dirId
                """);

        validarRelacion.setParameter("perId", clienteId.intValue());
        validarRelacion.setParameter("dirId", direccionId.intValue());

        Number total = (Number) validarRelacion.getSingleResult();

        if (total.intValue() == 0) {
            throw new IllegalArgumentException("La dirección no pertenece al cliente");
        }

        Query actualizarDireccion = entityManager.createNativeQuery("""
                UPDATE direcciones
                SET mun_id = :munId,
                    linea = :linea
                WHERE dir_id = :dirId
                """);

        actualizarDireccion.setParameter("munId", munId);
        actualizarDireccion.setParameter("linea", request.getDireccion());
        actualizarDireccion.setParameter("dirId", direccionId.intValue());
        actualizarDireccion.executeUpdate();

        request.setDireccionId(direccionId);

        return request;
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

    private String obtenerMunicipioId(String municipio, String departamento) {
        Query query = entityManager.createNativeQuery("""
                SELECT m.mun_id
                FROM municipios m
                INNER JOIN departamentos d ON d.dep_id = m.dep_id
                WHERE LOWER(m.nombre) = LOWER(:municipio)
                  AND LOWER(d.nombre) = LOWER(:departamento)
                LIMIT 1
                """);

        query.setParameter("municipio", municipio);
        query.setParameter("departamento", departamento);

        List<?> resultados = query.getResultList();

        if (resultados.isEmpty()) {
            throw new IllegalArgumentException("No se encontró el municipio indicado");
        }

        return resultados.get(0).toString();
    }

    private LocalDateTime convertirFecha(Object valor) {
        if (valor instanceof java.sql.Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }

        if (valor instanceof Date date) {
            return date.toLocalDate().atStartOfDay();
        }

        return LocalDateTime.now();
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