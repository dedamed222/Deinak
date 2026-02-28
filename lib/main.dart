import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/loans_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/database_helper.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (non-blocking)
  NotificationService().initialize().catchError((e) {
    debugPrint('Failed to initialize notifications: $e');
  });

  // Initialize everything in parallel — Supabase MUST be awaited before runApp
  final results = await Future.wait(<Future<dynamic>>[
    initializeDateFormatting('ar', null),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    SharedPreferences.getInstance(),
    Supabase.initialize(
      url: 'https://etomcbikgddebbhbjhij.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0b21jYmlrZ2RkZWJiaGJqaGlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxOTMyMTMsImV4cCI6MjA4Nzc2OTIxM30.0p8gtlY_wT400Bf6ztFOXUSDBoWhkMyL5KD6NvSBPFI',
    ).then((_) async {
      // Initialize local DB for backwards-compat
      try {
        await DatabaseHelper().database;
      } catch (_) {}
    }),
  ]);
  final SharedPreferences prefs = results[2] as SharedPreferences;

  // Set system UI style (synchronous)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => LoansProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs: prefs)),
      ],
      child: const DeInakApp(),
    ),
  );
}

class DeInakApp extends StatefulWidget {
  const DeInakApp({super.key});

  @override
  State<DeInakApp> createState() => _DeInakAppState();
}

class _DeInakAppState extends State<DeInakApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider = context.read<SettingsProvider>();
      final authProvider = context.read<AuthProvider>();

      try {
        // Add a timeout to avoid hanging on splash screen forever
        await Future.wait([
          settingsProvider.loadSettings(),
          authProvider.checkSession(),
        ]).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Startup initialization timed out or failed: $e');
        // If it hangs, we manually set a fallback state if possible
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          authProvider.logout(); // Fallback to login screen
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    ThemeMode themeMode;
    switch (settings.themeMode) {
      case ThemeModeEnum.light:
        themeMode = ThemeMode.light;
        break;
      case ThemeModeEnum.dark:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return ScreenUtilInit(
      designSize: const Size(540, 1170),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          locale: Locale(settings.locale),
          home: _buildHome(auth),
        );
      },
    );
  }

  Widget _buildHome(AuthProvider auth) {
    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const SplashScreen();
      case AuthStatus.authenticated:
      case AuthStatus.guest:
        return const MainScreen();
      default:
        return const LoginScreen();
    }
  }
}
