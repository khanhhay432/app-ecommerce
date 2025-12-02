package com.ecommerce.controller;

import com.ecommerce.dto.*;
import com.ecommerce.security.UserPrincipal;
import com.ecommerce.service.AddressService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/addresses")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AddressController {
    private final AddressService addressService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<AddressDTO>>> getUserAddresses(@AuthenticationPrincipal UserPrincipal user) {
        return ResponseEntity.ok(ApiResponse.success(addressService.getUserAddresses(user.getId())));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<AddressDTO>> createAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @Valid @RequestBody AddressDTO addressDTO) {
        return ResponseEntity.ok(ApiResponse.success("Address created", addressService.createAddress(user.getId(), addressDTO)));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<AddressDTO>> updateAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long id,
            @Valid @RequestBody AddressDTO addressDTO) {
        return ResponseEntity.ok(ApiResponse.success("Address updated", addressService.updateAddress(user.getId(), id, addressDTO)));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long id) {
        addressService.deleteAddress(user.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Address deleted", null));
    }
    
    @PutMapping("/{id}/default")
    public ResponseEntity<ApiResponse<AddressDTO>> setDefaultAddress(
            @AuthenticationPrincipal UserPrincipal user,
            @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success("Default address set", addressService.setDefaultAddress(user.getId(), id)));
    }
}
