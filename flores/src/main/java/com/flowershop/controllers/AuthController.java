package com.flowershop.controllers;

import com.flowershop.dto.LoginRequest;
import com.flowershop.dto.RegisterRequest;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @PostMapping("/register")
    public String register(@RequestBody RegisterRequest request) {
        return "Пользователь зарегистрирован";
    }

    @PostMapping("/login")
    public String login(@RequestBody LoginRequest request) {
        return "Вход выполнен";
    }
}
