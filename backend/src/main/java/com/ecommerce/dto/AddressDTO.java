package com.ecommerce.dto;

import com.ecommerce.entity.Address;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddressDTO {
    private Long id;
    private String fullName;
    private String phone;
    private String province;
    private String district;
    private String ward;
    private String streetAddress;
    private Boolean isDefault;
    
    public static AddressDTO fromEntity(Address address) {
        return AddressDTO.builder()
                .id(address.getId())
                .fullName(address.getRecipientName())
                .phone(address.getPhone())
                .province(address.getProvince())
                .district(address.getDistrict())
                .ward(address.getWard())
                .streetAddress(address.getStreetAddress())
                .isDefault(address.getIsDefault())
                .build();
    }
    
    public String getFullAddress() {
        StringBuilder sb = new StringBuilder();
        sb.append(streetAddress);
        if (ward != null) sb.append(", ").append(ward);
        sb.append(", ").append(district);
        sb.append(", ").append(province);
        return sb.toString();
    }
}
