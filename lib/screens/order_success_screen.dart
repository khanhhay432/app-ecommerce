import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import 'home_screen.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late Animation<double> _checkScale;
  late Animation<double> _checkRotation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _contentController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    
    _checkScale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _checkController, curve: Curves.elasticOut));
    _checkRotation = Tween<double>(begin: -0.5, end: 0).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack));
    
    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 400), () => _contentController.forward());
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.successColor.withOpacity(0.1), 
              Theme.of(context).scaffoldBackgroundColor
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Success animation
                AnimatedBuilder(
                  animation: _checkController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _checkScale.value,
                      child: Transform.rotate(angle: _checkRotation.value, child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.successColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 10)],
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 60),
                  ),
                ),
                const SizedBox(height: 32),
                // Content
                FadeTransition(
                  opacity: _contentController,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_contentController),
                    child: Column(
                      children: [
                        const Text('Đặt hàng thành công! 🎉', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Cảm ơn bạn đã mua hàng', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 16)),
                        const SizedBox(height: 32),
                        // Order info card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08
                                ), 
                                blurRadius: 20
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('Mã đơn hàng', widget.order.id, isBold: true),
                              const Divider(height: 24),
                              _buildInfoRow('Tổng tiền', formatCurrency(widget.order.total), isPrice: true),
                              _buildInfoRow('Thanh toán', _getPaymentMethodLabel(widget.order.paymentMethod)),
                              _buildInfoRow('Trạng thái', 'Đang xử lý', isStatus: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Buttons
                FadeTransition(
                  opacity: _contentController,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: widget.order))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Xem chi tiết đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: AppTheme.primaryColor),
                          ),
                          child: const Text('Tiếp tục mua sắm', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isPrice = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(value, style: const TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.w500, fontSize: 12)),
            )
          else
            Text(value, style: TextStyle(fontWeight: isBold || isPrice ? FontWeight.bold : FontWeight.w500, color: isPrice ? AppTheme.primaryColor : null, fontSize: isPrice ? 18 : null)),
        ],
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'COD': return 'Thanh toán khi nhận hàng';
      case 'BANK_TRANSFER': return 'Chuyển khoản';
      case 'E_WALLET': return 'Ví điện tử';
      default: return method;
    }
  }
}
