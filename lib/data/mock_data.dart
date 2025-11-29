import '../models/product.dart';
import '../models/category.dart';
import '../models/user.dart';

class MockData {
  // Test accounts với phân quyền rõ ràng
  static List<Map<String, dynamic>> testAccounts = [
    {
      'email': 'admin@shopnow.com',
      'password': 'admin123',
      'fullName': 'Quản trị viên',
      'phone': '0901234567',
      'role': 'ADMIN',
      'avatarUrl': 'https://ui-avatars.com/api/?name=Admin&background=667EEA&color=fff&size=200&font-size=0.6',
      'permissions': ['CREATE_PRODUCT', 'UPDATE_PRODUCT', 'DELETE_PRODUCT', 'MANAGE_ORDERS', 'VIEW_ANALYTICS'],
    },
    {
      'email': 'customer@gmail.com',
      'password': 'customer123',
      'fullName': 'Khách hàng VIP',
      'phone': '0912345678',
      'role': 'CUSTOMER',
      'avatarUrl': 'https://ui-avatars.com/api/?name=Customer&background=FF6B9D&color=fff&size=200&font-size=0.6',
      'permissions': ['VIEW_PRODUCTS', 'CREATE_ORDER', 'VIEW_ORDERS'],
    },
  ];

  static List<Category> categories = [
    Category(id: 1, name: 'Điện thoại', imageUrl: 'assets/img/smartphone.jpg'),
    Category(id: 2, name: 'Laptop', imageUrl: 'assets/img/laptop.jpg'),
    Category(id: 3, name: 'Thời trang Nam', imageUrl: 'assets/img/men\'s fashion.jpg'),
    Category(id: 4, name: 'Thời trang Nữ', imageUrl: 'assets/img/women\'s fashion.jpg'),
    Category(id: 5, name: 'Đồ gia dụng', imageUrl: 'assets/img/home appliances.jpg'),
    Category(id: 6, name: 'Sách', imageUrl: 'assets/img/books.jpg'),
    Category(id: 7, name: 'Đồng hồ', imageUrl: 'assets/img/watches.jpg'),
    Category(id: 8, name: 'Phụ kiện', imageUrl: 'assets/img/accessories.jpg'),
  ];

