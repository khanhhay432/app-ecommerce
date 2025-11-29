package com.ecommerce.service;

import com.ecommerce.dto.*;
import com.ecommerce.entity.*;
import com.ecommerce.repository.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewRepository reviewRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;
    
    public Page<ReviewDTO> getProductReviews(Long productId, int page, int size) {
        return reviewRepository.findByProductIdAndIsVisibleTrue(productId, PageRequest.of(page, size))
                .map(this::toDTO);
    }
    
    public ReviewDTO createReview(Long userId, CreateReviewRequest request) {
        if (reviewRepository.existsByUserIdAndProductId(userId, request.getProductId())) {
            throw new RuntimeException("You already reviewed this product");
        }
        
        User user = userRepository.findById(userId).orElseThrow();
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        String imagesJson = null;
        if (request.getImages() != null && !request.getImages().isEmpty()) {
            try {
                imagesJson = objectMapper.writeValueAsString(request.getImages());
            } catch (JsonProcessingException e) {
                imagesJson = null;
            }
        }
        
        Review review = Review.builder()
                .user(user)
                .product(product)
                .rating(request.getRating())
                .comment(request.getComment())
                .images(imagesJson)
                .isVerifiedPurchase(true)
                .build();
        
        return toDTO(reviewRepository.save(review));
    }
    
    private ReviewDTO toDTO(Review review) {
        List<String> images = Collections.emptyList();
        if (review.getImages() != null) {
            try {
                images = Arrays.asList(objectMapper.readValue(review.getImages(), String[].class));
            } catch (JsonProcessingException e) {
                images = Collections.emptyList();
            }
        }
        
        return ReviewDTO.builder()
                .id(review.getId())
                .productId(review.getProduct().getId())
                .userId(review.getUser().getId())
                .userName(review.getUser().getFullName())
                .userAvatar(review.getUser().getAvatarUrl())
                .rating(review.getRating())
                .comment(review.getComment())
                .images(images)
                .isVerifiedPurchase(review.getIsVerifiedPurchase())
                .createdAt(review.getCreatedAt())
                .build();
    }
}
