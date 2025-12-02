package com.ecommerce.dto;

import com.ecommerce.entity.Product;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private Long id;
    private Long categoryId;
    private String categoryName;
    private String name;
    private String description;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stockQuantity;
    private Integer soldQuantity;
    private String imageUrl;
    private List<String> images;
    private Boolean isFeatured;
    private Double rating;
    private Long reviewCount;
    private Integer discountPercent;
    
    public static ProductDTO fromEntity(Product product) {
        ProductDTO dto = ProductDTO.builder()
                .id(product.getId())
                .categoryId(product.getCategory().getId())
                .categoryName(product.getCategory().getName())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .originalPrice(product.getOriginalPrice())
                .stockQuantity(product.getStockQuantity())
                .soldQuantity(product.getSoldQuantity())
                .imageUrl(product.getImageUrl())
                .isFeatured(product.getIsFeatured())
                .build();
        
        if (product.getImages() != null) {
            dto.setImages(product.getImages().stream()
                    .map(img -> img.getImageUrl())
                    .collect(Collectors.toList()));
        }
        
        if (product.getOriginalPrice() != null && product.getOriginalPrice().compareTo(product.getPrice()) > 0) {
            BigDecimal discount = product.getOriginalPrice().subtract(product.getPrice());
            int percent = discount.multiply(BigDecimal.valueOf(100))
                    .divide(product.getOriginalPrice(), 0, java.math.RoundingMode.HALF_UP)
                    .intValue();
            dto.setDiscountPercent(percent);
        }
        
        return dto;
    }
}
