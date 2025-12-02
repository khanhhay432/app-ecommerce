import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../widgets/optimized_image.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, 
        elevation: 0, 
        title: const Text('Chi tiết đơn hàng', style: TextStyle(fontWeight: FontWeight.bold))
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 16),
          _buildShippingCard(context),
          const SizedBox(height: 16),
          _buildProductsCard(context),
          const SizedBox(height: 16),
          _buildPaymentCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _getStatusColor(order.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_getStatusLabel(order.status), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _getStatusColor(order.status))),
              Text('Mã đơn: ${order.id}', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 13)),
            ])),
          ]),
          const SizedBox(height: 16),
          _buildTimeline(context),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final steps = ['Đặt hàng', 'Xác nhận', 'Đang giao', 'Hoàn thành'];
    final currentStep = _getCurrentStep(order.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentStep;
        final isLast = i == steps.length - 1;
        return Expanded(
          child: Row(children: [
            Column(children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: isActive ? AppTheme.primaryColor : (isDark ? Colors.grey[700] : Colors.grey[300])
                ),
                child: isActive ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
              ),
              const SizedBox(height: 4),
              Text(steps[i], style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primaryColor : AppTheme.getTertiaryTextColor(context))),
            ]),
            if (!isLast) Expanded(child: Container(height: 2, color: i < currentStep ? AppTheme.primaryColor : (isDark ? Colors.grey[700] : Colors.grey[300]))),
          ]),
        );
      }),
    );
  }

  Widget _buildShippingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_shipping, color: AppTheme.accentColor)),
          const SizedBox(width: 12),
          const Text('Thông tin giao hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.person_outline, order.shippingName, context),
        _buildInfoRow(Icons.phone_outlined, order.shippingPhone, context),
        _buildInfoRow(Icons.location_on_outlined, order.shippingAddress, context),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(icon, size: 20, color: AppTheme.getSecondaryTextColor(context)), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontSize: 14)))]),
    );
  }

  Widget _buildProductsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shopping_bag, color: AppTheme.primaryColor)),
          const SizedBox(width: 12),
          Text('Sản phẩm (${order.items.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        ...order.items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2D2D2D) 
                : Colors.grey[50], 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(imageUrl: item.product.imageUrl, width: 60, height: 60)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 4),
              Text('x${item.quantity}', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
            ])),
            Text(
              formatCurrency(item.subtotal), 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppTheme.primaryColor 
                    : const Color(0xFF4338CA)
              )
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.payment, color: AppTheme.warningColor)),
          const SizedBox(width: 12),
          const Text('Thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        _buildPaymentRow('Tạm tính', formatCurrency(order.subtotal), context),
        if (order.discount > 0) _buildPaymentRow('Giảm giá', '-${formatCurrency(order.discount)}', context, isDiscount: true),
        _buildPaymentRow('Phí vận chuyển', order.shippingFee == 0 ? 'Miễn phí' : formatCurrency(order.shippingFee), context),
        const Divider(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Tổng cộng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            formatCurrency(order.total), 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.primaryColor 
                  : const Color(0xFF4338CA)
            )
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2D2D2D) 
                : Colors.grey[50], 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Row(children: [
            Icon(Icons.credit_card, size: 20, color: AppTheme.getSecondaryTextColor(context)),
            const SizedBox(width: 12),
            Text(_getPaymentMethodLabel(order.paymentMethod), style: const TextStyle(fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPaymentRow(String label, String value, BuildContext context, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDiscount ? AppTheme.successColor : null)),
      ]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return AppTheme.warningColor;
      case 'CONFIRMED': return Colors.blue;
      case 'SHIPPING': return Colors.purple;
      case 'DELIVERED': return AppTheme.successColor;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING': return Icons.access_time;
      case 'CONFIRMED': return Icons.check_circle;
      case 'SHIPPING': return Icons.local_shipping;
      case 'DELIVERED': return Icons.done_all;
      case 'CANCELLED': return Icons.cancel;
      default: return Icons.info;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING': return 'Chờ xác nhận';
      case 'CONFIRMED': return 'Đã xác nhận';
      case 'SHIPPING': return 'Đang giao hàng';
      case 'DELIVERED': return 'Đã giao hàng';
      case 'CANCELLED': return 'Đã hủy';
      default: return status;
    }
  }

  int _getCurrentStep(String status) {
    switch (status) {
      case 'PENDING': return 0;
      case 'CONFIRMED': return 1;
      case 'SHIPPING': return 2;
      case 'DELIVERED': return 3;
      default: return 0;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'COD': return 'Thanh toán khi nhận hàng';
      case 'BANK_TRANSFER': return 'Chuyển khoản ngân hàng';
      case 'E_WALLET': return 'Ví điện tử';
      default: return method;
    }
  }
}
