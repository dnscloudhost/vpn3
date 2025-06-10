// lib/services/app_settings_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_settings.dart';

/// سرویس برای دریافت تنظیمات و feature flags اپ
class AppSettingsApi {
  static const String _baseUrl = 'https://vppanel.nikanspeed.online';
  static const String _token   = '29|2OFhfh8JG80CtPgYu8HDZcivlXWYGbfMTYwARV1u7d198bfd';

  /// دریافت تنظیمات اپ از API
  static Future<AppSettings> fetchSettings() async {
    final uri = Uri.parse('$_baseUrl/api/applications');
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    });
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch app settings: ${resp.statusCode}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    if (list.isEmpty) {
      throw Exception('No app settings returned');
    }
    return AppSettings.fromJson(list.first as Map<String, dynamic>);
  }
}
