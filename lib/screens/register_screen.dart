import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await context.read<AppProvider>().register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text, phone: _phoneController.text.trim());
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đăng ký thành công! 🎉'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đăng ký thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.accentColor.withOpacity(0.1)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic)),
              child: FadeTransition(
                opacity: _animController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.accentGradient, boxShadow: [BoxShadow(color: AppTheme.accentColor.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 8))]),
                        child: const Icon(Icons.person_add_rounded, size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Tạo tài khoản mới', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Đăng ký để bắt đầu mua sắm', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 15), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecorationWithContext(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(_nameController, 'Họ và tên', Icons.person_outline, validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null),
                            const SizedBox(height: 16),
                            _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? 'Email không hợp lệ' : null),
                            const SizedBox(height: 16),
                            _buildTextField(_phoneController, 'Số điện thoại', Icons.phone_outlined, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildTextField(_passwordController, 'Mật khẩu', Icons.lock_outline, isPassword: true, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), validator: (v) => v!.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null),
                            const SizedBox(height: 16),
                            _buildTextField(_confirmPasswordController, 'Xác nhận mật khẩu', Icons.lock_outline, isPassword: true, obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm), validator: (v) => v != _passwordController.text ? 'Mật khẩu không khớp' : null),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.accentColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Đã có tài khoản? ', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                        TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, bool isPassword = false, bool obscure = false, VoidCallback? onToggle, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.accentColor),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.accentColor), onPressed: onToggle) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accentColor, width: 2)),
      ),
    );
  }
}
