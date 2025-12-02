import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/image_service.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _nameController.text = provider.userName;
    _phoneController.text = provider.currentUser?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ tên')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload avatar nếu có
      String? avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await ImageService.uploadImage(_selectedImage!);
      }

      // Update profile
      final user = await UserService.updateProfile(
        fullName: _nameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        avatarUrl: avatarUrl,
      );

      if (user != null && mounted) {
        // Update provider
        context.read<AppProvider>().updateUserInfo(user);
        
        setState(() {
          _isEditing = false;
          _isSaving = false;
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Cập nhật thành công!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? 'Hủy' : 'Sửa', style: const TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              // Avatar section
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (provider.userAvatar != null ? NetworkImage(provider.userAvatar!) : null),
                          child: _selectedImage == null && provider.userAvatar == null
                              ? Text(provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))
                              : null,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Info cards
              _buildInfoCard('Email', provider.userEmail, Icons.email_outlined, editable: false),
              const SizedBox(height: 16),
              _buildEditableCard('Họ và tên', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildEditableCard('Số điện thoại', _phoneController, Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildInfoCard('Vai trò', provider.isAdmin ? 'Quản trị viên' : 'Khách hàng', Icons.badge_outlined, editable: false),
              if (_isEditing) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, {bool editable = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppTheme.primaryColor)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ])),
      ]),
    );
  }

  Widget _buildEditableCard(String label, TextEditingController controller, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppTheme.primaryColor)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
          const SizedBox(height: 4),
          _isEditing
              ? TextField(controller: controller, decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))
              : Text(controller.text.isEmpty ? 'Chưa cập nhật' : controller.text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ])),
      ]),
    );
  }
}
