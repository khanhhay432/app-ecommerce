# 📱 HƯỚNG DẪN FRONTEND - FLUTTER

## 📂 Cấu trúc thư mục Frontend

```
lib/
├── config/
│   └── api_config.dart          # Cấu hình API base URL
├── l10n/
│   ├── app_localizations.dart   # Localization delegate
│   ├── translations_en.dart     # Bản dịch tiếng Anh
│   └── translations_vi.dart     # Bản dịch tiếng Việt
├── models/
│   ├── address.dart             # Model địa chỉ
│   ├── analytics.dart           # Model thống kê
│   ├── cart.dart                # Model giỏ hàng
│   ├── cart_item.dart           # Model item trong giỏ
│   ├── category.dart            # Model danh mục
│   ├── order.dart               # Model đơn hàng
│   ├── product.dart             # Model sản phẩm
│   ├── review.dart              # Model đánh giá
│   └── user.dart                # Model người dùng
├── providers/
│   ├── app_provider.dart        # Provider chính (state management)
│   ├── locale_provider.dart     # Provider ngôn ngữ
│   └── theme_provider.dart      # Provider theme (dark/light)
├── screens/
│   ├── admin/                   # Màn hình admin
│   │   ├── analytics_screen.dart
│   │   ├── edit_product_screen.dart
│   │   └── manage_products_screen.dart
│   ├── address_screen.dart
│   ├── all_products_screen.dart
│   ├── cart_screen.dart
│   ├── category_products_screen.dart
│   ├── change_password_screen.dart
│   ├── checkout_screen.dart
│   ├── flash_sale_screen.dart
│   ├── help_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── notifications_screen.dart
│   ├── order_detail_screen.dart
│   ├── order_success_screen.dart
│   ├── orders_screen.dart
│   ├── product_detail_screen.dart
│   ├── profile_screen.dart
│   ├── register_screen.dart
│   ├── review_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   └── wishlist_screen.dart
├── services/
│   ├── address_service.dart
│   ├── admin_product_service.dart
│   ├── analytics_service.dart
│   ├── api_service.dart         # Service chính gọi API
│   ├── auth_service.dart
│   ├── cart_service.dart
│   ├── category_service.dart
│   ├── image_service.dart
│   ├── order_service.dart
│   ├── pdf_service.dart
│   ├── product_service.dart
│   ├── review_service.dart
│   └── user_service.dart
├── theme/
│   └── app_theme.dart           # Theme configuration
├── utils/
│   └── currency_format.dart     # Format tiền tệ
├── widgets/
│   ├── admin_panel.dart
│   ├── animated_product_card.dart
│   ├── optimized_image.dart
│   ├── product_card.dart
│   ├── product_reviews.dart
│   └── shimmer_loading.dart
└── main.dart                    # Entry point
```

## 🎯 Các thành phần chính

### 1. main.dart - Entry Point
**Chức năng**: Điểm khởi đầu của ứng dụng
- Khởi tạo Flutter binding
- Setup system UI overlay
- Khởi tạo MultiProvider cho state management
- Cấu hình MaterialApp với theme và localization

### 2. State Management - Provider Pattern

#### app_provider.dart
**Vai trò**: Provider chính quản lý toàn bộ state của app
**Chức năng**:
- Quản lý trạng thái đăng nhập
- Quản lý thông tin user
- Quản lý danh sách sản phẩm
- Quản lý giỏ hàng (local + sync với backend)
- Quản lý đơn hàng
- Quản lý wishlist
- CRUD sản phẩm (admin)

#### theme_provider.dart
**Vai trò**: Quản lý theme (Dark/Light mode)
**Chức năng**:
- Toggle giữa dark và light mode
- Lưu preference vào SharedPreferences
- Cung cấp ThemeData cho MaterialApp

#### locale_provider.dart
**Vai trò**: Quản lý ngôn ngữ
**Chức năng**:
- Chuyển đổi giữa tiếng Việt và English
- Lưu preference vào SharedPreferences
- Cung cấp Locale cho MaterialApp

### 3. Models - Data Classes

Tất cả models đều có:
- Constructor với named parameters
- `fromJson()` factory constructor để parse JSON từ API
- `toJson()` method để convert sang JSON
- Các getter/setter cần thiết

### 4. Services - API Communication

#### api_service.dart
**Vai trò**: Service cơ bản nhất, xử lý HTTP requests
**Chức năng**:
- GET, POST, PUT, DELETE requests
- Quản lý JWT token
- Xử lý errors
- Base URL configuration

#### Các service khác
Mỗi service chuyên biệt cho một domain:
- `auth_service.dart`: Đăng ký, đăng nhập
- `product_service.dart`: CRUD sản phẩm
- `cart_service.dart`: Quản lý giỏ hàng
- `order_service.dart`: Tạo và quản lý đơn hàng
- v.v...

### 5. Screens - UI Screens

#### Cấu trúc chung của một screen:
```dart
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});
  
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // State variables
  
  @override
  void initState() {
    super.initState();
    // Initialize data
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: ...,
    );
  }
}
```

