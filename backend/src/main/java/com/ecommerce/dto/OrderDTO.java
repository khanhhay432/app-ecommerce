package com.ecommerce.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDTO {
    private Long id;
    private String orderNumber;
    private String status;
    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal shippingFee;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private String paymentStatus;
    private String shippingName;
    private String shippingPhone;
    private String shippingAddress;
    private String note;
    private String couponCode;
    private List<OrderItemDTO> items;
    private LocalDateTime createdAt;

    public OrderDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    public BigDecimal getShippingFee() { return shippingFee; }
    public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getShippingName() { return shippingName; }
    public void setShippingName(String shippingName) { this.shippingName = shippingName; }
    public String getShippingPhone() { return shippingPhone; }
    public void setShippingPhone(String shippingPhone) { this.shippingPhone = shippingPhone; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }
    public List<OrderItemDTO> getItems() { return items; }
    public void setItems(List<OrderItemDTO> items) { this.items = items; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public static OrderDTOBuilder builder() { return new OrderDTOBuilder(); }
    public static class OrderDTOBuilder {
        private final OrderDTO dto = new OrderDTO();
        public OrderDTOBuilder id(Long id) { dto.id = id; return this; }
        public OrderDTOBuilder orderNumber(String orderNumber) { dto.orderNumber = orderNumber; return this; }
        public OrderDTOBuilder status(String status) { dto.status = status; return this; }
        public OrderDTOBuilder subtotal(BigDecimal subtotal) { dto.subtotal = subtotal; return this; }
        public OrderDTOBuilder discountAmount(BigDecimal discountAmount) { dto.discountAmount = discountAmount; return this; }
        public OrderDTOBuilder shippingFee(BigDecimal shippingFee) { dto.shippingFee = shippingFee; return this; }
        public OrderDTOBuilder totalAmount(BigDecimal totalAmount) { dto.totalAmount = totalAmount; return this; }
        public OrderDTOBuilder paymentMethod(String paymentMethod) { dto.paymentMethod = paymentMethod; return this; }
        public OrderDTOBuilder paymentStatus(String paymentStatus) { dto.paymentStatus = paymentStatus; return this; }
        public OrderDTOBuilder shippingName(String shippingName) { dto.shippingName = shippingName; return this; }
        public OrderDTOBuilder shippingPhone(String shippingPhone) { dto.shippingPhone = shippingPhone; return this; }
        public OrderDTOBuilder shippingAddress(String shippingAddress) { dto.shippingAddress = shippingAddress; return this; }
        public OrderDTOBuilder note(String note) { dto.note = note; return this; }
        public OrderDTOBuilder couponCode(String couponCode) { dto.couponCode = couponCode; return this; }
        public OrderDTOBuilder items(List<OrderItemDTO> items) { dto.items = items; return this; }
        public OrderDTOBuilder createdAt(LocalDateTime createdAt) { dto.createdAt = createdAt; return this; }
        public OrderDTO build() { return dto; }
    }
}
