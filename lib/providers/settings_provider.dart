import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

enum ThemeModeEnum { light, dark, system }

class SettingsProvider extends ChangeNotifier {
  ThemeModeEnum _themeMode = ThemeModeEnum.system;
  bool _pinEnabled = false;
  String _pin = '';
  bool _biometricEnabled = false;
  double _defaultProfitValue = 10.0;
  String _defaultProfitType = AppConstants.profitTypePercentage;
  String _locale = 'ar';

  final SharedPreferences? _prefs;

  SettingsProvider({SharedPreferences? prefs}) : _prefs = prefs {
    loadSettings();
  }

  ThemeModeEnum get themeMode => _themeMode;
  bool get pinEnabled => _pinEnabled;
  String get pin => _pin;
  bool get biometricEnabled => _biometricEnabled;
  double get defaultProfitValue => _defaultProfitValue;
  String get defaultProfitType => _defaultProfitType;
  String get locale => _locale;

  Future<void> loadSettings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _locale = prefs.getString('locale') ?? 'ar';
    final themeStr = prefs.getString(AppConstants.prefKeyThemeMode) ?? 'system';
    _themeMode = ThemeModeEnum.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeModeEnum.system,
    );
    _pinEnabled = prefs.getBool(AppConstants.prefKeyPinEnabled) ?? false;
    _pin = prefs.getString(AppConstants.prefKeyPin) ?? '';
    _biometricEnabled =
        prefs.getBool(AppConstants.prefKeyBiometricEnabled) ?? false;
    _defaultProfitValue =
        prefs.getDouble(AppConstants.prefKeyDefaultProfit) ?? 10.0;
    _defaultProfitType =
        prefs.getString(AppConstants.prefKeyDefaultProfitType) ??
            AppConstants.profitTypePercentage;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeEnum mode) async {
    _themeMode = mode;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setPin(String pin, bool enabled) async {
    _pin = pin;
    _pinEnabled = enabled;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyPin, pin);
    await prefs.setBool(AppConstants.prefKeyPinEnabled, enabled);
    notifyListeners();
  }

  Future<void> setBiometric(bool enabled) async {
    _biometricEnabled = enabled;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyBiometricEnabled, enabled);
    notifyListeners();
  }

  Future<void> setDefaultProfit(double value, String type) async {
    _defaultProfitValue = value;
    _defaultProfitType = type;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefKeyDefaultProfit, value);
    await prefs.setString(AppConstants.prefKeyDefaultProfitType, type);
    notifyListeners();
  }

  Future<void> setLocale(String langCode) async {
    _locale = langCode;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('locale', langCode);
    notifyListeners();
  }

  bool verifyPin(String entered) => entered == _pin;
}
