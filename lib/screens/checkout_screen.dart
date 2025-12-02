import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'order_success_screen.dart';
import 'address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _couponController = TextEditingController();
  
  String _paymentMethod = 'COD';
  double _discount = 0;
  bool _isProcessing = false;
  late AnimationController _animController;
  
  List<Address> _savedAddresses = [];
  Address? _selectedAddress;
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _loadSavedAddresses();
  }
  
  Future<void> _loadSavedAddresses() async {
    final addresses = await AddressService.getMyAddresses();
    if (mounted) {
      setState(() {
        _savedAddresses = addresses;
        _isLoadingAddresses = false;
        // Tự động chọn địa chỉ mặc định
        _selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.isNotEmpty ? addresses.first : null as Address);
        if (_selectedAddress != null) {
          _fillAddressFields(_selectedAddress!);
        }
      });
    }
  }
  
  void _fillAddressFields(Address address) {
    _nameController.text = address.fullName;
    _phoneController.text = address.phone;
    _addressController.text = address.fullAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _couponController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    // TODO: Call API to validate coupon
    if (_couponController.text.toUpperCase() == 'WELCOME10') {
      final provider = context.read<AppProvider>();
      setState(() => _discount = provider.cartTotal * 0.1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Áp dụng mã giảm giá thành công!')]),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mã giảm giá không hợp lệ'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isProcessing = true);
    
    if (!mounted) return;
    
    final provider = context.read<AppProvider>();
    
    // Gọi API để lưu order vào MySQL
    final order = await provider.createOrderInBackend(
      shippingName: _nameController.text,
      shippingPhone: _phoneController.text,
      shippingAddress: _addressController.text,
      paymentMethod: _paymentMethod,
      discount: _discount,
      couponCode: _couponController.text.isNotEmpty ? _couponController.text : null,
    );
    
    setState(() => _isProcessing = false);
    
    if (!mounted) return;
    
    if (order != null) {
      // Đơn hàng đã được lưu vào MySQL thành công
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => OrderSuccessScreen(order: order),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Lỗi khi tạo đơn hàng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi khi tạo đơn hàng. Vui lòng thử lại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final subtotal = provider.cartTotal;
    final shippingFee = subtotal >= 500000 ? 0.0 : 30000.0;
    final total = subtotal - _discount + shippingFee;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildAnimatedSection(0, _buildShippingInfo()),
            const SizedBox(height: 16),
            _buildAnimatedSection(1, _buildPaymentMethod()),
            const SizedBox(height: 16),
            _buildAnimatedSection(2, _buildCouponSection()),
            const SizedBox(height: 16),
            _buildAnimatedSection(3, _buildOrderSummary(subtotal, shippingFee, total)),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(total),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.3 + index * 0.1), end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Interval(index * 0.1, 0.6 + index * 0.1, curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animController, curve: Interval(index * 0.1, 0.6 + index * 0.1)),
        ),
        child: child,
      ),
    );
  }


  Widget _buildShippingInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.location_on, color: AppTheme.primaryColor)),
            const SizedBox(width: 12),
            const Expanded(child: Text('Thông tin giao hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            if (_savedAddresses.isNotEmpty)
              TextButton.icon(
                onPressed: _showAddressSelector,
                icon: const Icon(Icons.list, size: 18),
                label: const Text('Chọn địa chỉ', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              ),
          ]),
          if (_isLoadingAddresses)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_savedAddresses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()));
                  _loadSavedAddresses();
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm địa chỉ mới'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          const SizedBox(height: 20),
          _buildTextField(_nameController, 'Họ và tên', Icons.person_outline, validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null),
          const SizedBox(height: 16),
          _buildTextField(_phoneController, 'Số điện thoại', Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? 'Số điện thoại không hợp lệ' : null),
          const SizedBox(height: 16),
          _buildTextField(_addressController, 'Địa chỉ giao hàng', Icons.home_outlined, maxLines: 2, validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null),
          const SizedBox(height: 16),
          _buildTextField(_noteController, 'Ghi chú (tùy chọn)', Icons.note_outlined, maxLines: 2),
        ],
      ),
    );
  }
  
  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  const Text('Chọn địa chỉ giao hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = _savedAddresses[index];
                  final isSelected = _selectedAddress?.id == address.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAddress = address;
                        _fillAddressFields(address);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Đã chọn địa chỉ giao hàng')),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Mặc định',
                                    style: TextStyle(color: AppTheme.successColor, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(address.phone, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(address.fullAddress, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()));
                    _loadSavedAddresses();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm địa chỉ mới'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[50],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.payment, color: AppTheme.accentColor)),
            const SizedBox(width: 12),
            const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          _buildPaymentOption('COD', 'Thanh toán khi nhận hàng', Icons.money),
          _buildPaymentOption('BANK_TRANSFER', 'Chuyển khoản ngân hàng', Icons.account_balance),
          _buildPaymentOption('E_WALLET', 'Ví điện tử', Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Theme.of(context).dividerColor, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.getSecondaryTextColor(context)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.primaryColor : null))),
          if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryColor),
        ]),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_offer, color: AppTheme.secondaryColor)),
            const SizedBox(width: 12),
            const Text('Mã giảm giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _applyCoupon,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Áp dụng'),
            ),
          ]),
          if (_discount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                const SizedBox(width: 8),
                Text('Giảm ${formatCurrency(_discount)}', style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double shippingFee, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long, color: AppTheme.warningColor)),
            const SizedBox(width: 12),
            const Text('Chi tiết đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          _buildSummaryRow('Tạm tính', formatCurrency(subtotal)),
          if (_discount > 0) _buildSummaryRow('Giảm giá', '-${formatCurrency(_discount)}', isDiscount: true),
          _buildSummaryRow('Phí vận chuyển', shippingFee == 0 ? 'Miễn phí' : formatCurrency(shippingFee), isFreeShip: shippingFee == 0),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              formatCurrency(total), 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppTheme.primaryColor 
                    : const Color(0xFF4338CA)
              )
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isFreeShip = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDiscount ? AppTheme.successColor : (isFreeShip ? AppTheme.accentColor : null))),
      ]),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))]
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _placeOrder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _isProcessing
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Đặt hàng - ${formatCurrency(total)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}
