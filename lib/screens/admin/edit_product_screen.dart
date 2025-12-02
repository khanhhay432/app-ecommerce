import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/image_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  
  late int _selectedCategoryId;
  late bool _isFeatured;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _originalPriceController = TextEditingController(
      text: widget.product.originalPrice?.toString() ?? ''
    );
    _stockController = TextEditingController(text: widget.product.stockQuantity.toString());
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
    _selectedCategoryId = widget.product.categoryId;
    _isFeatured = widget.product.isFeatured;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Upload ảnh mới nếu có
      String imageUrl = _imageUrlController.text.trim();
      if (_selectedImage != null) {
        print('📸 Uploading new image...');
        final uploadedUrl = await ImageService.uploadImage(_selectedImage!);
        if (uploadedUrl == null) {
          throw Exception('Upload ảnh thất bại');
        }
        imageUrl = uploadedUrl;
        print('✅ Image uploaded: $imageUrl');
      }
      
      final provider = context.read<AppProvider>();
      final category = provider.categories.firstWhere((c) => c.id == _selectedCategoryId);
      
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        originalPrice: _originalPriceController.text.isNotEmpty 
            ? double.parse(_originalPriceController.text) 
            : null,
        stockQuantity: int.parse(_stockController.text),
        soldQuantity: widget.product.soldQuantity,
        imageUrl: imageUrl,
        isFeatured: _isFeatured,
        categoryId: _selectedCategoryId,
        categoryName: category.name,
        averageRating: widget.product.averageRating,
        reviewCount: widget.product.reviewCount,
      );
      
      final success = await provider.updateProduct(updatedProduct);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        if (success) {
          await provider.refreshData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã cập nhật sản phẩm thành công!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Lỗi khi cập nhật sản phẩm'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
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
      appBar: AppBar(
        title: const Text('Sửa sản phẩm'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Tên sản phẩm',
                icon: Icons.shopping_bag,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Mô tả sản phẩm',
                icon: Icons.description,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Giá bán',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      label: 'Giá gốc (tùy chọn)',
                      icon: Icons.money_off,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _stockController,
                label: 'Số lượng tồn kho',
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập số lượng' : null,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationWithContext(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hình ảnh sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
                          : Image.network(
                              _imageUrlController.text,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Đổi ảnh'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (_selectedImage != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => setState(() => _selectedImage = null),
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Hoặc', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _imageUrlController,
                      label: 'Nhập URL hình ảnh',
                      icon: Icons.link,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationWithContext(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<AppProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: provider.categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategoryId = value!);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecorationWithContext(context),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.warningColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sản phẩm nổi bật',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                    Switch(
                      value: _isFeatured,
                      onChanged: (value) => setState(() => _isFeatured = value),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Cập nhật sản phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: AppTheme.cardDecorationWithContext(context),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
