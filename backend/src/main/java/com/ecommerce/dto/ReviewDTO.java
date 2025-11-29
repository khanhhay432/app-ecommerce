package com.ecommerce.dto;

import java.time.LocalDateTime;
import java.util.List;

public class ReviewDTO {
    private Long id;
    private Long productId;
    private Long userId;
    private String userName;
    private String userAvatar;
    private Integer rating;
    private String comment;
    private List<String> images;
    private Boolean isVerifiedPurchase;
    private LocalDateTime createdAt;

    public ReviewDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getUserAvatar() { return userAvatar; }
    public void setUserAvatar(String userAvatar) { this.userAvatar = userAvatar; }
    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public List<String> getImages() { return images; }
    public void setImages(List<String> images) { this.images = images; }
    public Boolean getIsVerifiedPurchase() { return isVerifiedPurchase; }
    public void setIsVerifiedPurchase(Boolean isVerifiedPurchase) { this.isVerifiedPurchase = isVerifiedPurchase; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public static ReviewDTOBuilder builder() { return new ReviewDTOBuilder(); }
    public static class ReviewDTOBuilder {
        private final ReviewDTO r = new ReviewDTO();
        public ReviewDTOBuilder id(Long id) { r.id = id; return this; }
        public ReviewDTOBuilder productId(Long productId) { r.productId = productId; return this; }
        public ReviewDTOBuilder userId(Long userId) { r.userId = userId; return this; }
        public ReviewDTOBuilder userName(String userName) { r.userName = userName; return this; }
        public ReviewDTOBuilder userAvatar(String userAvatar) { r.userAvatar = userAvatar; return this; }
        public ReviewDTOBuilder rating(Integer rating) { r.rating = rating; return this; }
        public ReviewDTOBuilder comment(String comment) { r.comment = comment; return this; }
        public ReviewDTOBuilder images(List<String> images) { r.images = images; return this; }
        public ReviewDTOBuilder isVerifiedPurchase(Boolean isVerifiedPurchase) { r.isVerifiedPurchase = isVerifiedPurchase; return this; }
        public ReviewDTOBuilder createdAt(LocalDateTime createdAt) { r.createdAt = createdAt; return this; }
        public ReviewDTO build() { return r; }
    }
}
