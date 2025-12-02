# 📱 TỔNG QUAN DỰ ÁN ECOMMERCE

## 🎯 Mô tả dự án
Ứng dụng thương mại điện tử (E-commerce) đầy đủ tính năng, được xây dựng bằng **Flutter** (Frontend) và **Spring Boot** (Backend), sử dụng **MySQL** làm cơ sở dữ liệu.

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                        │
│  (Android, iOS, Windows, Web - Cross Platform)              │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTP/REST API
                      ↓
┌─────────────────────────────────────────────────────────────┐
│              SPRING BOOT BACKEND (Java)                      │
│  - REST API Controllers                                      │
│  - Business Logic Services                                   │
│  - JPA/Hibernate ORM                                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ JDBC
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                    MYSQL DATABASE                            │
│  - Users, Products, Orders, Categories, Reviews             │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Cấu trúc thư mục

```
ecommerce/
├── lib/                          # Flutter Frontend
│   ├── config/                   # Cấu hình API
│   ├── l10n/                     # Đa ngôn ngữ (Vi/En)
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   ├── screens/                  # Màn hình UI
│   │   ├── admin/               # Màn hình quản trị
│   │   └── *.dart               # Màn hình người dùng
│   ├── services/                 # API services
│   ├── theme/                    # Theme & styling
│   ├── utils/                    # Utilities
│   ├── widgets/                  # Reusable widgets
│   └── main.dart                # Entry point
│
├── backend/                      # Spring Boot Backend
│   └── src/main/java/com/ecommerce/
│       ├── controller/          # REST API endpoints
│       ├── dto/                 # Data Transfer Objects
│       ├── entity/              # JPA Entities
│       ├── repository/          # Database repositories
│       ├── service/             # Business logic
│       └── EcommerceApplication.java
│
├── database/                     # SQL scripts
│   └── ecommerce_db.sql         # Database schema
│
├── assets/                       # Images & resources
│   └── img/
│
└── docs/                         # Documentation
    ├── PROJECT_OVERVIEW.md      # File này
    ├── FRONTEND_GUIDE.md        # Hướng dẫn Frontend
    ├── BACKEND_GUIDE.md         # Hướng dẫn Backend
    └── CODE_EXPLANATION/        # Giải thích chi tiết code
```

## 🎨 Tính năng chính

### 👤 Người dùng (Customer)
- ✅ Đăng ký / Đăng nhập / Đăng xuất
- ✅ Xem danh sách sản phẩm (Featured, Top Selling, New Arrivals, On Sale)
- ✅ Tìm kiếm sản phẩm theo tên
- ✅ Lọc sản phẩm theo danh mục
- ✅ Xem chi tiết sản phẩm
- ✅ Thêm vào giỏ hàng
- ✅ Quản lý giỏ hàng (thêm, sửa, xóa)
- ✅ Đặt hàng với thông tin giao hàng
- ✅ Xem lịch sử đơn hàng
- ✅ Đánh giá & review sản phẩm
- ✅ Quản lý địa chỉ giao hàng
- ✅ Đổi mật khẩu
- ✅ Cập nhật thông tin cá nhân
- ✅ Wishlist (danh sách yêu thích)
- ✅ Flash Sale
- ✅ Thông báo
- ✅ Đa ngôn ngữ (Tiếng Việt / English)
- ✅ Dark Mode / Light Mode

### 👨‍💼 Quản trị viên (Admin)
- ✅ Quản lý sản phẩm (CRUD)
- ✅ Upload hình ảnh sản phẩm
- ✅ Quản lý danh mục
- ✅ Xem thống kê doanh thu
- ✅ Xem biểu đồ phân tích
- ✅ Quản lý đơn hàng
- ✅ Xuất PDF hóa đơn

## 🛠️ Công nghệ sử dụng

### Frontend (Flutter)
- **Framework**: Flutter 3.10+
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **Image Caching**: cached_network_image
- **Charts**: fl_chart
- **PDF**: pdf, printing
- **Animations**: animate_do, lottie, flutter_staggered_animations
- **UI Components**: shimmer, badges, smooth_page_indicator

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.x
- **Language**: Java 17+
- **Database**: MySQL 8.0
- **ORM**: JPA/Hibernate
- **Security**: Spring Security (JWT)
- **Build Tool**: Maven

