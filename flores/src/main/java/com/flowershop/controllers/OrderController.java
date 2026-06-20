package com.flowershop.controllers;

import com.flowershop.models.Order;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orders")
public class OrderController {

    @PostMapping("/create")
    public String createOrder(@RequestBody Order order) {
        return "Заказ успешно создан";
    }
}
