import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    final addresses = await AddressService.getMyAddresses();
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await AddressService.deleteAddress(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã xóa địa chỉ')),
        );
        _loadAddresses();
      }
    }
  }

  Future<void> _setDefault(int id) async {
    final address = await AddressService.setDefaultAddress(id);
    if (address != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã đặt làm địa chỉ mặc định')),
      );
      _loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Địa chỉ của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAddresses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    itemBuilder: (_, i) => _buildAddressCard(_addresses[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Thêm địa chỉ'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_off, size: 60, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          const Text('Chưa có địa chỉ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Thêm địa chỉ để giao hàng nhanh hơn', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
            ), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Mặc định',
                    style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              const Spacer(),
              if (!address.isDefault)
                TextButton.icon(
                  onPressed: () => _setDefault(address.id),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Đặt mặc định', style: TextStyle(fontSize: 12)),
                ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showAddEditDialog(address: address),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () => _deleteAddress(address.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(address.phone, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(address.fullAddress, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showAddEditDialog({Address? address}) {
    final isEdit = address != null;
    final nameController = TextEditingController(text: address?.fullName);
    final phoneController = TextEditingController(text: address?.phone);
    final addressController = TextEditingController(text: address?.address);
    final cityController = TextEditingController(text: address?.city ?? 'TP.HCM');
    final districtController = TextEditingController(text: address?.district ?? 'Quận 1');
    final wardController = TextEditingController(text: address?.ward ?? 'Phường 1');
    bool isDefault = address?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Họ và tên *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ chi tiết *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wardController,
                        decoration: InputDecoration(
                          labelText: 'Phường/Xã',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: districtController,
                        decoration: InputDecoration(
                          labelText: 'Quận/Huyện',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (value) => setModalState(() => isDefault = value ?? false),
                  title: const Text('Đặt làm địa chỉ mặc định'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                        );
                        return;
                      }

                      Address? result;
                      if (isEdit) {
                        result = await AddressService.updateAddress(
                          id: address!.id,
                          fullName: nameController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                          city: cityController.text,
                          district: districtController.text,
                          ward: wardController.text,
                          isDefault: isDefault,
                        );
                      } else {
                        result = await AddressService.createAddress(
                          fullName: nameController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                          city: cityController.text,
                          district: districtController.text,
                          ward: wardController.text,
                          isDefault: isDefault,
                        );
                      }

                      if (result != null && mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? '✅ Đã cập nhật địa chỉ' : '✅ Đã thêm địa chỉ mới'),
                          ),
                        );
                        _loadAddresses();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEdit ? 'Cập nhật' : 'Lưu địa chỉ'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
