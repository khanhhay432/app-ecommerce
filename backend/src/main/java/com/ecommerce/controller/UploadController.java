package com.ecommerce.controller;

import com.ecommerce.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UploadController {
    
    @Value("${upload.path:uploads}")
    private String uploadPath;
    
    @Value("${server.port:8080}")
    private String serverPort;
    
    @Value("${app.base-url:http://localhost}")
    private String baseUrl;
    
    @PostMapping("/image")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadImage(
            @RequestParam("file") MultipartFile file) {
        
        System.out.println("📸 [UploadController] Base URL: " + baseUrl);
        System.out.println("📸 [UploadController] Server Port: " + serverPort);
        
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("File is empty"));
        }
        
        try {
            // Tạo thư mục nếu chưa tồn tại
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Tạo tên file unique
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".") 
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            String filename = UUID.randomUUID().toString() + extension;
            
            // Lưu file
            Path filePath = Paths.get(uploadPath, filename);
            Files.write(filePath, file.getBytes());
            
            // Trả về full URL
            String imageUrl = baseUrl + ":" + serverPort + "/uploads/" + filename;
            System.out.println("✅ [UploadController] Generated URL: " + imageUrl);
            
            Map<String, String> response = new HashMap<>();
            response.put("url", imageUrl);
            response.put("imageUrl", imageUrl);
            response.put("filename", filename);
            
            return ResponseEntity.ok(ApiResponse.success("Image uploaded successfully", response));
            
        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to upload image: " + e.getMessage()));
        }
    }
    
    @DeleteMapping("/image")
    public ResponseEntity<ApiResponse<Void>> deleteImage(@RequestParam String filename) {
        try {
            Path filePath = Paths.get(uploadPath, filename);
            Files.deleteIfExists(filePath);
            return ResponseEntity.ok(ApiResponse.success("Image deleted successfully", null));
        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to delete image: " + e.getMessage()));
        }
    }
}
