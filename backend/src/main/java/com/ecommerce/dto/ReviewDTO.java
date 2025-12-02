package com.ecommerce.dto;

import com.ecommerce.entity.Review;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewDTO {
    private Long id;
    private Long productId;
    private Long userId;
    private String userName;
    private String userAvatar;
    private Integer rating;
    private String comment;
    private java.util.List<String> images;
    private Boolean isVerifiedPurchase;
    private LocalDateTime createdAt;
}
