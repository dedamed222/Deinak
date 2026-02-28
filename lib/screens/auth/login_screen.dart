import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/validation_utils.dart';
import 'verification_screen.dart';
import 'register_screen.dart';
import '../home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialPhone;
  final String? initialPassword;

  const LoginScreen({
    super.key,
    this.initialPhone,
    this.initialPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.initialPhone ?? '';
    _passwordCtrl.text = widget.initialPassword ?? '';

    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final success = await auth.login(
        _phoneCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (mounted) {
        if (success) {
          // Handled by MainApp listener
        } else {
          if (auth.status == AuthStatus.pendingVerification) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationScreen(username: _phoneCtrl.text.trim()),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(auth.errorMessage ??
                    AppLocalizations.of(context)!.loginError),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loginError),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginAsGuest() async {
    await context.read<AuthProvider>().loginAsGuest();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A)
                  ]
                : [
                    AppColors.primary,
                    AppColors.primaryLight,
                    AppColors.secondary
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 100.r,
                        height: 100.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2.w),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 52.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 42.sp,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.appDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 48.h),

                      Container(
                        padding: EdgeInsets.all(28.w),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.login,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : AppColors.primary,
                                  fontSize: 22.sp,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: l10n.phoneNumber,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  hintText: l10n.enterPhoneNumber,
                                ),
                                validator: (v) => ValidationUtils.validatePhone(
                                  v,
                                  l10n.phoneRequired,
                                  l10n.invalidPhoneNumber,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  hintText: l10n.enterPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? l10n.passwordRequired
                                    : null,
                                onFieldSubmitted: (_) => _login(),
                              ),
                              SizedBox(height: 28.h),
                              SizedBox(
                                height: 52.h,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 22.h,
                                          width: 22.w,
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login_rounded,
                                                size: 22.sp),
                                            SizedBox(width: 8.w),
                                            Text(l10n.login,
                                                style:
                                                    TextStyle(fontSize: 18.sp)),
                                          ],
                                        ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterScreen()),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.noAccount,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.blue.shade300
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              const Divider(),
                              SizedBox(height: 8.h),
                              // ── زر التخطي ──
                              SizedBox(
                                height: 48.h,
                                child: OutlinedButton.icon(
                                  onPressed: _loginAsGuest,
                                  icon:
                                      const Icon(Icons.person_outline_rounded),
                                  label: Text(
                                    AppLocalizations.of(context)!
                                        .continueAsGuest,
                                    style: TextStyle(fontSize: 15.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                    ),
                                    foregroundColor: isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
