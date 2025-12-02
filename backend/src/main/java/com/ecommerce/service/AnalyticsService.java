package com.ecommerce.service;

import com.ecommerce.dto.AnalyticsDTO;
import com.ecommerce.entity.Order;
import com.ecommerce.entity.Product;
import com.ecommerce.entity.User;
import com.ecommerce.repository.OrderRepository;
import com.ecommerce.repository.ProductRepository;
import com.ecommerce.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    
    public AnalyticsDTO getAnalytics(String period) {
        LocalDateTime startDate = getStartDate(period);
        LocalDateTime endDate = LocalDateTime.now();
        
        List<Order> orders = orderRepository.findByCreatedAtBetween(startDate, endDate);
        List<Order> previousOrders = orderRepository.findByCreatedAtBetween(
            startDate.minusDays(getDaysDiff(period)), startDate
        );
        
        BigDecimal totalRevenue = orders.stream()
            .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
            
        BigDecimal previousRevenue = previousOrders.stream()
            .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        Integer totalOrders = (int) orders.stream()
            .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
            .count();
            
        Integer previousOrderCount = (int) previousOrders.stream()
            .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
            .count();
        
        BigDecimal revenueGrowth = calculateGrowth(totalRevenue, previousRevenue);
        BigDecimal ordersGrowth = calculateGrowth(
            BigDecimal.valueOf(totalOrders), 
            BigDecimal.valueOf(previousOrderCount)
        );
        
        return AnalyticsDTO.builder()
            .totalRevenue(totalRevenue)
            .totalOrders(totalOrders)
            .totalProducts((int) productRepository.count())
            .totalCustomers((int) userRepository.countByRole(User.Role.CUSTOMER))
            .revenueGrowth(revenueGrowth)
            .ordersGrowth(ordersGrowth)
            .revenueChart(getRevenueChart(orders, period))
            .ordersByStatus(getOrdersByStatus(orders))
            .topProducts(getTopProducts(10))
            .build();
    }
    
    private LocalDateTime getStartDate(String period) {
        LocalDateTime now = LocalDateTime.now();
        return switch (period) {
            case "7days" -> now.minusDays(7);
            case "30days" -> now.minusDays(30);
            case "3months" -> now.minusMonths(3);
            default -> now.minusDays(7);
        };
    }
    
    private long getDaysDiff(String period) {
        return switch (period) {
            case "7days" -> 7;
            case "30days" -> 30;
            case "3months" -> 90;
            default -> 7;
        };
    }
    
    private BigDecimal calculateGrowth(BigDecimal current, BigDecimal previous) {
        if (previous.compareTo(BigDecimal.ZERO) == 0) {
            return current.compareTo(BigDecimal.ZERO) > 0 ? BigDecimal.valueOf(100) : BigDecimal.ZERO;
        }
        return current.subtract(previous)
            .divide(previous, 4, RoundingMode.HALF_UP)
            .multiply(BigDecimal.valueOf(100))
            .setScale(1, RoundingMode.HALF_UP);
    }
    
    private List<AnalyticsDTO.RevenueDataPoint> getRevenueChart(List<Order> orders, String period) {
        Map<String, BigDecimal> revenueByDate = new LinkedHashMap<>();
        
        if ("7days".equals(period)) {
            for (int i = 6; i >= 0; i--) {
                LocalDate date = LocalDate.now().minusDays(i);
                String label = getWeekdayLabel(date.getDayOfWeek().getValue());
                revenueByDate.put(label, BigDecimal.ZERO);
            }
            
            orders.stream()
                .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
                .forEach(order -> {
                    String label = getWeekdayLabel(order.getCreatedAt().getDayOfWeek().getValue());
                    revenueByDate.merge(label, order.getTotalAmount(), BigDecimal::add);
                });
        } else if ("30days".equals(period)) {
            for (int i = 29; i >= 0; i--) {
                LocalDate date = LocalDate.now().minusDays(i);
                String label = date.format(DateTimeFormatter.ofPattern("dd/MM"));
                revenueByDate.put(label, BigDecimal.ZERO);
            }
            
            orders.stream()
                .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
                .forEach(order -> {
                    String label = order.getCreatedAt().toLocalDate()
                        .format(DateTimeFormatter.ofPattern("dd/MM"));
                    revenueByDate.merge(label, order.getTotalAmount(), BigDecimal::add);
                });
        } else {
            for (int i = 11; i >= 0; i--) {
                LocalDate date = LocalDate.now().minusWeeks(i);
                String label = "T" + date.format(DateTimeFormatter.ofPattern("w"));
                revenueByDate.put(label, BigDecimal.ZERO);
            }
            
            orders.stream()
                .filter(o -> o.getStatus() != Order.OrderStatus.CANCELLED)
                .forEach(order -> {
                    String label = "T" + order.getCreatedAt().toLocalDate()
                        .format(DateTimeFormatter.ofPattern("w"));
                    revenueByDate.merge(label, order.getTotalAmount(), BigDecimal::add);
                });
        }
        
        return revenueByDate.entrySet().stream()
            .map(e -> AnalyticsDTO.RevenueDataPoint.builder()
                .label(e.getKey())
                .value(e.getValue())
                .build())
            .collect(Collectors.toList());
    }
    
    private String getWeekdayLabel(int dayOfWeek) {
        return switch (dayOfWeek) {
            case 1 -> "T2";
            case 2 -> "T3";
            case 3 -> "T4";
            case 4 -> "T5";
            case 5 -> "T6";
            case 6 -> "T7";
            case 7 -> "CN";
            default -> "";
        };
    }
    
    private Map<String, Integer> getOrdersByStatus(List<Order> orders) {
        Map<String, Integer> statusCount = new HashMap<>();
        statusCount.put("DELIVERED", 0);
        statusCount.put("SHIPPING", 0);
        statusCount.put("PENDING", 0);
        statusCount.put("CANCELLED", 0);
        
        orders.forEach(order -> {
            String status = order.getStatus().name();
            if (status.equals("CONFIRMED") || status.equals("PROCESSING")) {
                status = "PENDING";
            }
            statusCount.merge(status, 1, Integer::sum);
        });
        
        return statusCount;
    }
    
    private List<AnalyticsDTO.TopProductDTO> getTopProducts(int limit) {
        List<Product> products = productRepository.findAll();
        
        return products.stream()
            .sorted((p1, p2) -> Integer.compare(p2.getSoldQuantity(), p1.getSoldQuantity()))
            .limit(limit)
            .map(p -> AnalyticsDTO.TopProductDTO.builder()
                .id(p.getId())
                .name(p.getName())
                .imageUrl(p.getImageUrl())
                .price(p.getPrice())
                .soldQuantity(p.getSoldQuantity())
                .revenue(p.getPrice().multiply(BigDecimal.valueOf(p.getSoldQuantity())))
                .build())
            .collect(Collectors.toList());
    }
}
