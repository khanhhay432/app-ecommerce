-- E-Commerce Database Schema
-- MySQL Database

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

-- Users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    role ENUM('CUSTOMER', 'ADMIN') DEFAULT 'CUSTOMER',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    parent_id BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Products table
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL,
    original_price DECIMAL(15,2),
    stock_quantity INT DEFAULT 0,
    sold_quantity INT DEFAULT 0,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);


-- Product images table
CREATE TABLE product_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Addresses table
CREATE TABLE addresses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    province VARCHAR(100),
    district VARCHAR(100),
    ward VARCHAR(100),
    street_address VARCHAR(500) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Carts table
CREATE TABLE carts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Cart items table
CREATE TABLE cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE KEY unique_cart_product (cart_id, product_id)
);

-- Wishlists table
CREATE TABLE wishlists (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product (user_id, product_id)
);

-- Coupons table
CREATE TABLE coupons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    discount_type ENUM('PERCENT', 'FIXED') NOT NULL,
    discount_value DECIMAL(15,2) NOT NULL,
    min_order_amount DECIMAL(15,2) DEFAULT 0,
    max_discount DECIMAL(15,2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    subtotal DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    shipping_fee DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPING', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    payment_status ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') DEFAULT 'PENDING',
    shipping_name VARCHAR(255) NOT NULL,
    shipping_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    coupon_code VARCHAR(50),
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order items table
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_image VARCHAR(500),
    price DECIMAL(15,2) NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Reviews table
CREATE TABLE reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    order_id BIGINT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
);


-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Insert admin user (password: admin123 - BCrypt encoded)
-- Password được mã hóa bằng BCrypt, có thể tạo mới tại: https://bcrypt-generator.com/
INSERT INTO users (email, password, full_name, phone, role, avatar_url) VALUES
('admin@shop.com', '$2a$10$rDkPvvAFV8kqwvKJzwlRv.FDXhXhLxCy6j5C5YQ5Z5Z5Z5Z5Z5Z5Z', 'Admin Shop', '0901234567', 'ADMIN', 'https://ui-avatars.com/api/?name=Admin&background=FF6B6B&color=fff'),
('user@shop.com', '$2a$10$rDkPvvAFV8kqwvKJzwlRv.FDXhXhLxCy6j5C5YQ5Z5Z5Z5Z5Z5Z5Z', 'Nguyễn Văn A', '0912345678', 'CUSTOMER', 'https://ui-avatars.com/api/?name=Nguyen+Van+A&background=4ECDC4&color=fff');

-- Lưu ý: Password mặc định là "password123" cho cả 2 tài khoản
-- Để đổi password, hãy tạo hash BCrypt mới và update vào database

