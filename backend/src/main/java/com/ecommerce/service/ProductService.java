package com.ecommerce.service;

import com.ecommerce.dto.PageResponse;
import com.ecommerce.dto.ProductDTO;
import com.ecommerce.entity.Category;
import com.ecommerce.entity.Product;
import com.ecommerce.repository.CategoryRepository;
import com.ecommerce.repository.ProductRepository;
import com.ecommerce.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {
    
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ReviewRepository reviewRepository;
    
    public PageResponse<ProductDTO> getAllProducts(int page, int size, String sortBy, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") 
                ? Sort.by(sortBy).descending() 
                : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<Product> products = productRepository.findByIsActiveTrue(pageable);
        List<ProductDTO> content = products.getContent().stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
        
        return PageResponse.from(products, content);
    }
    
    public PageResponse<ProductDTO> getProductsByCategory(Long categoryId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Product> products = productRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable);
        List<ProductDTO> content = products.getContent().stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
        
        return PageResponse.from(products, content);
    }
    
    public ProductDTO getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return enrichProductDTO(product);
    }
    
    public List<ProductDTO> getFeaturedProducts() {
        return productRepository.findByIsFeaturedTrueAndIsActiveTrue().stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
    }
    
    public List<ProductDTO> getTopSellingProducts(int limit) {
        return productRepository.findTopSelling(PageRequest.of(0, limit)).stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
    }
    
    public List<ProductDTO> getNewArrivals(int limit) {
        return productRepository.findNewArrivals(PageRequest.of(0, limit)).stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
    }
    
    public List<ProductDTO> getOnSaleProducts(int limit) {
        return productRepository.findOnSale(PageRequest.of(0, limit)).stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
    }
    
    public PageResponse<ProductDTO> searchProducts(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Product> products = productRepository.searchProducts(keyword, pageable);
        List<ProductDTO> content = products.getContent().stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
        
        return PageResponse.from(products, content);
    }
    
    @Transactional
    public ProductDTO createProduct(ProductDTO dto) {
        Category category = categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));
        
        Product product = Product.builder()
                .category(category)
                .name(dto.getName())
                .description(dto.getDescription())
                .price(dto.getPrice())
                .originalPrice(dto.getOriginalPrice())
                .stockQuantity(dto.getStockQuantity() != null ? dto.getStockQuantity() : 0)
                .soldQuantity(0)
                .imageUrl(dto.getImageUrl())
                .isActive(true)
                .isFeatured(dto.getIsFeatured() != null ? dto.getIsFeatured() : false)
                .build();
        
        return ProductDTO.fromEntity(productRepository.save(product));
    }
    
    @Transactional
    public ProductDTO updateProduct(Long id, ProductDTO dto) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        if (dto.getCategoryId() != null) {
            Category category = categoryRepository.findById(dto.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
            product.setCategory(category);
        }
        
        if (dto.getName() != null) product.setName(dto.getName());
        if (dto.getDescription() != null) product.setDescription(dto.getDescription());
        if (dto.getPrice() != null) product.setPrice(dto.getPrice());
        if (dto.getOriginalPrice() != null) product.setOriginalPrice(dto.getOriginalPrice());
        if (dto.getStockQuantity() != null) product.setStockQuantity(dto.getStockQuantity());
        if (dto.getImageUrl() != null) product.setImageUrl(dto.getImageUrl());
        if (dto.getIsFeatured() != null) product.setIsFeatured(dto.getIsFeatured());
        
        return ProductDTO.fromEntity(productRepository.save(product));
    }
    
    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        System.out.println("🗑️ [ProductService] Soft deleting product: " + id + " - " + product.getName());
        product.setIsActive(false);
        productRepository.save(product);
        System.out.println("✅ [ProductService] Product marked as inactive: " + id);
    }
    
    @Transactional
    public void hardDeleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        System.out.println("🗑️ [ProductService] Hard deleting product: " + id + " - " + product.getName());
        productRepository.delete(product);
        System.out.println("✅ [ProductService] Product permanently deleted: " + id);
    }
    
    public PageResponse<ProductDTO> getDeletedProducts(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("updatedAt").descending());
        Page<Product> products = productRepository.findByIsActiveFalse(pageable);
        List<ProductDTO> content = products.getContent().stream()
                .map(this::enrichProductDTO)
                .collect(Collectors.toList());
        
        return PageResponse.from(products, content);
    }
    
    @Transactional
    public ProductDTO restoreProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        System.out.println("♻️ [ProductService] Restoring product: " + id + " - " + product.getName());
        product.setIsActive(true);
        Product restored = productRepository.save(product);
        System.out.println("✅ [ProductService] Product restored: " + id);
        
        return enrichProductDTO(restored);
    }
    
    private ProductDTO enrichProductDTO(Product product) {
        ProductDTO dto = ProductDTO.fromEntity(product);
        Double rating = reviewRepository.getAverageRatingByProductId(product.getId());
        dto.setRating(rating != null ? rating : 0.0);
        dto.setReviewCount(reviewRepository.countByProductId(product.getId()));
        return dto;
    }
}
