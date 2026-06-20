package com.flowershop.exceptions;

import lombok.Getter;

@Getter
public enum ErrorCode {
    FLOWER_NOT_FOUND(404, "Товар не найден"),
    ORDER_NOT_FOUND(404, "Заказ не найден"),
    USER_NOT_FOUND(404, "Пользователь не найден"),
    FLOWER_OUT_OF_STOCK(400, "Цветок отсутствует на складе"),
    INVALID_QUANTITY(400, "Некорректное количество товара"),
    AUTH_FAILED(401, "Ошибка авторизации"),
    ACCESS_DENIED(403, "Недостаточно прав"),
    INTERNAL_ERROR(500, "Внутренняя ошибка сервера");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
