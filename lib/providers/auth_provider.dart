import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/database/user_repository.dart';
import '../core/services/sms_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  pendingVerification,
  guest,
  unauthenticated,
  error
}

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  final SharedPreferences? _prefs;

  AuthProvider({SharedPreferences? prefs}) : _prefs = prefs {
    checkSession();
  }

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _status == AuthStatus.guest;

  /// The effective user ID - 0 for guest, real ID for authenticated users
  int get effectiveUserId => _currentUser?.id ?? AppConstants.guestUserId;

  // Check saved session on startup
  Future<void> checkSession() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.prefKeyLoggedIn) ?? false;
      final isGuest = prefs.getBool(AppConstants.prefKeyIsGuest) ?? false;
      final userId = prefs.getInt(AppConstants.prefKeyUserId);

      if (isGuest) {
        _status = AuthStatus.guest;
        _currentUser = null;
      } else if (isLoggedIn && userId != null) {
        final user = await _userRepo.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
        } else {
          await _clearSession();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _errorMessage = null;

    try {
      final user = await _userRepo.authenticate(username.trim(), password);
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        await _saveSession(user);
        notifyListeners();
        return true;
      } else {
        // authenticate() returned null → username not found in DB
        _errorMessage =
            'اسم المستخدم غير موجود. تحقق من الاسم أو أنشئ حساباً جديداً.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      final err = e.toString();
      if (err.contains('not_verified')) {
        _status = AuthStatus.pendingVerification;
        _errorMessage = 'رقم الهاتف غير مفعل. يرجى إدخال رمز التأكيد.';
        try {
          await sendOTP(username.trim());
        } catch (otpErr) {
          debugPrint('Failed to send OTP during login: $otpErr');
          _errorMessage = _resolveErrorMessage(otpErr.toString());
        }
        notifyListeners();
        return false;
      }
      _errorMessage = _resolveErrorMessage(err);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String username, String password, String fullName, String country) async {
    try {
      final exists = await _userRepo.usernameExists(username.trim());
      if (exists) {
        _errorMessage = 'اسم المستخدم موجود بالفعل';
        notifyListeners();
        return false;
      }
      final id = await _userRepo.createUser(
          username.trim(), password, fullName, country);
      if (id > 0) {
        _status = AuthStatus.pendingVerification;
        try {
          await sendOTP(username.trim());
        } catch (otpErr) {
          debugPrint('Failed to send OTP during register: $otpErr');
          _errorMessage = _resolveErrorMessage(otpErr.toString());
        }
        notifyListeners();
        return true;
      }

      _errorMessage = 'فشل إنشاء الحساب. حاول مجدداً.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _resolveErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> sendOTP(String username) async {
    // Generate 6 digit code
    final code = (100000 + (DateTime.now().millisecond * 899))
        .toString()
        .padLeft(6, '0')
        .substring(0, 6);

    // CRITICAL for testing: Print code to console
    debugPrint('=========================================');
    debugPrint('DEINAK DEBUG - OTP FOR $username: $code');
    debugPrint('=========================================');

    // Always attempt to save to DB so developer can check Supabase if SMS fails
    await _userRepo.updateOTP(username, code);

    // Call the real SMS service
    final error = await SmsService.sendOTP(username, code);

    if (error != null) {
      // If it fails (like daily limit), we still want to throw so the UI shows the warning,
      // but the code is already in the DB for the developer to use.
      throw Exception('sms_error:$error');
    }
  }

  Future<bool> verifyOTP(String username, String code) async {
    _errorMessage = null;
    try {
      final success = await _userRepo.verifyOTP(username, code);
      if (success) {
        // Verification success - user can now log in
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      }
      _errorMessage = 'رمز التأكيد غير صحيح';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _resolveErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Maps typed error identifiers from [UserRepository] to Arabic messages.
  String _resolveErrorMessage(String error) {
    if (error.contains('wrong_password')) {
      return 'كلمة المرور غير صحيحة. تحقق من كلمة المرور وأعد المحاولة.';
    }
    if (error.contains('not_verified')) {
      return 'رقم الهاتف غير مفعل.';
    }
    if (error.contains('sms_error:limit_exceeded')) {
      return 'تم الوصول للحد الأقصى للرسائل اليوم. يرجى المحاولة غداً أو التواصل مع الدعم.';
    }
    if (error.contains('sms_error:')) {
      return 'فشل إرسال كود التأكيد. تحقق من رقم الهاتف أو حاول لاحقاً.';
    }
    if (error.contains('db_table_missing')) {
      return 'جداول قاعدة البيانات غير موجودة. يجب تشغيل SQL الإعداد في Supabase أولاً.';
    }
    if (error.contains('db_rls_error')) {
      return 'خطأ في صلاحيات Supabase (RLS). تأكد من تفعيل سياسات القراءة/الكتابة في لوحة Supabase.';
    }
    if (error.contains('db_duplicate')) {
      return 'اسم المستخدم موجود بالفعل.';
    }
    if (error.contains('db_network')) {
      return 'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت.';
    }
    if (error.contains('db_error:')) {
      final detail = error.replaceFirst('Exception: db_error:', '').trim();
      return 'خطأ في قاعدة البيانات: $detail';
    }
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  /// Login as guest - no account needed
  Future<void> loginAsGuest() async {
    _currentUser = null;
    _status = AuthStatus.guest;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyIsGuest, true);
    await prefs.remove(AppConstants.prefKeyLoggedIn);
    await prefs.remove(AppConstants.prefKeyUserId);
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearSession();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    final user =
        await _userRepo.authenticate(_currentUser!.username, oldPassword);
    if (user == null) {
      _errorMessage = 'كلمة المرور الحالية غير صحيحة';
      notifyListeners();
      return false;
    }
    return await _userRepo.updatePassword(_currentUser!.id!, newPassword);
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyLoggedIn, true);
    await prefs.setInt(AppConstants.prefKeyUserId, user.id!);
    await prefs.setString(AppConstants.prefKeyUsername, user.username);
    await prefs.remove(AppConstants.prefKeyIsGuest);
  }

  Future<void> _clearSession() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefKeyLoggedIn);
    await prefs.remove(AppConstants.prefKeyUserId);
    await prefs.remove(AppConstants.prefKeyUsername);
    await prefs.remove(AppConstants.prefKeyIsGuest);
  }
}
