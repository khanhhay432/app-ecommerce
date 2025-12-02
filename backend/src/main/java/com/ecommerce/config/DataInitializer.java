package com.ecommerce.config;

import com.ecommerce.entity.*;
import com.ecommerce.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {
    
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final CouponRepository couponRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    @Transactional
    public void run(String... args) {
        if (userRepository.count() == 0) {
            log.info("Initializing sample data...");
            initUsers();
            initCategories();
            initProducts();
            initCoupons();
            log.info("Sample data initialized successfully!");
        } else {
            log.info("Data already exists, skipping initialization.");
        }
    }
    
    private void initUsers() {
        User admin = User.builder()
                .email("admin@shop.com")
                .password(passwordEncoder.encode("admin123"))
                .fullName("Admin Shop")
                .phone("0901234567")
                .role(User.Role.ADMIN)
                .avatarUrl("https://ui-avatars.com/api/?name=Admin&background=FF6B6B&color=fff")
                .build();
        
        User customer = User.builder()
                .email("user@shop.com")
                .password(passwordEncoder.encode("user123"))
                .fullName("Nguyễn Văn A")
                .phone("0912345678")
                .role(User.Role.CUSTOMER)
                .avatarUrl("https://ui-avatars.com/api/?name=Nguyen+Van+A&background=4ECDC4&color=fff")
                .build();
        
        userRepository.saveAll(Arrays.asList(admin, customer));
        log.info("Created 2 users");
    }

    
    private void initCategories() {
        List<Category> categories = Arrays.asList(
            Category.builder().name("Điện thoại").description("Điện thoại thông minh các hãng")
                .imageUrl("https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200").build(),
            Category.builder().name("Laptop").description("Laptop văn phòng và gaming")
                .imageUrl("https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200").build(),
            Category.builder().name("Tablet").description("Máy tính bảng")
                .imageUrl("https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=200").build(),
            Category.builder().name("Phụ kiện").description("Phụ kiện điện tử")
                .imageUrl("https://images.unsplash.com/photo-1583394838336-acd977736f90?w=200").build(),
            Category.builder().name("Đồng hồ").description("Đồng hồ thông minh")
                .imageUrl("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200").build(),
            Category.builder().name("Âm thanh").description("Tai nghe và loa")
                .imageUrl("https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200").build(),
            Category.builder().name("Gaming").description("Thiết bị gaming")
                .imageUrl("https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=200").build(),
            Category.builder().name("Smart Home").description("Thiết bị nhà thông minh")
                .imageUrl("https://images.unsplash.com/photo-1558089687-f282ffcbc126?w=200").build()
        );
        categoryRepository.saveAll(categories);
        log.info("Created {} categories", categories.size());
    }
    
    private void initProducts() {
        List<Category> categories = categoryRepository.findAll();
        Category phones = categories.stream().filter(c -> c.getName().equals("Điện thoại")).findFirst().orElse(categories.get(0));
        Category laptops = categories.stream().filter(c -> c.getName().equals("Laptop")).findFirst().orElse(categories.get(0));
        Category tablets = categories.stream().filter(c -> c.getName().equals("Tablet")).findFirst().orElse(categories.get(0));
        Category accessories = categories.stream().filter(c -> c.getName().equals("Phụ kiện")).findFirst().orElse(categories.get(0));
        Category watches = categories.stream().filter(c -> c.getName().equals("Đồng hồ")).findFirst().orElse(categories.get(0));
        Category audio = categories.stream().filter(c -> c.getName().equals("Âm thanh")).findFirst().orElse(categories.get(0));
        Category gaming = categories.stream().filter(c -> c.getName().equals("Gaming")).findFirst().orElse(categories.get(0));
        
        List<Product> products = Arrays.asList(
            // Phones
            createProduct(phones, "iPhone 15 Pro Max 256GB", "iPhone 15 Pro Max với chip A17 Pro, camera 48MP", 
                34990000, 36990000, 50, 120, "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400", true),
            createProduct(phones, "iPhone 15 Pro 128GB", "iPhone 15 Pro với chip A17 Pro, thiết kế titanium", 
                28990000, 30990000, 45, 89, "https://images.unsplash.com/photo-1696446701796-da61225697cc?w=400", true),
            createProduct(phones, "Samsung Galaxy S24 Ultra", "Galaxy S24 Ultra với S Pen, camera 200MP, AI tích hợp", 
                31990000, 33990000, 40, 95, "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400", true),
            createProduct(phones, "Samsung Galaxy S24+", "Galaxy S24+ màn hình Dynamic AMOLED 2X 6.7 inch", 
                25990000, 27990000, 35, 67, "https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=400", false),
            createProduct(phones, "Xiaomi 14 Ultra", "Xiaomi 14 Ultra với camera Leica, Snapdragon 8 Gen 3", 
                23990000, 25990000, 30, 78, "https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400", false),
            createProduct(phones, "Google Pixel 8 Pro", "Pixel 8 Pro với AI Google, camera xuất sắc", 
                26990000, 28990000, 28, 62, "https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400", true),
            
            // Laptops
            createProduct(laptops, "MacBook Pro 14 M3 Pro", "MacBook Pro 14 inch với chip M3 Pro, RAM 18GB", 
                49990000, 52990000, 25, 45, "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400", true),
            createProduct(laptops, "MacBook Air 15 M3", "MacBook Air 15 inch siêu mỏng nhẹ với chip M3", 
                32990000, 34990000, 30, 67, "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=400", true),
            createProduct(laptops, "Dell XPS 15", "Dell XPS 15 với màn hình OLED 3.5K, Intel Core i7", 
                42990000, 45990000, 20, 38, "https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400", false),
            createProduct(laptops, "ASUS ROG Strix G16", "Laptop gaming với RTX 4070, Intel Core i9", 
                45990000, 48990000, 15, 42, "https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400", true),
            
            // Tablets
            createProduct(tablets, "iPad Pro 12.9 M2", "iPad Pro 12.9 inch với chip M2, màn hình Liquid Retina XDR", 
                28990000, 30990000, 25, 52, "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400", true),
            createProduct(tablets, "iPad Air 5", "iPad Air với chip M1, màn hình 10.9 inch", 
                16990000, 18490000, 35, 78, "https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400", false),
            createProduct(tablets, "Samsung Galaxy Tab S9 Ultra", "Tablet Android cao cấp với màn hình 14.6 inch", 
                27990000, 29990000, 20, 41, "https://images.unsplash.com/photo-1632634903228-f1f0c8e4e8e8?w=400", true),
            
            // Watches
            createProduct(watches, "Apple Watch Ultra 2", "Đồng hồ thông minh cao cấp nhất của Apple", 
                21990000, 23990000, 30, 67, "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400", true),
            createProduct(watches, "Apple Watch Series 9", "Apple Watch Series 9 GPS + Cellular 45mm", 
                12990000, 14490000, 45, 98, "https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400", true),
            createProduct(watches, "Samsung Galaxy Watch 6 Classic", "Đồng hồ thông minh với vòng xoay bezel", 
                9990000, 10990000, 40, 76, "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400", false),
            
            // Audio
            createProduct(audio, "AirPods Pro 2", "Tai nghe không dây với chống ồn chủ động", 
                6290000, 6790000, 60, 189, "https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=400", true),
            createProduct(audio, "AirPods Max", "Tai nghe over-ear cao cấp của Apple", 
                12990000, 14490000, 25, 45, "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400", true),
            createProduct(audio, "Sony WH-1000XM5", "Tai nghe chống ồn hàng đầu thế giới", 
                8490000, 9290000, 35, 87, "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400", true),
            createProduct(audio, "JBL Flip 6", "Loa bluetooth chống nước IP67", 
                2790000, 3090000, 70, 156, "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400", false),
            
            // Gaming
            createProduct(gaming, "PlayStation 5", "Máy chơi game thế hệ mới của Sony", 
                14990000, 15990000, 30, 89, "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400", true),
            createProduct(gaming, "Xbox Series X", "Máy chơi game mạnh mẽ nhất của Microsoft", 
                13990000, 14990000, 25, 67, "https://images.unsplash.com/photo-1621259182978-fbf93132d53d?w=400", true),
            createProduct(gaming, "Nintendo Switch OLED", "Máy chơi game cầm tay với màn hình OLED", 
                8990000, 9490000, 40, 134, "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=400", true),
            
            // Accessories
            createProduct(accessories, "Apple Magic Keyboard", "Bàn phím không dây Apple với Touch ID", 
                4290000, 4590000, 50, 89, "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400", false),
            createProduct(accessories, "Sạc nhanh Apple 140W", "Củ sạc USB-C 140W cho MacBook", 
                2490000, 2790000, 80, 156, "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400", false)
        );
        
        productRepository.saveAll(products);
        log.info("Created {} products", products.size());
    }
    
    private Product createProduct(Category category, String name, String description, 
            double price, double originalPrice, int stock, int sold, String imageUrl, boolean featured) {
        return Product.builder()
                .category(category)
                .name(name)
                .description(description)
                .price(BigDecimal.valueOf(price))
                .originalPrice(BigDecimal.valueOf(originalPrice))
                .stockQuantity(stock)
                .soldQuantity(sold)
                .imageUrl(imageUrl)
                .isFeatured(featured)
                .isActive(true)
                .build();
    }
    
    private void initCoupons() {
        List<Coupon> coupons = Arrays.asList(
            Coupon.builder()
                .code("WELCOME10")
                .description("Giảm 10% cho khách hàng mới")
                .discountType(Coupon.DiscountType.PERCENT)
                .discountValue(BigDecimal.valueOf(10))
                .minOrderAmount(BigDecimal.valueOf(500000))
                .maxDiscountAmount(BigDecimal.valueOf(200000))
                .usageLimit(1000)
                .startDate(LocalDateTime.now())
                .endDate(LocalDateTime.now().plusYears(1))
                .build(),
            Coupon.builder()
                .code("SALE20")
                .description("Giảm 20% đơn hàng từ 2 triệu")
                .discountType(Coupon.DiscountType.PERCENT)
                .discountValue(BigDecimal.valueOf(20))
                .minOrderAmount(BigDecimal.valueOf(2000000))
                .maxDiscountAmount(BigDecimal.valueOf(500000))
                .usageLimit(500)
                .startDate(LocalDateTime.now())
                .endDate(LocalDateTime.now().plusYears(1))
                .build(),
            Coupon.builder()
                .code("FREESHIP")
                .description("Miễn phí vận chuyển")
                .discountType(Coupon.DiscountType.FIXED)
                .discountValue(BigDecimal.valueOf(50000))
                .minOrderAmount(BigDecimal.valueOf(300000))
                .usageLimit(2000)
                .startDate(LocalDateTime.now())
                .endDate(LocalDateTime.now().plusYears(1))
                .build()
        );
        couponRepository.saveAll(coupons);
        log.info("Created {} coupons", coupons.size());
    }
}
