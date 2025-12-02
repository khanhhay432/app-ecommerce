package com.ecommerce.service;

import com.ecommerce.dto.CartDTO;
import com.ecommerce.entity.Cart;
import com.ecommerce.entity.CartItem;
import com.ecommerce.entity.Product;
import com.ecommerce.entity.User;
import com.ecommerce.repository.CartItemRepository;
import com.ecommerce.repository.CartRepository;
import com.ecommerce.repository.ProductRepository;
import com.ecommerce.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CartService {
    
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    
    public CartDTO getCart(Long userId) {
        Cart cart = getOrCreateCart(userId);
        return CartDTO.fromEntity(cart);
    }
    
    @Transactional
    public CartDTO addToCart(Long userId, Long productId, Integer quantity) {
        Cart cart = getOrCreateCart(userId);
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        if (product.getStockQuantity() < quantity) {
            throw new RuntimeException("Insufficient stock");
        }
        
        CartItem existingItem = cartItemRepository.findByCartIdAndProductId(cart.getId(), productId)
                .orElse(null);
        
        if (existingItem != null) {
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
            cartItemRepository.save(existingItem);
        } else {
            CartItem newItem = CartItem.builder()
                    .cart(cart)
                    .product(product)
                    .quantity(quantity)
                    .build();
            cart.getItems().add(newItem);
            cartItemRepository.save(newItem);
        }
        
        return CartDTO.fromEntity(cartRepository.findById(cart.getId()).get());
    }
    
    @Transactional
    public CartDTO updateCartItem(Long userId, Long productId, Integer quantity) {
        Cart cart = getOrCreateCart(userId);
        
        CartItem item = cartItemRepository.findByCartIdAndProductId(cart.getId(), productId)
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));
        
        if (quantity <= 0) {
            cart.getItems().remove(item);
            cartItemRepository.delete(item);
        } else {
            Product product = item.getProduct();
            if (product.getStockQuantity() < quantity) {
                throw new RuntimeException("Insufficient stock");
            }
            item.setQuantity(quantity);
            cartItemRepository.save(item);
        }
        
        return CartDTO.fromEntity(cartRepository.findById(cart.getId()).get());
    }
    
    @Transactional
    public CartDTO removeFromCart(Long userId, Long productId) {
        Cart cart = getOrCreateCart(userId);
        
        CartItem item = cartItemRepository.findByCartIdAndProductId(cart.getId(), productId)
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));
        
        cart.getItems().remove(item);
        cartItemRepository.delete(item);
        
        return CartDTO.fromEntity(cartRepository.findById(cart.getId()).get());
    }
    
    @Transactional
    public void clearCart(Long userId) {
        Cart cart = getOrCreateCart(userId);
        cart.getItems().clear();
        cartItemRepository.deleteByCartId(cart.getId());
    }
    
    private Cart getOrCreateCart(Long userId) {
        return cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("User not found"));
                    Cart newCart = Cart.builder().user(user).build();
                    return cartRepository.save(newCart);
                });
    }
}
