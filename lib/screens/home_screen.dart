import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/admin_panel.dart';
import '../widgets/optimized_image.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'category_products_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import 'address_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'flash_sale_screen.dart';
import 'all_products_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _buildCurrentScreen(provider),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _currentIndex == 0 ? ScaleTransition(
            scale: _fabAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const CartScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: AppTheme.normalAnimation,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Badge(
                  isLabelVisible: provider.cartItemCount > 0,
                  label: Text('${provider.cartItemCount}'),
                  child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ) : null,
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
                  _buildNavItem(1, Icons.category_rounded, 'Danh mục'),
                  if (provider.isAdmin)
                    _buildNavItem(2, Icons.admin_panel_settings_rounded, 'Quản trị'),
                  _buildNavItem(provider.isAdmin ? 3 : 2, Icons.person_rounded, 'Tài khoản'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(AppProvider provider) {
    if (provider.isAdmin) {
      // Admin có 4 tab: Home, Categories, Admin Panel, Account
      switch (_currentIndex) {
        case 0:
          return _buildHome();
        case 1:
          return _buildCategories();
        case 2:
          return const AdminPanel();
        case 3:
          return _buildAccount();
        default:
          return _buildHome();
      }
    } else {
      // Customer có 3 tab: Home, Categories, Account
      switch (_currentIndex) {
        case 0:
          return _buildHome();
        case 1:
          return _buildCategories();
        case 2:
          return _buildAccount();
        default:
          return _buildHome();
      }
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textTertiary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text('Tìm kiếm sản phẩm...', style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
            ),
          ],
        ),
        SliverToBoxAdapter(child: _buildBanner()),
        SliverToBoxAdapter(child: _buildCategorySection()),
        SliverToBoxAdapter(child: _buildSectionTitle('🔥 Sản phẩm nổi bật')),
        _buildFeaturedProducts(),
        SliverToBoxAdapter(child: _buildSectionTitle('⭐ Bán chạy nhất')),
        _buildProductGrid(),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          final banners = [
            {
              'title': 'FLASH SALE',
              'subtitle': 'Giảm đến 50%',
              'description': 'Khuyến mãi lớn cuối năm',
              'gradient': AppTheme.primaryGradient,
              'icon': Icons.flash_on_rounded,
            },
            {
              'title': 'NEW ARRIVAL',
              'subtitle': 'Sản phẩm mới',
              'description': 'Xu hướng thời trang 2024',
              'gradient': AppTheme.secondaryGradient,
              'icon': Icons.new_releases_rounded,
            },
            {
              'title': 'FREE SHIP',
              'subtitle': 'Miễn phí vận chuyển',
              'description': 'Đơn hàng từ 500K',
              'gradient': AppTheme.accentGradient,
              'icon': Icons.local_shipping_rounded,
            },
          ];
          
          final banner = banners[index];
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: banner['gradient'] as LinearGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  right: -50,
                  bottom: -50,
                  child: Icon(
                    banner['icon'] as IconData,
                    size: 150,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                
                // Floating elements
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 60,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          banner['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        banner['subtitle'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner['description'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FlashSaleScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Khám phá ngay',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return Consumer<AppProvider>(
      builder: (_, provider, __) => SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: provider.categories.length,
          itemBuilder: (_, i) {
            final cat = provider.categories[i];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(categoryId: cat.id, categoryName: cat.name),
              )),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    CategoryImage(
                      imageUrl: cat.imageUrl,
                      size: 60,
                    ),
                    const SizedBox(height: 8),
                    Text(cat.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(title: title.replaceAll(RegExp(r'[^\w\s]'), '').trim()))), child: const Text('Xem tất cả')),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Consumer<AppProvider>(
      builder: (_, provider, __) => SliverToBoxAdapter(
        child: SizedBox(
          height: 268,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: provider.featuredProducts.length,
            itemBuilder: (_, i) => Container(
              width: 165,
              margin: const EdgeInsets.only(right: 8),
              child: AnimatedProductCard(product: provider.featuredProducts[i], index: i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<AppProvider>(
      builder: (_, provider, __) => SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            childAspectRatio: 0.68, 
            crossAxisSpacing: 12, 
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => AnimatedProductCard(product: provider.topSellingProducts[i], index: i),
            childCount: provider.topSellingProducts.length,
          ),
        ),
      ),
    );
  }


  Widget _buildCategories() {
    return Consumer<AppProvider>(
      builder: (_, provider, __) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.categories.length,
        itemBuilder: (_, i) {
          final cat = provider.categories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CategoryImage(
                imageUrl: cat.imageUrl,
                size: 60,
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${provider.getProductsByCategory(cat.id).length} sản phẩm'),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(categoryId: cat.id, categoryName: cat.name),
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccount() {
    return Consumer<AppProvider>(
      builder: (_, provider, __) {
        if (!provider.isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline, size: 60, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                const Text('Chào mừng bạn!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Đăng nhập để trải nghiệm đầy đủ', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  icon: const Icon(Icons.login),
                  label: const Text('Đăng nhập'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            
            // User profile section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: provider.isAdmin 
                              ? AppTheme.primaryGradient 
                              : AppTheme.secondaryGradient,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: provider.userAvatar != null 
                              ? NetworkImage(provider.userAvatar!) 
                              : null,
                          child: provider.userAvatar == null 
                              ? Text(
                                  provider.userName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (provider.isAdmin)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.userEmail,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: provider.isAdmin 
                          ? AppTheme.primaryGradient 
                          : AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          provider.isAdmin 
                              ? Icons.admin_panel_settings_rounded 
                              : Icons.person_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isAdmin ? 'Quản trị viên' : 'Khách hàng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildAccountTile(Icons.person_outline, 'Thông tin cá nhân', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            _buildAccountTile(Icons.shopping_bag_outlined, 'Đơn hàng của tôi', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
            _buildAccountTile(Icons.favorite_outline, 'Yêu thích', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()))),
            _buildAccountTile(Icons.shopping_cart_outlined, 'Giỏ hàng', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
            _buildAccountTile(Icons.location_on_outlined, 'Địa chỉ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()))),
            _buildAccountTile(Icons.notifications_outlined, 'Thông báo', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _buildAccountTile(Icons.settings_outlined, 'Cài đặt', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            _buildAccountTile(Icons.help_outline, 'Trợ giúp', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
            const Divider(height: 32),
            _buildAccountTile(Icons.logout, 'Đăng xuất', () {
              provider.logout();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng xuất'), backgroundColor: AppTheme.primaryColor));
            }, isLogout: true),
          ],
        );
      },
    );
  }

  Widget _buildAccountTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isLogout ? Colors.red : AppTheme.primaryColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isLogout ? Colors.red : null)),
        trailing: Icon(Icons.chevron_right, color: isLogout ? Colors.red : Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
