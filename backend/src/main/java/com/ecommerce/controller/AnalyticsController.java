package com.ecommerce.controller;

import com.ecommerce.dto.AnalyticsDTO;
import com.ecommerce.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {
    private final AnalyticsService analyticsService;
    
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AnalyticsDTO> getAnalytics(
            @RequestParam(defaultValue = "7days") String period,
            Authentication authentication) {
        log.info("📊 Analytics request - User: {}, Period: {}", 
            authentication != null ? authentication.getName() : "null", period);
        log.info("🔑 Authorities: {}", 
            authentication != null ? authentication.getAuthorities() : "null");
        
        AnalyticsDTO analytics = analyticsService.getAnalytics(period);
        log.info("✅ Analytics data generated successfully");
        return ResponseEntity.ok(analytics);
    }
}
