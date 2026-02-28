import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class VerificationScreen extends StatefulWidget {
  final String username;
  const VerificationScreen({super.key, required this.username});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initSmsListener();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  Future<void> _initSmsListener() async {
    String? comingSms;
    try {
      comingSms = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      comingSms = 'Failed to get SMS.';
    }
    if (!mounted) return;

    if (comingSms != null && comingSms.contains(RegExp(r'\d{6}'))) {
      final otp = RegExp(r'\d{6}').firstMatch(comingSms)?.group(0);
      if (otp != null) {
        setState(() {
          _pinController.text = otp;
        });
        _verify();
      }
    }
  }

  void _startTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        timer.cancel();
      } else {
        setState(() => _resendTimer--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _pinController.text;
    if (code.length < 6) return;

    setState(() => _isLoading = true);
    final success =
        await context.read<AuthProvider>().verifyOTP(widget.username, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تفعيل الحساب بنجاح! يمكنك الآن تسجيل الدخول.')),
        );
        Navigator.pop(context); // Go back to Login
      } else {
        final error = context.read<AuthProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error ?? 'رمز التأكيد خاطئ'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _resend() async {
    if (_resendTimer > 0) return;
    try {
      await context.read<AuthProvider>().sendOTP(widget.username);
      _startTimer();
      _initSmsListener(); // Re-listen for the new SMS
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة إرسال الرمز')),
        );
      }
    } catch (e) {
      if (mounted) {
        final error = context.read<AuthProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'فشل إعادة إرسال الرمز'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 60.h,
      textStyle: TextStyle(
          fontSize: 22.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد رقم الهاتف')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Text(
              'أدخل رمز التأكيد المرسل إلى الرقم:',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.username,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            SizedBox(height: 40.h),
            Pinput(
              length: 6,
              controller: _pinController,
              focusNode: _focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primary),
                ),
              ),
              onCompleted: (pin) => _verify(),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تأكيد'),
              ),
            ),
            SizedBox(height: 24.h),
            TextButton(
              onPressed: _resendTimer == 0 ? _resend : null,
              child: Text(
                _resendTimer > 0
                    ? 'إعادة الإرسال خلال $_resendTimer ثانية'
                    : 'إعادة إرسال الرمز',
                style: TextStyle(
                    color: _resendTimer == 0 ? AppColors.primary : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
