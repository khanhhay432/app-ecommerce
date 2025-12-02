package com.ecommerce.service;

import com.ecommerce.dto.UpdateProfileRequest;
import com.ecommerce.dto.UserDTO;
import com.ecommerce.entity.User;
import com.ecommerce.repository.UserRepository;
import com.ecommerce.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public UserDTO getProfile() {
        User user = getCurrentUser();
        return UserDTO.fromEntity(user);
    }
    
    @Transactional
    public UserDTO updateProfile(UpdateProfileRequest request) {
        User user = getCurrentUser();
        
        System.out.println("👤 [UserService] Updating profile for user: " + user.getId());
        
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        
        User updated = userRepository.save(user);
        System.out.println("✅ [UserService] Profile updated successfully");
        
        return UserDTO.fromEntity(updated);
    }
    
    @Transactional
    public void changePassword(String oldPassword, String newPassword) {
        User user = getCurrentUser();
        
        System.out.println("🔐 [UserService] Changing password for user: " + user.getId());
        
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("Old password is incorrect");
        }
        
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        
        System.out.println("✅ [UserService] Password changed successfully");
    }
    
    private User getCurrentUser() {
        UserPrincipal principal = (UserPrincipal) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        
        return userRepository.findById(principal.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
