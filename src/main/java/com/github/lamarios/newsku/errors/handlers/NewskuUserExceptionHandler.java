package com.github.lamarios.newsku.errors.handlers;

import com.github.lamarios.newsku.errors.NewskuException;
import com.github.lamarios.newsku.errors.NewskuUserException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.OptimisticLockException;
import jakarta.validation.ConstraintViolationException;
import org.jetbrains.annotations.NotNull;
import org.jspecify.annotations.Nullable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.util.MultiValueMap;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@ControllerAdvice
public class NewskuUserExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler({NewskuUserException.class, NewskuException.class})
    @Nullable
    ResponseEntity<@NotNull Object> handleError(NewskuException exception, WebRequest request) {
        return build(exception, exception.getClass().getSimpleName(), HttpStatus.BAD_REQUEST, request);
    }

    @ExceptionHandler(EntityNotFoundException.class)
    @Nullable
    ResponseEntity<@NotNull Object> handleNotFound(EntityNotFoundException exception, WebRequest request) {
        return build(exception, "EntityNotFoundException", HttpStatus.NOT_FOUND, request);
    }

    @ExceptionHandler(AccessDeniedException.class)
    @Nullable
    ResponseEntity<@NotNull Object> handleAccessDenied(AccessDeniedException exception, WebRequest request) {
        return build(exception, "AccessDeniedException", HttpStatus.FORBIDDEN, request);
    }

    @ExceptionHandler(OptimisticLockException.class)
    @Nullable
    ResponseEntity<@NotNull Object> handleOptimisticLock(OptimisticLockException exception, WebRequest request) {
        return build(exception, "OptimisticLockException", HttpStatus.CONFLICT, request);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    @Nullable
    ResponseEntity<@NotNull Object> handleConstraintViolation(ConstraintViolationException exception, WebRequest request) {
        List<Map<String, String>> fieldErrors = exception.getConstraintViolations().stream()
                .map(v -> Map.of(
                        "field", v.getPropertyPath().toString(),
                        "message", v.getMessage()))
                .toList();
        Map<String, Object> body = Map.of(
                "message", "Validation failed",
                "type", "ConstraintViolationException",
                "uuid", UUID.randomUUID().toString(),
                "fields", fieldErrors);
        return super.handleExceptionInternal(exception, body, jsonHeaders(), HttpStatus.BAD_REQUEST, request);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex,
                                                                  HttpHeaders headers,
                                                                  org.springframework.http.HttpStatusCode status,
                                                                  WebRequest request) {
        List<Map<String, String>> fieldErrors = ex.getBindingResult().getFieldErrors().stream()
                .map(this::formatFieldError)
                .toList();
        Map<String, Object> body = Map.of(
                "message", "Validation failed",
                "type", "ValidationException",
                "uuid", UUID.randomUUID().toString(),
                "fields", fieldErrors);
        return super.handleExceptionInternal(ex, body, jsonHeaders(), HttpStatus.UNPROCESSABLE_ENTITY, request);
    }

    private Map<String, String> formatFieldError(FieldError error) {
        return Map.of(
                "field", error.getField(),
                "message", error.getDefaultMessage() != null ? error.getDefaultMessage() : "invalid");
    }

    private ResponseEntity<@NotNull Object> build(Exception exception, String type, HttpStatus status, WebRequest request) {
        Map<String, Object> body = Map.of(
                "message", exception.getMessage() != null ? exception.getMessage() : type,
                "type", type,
                "uuid", UUID.randomUUID().toString());
        return super.handleExceptionInternal(exception, body, jsonHeaders(), status, request);
    }

    private HttpHeaders jsonHeaders() {
        return new HttpHeaders(MultiValueMap.fromSingleValue(Map.of("Content-Type", "application/json")));
    }
}
