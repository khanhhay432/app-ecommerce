package com.ecommerce.service;

import com.ecommerce.dto.CategoryDTO;
import com.ecommerce.entity.Category;
import com.ecommerce.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {
    
    private final CategoryRepository categoryRepository;
    
    public List<CategoryDTO> getAllCategories() {
        return categoryRepository.findByIsActiveTrue().stream()
                .map(CategoryDTO::fromEntity)
                .collect(Collectors.toList());
    }
    
    public List<CategoryDTO> getRootCategories() {
        return categoryRepository.findByIsActiveTrueAndParentIsNull().stream()
                .map(CategoryDTO::fromEntity)
                .collect(Collectors.toList());
    }
    
    public CategoryDTO getCategoryById(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        return CategoryDTO.fromEntity(category);
    }
    
    public List<CategoryDTO> getSubCategories(Long parentId) {
        return categoryRepository.findByParentId(parentId).stream()
                .filter(Category::getIsActive)
                .map(CategoryDTO::fromEntity)
                .collect(Collectors.toList());
    }
}
