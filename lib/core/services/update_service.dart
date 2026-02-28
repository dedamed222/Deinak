import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';

class UpdateService {
  // Remote version file on GitHub
  static const String _versionUrl =
      'https://raw.githubusercontent.com/dedamed222/Deinak/main/version.json';

  /// Checks if a new version is available.
  /// Returns a map with 'updateAvailable', 'version', and 'url' if available.
  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        final remoteData = jsonDecode(response.body);
        final remoteVersion = remoteData['version'] as String;
        final downloadUrl = remoteData['url'] as String;

        final packageInfo = await PackageInfo.fromPlatform();
        final localVersion = packageInfo.version;

        if (_isNewerVersion(localVersion, remoteVersion)) {
          return {
            'updateAvailable': true,
            'version': remoteVersion,
            'url': downloadUrl,
            'notes': remoteData['notes'] ?? '',
          };
        }
      }
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
    return null;
  }

  /// Compares two version strings (e.g., '1.0.0' and '1.1.0')
  static bool _isNewerVersion(String local, String remote) {
    try {
      final localParts = local.split('.').map(int.parse).toList();
      final remoteParts = remote.split('.').map(int.parse).toList();

      for (var i = 0; i < remoteParts.length; i++) {
        if (i >= localParts.length) return true;
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }
    } catch (e) {
      debugPrint('Version Comparison Error: $e');
    }
    return false;
  }

  /// Triggers the OTA update process.
  static Stream<OtaEvent> performUpdate(String url) {
    return OtaUpdate().execute(
      url,
      destinationFilename: 'deinak_update.apk',
    );
  }
}
