package com.ecommerce.controller;

import com.ecommerce.dto.*;
import com.ecommerce.security.UserPrincipal;
import com.ecommerce.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/wishlist")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class WishlistController {
    private final WishlistService wishlistService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getWishlist(@AuthenticationPrincipal UserPrincipal user) {
        return ResponseEntity.ok(ApiResponse.success(wishlistService.getWishlist(user.getId())));
    }
    
    @PostMapping("/{productId}")
    public ResponseEntity<ApiResponse<Void>> addToWishlist(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long productId) {
        wishlistService.addToWishlist(user.getId(), productId);
        return ResponseEntity.ok(ApiResponse.success("Added to wishlist", null));
    }
    
    @DeleteMapping("/{productId}")
    public ResponseEntity<ApiResponse<Void>> removeFromWishlist(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long productId) {
        wishlistService.removeFromWishlist(user.getId(), productId);
        return ResponseEntity.ok(ApiResponse.success("Removed from wishlist", null));
    }
    
    @GetMapping("/check/{productId}")
    public ResponseEntity<ApiResponse<Boolean>> isInWishlist(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long productId) {
        return ResponseEntity.ok(ApiResponse.success(wishlistService.isInWishlist(user.getId(), productId)));
    }
}
