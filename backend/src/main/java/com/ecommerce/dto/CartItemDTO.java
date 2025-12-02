package com.ecommerce.dto;

import com.ecommerce.entity.CartItem;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CartItemDTO {
    private Long id;
    private Long productId;
    private String productName;
    private String productImage;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer quantity;
    private BigDecimal subtotal;
    private Integer stockQuantity;
    
    public static CartItemDTO fromEntity(CartItem item) {
        return CartItemDTO.builder()
                .id(item.getId())
                .productId(item.getProduct().getId())
                .productName(item.getProduct().getName())
                .productImage(item.getProduct().getImageUrl())
                .price(item.getProduct().getPrice())
                .originalPrice(item.getProduct().getOriginalPrice())
                .quantity(item.getQuantity())
                .subtotal(item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .stockQuantity(item.getProduct().getStockQuantity())
                .build();
    }
}