#### home_screen.dart
**Màn hình chính** với:
- Banner carousel (Flash Sale, New Arrival, Free Ship)
- Categories grid
- Featured products
- Top selling products
- New arrivals
- On sale products
- Bottom navigation bar

#### product_detail_screen.dart
**Chi tiết sản phẩm** với:
- Image carousel
- Product info (name, price, description)
- Add to cart button
- Reviews section
- Related products

#### cart_screen.dart
**Giỏ hàng** với:
- Danh sách items
- Tăng/giảm số lượng
- Xóa item
- Tổng tiền
- Checkout button

#### checkout_screen.dart
**Thanh toán** với:
- Form thông tin giao hàng
- Chọn phương thức thanh toán
- Áp dụng mã giảm giá
- Xác nhận đặt hàng

### 6. Widgets - Reusable Components

#### product_card.dart
Widget hiển thị sản phẩm dạng card với:
- Hình ảnh
- Tên sản phẩm
- Giá (có giá gốc nếu đang sale)
- Badge "Sale" nếu có
- Nút thêm vào giỏ hàng

#### shimmer_loading.dart
Widget hiển thị loading skeleton với hiệu ứng shimmer

#### optimized_image.dart
Widget tối ưu hiển thị ảnh với:
- Cached network image
- Placeholder khi loading
- Error widget khi load fail

### 7. Theme - Styling

#### app_theme.dart
**Cấu hình theme** với:
- Colors (primary, secondary, accent, etc.)
- Gradients
- Light theme configuration
- Dark theme configuration
- Text styles
- Button styles
- Input decoration
- Helper methods cho theme-aware colors

**Màu sắc chính**:
- Primary: `#667EEA` (Xanh tím)
- Secondary: `#FF6B9D` (Hồng)
- Accent: `#4FD1C7` (Xanh ngọc)
- Success: `#48BB78` (Xanh lá)
- Warning: `#ED8936` (Cam)
- Error: `#E53E3E` (Đỏ)

### 8. Localization - Đa ngôn ngữ

#### app_localizations.dart
Delegate cho localization system

#### translations_vi.dart & translations_en.dart
Chứa tất cả text trong app bằng 2 ngôn ngữ

**Cách sử dụng**:
```dart
AppLocalizations.of(context).translate('key')
```

## 🔄 Data Flow

```
User Action (UI)
    ↓
Screen calls Provider method
    ↓
Provider calls Service
    ↓
Service calls API (HTTP)
    ↓
Backend processes request
    ↓
Response returns to Service
    ↓
Service parses JSON to Model
    ↓
Provider updates state
    ↓
UI rebuilds (notifyListeners)
```

## 🎨 UI/UX Features

### Animations
- Fade in/out
- Slide transitions
- Scale animations
- Shimmer loading
- Staggered animations
- Hero animations (product images)

### Responsive Design
- Adaptive layouts
- MediaQuery for screen sizes
- Flexible widgets
- GridView với crossAxisCount động

### Performance Optimizations
- Image caching
- Lazy loading
- Pagination (có thể thêm)
- Debouncing search
- Optimized rebuilds với Consumer

## 📦 Dependencies chính

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  http: ^1.1.0                  # HTTP client
  shared_preferences: ^2.2.2    # Local storage
  cached_network_image: ^3.3.0  # Image caching
  flutter_rating_bar: ^4.0.1    # Rating widget
  intl: ^0.20.2                 # Internationalization
  shimmer: ^3.0.0               # Shimmer effect
  animate_do: ^3.3.4            # Animations
  lottie: ^3.1.0                # Lottie animations
  fl_chart: ^0.66.2             # Charts
  pdf: ^3.10.7                  # PDF generation
  printing: ^5.12.0             # PDF printing
  image_picker: ^1.0.7          # Image picker
```

## 🚀 Best Practices được áp dụng

1. **Separation of Concerns**: UI, Business Logic, Data riêng biệt
2. **DRY (Don't Repeat Yourself)**: Reusable widgets và functions
3. **State Management**: Provider pattern rõ ràng
4. **Error Handling**: Try-catch và user-friendly messages
5. **Loading States**: Shimmer và progress indicators
6. **Responsive Design**: Adaptive cho nhiều màn hình
7. **Code Organization**: Folder structure rõ ràng
8. **Naming Conventions**: Camel case, descriptive names
9. **Comments**: Giải thích logic phức tạp
10. **Performance**: Lazy loading, caching, optimized rebuilds

## 🔍 Debugging Tips

1. **Print statements**: Sử dụng `print()` để debug
2. **Flutter DevTools**: Inspect widget tree, performance
3. **Hot Reload**: `r` để reload nhanh
4. **Hot Restart**: `R` để restart app
5. **Debug Console**: Xem logs và errors
6. **Network Inspector**: Kiểm tra API calls

## 📚 Tài liệu tham khảo

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design](https://material.io/design)
- [Dart Language](https://dart.dev/guides)

---

**Xem tiếp**: [CODE_EXPLANATION/](./CODE_EXPLANATION/) để hiểu chi tiết code từng file
