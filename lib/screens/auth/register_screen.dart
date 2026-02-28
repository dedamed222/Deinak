import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/validation_utils.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import 'package:country_picker/country_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String? _selectedCountry;

  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
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
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordsNotMatch)),
      );
      return;
    }

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectCountry)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final success = await auth.register(
        _phoneCtrl.text.trim(),
        _passwordCtrl.text,
        _nameCtrl.text.trim(),
        _selectedCountry!,
      );

      if (mounted) {
        if (success) {
          if (auth.status == AuthStatus.pendingVerification) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationScreen(username: _phoneCtrl.text.trim()),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.accountCreated),
                backgroundColor: Colors.green.shade700,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  initialPhone: _phoneCtrl.text.trim(),
                  initialPassword: _passwordCtrl.text,
                ),
              ),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(auth.errorMessage ??
                  AppLocalizations.of(context)!.registerError),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerError),
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                      // Header
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 24.sp),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerRight,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        l10n.registerTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28.sp,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Register Card
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
                              InkWell(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: true,
                                    onSelect: (Country country) {
                                      setState(() {
                                        _selectedCountry =
                                            "${country.flagEmoji} ${country.name}";
                                      });
                                    },
                                  );
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.countryLabel,
                                    prefixIcon:
                                        const Icon(Icons.public_outlined),
                                  ),
                                  child: Text(
                                      _selectedCountry ?? l10n.selectCountry),
                                ),
                              ),
                              SizedBox(height: 16.h),
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
                                controller: _nameCtrl,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  labelText: l10n.fullNameLabel,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  hintText: l10n.fullNameLabel,
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? l10n.fullNameRequired
                                    : null,
                              ),
                              SizedBox(height: 16.h),
                              FormField(
                                builder: (state) {
                                  return TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: l10n.password,
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),
                                    validator: (v) => v == null || v.length < 6
                                        ? l10n.passwordTooShort
                                        : null,
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                              TextFormField(
                                controller: _confirmPasswordCtrl,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: l10n.confirmPassword,
                                  prefixIcon:
                                      const Icon(Icons.lock_reset_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? l10n.confirmPasswordRequired
                                    : null,
                              ),
                              SizedBox(height: 32.h),
                              SizedBox(
                                height: 52.h,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 22.h,
                                          width: 22.w,
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white),
                                        )
                                      : Text(l10n.createAccount,
                                          style: TextStyle(fontSize: 18.sp)),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              const Divider(),
                              SizedBox(height: 8.h),
                              SizedBox(
                                height: 48.h,
                                child: OutlinedButton.icon(
                                  onPressed: _loginAsGuest,
                                  icon:
                                      const Icon(Icons.person_outline_rounded),
                                  label: Text(
                                    l10n.continueAsGuest,
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
