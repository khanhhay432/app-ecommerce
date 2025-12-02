package com.ecommerce.dto;

import com.ecommerce.entity.Category;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {
    private Long id;
    private String name;
    private String description;
    private String imageUrl;
    private Long parentId;
    private List<CategoryDTO> children;
    
    public static CategoryDTO fromEntity(Category category) {
        CategoryDTO dto = CategoryDTO.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .imageUrl(category.getImageUrl())
                .parentId(category.getParent() != null ? category.getParent().getId() : null)
                .build();
        
        if (category.getChildren() != null && !category.getChildren().isEmpty()) {
            dto.setChildren(category.getChildren().stream()
                    .filter(Category::getIsActive)
                    .map(CategoryDTO::fromEntity)
                    .collect(Collectors.toList()));
        }
        
        return dto;
    }
}
