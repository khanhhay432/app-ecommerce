package com.ecommerce.service;

import com.ecommerce.dto.*;
import com.ecommerce.entity.*;
import com.ecommerce.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final CouponRepository couponRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    
    @Transactional
    public OrderDTO createOrder(Long userId, CreateOrderRequest request) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        if (cart.getItems().isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }
        
        User user = userRepository.findById(userId).orElseThrow();
        
        BigDecimal subtotal = cart.getItems().stream()
                .map(item -> item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal discount = BigDecimal.ZERO;
        Coupon coupon = null;
        if (request.getCouponCode() != null && !request.getCouponCode().isEmpty()) {
            coupon = couponRepository.findByCodeAndIsActiveTrue(request.getCouponCode())
                    .orElseThrow(() -> new RuntimeException("Invalid coupon"));
            if (!coupon.isValid()) {
                throw new RuntimeException("Coupon expired or limit reached");
            }
            discount = coupon.calculateDiscount(subtotal);
            coupon.setUsedCount(coupon.getUsedCount() + 1);
            couponRepository.save(coupon);
        }
        
        BigDecimal shippingFee = subtotal.compareTo(BigDecimal.valueOf(500000)) >= 0 
                ? BigDecimal.ZERO : BigDecimal.valueOf(30000);
        BigDecimal total = subtotal.subtract(discount).add(shippingFee);
        
        Order order = Order.builder()
                .user(user)
                .orderNumber(generateOrderNumber())
                .subtotal(subtotal)
                .discountAmount(discount)
                .shippingFee(shippingFee)
                .totalAmount(total)
                .coupon(coupon)
                .paymentMethod(Order.PaymentMethod.valueOf(request.getPaymentMethod()))
                .shippingName(request.getShippingName())
                .shippingPhone(request.getShippingPhone())
                .shippingAddress(request.getShippingAddress())
                .note(request.getNote())
                .build();
        
        for (CartItem cartItem : cart.getItems()) {
            Product product = cartItem.getProduct();
            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .product(product)
                    .productName(product.getName())
                    .productImage(product.getImageUrl())
                    .price(product.getPrice())
                    .quantity(cartItem.getQuantity())
                    .subtotal(product.getPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity())))
                    .build();
            order.getItems().add(orderItem);
            
            product.setStockQuantity(product.getStockQuantity() - cartItem.getQuantity());
            product.setSoldQuantity(product.getSoldQuantity() + cartItem.getQuantity());
            productRepository.save(product);
        }
        
        orderRepository.save(order);
        cartItemRepository.deleteByCartId(cart.getId());
        
        return toDTO(order);
    }
    
    public Page<OrderDTO> getUserOrders(Long userId, int page, int size) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(page, size))
                .map(this::toDTO);
    }
    
    public OrderDTO getOrderById(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return toDTO(order);
    }
    
    @Transactional
    public OrderDTO cancelOrder(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        if (!order.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new RuntimeException("Cannot cancel this order");
        }
        
        order.setStatus(Order.OrderStatus.CANCELLED);
        for (OrderItem item : order.getItems()) {
            Product product = item.getProduct();
            product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
            product.setSoldQuantity(product.getSoldQuantity() - item.getQuantity());
            productRepository.save(product);
        }
        
        return toDTO(orderRepository.save(order));
    }
    
    @Transactional
    public OrderDTO updateOrderStatus(Long orderId, String status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        try {
            Order.OrderStatus newStatus = Order.OrderStatus.valueOf(status);
            order.setStatus(newStatus);
            
            // Nếu chuyển sang DELIVERED, cập nhật payment status
            if (newStatus == Order.OrderStatus.DELIVERED) {
                order.setPaymentStatus(Order.PaymentStatus.PAID);
            }
            
            return toDTO(orderRepository.save(order));
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid order status: " + status);
        }
    }
    
    private String generateOrderNumber() {
        return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) 
                + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }
    
    private OrderDTO toDTO(Order order) {
        var items = order.getItems().stream().map(item ->
            OrderItemDTO.builder()
                .id(item.getId())
                .productId(item.getProduct().getId())
                .productName(item.getProductName())
                .productImage(item.getProductImage())
                .price(item.getPrice())
                .quantity(item.getQuantity())
                .subtotal(item.getSubtotal())
                .build()
        ).collect(Collectors.toList());
        
        return OrderDTO.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .status(order.getStatus().name())
                .subtotal(order.getSubtotal())
                .discountAmount(order.getDiscountAmount())
                .shippingFee(order.getShippingFee())
                .totalAmount(order.getTotalAmount())
                .paymentMethod(order.getPaymentMethod().name())
                .paymentStatus(order.getPaymentStatus().name())
                .shippingName(order.getShippingName())
                .shippingPhone(order.getShippingPhone())
                .shippingAddress(order.getShippingAddress())
                .note(order.getNote())
                .couponCode(order.getCoupon() != null ? order.getCoupon().getCode() : null)
                .items(items)
                .createdAt(order.getCreatedAt())
                .build();
    }
}
