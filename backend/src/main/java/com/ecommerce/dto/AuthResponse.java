package com.ecommerce.dto;

public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private Long userId;
    private String email;
    private String fullName;
    private String role;

    public AuthResponse() {}

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public static AuthResponseBuilder builder() { return new AuthResponseBuilder(); }
    public static class AuthResponseBuilder {
        private final AuthResponse r = new AuthResponse();
        public AuthResponseBuilder token(String token) { r.token = token; return this; }
        public AuthResponseBuilder type(String type) { r.type = type; return this; }
        public AuthResponseBuilder userId(Long userId) { r.userId = userId; return this; }
        public AuthResponseBuilder email(String email) { r.email = email; return this; }
        public AuthResponseBuilder fullName(String fullName) { r.fullName = fullName; return this; }
        public AuthResponseBuilder role(String role) { r.role = role; return this; }
        public AuthResponse build() { return r; }
    }
}
