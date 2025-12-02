import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _enableNotifications = true;
  bool _autoConfirmOrders = false;
  bool _enableInventoryAlerts = true;
  double _lowStockThreshold = 10;
  String _defaultCurrency = 'VND';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store settings
            _buildSectionTitle('Cài đặt cửa hàng'),
            _buildSettingsCard([
              _buildSwitchTile(
                'Thông báo đẩy',
                'Nhận thông báo về đơn hàng mới',
                Icons.notifications,
                _enableNotifications,
                (value) => setState(() => _enableNotifications = value),
              ),
              _buildSwitchTile(
                'Tự động xác nhận đơn hàng',
                'Tự động xác nhận đơn hàng khi thanh toán thành công',
                Icons.auto_awesome,
                _autoConfirmOrders,
                (value) => setState(() => _autoConfirmOrders = value),
              ),
              _buildSwitchTile(
                'Cảnh báo tồn kho',
                'Thông báo khi sản phẩm sắp hết hàng',
                Icons.inventory,
                _enableInventoryAlerts,
                (value) => setState(() => _enableInventoryAlerts = value),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Inventory settings
            _buildSectionTitle('Quản lý kho'),
            _buildSettingsCard([
              _buildSliderTile(
                'Ngưỡng cảnh báo tồn kho',
                'Cảnh báo khi số lượng sản phẩm dưới mức này',
                Icons.warning,
                _lowStockThreshold,
                1,
                50,
                (value) => setState(() => _lowStockThreshold = value),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // System settings
            _buildSectionTitle('Hệ thống'),
            _buildSettingsCard([
              _buildDropdownTile(
                'Đơn vị tiền tệ',
                'Chọn đơn vị tiền tệ mặc định',
                Icons.attach_money,
                _defaultCurrency,
                ['VND', 'USD', 'EUR'],
                (value) => setState(() => _defaultCurrency = value!),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Data management
            _buildSectionTitle('Quản lý dữ liệu'),
            _buildSettingsCard([
              _buildActionTile(
                'Xuất dữ liệu',
                'Xuất dữ liệu sản phẩm và đơn hàng',
                Icons.download,
                () => _exportData(),
              ),
              _buildActionTile(
                'Sao lưu dữ liệu',
                'Tạo bản sao lưu toàn bộ dữ liệu',
                Icons.backup,
                () => _backupData(),
              ),
              _buildActionTile(
                'Xóa dữ liệu test',
                'Xóa tất cả dữ liệu mẫu (không thể hoàn tác)',
                Icons.delete_forever,
                () => _clearTestData(),
                isDestructive: true,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Save button
            Container(
              width: double.infinity,
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
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.getPrimaryTextColor(context),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecorationWithContext(context),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.getPrimaryTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getSecondaryTextColor(context),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.warningColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.getPrimaryTextColor(context),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  onChanged: onChanged,
                  activeColor: AppTheme.warningColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.accentColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.getPrimaryTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getSecondaryTextColor(context),
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.errorColor : AppTheme.successColor;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppTheme.errorColor : AppTheme.getPrimaryTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getSecondaryTextColor(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color,
      ),
      onTap: onTap,
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất dữ liệu'),
        content: const Text('Chức năng xuất dữ liệu sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _backupData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao lưu dữ liệu'),
        content: const Text('Đã tạo bản sao lưu thành công!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _clearTestData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu test'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả dữ liệu mẫu? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa dữ liệu test thành công!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu cài đặt thành công! 🎉'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
