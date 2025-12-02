package com.ecommerce.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnalyticsDTO {
    private BigDecimal totalRevenue;
    private Integer totalOrders;
    private Integer totalProducts;
    private Integer totalCustomers;
    private BigDecimal revenueGrowth;
    private BigDecimal ordersGrowth;
    private List<RevenueDataPoint> revenueChart;
    private Map<String, Integer> ordersByStatus;
    private List<TopProductDTO> topProducts;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RevenueDataPoint {
        private String label;
        private BigDecimal value;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopProductDTO {
        private Long id;
        private String name;
        private String imageUrl;
        private BigDecimal price;
        private Integer soldQuantity;
        private BigDecimal revenue;
    }
}