  static List<Product> products = [
    // Điện thoại
    Product(
      id: 1, 
      name: 'iPhone 15 Pro Max 256GB', 
      description: 'iPhone 15 Pro Max với chip A17 Pro mạnh mẽ, camera 48MP chụp ảnh sắc nét, khung titan cao cấp, màn hình Super Retina XDR 6.7 inch.', 
      price: 34990000, 
      originalPrice: 36990000, 
      stockQuantity: 50, 
      soldQuantity: 120, 
      imageUrl: 'assets/img/iPhone 15 Pro Max.jpg', 
      isFeatured: true, 
      categoryId: 1, 
      categoryName: 'Điện thoại', 
      averageRating: 4.8, 
      reviewCount: 156
    ),
    Product(
      id: 2, 
      name: 'Samsung Galaxy S24 Ultra', 
      description: 'Samsung Galaxy S24 Ultra 512GB với S Pen tích hợp, camera 200MP, chip Snapdragon 8 Gen 3, màn hình Dynamic AMOLED 2X.', 
      price: 31990000, 
      originalPrice: 33990000, 
      stockQuantity: 30, 
      soldQuantity: 85, 
      imageUrl: 'assets/img/Samsung Galaxy S24 Ultra.jpg', 
      isFeatured: true, 
      categoryId: 1, 
      categoryName: 'Điện thoại', 
      averageRating: 4.7, 
      reviewCount: 98
    ),
    Product(
      id: 3, 
      name: 'Xiaomi 14 Pro', 
      description: 'Xiaomi 14 Pro 256GB Snapdragon 8 Gen 3, camera Leica 50MP, sạc nhanh 120W, màn hình LTPO AMOLED 6.73 inch.', 
      price: 18990000, 
      originalPrice: 20990000, 
      stockQuantity: 45, 
      soldQuantity: 60, 
      imageUrl: 'assets/img/Xiaomi 14 Pro.jpg', 
      isFeatured: false, 
      categoryId: 1, 
      categoryName: 'Điện thoại', 
      averageRating: 4.5, 
      reviewCount: 72
    ),
    Product(
      id: 4, 
      name: 'OPPO Find X7 Ultra', 
      description: 'OPPO Find X7 Ultra camera Hasselblad, chip Snapdragon 8 Gen 3, màn hình LTPO AMOLED 6.82 inch, sạc nhanh 100W.', 
      price: 25990000, 
      originalPrice: 27990000, 
      stockQuantity: 2, 
      soldQuantity: 40, 
      imageUrl: 'assets/img/OPPO Find X7 Ultra.jpg', 
      isFeatured: false, 
      categoryId: 1, 
      categoryName: 'Điện thoại', 
      averageRating: 4.6, 
      reviewCount: 45
    ),
    // Laptop
    Product(
      id: 5, 
      name: 'MacBook Pro 14 M3 Pro', 
      description: 'MacBook Pro 14 inch M3 Pro 18GB/512GB, màn hình Liquid Retina XDR, thời lượng pin lên đến 17 giờ.', 
      price: 52990000, 
      originalPrice: 54990000, 
      stockQuantity: 20, 
      soldQuantity: 35, 
      imageUrl: 'assets/img/MacBook Pro M3.jpg', 
      isFeatured: true, 
      categoryId: 2, 
      categoryName: 'Laptop', 
      averageRating: 4.9, 
      reviewCount: 89
    ),
    Product(
      id: 6, 
      name: 'Dell XPS 15', 
      description: 'Dell XPS 15 Core i7-13700H 16GB/512GB, màn hình OLED 3.5K 15.6 inch, thiết kế siêu mỏng nhẹ.', 
      price: 42990000, 
      originalPrice: 45990000, 
      stockQuantity: 15, 
      soldQuantity: 28, 
      imageUrl: 'assets/img/Dell XPS 15.jpg', 
      isFeatured: false, 
      categoryId: 2, 
      categoryName: 'Laptop', 
      averageRating: 4.6, 
      reviewCount: 56
    ),
    Product(
      id: 7, 
      name: 'ASUS ROG Strix G16', 
      description: 'ASUS ROG Strix G16 RTX 4060 Gaming, Core i7-13650HX, RAM 16GB, màn hình 165Hz, bàn phím RGB.', 
      price: 35990000, 
      originalPrice: 38990000, 
      stockQuantity: 18, 
      soldQuantity: 42, 
      imageUrl: 'assets/img/ASUS ROG Strix G16.jpg', 
      isFeatured: true, 
      categoryId: 2, 
      categoryName: 'Laptop', 
      averageRating: 4.7, 
      reviewCount: 67
    ),

    // Thời trang Nam
    Product(
      id: 8, 
      name: 'Áo Polo Nam Premium', 
      description: 'Áo Polo nam cotton cao cấp, form regular fit thoải mái, chất liệu cotton 100% thấm hút mồ hôi tốt.', 
      price: 450000, 
      originalPrice: 550000, 
      stockQuantity: 200, 
      soldQuantity: 350, 
      imageUrl: 'assets/img/Áo Polo nam.jpg', 
      isFeatured: false, 
      categoryId: 3, 
      categoryName: 'Thời trang Nam', 
      averageRating: 4.4, 
      reviewCount: 234
    ),
    Product(
      id: 9, 
      name: 'Quần Jean Nam Slim Fit', 
      description: 'Quần jean nam form slim fit co giãn, chất liệu denim cao cấp, màu xanh đậm classic.', 
      price: 650000, 
      originalPrice: 750000, 
      stockQuantity: 150, 
      soldQuantity: 280, 
      imageUrl: 'assets/img/Quần jean nam.jpg', 
      isFeatured: true, 
      categoryId: 3, 
      categoryName: 'Thời trang Nam', 
      averageRating: 4.5, 
      reviewCount: 189
    ),
    Product(
      id: 10, 
      name: 'Áo Khoác Bomber', 
      description: 'Áo khoác bomber nam phong cách Hàn Quốc, chất liệu dù cao cấp chống nước nhẹ.', 
      price: 890000, 
      originalPrice: 990000, 
      stockQuantity: 80, 
      soldQuantity: 120, 
      imageUrl: 'assets/img/Áo khoác bomber.jpg', 
      isFeatured: false, 
      categoryId: 3, 
      categoryName: 'Thời trang Nam', 
      averageRating: 4.3, 
      reviewCount: 98
    ),
    // Thời trang Nữ
    Product(
      id: 11, 
      name: 'Đầm Maxi Hoa Vintage', 
      description: 'Đầm maxi họa tiết hoa phong cách vintage, chất liệu voan mềm mại, phù hợp đi biển, dạo phố.', 
      price: 750000, 
      originalPrice: 890000, 
      stockQuantity: 100, 
      soldQuantity: 180, 
      imageUrl: 'assets/img/Đầm maxi hoa.jpg', 
      isFeatured: true, 
      categoryId: 4, 
      categoryName: 'Thời trang Nữ', 
      averageRating: 4.6, 
      reviewCount: 156
    ),
    Product(
      id: 12, 
      name: 'Áo Blouse Lụa', 
      description: 'Áo blouse lụa cao cấp thanh lịch, thiết kế cổ V sang trọng, phù hợp công sở và dạo phố.', 
      price: 550000, 
      originalPrice: 650000, 
      stockQuantity: 120, 
      soldQuantity: 200, 
      imageUrl: 'assets/img/Áo blouse lụa.jpg', 
      isFeatured: false, 
      categoryId: 4, 
      categoryName: 'Thời trang Nữ', 
      averageRating: 4.5, 
      reviewCount: 134
    ),
    // Đồ gia dụng
    Product(
      id: 13, 
      name: 'Nồi chiên không dầu Philips', 
      description: 'Nồi chiên không dầu Philips 6.2L Digital, công nghệ Rapid Air, 7 chế độ nấu tự động.', 
      price: 3290000, 
      originalPrice: 3790000, 
      stockQuantity: 40, 
      soldQuantity: 95, 
      imageUrl: 'assets/img/Nồi chiên không dầu.jpg', 
      isFeatured: true, 
      categoryId: 5, 
      categoryName: 'Đồ gia dụng', 
      averageRating: 4.8, 
      reviewCount: 267
    ),
    Product(
      id: 14, 
      name: 'Robot hút bụi Xiaomi', 
      description: 'Robot hút bụi lau nhà Xiaomi thông minh, lực hút 4000Pa, pin 5200mAh, điều khiển qua app.', 
      price: 7990000, 
      originalPrice: 8990000, 
      stockQuantity: 25, 
      soldQuantity: 45, 
      imageUrl: 'assets/img/Robot hút bụi.jpg', 
      isFeatured: false, 
      categoryId: 5, 
      categoryName: 'Đồ gia dụng', 
      averageRating: 4.6, 
      reviewCount: 89
    ),
    // Sách
    Product(
      id: 15, 
      name: 'Đắc Nhân Tâm', 
      description: 'Dale Carnegie - Nghệ thuật đối nhân xử thế, cuốn sách kinh điển về kỹ năng giao tiếp và xây dựng mối quan hệ.', 
      price: 108000, 
      originalPrice: 128000, 
      stockQuantity: 500, 
      soldQuantity: 1200, 
      imageUrl: 'assets/img/Đắc Nhân Tâm.jpg', 
      isFeatured: true, 
      categoryId: 6, 
      categoryName: 'Sách', 
      averageRating: 4.9, 
      reviewCount: 567
    ),
    Product(
      id: 16, 
      name: 'Nhà Giả Kim', 
      description: 'Paulo Coelho - Tiểu thuyết bán chạy nhất mọi thời đại về hành trình theo đuổi ước mơ.', 
      price: 79000, 
      originalPrice: 95000, 
      stockQuantity: 400, 
      soldQuantity: 980, 
      imageUrl: 'assets/img/Nhà Giả Kim.jpg', 
      isFeatured: false, 
      categoryId: 6, 
      categoryName: 'Sách', 
      averageRating: 4.8, 
      reviewCount: 445
    ),
    
    // Đồng hồ
    Product(
      id: 17, 
      name: 'Apple Watch Series 9', 
      description: 'Apple Watch Series 9 GPS 45mm với chip S9 mạnh mẽ, màn hình Retina Always-On, theo dõi sức khỏe toàn diện.', 
      price: 10990000, 
      originalPrice: 11990000, 
      stockQuantity: 35, 
      soldQuantity: 78, 
      imageUrl: 'assets/img/Apple Watch Series 9.jpg', 
      isFeatured: true, 
      categoryId: 7, 
      categoryName: 'Đồng hồ', 
      averageRating: 4.7, 
      reviewCount: 123
    ),
    Product(
      id: 18, 
      name: 'Samsung Galaxy Watch 6', 
      description: 'Samsung Galaxy Watch 6 Classic 47mm với khung thép không gỉ, theo dõi giấc ngủ và sức khỏe thông minh.', 
      price: 7990000, 
      originalPrice: 8990000, 
      stockQuantity: 28, 
      soldQuantity: 65, 
      imageUrl: 'assets/img/Samsung Galaxy Watch 6.jpg', 
      isFeatured: false, 
      categoryId: 7, 
      categoryName: 'Đồng hồ', 
      averageRating: 4.5, 
      reviewCount: 89
    ),
    
    // Phụ kiện
    Product(
      id: 19, 
      name: 'AirPods Pro 2', 
      description: 'Apple AirPods Pro thế hệ 2 với chip H2, chống ồn chủ động, âm thanh không gian và hộp sạc MagSafe.', 
      price: 6490000, 
      originalPrice: 6990000, 
      stockQuantity: 42, 
      soldQuantity: 156, 
      imageUrl: 'assets/img/AirPods Pro 2.jpg', 
      isFeatured: true, 
      categoryId: 8, 
      categoryName: 'Phụ kiện', 
      averageRating: 4.8, 
      reviewCount: 234
    ),
    Product(
      id: 20, 
      name: 'Balo Laptop Cao Cấp', 
      description: 'Balo laptop chống nước, thiết kế hiện đại với nhiều ngăn tiện ích, phù hợp laptop 15.6 inch.', 
      price: 890000, 
      originalPrice: 1190000, 
      stockQuantity: 0, 
      soldQuantity: 89, 
      imageUrl: 'assets/img/Balo laptop.jpg', 
      isFeatured: false, 
      categoryId: 8, 
      categoryName: 'Phụ kiện', 
      averageRating: 4.4, 
      reviewCount: 67
    ),
  ];

