package com.ecommerce.dto;

public class CategoryDTO {
    private Long id;
    private String name;
    private String description;
    private String imageUrl;
    private Long parentId;

    public CategoryDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public Long getParentId() { return parentId; }
    public void setParentId(Long parentId) { this.parentId = parentId; }

    public static CategoryDTOBuilder builder() { return new CategoryDTOBuilder(); }
    public static class CategoryDTOBuilder {
        private final CategoryDTO c = new CategoryDTO();
        public CategoryDTOBuilder id(Long id) { c.id = id; return this; }
        public CategoryDTOBuilder name(String name) { c.name = name; return this; }
        public CategoryDTOBuilder description(String description) { c.description = description; return this; }
        public CategoryDTOBuilder imageUrl(String imageUrl) { c.imageUrl = imageUrl; return this; }
        public CategoryDTOBuilder parentId(Long parentId) { c.parentId = parentId; return this; }
        public CategoryDTO build() { return c; }
    }
}
