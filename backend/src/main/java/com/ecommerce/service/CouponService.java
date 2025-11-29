package com.ecommerce.service;

import com.ecommerce.dto.CouponDTO;
import com.ecommerce.entity.Coupon;
import com.ecommerce.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class CouponService {
    private final CouponRepository couponRepository;
    
    public CouponDTO validateCoupon(String code, BigDecimal orderAmount) {
        Coupon coupon = couponRepository.findByCodeAndIsActiveTrue(code)
                .orElseThrow(() -> new RuntimeException("Coupon not found"));
        
        if (!coupon.isValid()) {
            throw new RuntimeException("Coupon is expired or usage limit reached");
        }
        
        if (orderAmount.compareTo(coupon.getMinOrderAmount()) < 0) {
            throw new RuntimeException("Order amount does not meet minimum requirement");
        }
        
        BigDecimal discount = coupon.calculateDiscount(orderAmount);
        
        return CouponDTO.builder()
                .id(coupon.getId())
                .code(coupon.getCode())
                .description(coupon.getDescription())
                .discountType(coupon.getDiscountType().name())
                .discountValue(coupon.getDiscountValue())
                .minOrderAmount(coupon.getMinOrderAmount())
                .maxDiscountAmount(coupon.getMaxDiscountAmount())
                .calculatedDiscount(discount)
                .build();
    }
}
