package com.ecommerce.dto;

import java.math.BigDecimal;

public class CouponDTO {
    private Long id;
    private String code;
    private String description;
    private String discountType;
    private BigDecimal discountValue;
    private BigDecimal minOrderAmount;
    private BigDecimal maxDiscountAmount;
    private BigDecimal calculatedDiscount;

    public CouponDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }
    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }
    public BigDecimal getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(BigDecimal minOrderAmount) { this.minOrderAmount = minOrderAmount; }
    public BigDecimal getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }
    public BigDecimal getCalculatedDiscount() { return calculatedDiscount; }
    public void setCalculatedDiscount(BigDecimal calculatedDiscount) { this.calculatedDiscount = calculatedDiscount; }

    public static CouponDTOBuilder builder() { return new CouponDTOBuilder(); }
    public static class CouponDTOBuilder {
        private final CouponDTO c = new CouponDTO();
        public CouponDTOBuilder id(Long id) { c.id = id; return this; }
        public CouponDTOBuilder code(String code) { c.code = code; return this; }
        public CouponDTOBuilder description(String description) { c.description = description; return this; }
        public CouponDTOBuilder discountType(String discountType) { c.discountType = discountType; return this; }
        public CouponDTOBuilder discountValue(BigDecimal discountValue) { c.discountValue = discountValue; return this; }
        public CouponDTOBuilder minOrderAmount(BigDecimal minOrderAmount) { c.minOrderAmount = minOrderAmount; return this; }
        public CouponDTOBuilder maxDiscountAmount(BigDecimal maxDiscountAmount) { c.maxDiscountAmount = maxDiscountAmount; return this; }
        public CouponDTOBuilder calculatedDiscount(BigDecimal calculatedDiscount) { c.calculatedDiscount = calculatedDiscount; return this; }
        public CouponDTO build() { return c; }
    }
}