  static List<Map<String, dynamic>> coupons = [
    {'code': 'WELCOME10', 'description': 'Giảm 10% cho khách mới', 'discountPercent': 10, 'minOrder': 200000, 'maxDiscount': 100000},
    {'code': 'SALE50K', 'description': 'Giảm 50.000đ', 'discountAmount': 50000, 'minOrder': 500000},
    {'code': 'FREESHIP', 'description': 'Miễn phí vận chuyển', 'discountAmount': 30000, 'minOrder': 300000},
  ];

  static List<Map<String, dynamic>> reviews = [
    {'productId': 1, 'userName': 'Nguyễn Văn A', 'rating': 5, 'comment': 'Sản phẩm tuyệt vời, đóng gói cẩn thận!', 'date': '2024-11-20', 'avatarUrl': 'https://ui-avatars.com/api/?name=Nguyen+Van+A&background=random'},
    {'productId': 1, 'userName': 'Trần Thị B', 'rating': 4, 'comment': 'Máy đẹp, pin tốt, camera chụp đẹp.', 'date': '2024-11-18', 'avatarUrl': 'https://ui-avatars.com/api/?name=Tran+Thi+B&background=random'},
    {'productId': 2, 'userName': 'Lê Văn C', 'rating': 5, 'comment': 'Samsung S24 Ultra quá đỉnh!', 'date': '2024-11-15', 'avatarUrl': 'https://ui-avatars.com/api/?name=Le+Van+C&background=random'},
    {'productId': 5, 'userName': 'Phạm Văn D', 'rating': 5, 'comment': 'MacBook M3 mạnh mẽ, thiết kế đẹp!', 'date': '2024-11-10', 'avatarUrl': 'https://ui-avatars.com/api/?name=Pham+Van+D&background=random'},
    {'productId': 13, 'userName': 'Hoàng Thị E', 'rating': 5, 'comment': 'Nồi chiên không dầu rất tiện, nấu ăn healthy!', 'date': '2024-11-08', 'avatarUrl': 'https://ui-avatars.com/api/?name=Hoang+Thi+E&background=random'},
  ];

  static List<Map<String, dynamic>> banners = [
    {'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:690:300/q:90/plain/https://dashboard.cellphones.com.vn/storage/iphone-16-pro-max-sliding-mobi.jpg', 'title': 'iPhone 16 Pro Max', 'subtitle': 'Siêu phẩm mới nhất'},
    {'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:690:300/q:90/plain/https://dashboard.cellphones.com.vn/storage/samsung-s24-ultra-sliding.jpg', 'title': 'Samsung S24 Ultra', 'subtitle': 'Giảm đến 3 triệu'},
    {'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:690:300/q:90/plain/https://dashboard.cellphones.com.vn/storage/macbook-pro-m3-sliding.jpg', 'title': 'MacBook Pro M3', 'subtitle': 'Hiệu năng vượt trội'},
  ];
}
