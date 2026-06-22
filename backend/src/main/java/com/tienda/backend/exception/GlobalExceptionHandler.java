package com.tienda.backend.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> manejarValidaciones(
            MethodArgumentNotValidException exception
    ) {
        String mensaje = exception.getBindingResult()
                .getFieldErrors()
                .stream()
                .findFirst()
                .map(error -> error.getDefaultMessage())
                .orElse("Hay campos inválidos en la solicitud.");

        Map<String, Object> respuesta = new LinkedHashMap<>();
        respuesta.put("exito", false);
        respuesta.put("mensaje", mensaje);

        return ResponseEntity.badRequest().body(respuesta);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> manejarArgumentosInvalidos(
            IllegalArgumentException exception
    ) {
        Map<String, Object> respuesta = new LinkedHashMap<>();
        respuesta.put("exito", false);
        respuesta.put("mensaje", exception.getMessage());

        return ResponseEntity.badRequest().body(respuesta);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> manejarRuntime(
            RuntimeException exception
    ) {
        Map<String, Object> respuesta = new LinkedHashMap<>();
        respuesta.put("exito", false);
        respuesta.put("mensaje", exception.getMessage());

        return ResponseEntity.badRequest().body(respuesta);
    }
}