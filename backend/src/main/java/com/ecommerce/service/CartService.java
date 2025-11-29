package com.ecommerce.service;

import com.ecommerce.dto.CartDTO;
import com.ecommerce.entity.*;
import com.ecommerce.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartService {
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    
    public CartDTO getCart(Long userId) {
        Cart cart = getOrCreateCart(userId);
        return toDTO(cart);
    }
    
    @Transactional
    public CartDTO addToCart(Long userId, Long productId, int quantity) {
        Cart cart = getOrCreateCart(userId);
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        CartItem item = cartItemRepository.findByCartIdAndProductId(cart.getId(), productId)
                .orElse(CartItem.builder().cart(cart).product(product).quantity(0).build());
        
        item.setQuantity(item.getQuantity() + quantity);
        cartItemRepository.save(item);
        
        return toDTO(cartRepository.findById(cart.getId()).orElse(cart));
    }
    
    @Transactional
    public CartDTO updateCartItem(Long userId, Long productId, int quantity) {
        Cart cart = getOrCreateCart(userId);
        CartItem item = cartItemRepository.findByCartIdAndProductId(cart.getId(), productId)
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));
        
        if (quantity <= 0) {
            cartItemRepository.delete(item);
        } else {
            item.setQuantity(quantity);
            cartItemRepository.save(item);
        }
        
        return toDTO(cartRepository.findById(cart.getId()).orElse(cart));
    }
    
    @Transactional
    public CartDTO removeFromCart(Long userId, Long productId) {
        Cart cart = getOrCreateCart(userId);
        cartItemRepository.findByCartIdAndProductId(cart.getId(), productId)
                .ifPresent(cartItemRepository::delete);
        return toDTO(cartRepository.findById(cart.getId()).orElse(cart));
    }
    
    @Transactional
    public void clearCart(Long userId) {
        Cart cart = getOrCreateCart(userId);
        cartItemRepository.deleteByCartId(cart.getId());
    }
    
    private Cart getOrCreateCart(Long userId) {
        return cartRepository.findByUserId(userId).orElseGet(() -> {
            User user = userRepository.findById(userId).orElseThrow();
            return cartRepository.save(Cart.builder().user(user).build());
        });
    }
    
    private CartDTO toDTO(Cart cart) {
        var items = cart.getItems().stream().map(item -> 
            com.ecommerce.dto.CartItemDTO.builder()
                .id(item.getId())
                .productId(item.getProduct().getId())
                .productName(item.getProduct().getName())
                .productImage(item.getProduct().getImageUrl())
                .price(item.getProduct().getPrice())
                .quantity(item.getQuantity())
                .subtotal(item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .stockQuantity(item.getProduct().getStockQuantity())
                .build()
        ).collect(Collectors.toList());
        
        BigDecimal total = items.stream()
                .map(i -> i.getSubtotal())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return CartDTO.builder()
                .id(cart.getId())
                .items(items)
                .totalAmount(total)
                .totalItems(items.size())
                .build();
    }
}
