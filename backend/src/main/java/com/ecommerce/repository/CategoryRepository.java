package com.ecommerce.repository;

import com.ecommerce.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findByIsActiveTrueAndParentIsNull();
    List<Category> findByIsActiveTrue();
    List<Category> findByParentId(Long parentId);
}
