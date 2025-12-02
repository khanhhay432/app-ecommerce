package com.ecommerce.controller;

import com.ecommerce.dto.*;
import com.ecommerce.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProductController {
    private final ProductService productService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<ProductDTO>>> getAllProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        return ResponseEntity.ok(ApiResponse.success(productService.getAllProducts(page, size, sortBy, sortDir)));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductDTO>> getProductById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(productService.getProductById(id)));
    }
    
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<ApiResponse<PageResponse<ProductDTO>>> getProductsByCategory(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(productService.getProductsByCategory(categoryId, page, size)));
    }
    
    @GetMapping("/featured")
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getFeaturedProducts() {
        return ResponseEntity.ok(ApiResponse.success(productService.getFeaturedProducts()));
    }
    
    @GetMapping("/top-selling")
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getTopSellingProducts(
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(ApiResponse.success(productService.getTopSellingProducts(limit)));
    }
    
    @GetMapping("/new-arrivals")
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getNewArrivals(
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(ApiResponse.success(productService.getNewArrivals(limit)));
    }
    
    @GetMapping("/on-sale")
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getOnSaleProducts(
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(ApiResponse.success(productService.getOnSaleProducts(limit)));
    }
    
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<PageResponse<ProductDTO>>> searchProducts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(productService.searchProducts(keyword, page, size)));
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductDTO>> createProduct(@RequestBody ProductDTO productDTO) {
        return ResponseEntity.ok(ApiResponse.success(productService.createProduct(productDTO)));
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductDTO>> updateProduct(@PathVariable Long id, @RequestBody ProductDTO productDTO) {
        return ResponseEntity.ok(ApiResponse.success(productService.updateProduct(id, productDTO)));
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @DeleteMapping("/{id}/hard")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> hardDeleteProduct(@PathVariable Long id) {
        productService.hardDeleteProduct(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/deleted")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<ProductDTO>>> getDeletedProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.success(productService.getDeletedProducts(page, size)));
    }
    
    @PutMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductDTO>> restoreProduct(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(productService.restoreProduct(id)));
    }
}
