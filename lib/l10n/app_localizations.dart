import 'package:flutter/material.dart';
import 'translations_en.dart';
import 'translations_vi.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': translationsEn,
    'vi': translationsVi,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Helper method to get translation with shorthand
  String t(String key) => translate(key);

  // Common
  String get appName => t('app_name');
  String get home => t('home');
  String get categories => t('categories');
  String get cart => t('cart');
  String get profile => t('profile');
  String get search => t('search');
  String get loading => t('loading');
  String get error => t('error');
  String get success => t('success');
  String get cancel => t('cancel');
  String get confirm => t('confirm');
  String get save => t('save');
  String get delete => t('delete');
  String get edit => t('edit');
  String get add => t('add');
  String get update => t('update');
  String get close => t('close');
  String get back => t('back');
  String get next => t('next');
  String get done => t('done');
  
  // Auth
  String get login => t('login');
  String get register => t('register');
  String get logout => t('logout');
  String get email => t('email');
  String get password => t('password');
  String get welcomeBack => t('welcome_back');
  String get loginToContinue => t('login_to_continue');
  
  // Products
  String get featuredProducts => t('featured_products');
  String get newArrivals => t('new_arrivals');
  String get bestSelling => t('best_selling');
  String get addToCart => t('add_to_cart');
  String get buyNow => t('buy_now');
  String get productDetails => t('product_details');
  
  // Cart
  String get shoppingCart => t('shopping_cart');
  String get cartEmpty => t('cart_empty');
  String get continueShopping => t('continue_shopping');
  String get subtotal => t('subtotal');
  String get total => t('total');
  String get checkout => t('checkout');
  
  // Orders
  String get myOrders => t('my_orders');
  String get orderDetails => t('order_details');
  String get orderSuccess => t('order_success');
  String get thankYou => t('thank_you');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
