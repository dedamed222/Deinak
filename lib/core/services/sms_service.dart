import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'secrets.dart';

class SmsService {
  // Use config from secrets.dart (ignored by git)
  static final String _accountSid = SmsConfig.accountSid;
  static final String _authToken = SmsConfig.authToken;
  static final String _fromNumber = SmsConfig.fromNumber;

  /// Sends an OTP code via Twilio SMS.
  /// Formats for Mauritania (+222) automatically.
  /// Returns null on success, or an error string on failure.
  static Future<String?> sendOTP(String phoneNumber, String code) async {
    try {
      final message = 'كود ديناك الخاص بك هو: $code';

      // Format number for Twilio (must start with +)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length == 8) {
        cleanPhone = '+222$cleanPhone';
      } else if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+$cleanPhone';
      }

      final url =
          'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json';

      // Basic Auth Header
      final auth = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      debugPrint('SMS: Sending via Twilio to $cleanPhone');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': cleanPhone,
          'From': _fromNumber,
          'Body': message,
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Twilio Success: ${response.body}');
        return null; // Success
      } else {
        debugPrint('Twilio Failed (${response.statusCode}): ${response.body}');
        final errorCode = responseBody['code'];
        if (errorCode == 63038 || response.statusCode == 429) {
          return 'limit_exceeded';
        }
        return 'sms_failed';
      }
    } catch (e) {
      debugPrint('Twilio Error: $e');
      return 'network_error';
    }
  }
}
