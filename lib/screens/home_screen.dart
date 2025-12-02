import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/optimized_image.dart';
import '../widgets/admin_panel.dart';
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
  late PageController _bannerController;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
    );
    _fabController.forward();
    
    _bannerController = PageController();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _bannerController.hasClients) {
        final nextPage = (_currentBanner + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => _currentBanner = nextPage);
        _startBannerAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _buildCurrentScreen(provider),
          bottomNavigationBar: _buildBottomNav(provider),
          floatingActionButton: _currentIndex == 0
              ? ScaleTransition(
                  scale: _fabAnimation,
                  child: _buildCartFAB(provider),
                )
              : null,
        );
      },
    );
  }

  Widget _buildCartFAB(AppProvider provider) {
    return Container(
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
        onPressed: () => _navigateWithAnimation(const CartScreen()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Badge(
          isLabelVisible: provider.cartItemCount > 0,
          label: Text('${provider.cartItemCount}'),
          child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }


  void _navigateWithAnimation(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
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
    );
  }

  Widget _buildBottomNav(AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
              _buildNavItem(2, Icons.person_rounded, 'Tài khoản'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.grey[400] : AppTheme.textTertiary), 
              size: 24
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(AppProvider provider) {
    switch (_currentIndex) {
      case 0:
        return _buildHome(provider);
      case 1:
        return _buildCategories(provider);
      case 2:
        return _buildAccount(provider);
      default:
        return _buildHome(provider);
    }
  }

  Widget _buildHome(AppProvider provider) {
    if (provider.isLoading) {
      return const ShimmerHomeLoading();
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildBanner()),
          SliverToBoxAdapter(child: _buildCategorySection(provider)),
          SliverToBoxAdapter(child: _buildSectionTitle('🔥 Sản phẩm nổi bật', 'featured')),
          _buildHorizontalProductList(provider.featuredProducts),
          SliverToBoxAdapter(child: _buildSectionTitle('⭐ Bán chạy nhất', 'top-selling')),
          _buildHorizontalProductList(provider.topSellingProducts),
          SliverToBoxAdapter(child: _buildSectionTitle('🆕 Hàng mới về', 'new-arrivals')),
          _buildProductGrid(provider.newArrivals),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      title: GestureDetector(
        onTap: () => _navigateWithAnimation(const SearchScreen()),
        child: Hero(
          tag: 'search_bar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[800] 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[700]! 
                      : Colors.grey[200]!
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search, 
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[500], 
                    size: 20
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tìm kiếm sản phẩm...',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[400] 
                          : Colors.grey[500], 
                      fontSize: 14, 
                      fontWeight: FontWeight.normal
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_border, color: AppTheme.secondaryColor, size: 20),
          ),
          onPressed: () => _navigateWithAnimation(const WishlistScreen()),
        ),
        const SizedBox(width: 8),
      ],
    );
  }


  Widget _buildBanner() {
    final banners = [
      {'title': 'FLASH SALE', 'subtitle': 'Giảm đến 50%', 'desc': 'Khuyến mãi lớn cuối năm', 'gradient': AppTheme.primaryGradient, 'icon': Icons.flash_on_rounded},
      {'title': 'NEW ARRIVAL', 'subtitle': 'Sản phẩm mới', 'desc': 'Xu hướng thời trang 2024', 'gradient': AppTheme.secondaryGradient, 'icon': Icons.new_releases_rounded},
      {'title': 'FREE SHIP', 'subtitle': 'Miễn phí vận chuyển', 'desc': 'Đơn hàng từ 500K', 'gradient': AppTheme.accentGradient, 'icon': Icons.local_shipping_rounded},
    ];

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) => setState(() => _currentBanner = index),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return AnimatedBuilder(
                animation: _bannerController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_bannerController.position.haveDimensions) {
                    value = _bannerController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * (1 - Curves.easeOut.transform(value)),
                    ),
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: banner['gradient'] as LinearGradient,
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned(right: -30, bottom: -30, child: Icon(banner['icon'] as IconData, size: 150, color: Colors.white.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                child: Text(banner['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                              const SizedBox(height: 8),
                              Text(banner['subtitle'] as String, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(banner['desc'] as String, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _navigateWithAnimation(const FlashSaleScreen()),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Khám phá', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), SizedBox(width: 4), Icon(Icons.arrow_forward_rounded, size: 16)]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentBanner == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentBanner == index ? AppTheme.primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300]),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildCategorySection(AppProvider provider) {
    if (provider.categories.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: Text('Không có danh mục')));
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.categories.length,
        itemBuilder: (_, i) {
          final cat = provider.categories[i];
          return GestureDetector(
            onTap: () => _navigateWithAnimation(CategoryProductsScreen(categoryId: cat.id, categoryName: cat.name)),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Hero(
                    tag: 'category_${cat.id}',
                    child: CategoryImage(imageUrl: cat.imageUrl, size: 60),
                  ),
                  const SizedBox(height: 8),
                  Text(cat.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, String type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
            onPressed: () => _navigateWithAnimation(AllProductsScreen(title: title.replaceAll(RegExp(r'[^\w\s]'), '').trim(), type: type)),
            child: const Row(children: [Text('Xem tất cả'), SizedBox(width: 4), Icon(Icons.arrow_forward_ios, size: 12)]),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(List products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: Text('Không có sản phẩm'))));
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 268,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          physics: const BouncingScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (_, i) => Container(
            width: 165,
            margin: const EdgeInsets.only(right: 12),
            child: AnimatedProductCard(product: products[i], index: i),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: Text('Không có sản phẩm'))));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
        delegate: SliverChildBuilderDelegate((_, i) => AnimatedProductCard(product: products[i], index: i), childCount: products.length),
      ),
    );
  }


  Widget _buildCategories(AppProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.categories.length,
        itemBuilder: (_, i) {
          final cat = provider.categories[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (i * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shadowColor: AppTheme.primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => _navigateWithAnimation(CategoryProductsScreen(categoryId: cat.id, categoryName: cat.name)),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Hero(tag: 'category_${cat.id}', child: CategoryImage(imageUrl: cat.imageUrl, size: 60)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(cat.description ?? 'Khám phá ngay', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccount(AppProvider provider) {
    if (!provider.isLoggedIn) {
      return _buildLoginPrompt();
    }
    return _buildAccountContent(provider);
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.person_outline, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Chào mừng bạn! 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Đăng nhập để trải nghiệm đầy đủ', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 15)),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
              child: ElevatedButton.icon(
                onPressed: () => _navigateWithAnimation(const LoginScreen()),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountContent(AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 20),
        _buildUserHeader(provider),
        const SizedBox(height: 24),
        if (provider.isAdmin) ...[
          _buildAccountTile(
            Icons.admin_panel_settings,
            'Quản trị viên',
            () => _navigateWithAnimation(const AdminPanel()),
            isAdmin: true,
          ),
          const SizedBox(height: 8),
        ],
        _buildAccountTile(Icons.person_outline, 'Thông tin cá nhân', () => _navigateWithAnimation(const ProfileScreen())),
        _buildAccountTile(Icons.shopping_bag_outlined, 'Đơn hàng của tôi', () => _navigateWithAnimation(const OrdersScreen())),
        _buildAccountTile(Icons.favorite_outline, 'Yêu thích', () => _navigateWithAnimation(const WishlistScreen())),
        _buildAccountTile(Icons.shopping_cart_outlined, 'Giỏ hàng', () => _navigateWithAnimation(const CartScreen())),
        _buildAccountTile(Icons.location_on_outlined, 'Địa chỉ', () => _navigateWithAnimation(const AddressScreen())),
        _buildAccountTile(Icons.notifications_outlined, 'Thông báo', () => _navigateWithAnimation(const NotificationsScreen())),
        _buildAccountTile(Icons.settings_outlined, 'Cài đặt', () => _navigateWithAnimation(const SettingsScreen())),
        _buildAccountTile(Icons.help_outline, 'Trợ giúp', () => _navigateWithAnimation(const HelpScreen())),
        const Divider(height: 32),
        _buildAccountTile(Icons.logout, 'Đăng xuất', () {
          provider.logout();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đã đăng xuất'), backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
        }, isLogout: true),
      ],
    );
  }

  Widget _buildUserHeader(AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: provider.isAdmin ? AppTheme.primaryGradient : AppTheme.secondaryGradient),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
                  backgroundImage: provider.userAvatar != null ? NetworkImage(provider.userAvatar!) : null,
                  child: provider.userAvatar == null ? Text(
                    provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U', 
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? Colors.white : AppTheme.primaryColor
                    )
                  ) : null,
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
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
                        width: 2
                      )
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(provider.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(provider.userEmail, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(gradient: provider.isAdmin ? AppTheme.primaryGradient : AppTheme.accentGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(provider.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(provider.isAdmin ? 'Quản trị viên' : 'Khách hàng', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false, bool isAdmin = false}) {
    final color = isLogout ? Colors.red : (isAdmin ? AppTheme.warningColor : AppTheme.primaryColor);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: isAdmin ? 3 : 1,
        shadowColor: isAdmin 
            ? AppTheme.warningColor.withOpacity(0.3) 
            : (isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).cardColor,
        child: Container(
          decoration: isAdmin ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppTheme.warningColor.withOpacity(isDark ? 0.2 : 0.1), 
                AppTheme.primaryColor.withOpacity(isDark ? 0.2 : 0.1)
              ],
            ),
          ) : null,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isAdmin ? FontWeight.bold : FontWeight.w500,
                color: isLogout ? Colors.red : (isAdmin ? AppTheme.warningColor : null),
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: color),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
