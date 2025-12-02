import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..forward();
    _floatingController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await context.read<AppProvider>().login(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đăng nhập thành công! 🎉'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Email hoặc mật khẩu không đúng'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          ...List.generate(3, (i) => AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Positioned(
                left: [50, 250, 150][i] + (30 * _floatingController.value),
                top: [100, 300, 500][i] + (20 * _floatingController.value),
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: [120, 80, 100][i].toDouble(),
                    height: [120, 80, 100][i].toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: [AppTheme.primaryGradient, AppTheme.secondaryGradient, AppTheme.accentGradient][i],
                    ),
                  ),
                ),
              );
            },
          )),
          Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryColor.withOpacity(0.05), AppTheme.secondaryColor.withOpacity(0.05)])),
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
                        const SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 10 * _floatingController.value),
                              child: Hero(
                                tag: 'app_logo',
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient, boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 8))]),
                                  child: const Icon(Icons.shopping_bag_rounded, size: 50, color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                    const SizedBox(height: 32),
                    Text(AppLocalizations.of(context).welcomeBack, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context).loginToContinue, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecorationWithContext(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context).email, prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2))),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v!.isEmpty ? AppLocalizations.of(context).t('please_enter_email') : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context).password, prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.primaryColor), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2))),
                              obscureText: _obscurePassword,
                              validator: (v) => v!.length < 6 ? AppLocalizations.of(context).t('password_too_short') : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(AppLocalizations.of(context).login, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                        Text(AppLocalizations.of(context).t('dont_have_account') + ' ', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                        TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: Text(AppLocalizations.of(context).t('register_now'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
                      ],
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
