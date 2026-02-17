import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'buyer_screens.dart';
import 'partner_screens.dart';
import 'admin_screens.dart';

// ═══════════════════════════════════════════════
//  SPLASH SCREEN
// ═══════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideUp = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeIn,
              child: Transform.translate(offset: Offset(0, _slideUp.value), child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset('assets/logo.png', width: 60, height: 60),
                ),
              ),
              const SizedBox(height: 24),
              Text('FoodLoop', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontSize: 36)),
              const SizedBox(height: 8),
              Text('Save Food. Save Money. Save Earth.', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  LOGIN SCREEN  (credential-based routing)
// ═══════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // Demo credentials
  static const _credentials = {
    'user@foodloop.com':    {'password': 'user123',    'role': 'Buyer'},
    'partner@foodloop.com': {'password': 'partner123', 'role': 'Partner'},
    'admin@foodloop.com':   {'password': 'admin123',   'role': 'Admin'},
  };

  void _login() {
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass  = _passCtrl.text.trim();

    final account = _credentials[email];
    if (account != null && account['password'] == pass) {
      Widget destination;
      switch (account['role']) {
        case 'Partner': destination = const PartnerShell(); break;
        case 'Admin':   destination = const AdminShell();   break;
        default:        destination = const BuyerShell();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid email or password', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      ));
    }
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/logo.png', width: 48, height: 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: Text('FoodLoop', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary))),
              const SizedBox(height: 48),

              Text('Welcome back', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text('Log in to save food & money 🌱', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 32),

              AppInputField(label: 'Email', hint: 'Enter your email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, controller: _emailCtrl),
              const SizedBox(height: 20),
              AppInputField(label: 'Password', hint: 'Enter your password', prefixIcon: Icons.lock_outline, obscureText: true, controller: _passCtrl),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Forgot Password?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(label: 'Log in', onPressed: _login),
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: RichText(
                    text: TextSpan(text: "Don't have an account? ", style: AppTextStyles.bodyMedium, children: [
                      TextSpan(text: 'Sign up', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Demo credentials card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Demo Credentials', style: AppTextStyles.titleMedium.copyWith(fontSize: 14, color: AppColors.primary)),
                    ]),
                    const SizedBox(height: 12),
                    _credRow(Icons.person, 'Buyer', 'user@foodloop.com', 'user123'),
                    const SizedBox(height: 8),
                    _credRow(Icons.storefront, 'Partner', 'partner@foodloop.com', 'partner123'),
                    const SizedBox(height: 8),
                    _credRow(Icons.admin_panel_settings, 'Admin', 'admin@foodloop.com', 'admin123'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _credRow(IconData icon, String role, String email, String pass) {
    return InkWell(
      onTap: () {
        _emailCtrl.text = email;
        _passCtrl.text = pass;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(role, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const Spacer(),
          Text('$email  /  $pass', style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textHint)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  REGISTER SCREEN
// ═══════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedRole = 'Buyer';

  void _register() {
    Widget destination;
    switch (_selectedRole) {
      case 'Partner': destination = const PartnerShell(); break;
      default: destination = const BuyerShell();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/logo.png', width: 48, height: 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: Text('FoodLoop', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary))),
              const SizedBox(height: 48),

              Text('Create account', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text('Join us and save good food 🌱', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 32),

              const AppInputField(label: 'Full Name', hint: 'Enter your full name', prefixIcon: Icons.person_outline),
              const SizedBox(height: 20),
              const AppInputField(label: 'Email', hint: 'Enter your email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              const AppInputField(label: 'Password', hint: 'Create a password', prefixIcon: Icons.lock_outline, obscureText: true),
              const SizedBox(height: 24),

              Text('I want to', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _roleOption(icon: Icons.shopping_bag_outlined, label: 'Buy Food', subtitle: 'Find surplus deals', value: 'Buyer'),
                  const SizedBox(width: 12),
                  _roleOption(icon: Icons.storefront_outlined, label: 'Sell Surplus', subtitle: 'List your offers', value: 'Partner'),
                ],
              ),
              const SizedBox(height: 32),

              PrimaryButton(label: 'Sign up', onPressed: _register),
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: RichText(
                    text: TextSpan(text: 'Already have an account? ', style: AppTextStyles.bodyMedium, children: [
                      TextSpan(text: 'Log in', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleOption({required IconData icon, required String label, required String subtitle, required String value}) {
    final selected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: selected ? AppColors.primary : AppColors.textHint),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.titleMedium.copyWith(fontSize: 14, color: selected ? AppColors.primary : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption.copyWith(color: selected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textHint), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
