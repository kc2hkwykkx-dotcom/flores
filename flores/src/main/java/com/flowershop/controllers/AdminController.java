package com.flowershop.controllers;

import com.flowershop.dto.FlowerDto;
import com.flowershop.models.Flower;
import com.flowershop.models.Order;
import com.flowershop.models.OrderStatus;
import com.flowershop.models.User;
import com.flowershop.services.FlowerService;
import com.flowershop.services.OrderService;
import com.flowershop.services.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final FlowerService flowerService;
    private final OrderService orderService;
    private final UserService userService;

    @PostMapping("/flowers/create")
    public ResponseEntity<Flower> createFlower(@Valid @RequestBody FlowerDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(flowerService.create(dto));
    }

    @PutMapping("/flowers/update/{id}")
    public ResponseEntity<Flower> updateFlower(@PathVariable Long id, @Valid @RequestBody FlowerDto dto) {
        return ResponseEntity.ok(flowerService.update(id, dto));
    }

    @PatchMapping("/flowers/update/{id}")
    public ResponseEntity<Flower> updateFlowerPrice(@PathVariable Long id, @RequestParam Double price) {
        return ResponseEntity.ok(flowerService.updatePrice(id, price));
    }

    @PatchMapping("/flowers/hide/{id}")
    public ResponseEntity<Flower> hideFlower(@PathVariable Long id) {
        return ResponseEntity.ok(flowerService.hide(id));
    }

    @DeleteMapping("/flowers/delete/{id}")
    public ResponseEntity<Void> deleteFlower(@PathVariable Long id) {
        flowerService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/orders")
    public ResponseEntity<List<Order>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @PatchMapping("/orders/{id}")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable Long id, @RequestParam OrderStatus status) {
        return ResponseEntity.ok(orderService.updateStatus(id, status));
    }
}
