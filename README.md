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

### 1.  Backend (Spring Boot)
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
```

### Flutter
File: `lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://YOUR_IP:8080/api';
```

## 🛠️ Tech Stack

| Frontend | Backend |
|----------|---------|
| Flutter 3.10+ | Spring Boot 3.x |
| Provider | Spring Security + JWT |
| HTTP, SharedPreferences | MySQL |
| PDF, Printing | Hibernate/JPA |

## 📝 License

MIT License
