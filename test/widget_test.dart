import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:deinak/main.dart';
import 'package:deinak/providers/auth_provider.dart';
import 'package:deinak/providers/loans_provider.dart';
import 'package:deinak/providers/settings_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LoansProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const DeInakApp(),
      ),
    );

    // Verify that our app starts. (Customized for Deinak)
    expect(find.text('دينك'), findsOneWidget);
  });
}
