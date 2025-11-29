package com.ecommerce.dto;

import java.math.BigDecimal;
import java.util.List;

public class ProductDTO {
    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stockQuantity;
    private Integer soldQuantity;
    private String imageUrl;
    private Boolean isFeatured;
    private Long categoryId;
    private String categoryName;
    private Double averageRating;
    private Long reviewCount;
    private List<String> images;
    private Integer discountPercent;

    public ProductDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }
    public Integer getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }
    public Integer getSoldQuantity() { return soldQuantity; }
    public void setSoldQuantity(Integer soldQuantity) { this.soldQuantity = soldQuantity; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public Boolean getIsFeatured() { return isFeatured; }
    public void setIsFeatured(Boolean isFeatured) { this.isFeatured = isFeatured; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public Double getAverageRating() { return averageRating; }
    public void setAverageRating(Double averageRating) { this.averageRating = averageRating; }
    public Long getReviewCount() { return reviewCount; }
    public void setReviewCount(Long reviewCount) { this.reviewCount = reviewCount; }
    public List<String> getImages() { return images; }
    public void setImages(List<String> images) { this.images = images; }
    public Integer getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(Integer discountPercent) { this.discountPercent = discountPercent; }

    public static ProductDTOBuilder builder() { return new ProductDTOBuilder(); }
    public static class ProductDTOBuilder {
        private final ProductDTO p = new ProductDTO();
        public ProductDTOBuilder id(Long id) { p.id = id; return this; }
        public ProductDTOBuilder name(String name) { p.name = name; return this; }
        public ProductDTOBuilder description(String description) { p.description = description; return this; }
        public ProductDTOBuilder price(BigDecimal price) { p.price = price; return this; }
        public ProductDTOBuilder originalPrice(BigDecimal originalPrice) { p.originalPrice = originalPrice; return this; }
        public ProductDTOBuilder stockQuantity(Integer stockQuantity) { p.stockQuantity = stockQuantity; return this; }
        public ProductDTOBuilder soldQuantity(Integer soldQuantity) { p.soldQuantity = soldQuantity; return this; }
        public ProductDTOBuilder imageUrl(String imageUrl) { p.imageUrl = imageUrl; return this; }
        public ProductDTOBuilder isFeatured(Boolean isFeatured) { p.isFeatured = isFeatured; return this; }
        public ProductDTOBuilder categoryId(Long categoryId) { p.categoryId = categoryId; return this; }
        public ProductDTOBuilder categoryName(String categoryName) { p.categoryName = categoryName; return this; }
        public ProductDTOBuilder averageRating(Double averageRating) { p.averageRating = averageRating; return this; }
        public ProductDTOBuilder reviewCount(Long reviewCount) { p.reviewCount = reviewCount; return this; }
        public ProductDTOBuilder images(List<String> images) { p.images = images; return this; }
        public ProductDTOBuilder discountPercent(Integer discountPercent) { p.discountPercent = discountPercent; return this; }
        public ProductDTO build() { return p; }
    }
}
