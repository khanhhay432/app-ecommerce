package com.ecommerce.service;

import com.ecommerce.dto.AddressDTO;
import com.ecommerce.entity.Address;
import com.ecommerce.entity.User;
import com.ecommerce.repository.AddressRepository;
import com.ecommerce.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AddressService {
    
    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    
    public List<AddressDTO> getUserAddresses(Long userId) {
        return addressRepository.findByUserIdOrderByIsDefaultDesc(userId).stream()
                .map(AddressDTO::fromEntity)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public AddressDTO createAddress(Long userId, AddressDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // If this is the first address or marked as default, set it as default
        List<Address> existingAddresses = addressRepository.findByUserId(userId);
        boolean isDefault = existingAddresses.isEmpty() || Boolean.TRUE.equals(dto.getIsDefault());
        
        if (isDefault) {
            // Unset other default addresses
            existingAddresses.forEach(addr -> {
                addr.setIsDefault(false);
                addressRepository.save(addr);
            });
        }
        
        Address address = Address.builder()
                .user(user)
                .recipientName(dto.getFullName())
                .phone(dto.getPhone())
                .province(dto.getProvince())
                .district(dto.getDistrict())
                .ward(dto.getWard())
                .streetAddress(dto.getStreetAddress())
                .isDefault(isDefault)
                .build();
        
        return AddressDTO.fromEntity(addressRepository.save(address));
    }
    
    @Transactional
    public AddressDTO updateAddress(Long userId, Long addressId, AddressDTO dto) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        
        if (!address.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        
        address.setRecipientName(dto.getFullName());
        address.setPhone(dto.getPhone());
        address.setProvince(dto.getProvince());
        address.setDistrict(dto.getDistrict());
        address.setWard(dto.getWard());
        address.setStreetAddress(dto.getStreetAddress());
        
        return AddressDTO.fromEntity(addressRepository.save(address));
    }
    
    @Transactional
    public void deleteAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        
        if (!address.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        
        addressRepository.delete(address);
    }
    
    @Transactional
    public AddressDTO setDefaultAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        
        if (!address.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        
        // Unset other default addresses
        addressRepository.findByUserId(userId).forEach(addr -> {
            addr.setIsDefault(false);
            addressRepository.save(addr);
        });
        
        address.setIsDefault(true);
        return AddressDTO.fromEntity(addressRepository.save(address));
    }
}
