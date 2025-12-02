package com.ecommerce.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateOrderRequest {
    @NotBlank
    private String shippingName;
    
    @NotBlank
    private String shippingPhone;
    
    @NotBlank
    private String shippingAddress;
    
    @NotBlank
    private String paymentMethod;
    
    private String couponCode;
    
    private String note;
}