-- Insert categories
INSERT INTO categories (name, description, image_url) VALUES
('Điện thoại', 'Điện thoại thông minh các hãng', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200'),
('Laptop', 'Laptop văn phòng và gaming', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200'),
('Tablet', 'Máy tính bảng', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=200'),
('Phụ kiện', 'Phụ kiện điện tử', 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=200'),
('Đồng hồ', 'Đồng hồ thông minh', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200'),
('Âm thanh', 'Tai nghe và loa', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200'),
('Gaming', 'Thiết bị gaming', 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=200'),
('Smart Home', 'Thiết bị nhà thông minh', 'https://images.unsplash.com/photo-1558089687-f282ffcbc126?w=200');

-- Insert products - Điện thoại
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(1, 'iPhone 15 Pro Max 256GB', 'iPhone 15 Pro Max với chip A17 Pro, camera 48MP, màn hình Super Retina XDR 6.7 inch', 34990000, 36990000, 50, 120, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400', TRUE),
(1, 'iPhone 15 Pro 128GB', 'iPhone 15 Pro với chip A17 Pro, thiết kế titanium cao cấp', 28990000, 30990000, 45, 89, 'https://images.unsplash.com/photo-1696446701796-da61225697cc?w=400', TRUE),
(1, 'Samsung Galaxy S24 Ultra', 'Galaxy S24 Ultra với S Pen, camera 200MP, AI tích hợp', 31990000, 33990000, 40, 95, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400', TRUE),
(1, 'Samsung Galaxy S24+', 'Galaxy S24+ màn hình Dynamic AMOLED 2X 6.7 inch', 25990000, 27990000, 35, 67, 'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=400', FALSE),
(1, 'Samsung Galaxy Z Fold5', 'Điện thoại gập cao cấp, màn hình 7.6 inch khi mở', 41990000, 44990000, 20, 45, 'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?w=400', TRUE),
(1, 'Xiaomi 14 Ultra', 'Xiaomi 14 Ultra với camera Leica, Snapdragon 8 Gen 3', 23990000, 25990000, 30, 78, 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400', FALSE),
(1, 'OPPO Find X7 Ultra', 'OPPO Find X7 Ultra với camera Hasselblad', 24990000, 26990000, 25, 56, 'https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=400', FALSE),
(1, 'Google Pixel 8 Pro', 'Pixel 8 Pro với AI Google, camera xuất sắc', 26990000, 28990000, 28, 62, 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400', TRUE);

-- Insert products - Laptop
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(2, 'MacBook Pro 14 M3 Pro', 'MacBook Pro 14 inch với chip M3 Pro, RAM 18GB, SSD 512GB', 49990000, 52990000, 25, 45, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400', TRUE),
(2, 'MacBook Air 15 M3', 'MacBook Air 15 inch siêu mỏng nhẹ với chip M3', 32990000, 34990000, 30, 67, 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=400', TRUE),
(2, 'Dell XPS 15', 'Dell XPS 15 với màn hình OLED 3.5K, Intel Core i7 Gen 13', 42990000, 45990000, 20, 38, 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400', FALSE),
(2, 'ASUS ROG Strix G16', 'Laptop gaming với RTX 4070, Intel Core i9, màn hình 240Hz', 45990000, 48990000, 15, 42, 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400', TRUE),
(2, 'Lenovo ThinkPad X1 Carbon', 'Laptop doanh nhân cao cấp, siêu nhẹ 1.12kg', 38990000, 41990000, 18, 35, 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400', FALSE),
(2, 'HP Spectre x360', 'Laptop 2-in-1 cao cấp với màn hình OLED cảm ứng', 35990000, 38990000, 22, 29, 'https://images.unsplash.com/photo-1544731612-de7f96afe55f?w=400', FALSE);


-- Insert products - Tablet
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(3, 'iPad Pro 12.9 M2', 'iPad Pro 12.9 inch với chip M2, màn hình Liquid Retina XDR', 28990000, 30990000, 25, 52, 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400', TRUE),
(3, 'iPad Air 5', 'iPad Air với chip M1, màn hình 10.9 inch', 16990000, 18490000, 35, 78, 'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400', FALSE),
(3, 'Samsung Galaxy Tab S9 Ultra', 'Tablet Android cao cấp với màn hình 14.6 inch', 27990000, 29990000, 20, 41, 'https://images.unsplash.com/photo-1632634903228-f1f0c8e4e8e8?w=400', TRUE),
(3, 'Samsung Galaxy Tab S9+', 'Galaxy Tab S9+ màn hình 12.4 inch AMOLED', 22990000, 24990000, 25, 36, 'https://images.unsplash.com/photo-1585790050230-5dd28404ccb9?w=400', FALSE);

-- Insert products - Phụ kiện
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(4, 'Apple Magic Keyboard', 'Bàn phím không dây Apple với Touch ID', 4290000, 4590000, 50, 89, 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400', FALSE),
(4, 'Sạc nhanh Apple 140W', 'Củ sạc USB-C 140W cho MacBook', 2490000, 2790000, 80, 156, 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400', FALSE),
(4, 'Cáp USB-C to Lightning', 'Cáp sạc nhanh chính hãng Apple 2m', 590000, 690000, 200, 450, 'https://images.unsplash.com/photo-1606292943133-cc1e8d6f5e3a?w=400', FALSE),
(4, 'Samsung 45W Travel Adapter', 'Sạc nhanh Samsung 45W', 890000, 990000, 100, 234, 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', FALSE),
(4, 'Ốp lưng iPhone 15 Pro Max', 'Ốp lưng silicon chính hãng Apple', 1290000, 1490000, 150, 320, 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400', FALSE);

-- Insert products - Đồng hồ
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(5, 'Apple Watch Ultra 2', 'Đồng hồ thông minh cao cấp nhất của Apple', 21990000, 23990000, 30, 67, 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400', TRUE),
(5, 'Apple Watch Series 9', 'Apple Watch Series 9 GPS + Cellular 45mm', 12990000, 14490000, 45, 98, 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400', TRUE),
(5, 'Samsung Galaxy Watch 6 Classic', 'Đồng hồ thông minh với vòng xoay bezel', 9990000, 10990000, 40, 76, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400', FALSE),
(5, 'Garmin Fenix 7X', 'Đồng hồ thể thao cao cấp với GPS đa băng tần', 18990000, 20990000, 20, 34, 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=400', FALSE);

-- Insert products - Âm thanh
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(6, 'AirPods Pro 2', 'Tai nghe không dây với chống ồn chủ động', 6290000, 6790000, 60, 189, 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=400', TRUE),
(6, 'AirPods Max', 'Tai nghe over-ear cao cấp của Apple', 12990000, 14490000, 25, 45, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', TRUE),
(6, 'Sony WH-1000XM5', 'Tai nghe chống ồn hàng đầu thế giới', 8490000, 9290000, 35, 87, 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400', TRUE),
(6, 'Samsung Galaxy Buds2 Pro', 'Tai nghe true wireless với ANC', 4290000, 4790000, 50, 123, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400', FALSE),
(6, 'JBL Flip 6', 'Loa bluetooth chống nước IP67', 2790000, 3090000, 70, 156, 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400', FALSE),
(6, 'Bose SoundLink Max', 'Loa bluetooth cao cấp âm thanh vượt trội', 9990000, 10990000, 25, 42, 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=400', FALSE);

-- Insert products - Gaming
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(7, 'PlayStation 5', 'Máy chơi game thế hệ mới của Sony', 14990000, 15990000, 30, 89, 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400', TRUE),
(7, 'Xbox Series X', 'Máy chơi game mạnh mẽ nhất của Microsoft', 13990000, 14990000, 25, 67, 'https://images.unsplash.com/photo-1621259182978-fbf93132d53d?w=400', TRUE),
(7, 'Nintendo Switch OLED', 'Máy chơi game cầm tay với màn hình OLED', 8990000, 9490000, 40, 134, 'https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=400', TRUE),
(7, 'DualSense Controller', 'Tay cầm PS5 với haptic feedback', 1790000, 1990000, 80, 234, 'https://images.unsplash.com/photo-1592840496694-26d035b52b48?w=400', FALSE),
(7, 'Razer BlackWidow V4', 'Bàn phím cơ gaming RGB', 4290000, 4790000, 45, 78, 'https://images.unsplash.com/photo-1595225476474-87563907a212?w=400', FALSE),
(7, 'Logitech G Pro X Superlight', 'Chuột gaming không dây siêu nhẹ', 3290000, 3590000, 55, 145, 'https://images.unsplash.com/photo-1527814050087-3793815479db?w=400', FALSE);

-- Insert products - Smart Home
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
(8, 'Apple HomePod mini', 'Loa thông minh với Siri', 2490000, 2790000, 50, 89, 'https://images.unsplash.com/photo-1558089687-f282ffcbc126?w=400', FALSE),
(8, 'Google Nest Hub 2', 'Màn hình thông minh với Google Assistant', 2290000, 2590000, 40, 67, 'https://images.unsplash.com/photo-1543512214-318c7553f230?w=400', FALSE),
(8, 'Xiaomi Robot Vacuum X10+', 'Robot hút bụi lau nhà thông minh', 12990000, 14490000, 25, 56, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', TRUE),
(8, 'Philips Hue Starter Kit', 'Bộ đèn thông minh Philips Hue', 3990000, 4490000, 35, 78, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', FALSE),
(8, 'Ring Video Doorbell 4', 'Chuông cửa thông minh có camera', 4990000, 5490000, 30, 45, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', FALSE);

-- Insert coupons
INSERT INTO coupons (code, description, discount_type, discount_value, min_order_amount, max_discount, usage_limit, start_date, end_date) VALUES
('WELCOME10', 'Giảm 10% cho khách hàng mới', 'PERCENT', 10, 500000, 200000, 1000, '2024-01-01', '2025-12-31'),
('SALE20', 'Giảm 20% đơn hàng từ 2 triệu', 'PERCENT', 20, 2000000, 500000, 500, '2024-01-01', '2025-12-31'),
('FREESHIP', 'Miễn phí vận chuyển', 'FIXED', 50000, 300000, NULL, 2000, '2024-01-01', '2025-12-31'),
('FLASH50', 'Flash Sale giảm 50%', 'PERCENT', 50, 1000000, 1000000, 100, '2024-01-01', '2025-12-31'),
('VIP100K', 'Giảm 100K cho VIP', 'FIXED', 100000, 500000, NULL, 500, '2024-01-01', '2025-12-31');

-- Create indexes for better performance
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
