import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> _addresses = [
    {'id': 1, 'name': 'Nhà', 'recipient': 'Nguyễn Văn A', 'phone': '0912345678', 'address': '123 Nguyễn Huệ, Quận 1, TP.HCM', 'isDefault': true},
    {'id': 2, 'name': 'Công ty', 'recipient': 'Nguyễn Văn A', 'phone': '0912345678', 'address': '456 Lê Lợi, Quận 3, TP.HCM', 'isDefault': false},
  ];

  void _showAddressForm({Map<String, dynamic>? address}) {
    final nameController = TextEditingController(text: address?['recipient'] ?? '');
    final phoneController = TextEditingController(text: address?['phone'] ?? '');
    final addressController = TextEditingController(text: address?['address'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ tên người nhận')),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Địa chỉ'), maxLines: 2),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(address == null ? 'Đã thêm địa chỉ!' : 'Đã cập nhật!'), backgroundColor: Colors.green));
              },
              child: Text(address == null ? 'Thêm địa chỉ' : 'Lưu'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ của tôi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (_, i) => _buildAddressCard(_addresses[i]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm địa chỉ'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(address['name'], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                if (address['isDefault']) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Mặc định', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showAddressForm(address: address)),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            Text(address['recipient'], style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(address['phone'], style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(address['address'], style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
