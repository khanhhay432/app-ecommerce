-- Seed Data for E-Commerce Database
USE ecommerce_db;

-- Insert sample users
INSERT INTO users (email, password, full_name, phone, role) VALUES
('admin@shop.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqQlBNe8Y5JmqKcHqHqKcHqHqKcHq', 'Admin User', '0901234567', 'ADMIN'),
('user1@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqQlBNe8Y5JmqKcHqHqKcHqHqKcHq', 'Nguyễn Văn A', '0912345678', 'CUSTOMER'),
('user2@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqQlBNe8Y5JmqKcHqHqKcHqHqKcHq', 'Trần Thị B', '0923456789', 'CUSTOMER');

-- Insert addresses
INSERT INTO addresses (user_id, recipient_name, phone, province, district, ward, street_address, is_default) VALUES
(2, 'Nguyễn Văn A', '0912345678', 'Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '123 Nguyễn Huệ', TRUE),
(2, 'Nguyễn Văn A', '0912345678', 'Hồ Chí Minh', 'Quận 3', 'Phường 1', '456 Võ Văn Tần', FALSE),
(3, 'Trần Thị B', '0923456789', 'Hà Nội', 'Quận Hoàn Kiếm', 'Phường Hàng Bạc', '789 Hàng Đào', TRUE);

-- Insert categories
INSERT INTO categories (name, description, image_url) VALUES
('Điện thoại', 'Điện thoại di động các loại', 'https://picsum.photos/seed/phone/400/400'),
('Laptop', 'Máy tính xách tay', 'https://picsum.photos/seed/laptop/400/400'),
('Thời trang Nam', 'Quần áo nam', 'https://picsum.photos/seed/men/400/400'),
('Thời trang Nữ', 'Quần áo nữ', 'https://picsum.photos/seed/women/400/400'),
('Đồ gia dụng', 'Thiết bị gia đình', 'https://picsum.photos/seed/home/400/400'),
('Sách', 'Sách các thể loại', 'https://picsum.photos/seed/book/400/400');

-- Insert products
INSERT INTO products (category_id, name, description, price, original_price, stock_quantity, sold_quantity, image_url, is_featured) VALUES
-- Điện thoại
(1, 'iPhone 15 Pro Max', 'iPhone 15 Pro Max 256GB - Titan tự nhiên', 34990000, 36990000, 50, 120, 'https://picsum.photos/seed/iphone15/400/400', TRUE),
(1, 'Samsung Galaxy S24 Ultra', 'Samsung Galaxy S24 Ultra 512GB', 31990000, 33990000, 30, 85, 'https://picsum.photos/seed/s24/400/400', TRUE),
(1, 'Xiaomi 14 Pro', 'Xiaomi 14 Pro 256GB', 18990000, 20990000, 45, 60, 'https://picsum.photos/seed/xiaomi14/400/400', FALSE),
(1, 'OPPO Find X7 Ultra', 'OPPO Find X7 Ultra 512GB', 25990000, 27990000, 25, 40, 'https://picsum.photos/seed/oppox7/400/400', FALSE),

-- Laptop
(2, 'MacBook Pro 14 M3', 'MacBook Pro 14 inch M3 Pro 18GB/512GB', 52990000, 54990000, 20, 35, 'https://picsum.photos/seed/macbook/400/400', TRUE),
(2, 'Dell XPS 15', 'Dell XPS 15 Core i7-13700H 16GB/512GB', 42990000, 45990000, 15, 28, 'https://picsum.photos/seed/dellxps/400/400', FALSE),
(2, 'ASUS ROG Strix G16', 'ASUS ROG Strix G16 RTX 4060 16GB/512GB', 35990000, 38990000, 18, 42, 'https://picsum.photos/seed/asusrog/400/400', TRUE),
(2, 'Lenovo ThinkPad X1 Carbon', 'ThinkPad X1 Carbon Gen 11 i7/16GB/512GB', 38990000, 41990000, 12, 20, 'https://picsum.photos/seed/thinkpad/400/400', FALSE),

-- Thời trang Nam
(3, 'Áo Polo Nam Premium', 'Áo Polo nam cotton cao cấp', 450000, 550000, 200, 350, 'https://picsum.photos/seed/polo/400/400', FALSE),
(3, 'Quần Jean Nam Slim Fit', 'Quần jean nam form slim fit', 650000, 750000, 150, 280, 'https://picsum.photos/seed/jean/400/400', TRUE),
(3, 'Áo Khoác Bomber', 'Áo khoác bomber nam phong cách', 890000, 990000, 80, 120, 'https://picsum.photos/seed/bomber/400/400', FALSE),

-- Thời trang Nữ
(4, 'Đầm Maxi Hoa', 'Đầm maxi họa tiết hoa vintage', 750000, 890000, 100, 180, 'https://picsum.photos/seed/dress/400/400', TRUE),
(4, 'Áo Blouse Lụa', 'Áo blouse lụa cao cấp', 550000, 650000, 120, 200, 'https://picsum.photos/seed/blouse/400/400', FALSE),
(4, 'Chân Váy Xếp Ly', 'Chân váy xếp ly dáng dài', 480000, 580000, 90, 150, 'https://picsum.photos/seed/skirt/400/400', FALSE),

-- Đồ gia dụng
(5, 'Nồi chiên không dầu Philips', 'Nồi chiên không dầu Philips 6.2L', 3290000, 3790000, 40, 95, 'https://picsum.photos/seed/airfryer/400/400', TRUE),
(5, 'Robot hút bụi Xiaomi', 'Robot hút bụi lau nhà Xiaomi', 7990000, 8990000, 25, 45, 'https://picsum.photos/seed/robot/400/400', FALSE),
(5, 'Máy lọc không khí Sharp', 'Máy lọc không khí Sharp 40m2', 5490000, 5990000, 30, 55, 'https://picsum.photos/seed/airpurifier/400/400', FALSE),

-- Sách
(6, 'Đắc Nhân Tâm', 'Dale Carnegie - Bản dịch mới nhất', 108000, 128000, 500, 1200, 'https://picsum.photos/seed/book1/400/400', TRUE),
(6, 'Nhà Giả Kim', 'Paulo Coelho - Tiểu thuyết', 79000, 95000, 400, 980, 'https://picsum.photos/seed/book2/400/400', FALSE),
(6, 'Atomic Habits', 'James Clear - Thói quen nguyên tử', 169000, 199000, 300, 750, 'https://picsum.photos/seed/book3/400/400', TRUE);

-- Insert coupons
INSERT INTO coupons (code, description, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, start_date, end_date) VALUES
('WELCOME10', 'Giảm 10% cho khách hàng mới', 'PERCENTAGE', 10, 200000, 100000, 1000, '2024-01-01', '2025-12-31'),
('SALE50K', 'Giảm 50.000đ đơn từ 500.000đ', 'FIXED_AMOUNT', 50000, 500000, NULL, 500, '2024-01-01', '2025-12-31'),
('FREESHIP', 'Miễn phí vận chuyển', 'FIXED_AMOUNT', 30000, 300000, NULL, NULL, '2024-01-01', '2025-12-31'),
('SUMMER20', 'Giảm 20% mùa hè', 'PERCENTAGE', 20, 500000, 200000, 200, '2024-06-01', '2024-08-31'),
('VIP100K', 'Giảm 100.000đ cho VIP', 'FIXED_AMOUNT', 100000, 1000000, NULL, 100, '2024-01-01', '2025-12-31');

-- Insert sample reviews
INSERT INTO reviews (product_id, user_id, rating, comment, is_verified_purchase) VALUES
(1, 2, 5, 'Sản phẩm tuyệt vời, đóng gói cẩn thận, giao hàng nhanh!', TRUE),
(1, 3, 4, 'Máy đẹp, pin tốt, camera chụp đẹp. Giá hơi cao.', TRUE),
(2, 2, 5, 'Samsung S24 Ultra quá đỉnh, màn hình đẹp, camera zoom xa cực nét!', TRUE),
(5, 3, 5, 'MacBook Pro M3 mạnh mẽ, thiết kế sang trọng, rất hài lòng!', TRUE),
(9, 2, 4, 'Áo polo chất lượng tốt, form đẹp, giao hàng nhanh.', TRUE),
(12, 3, 5, 'Đầm rất đẹp, đúng như hình, chất vải mát mẻ.', TRUE),
(15, 2, 5, 'Nồi chiên không dầu Philips rất tiện, nấu ăn healthy!', TRUE),
(18, 3, 5, 'Sách hay, bìa đẹp, giao hàng cẩn thận.', TRUE);
