package com.flowershop.services;

import com.flowershop.dto.FlowerDto;
import com.flowershop.exceptions.ApiException;
import com.flowershop.exceptions.ErrorCode;
import com.flowershop.models.Flower;
import com.flowershop.repositories.FlowerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FlowerService {

    private final FlowerRepository flowerRepository;

    @Cacheable(value = "flowers")
    public List<Flower> getAllFlowers() {
        return flowerRepository.findAll();
    }

    @Cacheable(value = "flower", key = "#id")
    public Flower findById(Long id) {
        return flowerRepository.findById(id)
                .orElseThrow(() -> new ApiException(
                        ErrorCode.FLOWER_NOT_FOUND.getMessage(),
                        ErrorCode.FLOWER_NOT_FOUND.getCode()
                ));
    }

    public Flower save(Flower flower) {
        return flowerRepository.save(flower);
    }

    @Caching(evict = {
        @CacheEvict(value = "flowers", allEntries = true)
    })
    @Transactional
    public Flower create(FlowerDto dto) {
        Flower flower = Flower.builder()
                .name(dto.getName())
                .description(dto.getDescription())
                .price(dto.getPrice())
                .quantity(dto.getQuantity())
                .isActive(true)
                .build();
        return flowerRepository.save(flower);
    }

    @Caching(evict = {
        @CacheEvict(value = "flowers", allEntries = true),
        @CacheEvict(value = "flower", key = "#id")
    })
    @Transactional
    public Flower update(Long id, FlowerDto dto) {
        Flower flower = findById(id);
        flower.setName(dto.getName());
        flower.setDescription(dto.getDescription());
        flower.setPrice(dto.getPrice());
        flower.setQuantity(dto.getQuantity());
        return flowerRepository.save(flower);
    }

    @Caching(evict = {
        @CacheEvict(value = "flowers", allEntries = true),
        @CacheEvict(value = "flower", key = "#id")
    })
    @Transactional
    public Flower updatePrice(Long id, Double price) {
        Flower flower = findById(id);
        flower.setPrice(price);
        return flowerRepository.save(flower);
    }

    @Caching(evict = {
        @CacheEvict(value = "flowers", allEntries = true),
        @CacheEvict(value = "flower", key = "#id")
    })
    @Transactional
    public Flower hide(Long id) {
        Flower flower = findById(id);
        flower.setIsActive(false);
        return flowerRepository.save(flower);
    }

    @Caching(evict = {
        @CacheEvict(value = "flowers", allEntries = true),
        @CacheEvict(value = "flower", key = "#id")
    })
    @Transactional
    public void delete(Long id) {
        Flower flower = findById(id);
        flowerRepository.delete(flower);
    }
}
