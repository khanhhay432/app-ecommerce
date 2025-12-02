import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/currency_format.dart';
import '../order_detail_screen.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'ALL';

  final List<String> _statuses = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'PROCESSING',
    'SHIPPING',
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await OrderService.getMyOrders(); // TODO: Change to admin endpoint
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  List<Order> get _filteredOrders {
    if (_selectedStatus == 'ALL') return _orders;
    return _orders.where((o) => o.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Quản lý đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (_, i) => _buildOrderCard(_filteredOrders[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _statuses.length,
        itemBuilder: (_, i) {
          final status = _statuses[i];
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedStatus = status);
              },
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[100],
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.getSecondaryTextColor(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: AppTheme.getTertiaryTextColor(context)),
          const SizedBox(height: 16),
          Text(
            'Không có đơn hàng',
            style: TextStyle(fontSize: 18, color: AppTheme.getSecondaryTextColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        formatDate(order.createdAt),
                        style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Khách hàng:', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
                      Text(order.shippingName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(order.shippingPhone, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tổng tiền:', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
                    Text(
                      formatCurrency(order.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppTheme.primaryColor 
                            : const Color(0xFF4338CA),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showUpdateStatusDialog(order),
                    child: const Text('Cập nhật trạng thái'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                  ),
                  child: const Text('Chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING':
        color = AppTheme.warningColor;
        label = 'Chờ xác nhận';
        break;
      case 'CONFIRMED':
        color = Colors.blue;
        label = 'Đã xác nhận';
        break;
      case 'PROCESSING':
        color = Colors.orange;
        label = 'Đang xử lý';
        break;
      case 'SHIPPING':
        color = Colors.purple;
        label = 'Đang giao';
        break;
      case 'DELIVERED':
        color = AppTheme.successColor;
        label = 'Đã giao';
        break;
      case 'CANCELLED':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ALL':
        return 'Tất cả';
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'PROCESSING':
        return 'Đang xử lý';
      case 'SHIPPING':
        return 'Đang giao';
      case 'DELIVERED':
        return 'Đã giao';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  void _showUpdateStatusDialog(Order order) {
    String selectedStatus = order.status;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cập nhật trạng thái'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statuses
                .where((s) => s != 'ALL')
                .map((status) => RadioListTile<String>(
                      title: Text(_getStatusLabel(status)),
                      value: status,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setDialogState(() => selectedStatus = value!);
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Gọi API để cập nhật trạng thái
                final updatedOrder = await OrderService.updateOrderStatus(
                  order.id,
                  selectedStatus,
                );
                
                if (updatedOrder != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã cập nhật trạng thái')),
                  );
                  _loadOrders();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Lỗi khi cập nhật trạng thái'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}
