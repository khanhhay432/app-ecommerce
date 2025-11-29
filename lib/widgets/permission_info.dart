import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';

class PermissionInfoDialog extends StatelessWidget {
  const PermissionInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Thông tin phân quyền',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Admin permissions
            _buildRoleSection(
              'Quản trị viên',
              Icons.admin_panel_settings,
              AppTheme.primaryColor,
              MockData.testAccounts[0]['permissions'] as List<String>,
            ),
            const SizedBox(height: 20),
            
            // Customer permissions
            _buildRoleSection(
              'Khách hàng',
              Icons.person,
              AppTheme.secondaryColor,
              MockData.testAccounts[1]['permissions'] as List<String>,
            ),
            const SizedBox(height: 24),
            
            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.accentColor, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hệ thống phân quyền đảm bảo bảo mật và kiểm soát truy cập phù hợp với từng vai trò.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection(String role, IconData icon, Color color, List<String> permissions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                role,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permissions.map((permission) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  _getPermissionDisplayName(permission),
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getPermissionDisplayName(String permission) {
    switch (permission) {
      case 'CREATE_PRODUCT':
        return 'Tạo sản phẩm';
      case 'UPDATE_PRODUCT':
        return 'Sửa sản phẩm';
      case 'DELETE_PRODUCT':
        return 'Xóa sản phẩm';
      case 'MANAGE_ORDERS':
        return 'Quản lý đơn hàng';
      case 'VIEW_ANALYTICS':
        return 'Xem thống kê';
      case 'VIEW_PRODUCTS':
        return 'Xem sản phẩm';
      case 'CREATE_ORDER':
        return 'Tạo đơn hàng';
      case 'VIEW_ORDERS':
        return 'Xem đơn hàng';
      default:
        return permission;
    }
  }
}

class PermissionChecker {
  static bool hasPermission(List<String>? userPermissions, String requiredPermission) {
    if (userPermissions == null) return false;
    return userPermissions.contains(requiredPermission);
  }

  static bool canCreateProduct(List<String>? permissions) {
    return hasPermission(permissions, 'CREATE_PRODUCT');
  }

  static bool canUpdateProduct(List<String>? permissions) {
    return hasPermission(permissions, 'UPDATE_PRODUCT');
  }

  static bool canDeleteProduct(List<String>? permissions) {
    return hasPermission(permissions, 'DELETE_PRODUCT');
  }

  static bool canManageOrders(List<String>? permissions) {
    return hasPermission(permissions, 'MANAGE_ORDERS');
  }

  static bool canViewAnalytics(List<String>? permissions) {
    return hasPermission(permissions, 'VIEW_ANALYTICS');
  }
}