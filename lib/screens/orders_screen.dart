import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../services/pdf_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    await context.read<AppProvider>().loadOrders();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Đơn hàng của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Tải lại từ MySQL',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.orders.isEmpty) {
                  return _buildEmptyOrders();
                }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                          ), 
                          blurRadius: 15, 
                          offset: const Offset(0, 5)
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(formatDate(order.createdAt), style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(order.status),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Text('${order.items.length} sản phẩm', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                                  const Spacer(),
                                  const Text('Tổng: ', style: TextStyle(color: Colors.grey)),
                                  Text(
                                    formatCurrency(order.total), 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? AppTheme.primaryColor 
                                          : const Color(0xFF4338CA), 
                                      fontSize: 16
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF2D2D2D) 
                                : Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 18, color: AppTheme.getSecondaryTextColor(context)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(order.shippingAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 13))),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
              },
            ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, size: 60, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          const Text('Chưa có đơn hàng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Hãy mua sắm để có đơn hàng đầu tiên', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING': color = AppTheme.warningColor; label = 'Chờ xác nhận'; break;
      case 'CONFIRMED': color = Colors.blue; label = 'Đã xác nhận'; break;
      case 'PROCESSING': color = Colors.orange; label = 'Đang xử lý'; break;
      case 'SHIPPING': color = Colors.purple; label = 'Đang giao'; break;
      case 'DELIVERED': color = AppTheme.successColor; label = 'Đã giao'; break;
      case 'CANCELLED': color = Colors.red; label = 'Đã hủy'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