### Database
- **RDBMS**: MySQL 8.0
- **Tables**: users, products, categories, orders, order_items, reviews, addresses

## 🚀 Cách chạy dự án

### 1. Cài đặt Database
```bash
# Import database
mysql -u root -p < database/ecommerce_db.sql
```

### 2. Chạy Backend
```bash
cd backend
mvn spring-boot:run
# Backend chạy tại: http://localhost:8080
```

### 3. Chạy Frontend
```bash
# Cài đặt dependencies
flutter pub get

# Chạy trên Windows
flutter run -d windows

# Chạy trên Android
flutter run -d android

# Chạy trên iOS
flutter run -d ios
```

## 📊 Thống kê dự án

- **Tổng số file Dart**: ~50 files
- **Tổng số file Java**: ~30 files
- **Tổng số dòng code**: ~15,000+ lines
- **Số màn hình**: 25+ screens
- **Số API endpoints**: 40+ endpoints
- **Số models**: 10+ models

## 📖 Tài liệu chi tiết

Xem các file sau để hiểu rõ hơn về từng phần:

1. **[FRONTEND_GUIDE.md](./FRONTEND_GUIDE.md)** - Hướng dẫn chi tiết Frontend
2. **[BACKEND_GUIDE.md](./BACKEND_GUIDE.md)** - Hướng dẫn chi tiết Backend
3. **[CODE_EXPLANATION/](./CODE_EXPLANATION/)** - Giải thích code từng file

## 👥 Vai trò & Quyền hạn

### Customer (Khách hàng)
- Email: `customer@example.com`
- Password: `password123`
- Quyền: Mua hàng, xem sản phẩm, đánh giá

### Admin (Quản trị viên)
- Email: `admin@example.com`
- Password: `admin123`
- Quyền: Quản lý sản phẩm, xem thống kê, quản lý đơn hàng

## 🔐 Bảo mật

- ✅ JWT Authentication
- ✅ Password hashing (BCrypt)
- ✅ Role-based access control (RBAC)
- ✅ Input validation
- ✅ SQL injection prevention (JPA)
- ✅ XSS protection

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập

### Products
- `GET /api/products` - Lấy danh sách sản phẩm
- `GET /api/products/{id}` - Lấy chi tiết sản phẩm
- `GET /api/products/featured` - Sản phẩm nổi bật
- `GET /api/products/search` - Tìm kiếm sản phẩm
- `POST /api/admin/products` - Tạo sản phẩm (Admin)
- `PUT /api/admin/products/{id}` - Cập nhật sản phẩm (Admin)
- `DELETE /api/admin/products/{id}` - Xóa sản phẩm (Admin)

### Orders
- `POST /api/orders` - Tạo đơn hàng
- `GET /api/orders/my-orders` - Lấy đơn hàng của tôi
- `GET /api/orders/{id}` - Chi tiết đơn hàng

### Cart
- `GET /api/cart` - Lấy giỏ hàng
- `POST /api/cart` - Thêm vào giỏ hàng
- `PUT /api/cart/{productId}` - Cập nhật số lượng
- `DELETE /api/cart/{productId}` - Xóa khỏi giỏ hàng

### Categories
- `GET /api/categories` - Lấy danh sách danh mục

### Reviews
- `GET /api/reviews/product/{productId}` - Lấy đánh giá sản phẩm
- `POST /api/reviews` - Tạo đánh giá

### Analytics (Admin)
- `GET /api/admin/analytics/overview` - Tổng quan thống kê
- `GET /api/admin/analytics/revenue` - Doanh thu theo thời gian

## 📱 Screenshots

(Xem thêm screenshots trong thư mục `docs/screenshots/`)

## 🐛 Known Issues

- File picker warning trên một số platform (không ảnh hưởng chức năng)
- Dark mode cần optimize thêm một số màn hình

## 🔮 Tính năng tương lai

- [ ] Payment gateway integration (VNPay, Momo)
- [ ] Push notifications
- [ ] Chat support
- [ ] Social login (Google, Facebook)
- [ ] Product recommendations (AI)
- [ ] Voucher/Coupon system
- [ ] Multi-vendor support

## 📞 Liên hệ & Hỗ trợ

- Email: support@ecommerce.com
- GitHub: [Repository URL]

---

**Phiên bản**: 1.0.0  
**Ngày cập nhật**: December 2, 2025  
**Tác giả**: Development Team
