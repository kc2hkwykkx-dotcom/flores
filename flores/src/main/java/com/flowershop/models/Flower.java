package com.flowershop.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "flowers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Flower {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String description;

    private Double price;

    private Integer quantity;

    @Column(name = "is_active", columnDefinition = "boolean default true")
    private Boolean isActive;
}
