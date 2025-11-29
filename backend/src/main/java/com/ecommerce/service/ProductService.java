package com.ecommerce.service;

import com.ecommerce.dto.ProductDTO;
import com.ecommerce.entity.Product;
import com.ecommerce.repository.ProductRepository;
import com.ecommerce.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository productRepository;
    private final ReviewRepository reviewRepository;
    
    public Page<ProductDTO> getAllProducts(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return productRepository.findByIsActiveTrue(pageable).map(this::toDTO);
    }
    
    public Page<ProductDTO> getProductsByCategory(Long categoryId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return productRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable).map(this::toDTO);
    }
    
    public ProductDTO getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return toDTO(product);
    }
    
    public List<ProductDTO> getFeaturedProducts() {
        return productRepository.findByIsFeaturedTrueAndIsActiveTrue()
                .stream().map(this::toDTO).collect(Collectors.toList());
    }
    
    public List<ProductDTO> getTopSellingProducts(int limit) {
        return productRepository.findTopSelling(PageRequest.of(0, limit))
                .stream().map(this::toDTO).collect(Collectors.toList());
    }
    
    public List<ProductDTO> getNewArrivals(int limit) {
        return productRepository.findNewArrivals(PageRequest.of(0, limit))
                .stream().map(this::toDTO).collect(Collectors.toList());
    }
    
    public Page<ProductDTO> searchProducts(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return productRepository.searchProducts(keyword, pageable).map(this::toDTO);
    }
    
    private ProductDTO toDTO(Product product) {
        Double avgRating = reviewRepository.getAverageRatingByProductId(product.getId());
        Long reviewCount = reviewRepository.countByProductId(product.getId());
        
        Integer discountPercent = null;
        if (product.getOriginalPrice() != null && product.getOriginalPrice().compareTo(product.getPrice()) > 0) {
            discountPercent = product.getOriginalPrice().subtract(product.getPrice())
                    .multiply(java.math.BigDecimal.valueOf(100))
                    .divide(product.getOriginalPrice(), 0, java.math.RoundingMode.HALF_UP)
                    .intValue();
        }
        
        return ProductDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .originalPrice(product.getOriginalPrice())
                .stockQuantity(product.getStockQuantity())
                .soldQuantity(product.getSoldQuantity())
                .imageUrl(product.getImageUrl())
                .isFeatured(product.getIsFeatured())
                .categoryId(product.getCategory().getId())
                .categoryName(product.getCategory().getName())
                .averageRating(avgRating)
                .reviewCount(reviewCount)
                .discountPercent(discountPercent)
                .build();
    }
}
