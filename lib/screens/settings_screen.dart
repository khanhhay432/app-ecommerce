import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          _buildSection('Thông báo', [
            _buildSwitchTile('Thông báo đẩy', 'Nhận thông báo về đơn hàng và khuyến mãi', Icons.notifications_outlined, _notifications, (v) => setState(() => _notifications = v)),
            _buildSwitchTile('Email thông báo', 'Nhận email về đơn hàng và khuyến mãi', Icons.email_outlined, _emailNotifications, (v) => setState(() => _emailNotifications = v)),
          ]),
          _buildSection('Giao diện', [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => _buildSwitchTile(
                'Chế độ tối',
                'Bật chế độ tối cho ứng dụng',
                Icons.dark_mode_outlined,
                themeProvider.isDarkMode,
                (v) => themeProvider.toggleTheme(),
              ),
            ),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) => _buildSelectTile(
                'Ngôn ngữ',
                localeProvider.isVietnamese ? 'Tiếng Việt' : 'English',
                Icons.language,
                () => _showLanguageDialog(localeProvider),
              ),
            ),
          ]),
          _buildSection('Bảo mật', [
            _buildNavigationTile('Đổi mật khẩu', Icons.lock_outline, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
            }),
            _buildNavigationTile('Xác thực 2 bước', Icons.security, () {}),
          ]),
          _buildSection('Khác', [
            _buildNavigationTile('Điều khoản sử dụng', Icons.description_outlined, () {}),
            _buildNavigationTile('Chính sách bảo mật', Icons.privacy_tip_outlined, () {}),
            _buildNavigationTile('Về chúng tôi', Icons.info_outline, () => _showAboutDialog()),
            _buildNavigationTile('Đánh giá ứng dụng', Icons.star_outline, () {}),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => _buildNavigationTile(
                'Reset về chế độ sáng',
                Icons.refresh,
                () async {
                  await themeProvider.resetToLightMode();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Đã reset về chế độ sáng')),
                    );
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Phiên bản 1.0.0', style: TextStyle(color: AppTheme.getSecondaryTextColor(context)), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context))),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryColor),
    );
  }

  Widget _buildSelectTile(String title, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildNavigationTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (v) {
                localeProvider.setLocale(const Locale('vi'));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (v) {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Về ShopNow'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag, size: 60, color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text('ShopNow v1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Ứng dụng mua sắm trực tuyến hàng đầu Việt Nam', textAlign: TextAlign.center),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
      ),
    );
  }
}
