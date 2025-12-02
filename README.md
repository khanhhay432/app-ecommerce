# 🛍️ E-Commerce Flutter App

Ứng dụng thương mại điện tử full-stack với Flutter + Spring Boot + MySQL.

## ✨ Tính năng

### Người dùng
- 🔐 Đăng nhập/Đăng ký
- 🛒 Giỏ hàng (đồng bộ với backend)
- 📦 Đặt hàng và theo dõi
- ⭐ Đánh giá sản phẩm
- 📍 Quản lý địa chỉ giao hàng
- 🌙 Dark mode
- 🌐 Đa ngôn ngữ (Anh-Việt)
- 🔒 Đổi mật khẩu
- 📄 Xuất hóa đơn PDF

### Admin
- 📊 Dashboard analytics
- 📦 Quản lý sản phẩm
- 🏷️ Quản lý danh mục
- 📋 Quản lý đơn hàng
- 📸 Upload ảnh sản phẩm

## 🚀 Cài đặt

### 1. Backend (Spring Boot)
```bash
cd backend
mvn spring-boot:run
```

### 2. Database (MySQL)
```bash
mysql -u root -p < database/ecommerce_db.sql
```

### 3. Frontend (Flutter)
```bash
flutter pub get
flutter run
```

## 🔧 Cấu hình

### Backend
File: `backend/src/main/resources/application.yml`
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ecommerce_db
    username: root
    password: your_password

app:
  base-url: http://192.168.1.88  # Thay bằng IP máy bạn
```

### Flutter
File: `lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://192.168.1.88:8080/api';
```

## 👤 Tài khoản test

**Admin:**
- Email: admin@example.com
- Password: admin123

**User:**
- Email: user@example.com  
- Password: user123

## 📱 Screenshots

- Trang chủ với sản phẩm nổi bật
- Giỏ hàng và thanh toán
- Quản lý đơn hàng
- Dark mode
- Đa ngôn ngữ

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.10+
- Provider (State management)
- HTTP, SharedPreferences
- PDF, Printing

**Backend:**
- Spring Boot 3.x
- Spring Security + JWT
- MySQL
- Hibernate/JPA

## 📝 License

MIT License
