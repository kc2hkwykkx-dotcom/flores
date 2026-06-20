package com.flowershop.services;

import com.flowershop.dto.OrderRequest;
import com.flowershop.exceptions.ApiException;
import com.flowershop.exceptions.ErrorCode;
import com.flowershop.models.Flower;
import com.flowershop.models.Order;
import com.flowershop.models.OrderStatus;
import com.flowershop.models.User;
import com.flowershop.repositories.FlowerRepository;
import com.flowershop.repositories.OrderRepository;
import com.flowershop.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final FlowerRepository flowerRepository;
    private final UserRepository userRepository;

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    public Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new ApiException(
                        ErrorCode.ORDER_NOT_FOUND.getMessage(),
                        ErrorCode.ORDER_NOT_FOUND.getCode()
                ));
    }

    @Transactional
    public Order save(Order order) {
        return orderRepository.save(order);
    }

    @Transactional
    public Order createFromRequest(OrderRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ApiException(
                        ErrorCode.USER_NOT_FOUND.getMessage(),
                        ErrorCode.USER_NOT_FOUND.getCode()
                ));

        Flower flower = flowerRepository.findById(request.getFlowerId())
                .orElseThrow(() -> new ApiException(
                        ErrorCode.FLOWER_NOT_FOUND.getMessage(),
                        ErrorCode.FLOWER_NOT_FOUND.getCode()
                ));

        if (flower.getQuantity() < request.getQuantity()) {
            throw new ApiException(
                    ErrorCode.FLOWER_OUT_OF_STOCK.getMessage(),
                    ErrorCode.FLOWER_OUT_OF_STOCK.getCode()
            );
        }

        flower.setQuantity(flower.getQuantity() - request.getQuantity());
        flowerRepository.save(flower);

        Order order = Order.builder()
                .user(user)
                .flowerName(flower.getName())
                .quantity(request.getQuantity())
                .totalPrice(BigDecimal.valueOf(flower.getPrice() * request.getQuantity()))
                .orderDate(LocalDateTime.now())
                .status(OrderStatus.NEW)
                .build();
        return orderRepository.save(order);
    }

    @Transactional
    public Order updateStatus(Long id, OrderStatus status) {
        Order order = findById(id);
        order.setStatus(status);
        return orderRepository.save(order);
    }
}
