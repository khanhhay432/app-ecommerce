package com.ecommerce.dto;

import com.ecommerce.entity.Cart;
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
public class CartDTO {
    private Long id;
    private List<CartItemDTO> items;
    private BigDecimal totalAmount;
    private Integer totalItems;
    
    public static CartDTO fromEntity(Cart cart) {
        List<CartItemDTO> items = cart.getItems().stream()
                .map(CartItemDTO::fromEntity)
                .collect(Collectors.toList());
        
        BigDecimal total = items.stream()
                .map(CartItemDTO::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return CartDTO.builder()
                .id(cart.getId())
                .items(items)
                .totalAmount(total)
                .totalItems(items.size())
                .build();
    }
}
