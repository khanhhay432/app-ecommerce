import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _couponController = TextEditingController();
  String _paymentMethod = 'COD';
  double _discount = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final provider = context.read<AppProvider>();
    final discount = provider.applyCoupon(_couponController.text);
    setState(() => _discount = discount);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(discount > 0 ? 'Áp dụng mã giảm giá thành công!' : 'Mã giảm giá không hợp lệ'),
      backgroundColor: discount > 0 ? Colors.green : Colors.red,
    ));
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    final provider = context.read<AppProvider>();
    final order = provider.createOrder(
      shippingName: _nameController.text,
      shippingPhone: _phoneController.text,
      shippingAddress: _addressController.text,
      paymentMethod: _paymentMethod,
      discount: _discount,
      couponCode: _couponController.text.isNotEmpty ? _couponController.text : null,
    );
    
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final subtotal = provider.cartTotal;
    final shipping = subtotal >= 500000 ? 0.0 : 30000.0;
    final total = subtotal - _discount + shipping;

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('📍 Thông tin giao hàng', [
              _buildTextField(_nameController, 'Họ tên người nhận', Icons.person_outline),
              _buildTextField(_phoneController, 'Số điện thoại', Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextField(_addressController, 'Địa chỉ giao hàng', Icons.location_on_outlined, maxLines: 2),
            ]),
            const SizedBox(height: 16),
            _buildSection('💳 Phương thức thanh toán', [
              _buildPaymentOption('COD', 'Thanh toán khi nhận hàng', Icons.money),
              _buildPaymentOption('BANK', 'Chuyển khoản ngân hàng', Icons.account_balance),
              _buildPaymentOption('EWALLET', 'Ví điện tử', Icons.account_balance_wallet),
            ]),
            const SizedBox(height: 16),
            _buildSection('🎁 Mã giảm giá', [
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _couponController, decoration: const InputDecoration(hintText: 'Nhập mã giảm giá'))),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _applyCoupon, child: const Text('Áp dụng')),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildOrderSummary(subtotal, _discount, shipping, total),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Đặt hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (v) => v!.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double discount, double shipping, double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Tóm tắt đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPriceRow('Tạm tính', subtotal),
            if (discount > 0) _buildPriceRow('Giảm giá', -discount, isDiscount: true),
            _buildPriceRow('Phí vận chuyển', shipping),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formatCurrency(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(isDiscount ? '-${formatCurrency(amount.abs())}' : formatCurrency(amount),
            style: TextStyle(color: isDiscount ? Colors.green : null, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
