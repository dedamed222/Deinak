import 'package:intl/intl.dart';

class FormatUtils {
  /// Formats a date using the provided pattern and 'ar' locale,
  /// but ensures all numerals are Latin (0-9).
  static String formatDate(DateTime date, String pattern,
      {String locale = 'ar'}) {
    String formatted = DateFormat(pattern, locale).format(date);
    return _toLatinNumerals(formatted);
  }

  /// Formats a double to a string with fixed decimals, ensures Latin numerals.
  /// (Though toStringAsFixed usually is Latin, this is for consistency).
  static String formatNumber(double number, {int decimals = 0}) {
    return _toLatinNumerals(number.toStringAsFixed(decimals));
  }

  static String _toLatinNumerals(String input) {
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(eastern[i], western[i]);
    }
    return result;
  }

  static String getDurationLabel(String key, dynamic l10n) {
    // Attempt to extract numeric days for a generic label (e.g., "15 days")
    final match = RegExp(r'^(\d+)').firstMatch(key);
    if (match != null) {
      final days = match.group(1);
      if (l10n.localeName == 'ar') {
        return '$days يوم';
      } else {
        return '$days jours';
      }
    }

    switch (key) {
      case 'أسبوع':
        return l10n.sevenDays;
      case 'أسبوعين':
        return l10n.twoWeeks;
      case 'شهر':
        return l10n.month;
      case 'شهرين':
        return l10n.twoMonths;
      case '3 أشهر':
        return l10n.threeMonths;
      case '6 أشهر':
        return l10n.sixMonths;
      default:
        return key;
    }
  }

  static String getCompanyLabel(String key, dynamic l10n) {
    switch (key) {
      case 'موريتل':
        return l10n.mauritel;
      case 'شنقيتل':
        return l10n.chinguitel;
      case 'ماتل':
        return l10n.mattel;
      case 'أخرى':
        return l10n.other;
      default:
        return key;
    }
  }
}
