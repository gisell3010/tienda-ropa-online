package com.tienda.backend.repository;

import com.tienda.backend.model.Persona;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface PersonaRepository extends JpaRepository<Persona, Integer> {

    Optional<Persona> findByCorreo(String correo);

    Optional<Persona> findByCorreoIgnoreCase(String correo);

    boolean existsByCorreoIgnoreCase(String correo);

    @Modifying
    @Transactional
    @Query(
            value = "CALL cambiar_estado_persona(:personaId, :activo)",
            nativeQuery = true
    )
    void cambiarEstadoPersona(
            Integer personaId,
            Boolean activo
    );

}