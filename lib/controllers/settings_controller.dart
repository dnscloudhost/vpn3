// lib/controllers/settings_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;    // ← اضافه شد
import '../models/app_settings.dart';
import '../services/app_settings_api.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../data/tz_country_map.dart';

/// Singleton برای مدیریت و دسترسی به تنظیمات اپ
class SettingsController {
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  /// مقداردهی می‌شود پس از فراخوانی load()
  late AppSettings settings;

  /// بارگذاری تنظیمات از سرور
  Future<void> load() async {
    try {
      settings = await AppSettingsApi.fetchSettings();
      debugPrint('>>> Loaded AppSettings: $settings');
      debugPrint('    includeEnabled: ${settings.includeEnabled}');
      debugPrint('    smartModeEnabled: ${settings.smartModeEnabled}');
      debugPrint('    includeTimezones: ${settings.includeTimezones}');
    } catch (e, st) {
      debugPrint('Error loading AppSettings: $e\n$st');
      // در صورت خطا یک نمونه‌ی پیش‌فرض بسازید
      settings = AppSettings.fromJson({
        // زمان‌بندی‌ها
        'connection_limit_hours':    null,
        'connection_limit_minutes':  null,
        'delay_before_connect':      null,
        'delay_before_disconnect':   null,
        'delay_before_splash_smc':   null,
        'delay_before_splash_smd':   null,
        // پینگ‌ها
        'splash_smc_ping_before_connect_enabled': false,
        'splash_smc_request_time':               null,
        'splash_smc_ping_after_connect_enabled':  false,
        'splash_smd_ping_before_connect_enabled': false,
        'splash_smd_request_time':               null,
        'splash_smd_ping_after_connect_enabled':  false,
        'normal_int_c_ping_before_connect_enabled': false,
        'normal_int_c_request_time':               null,
        'normal_int_c_ping_after_connect_enabled':  false,
        // قابلیت‌ها
        'include_timezones':           <String>[],
        'include_enabled':             false,
        'smart_mode_enabled':          false,
        'show_admob_ads':              false,
        'update_filter_enabled':       false,
        'auto_connect_enabled':        false,
        'gdpr_active':                 false,
        // لینک‌ها و متون
        'privacy_policy_link':         '',
        'app_version':                 '',
        'persian_update_text':         '',
        'english_update_text':         '',
        // یونیتی‌ادز
        'unityads_interstitial_connect_id':            '',
        'unityads_interstitial_disconnect_id':         '',
        'unityads_reward_interstitial_connect_id':     '',
        'unityads_reward_interstitial_disconnect_id':  '',
        'unityads_smart_interstitial_connect_id':      '',
        'unityads_smart_interstitial_disconnect_id':   '',
      });
    }
  }

  /// آیا Smart-mode از سرور فعال شده؟
  bool get smartModeEnabled => settings.smartModeEnabled;

  /// آیا include_mode از سرور فعال است؟
  bool get includeEnabled => settings.includeEnabled;

  /// لیست کدهای کشور برای Smart
  List<String> get includeTimezones => settings.includeTimezones;


  /// تشخیص کد کشور (۱: timezone، ۲: IP، ۳: locale)
  Future<String> detectUserCountryCode() async {
    // ۱) بر اساس منطقهٔ زمانی
    try {
      final tz = await FlutterTimezone.getLocalTimezone(); // مثل Asia/Tehran
      debugPrint('DetectCountry: timezone = $tz');

      final ccFromTz = getCountryForTZ(tz); // یا tzToCountry[tz]
      if (ccFromTz != null && ccFromTz.isNotEmpty) {
        debugPrint('DetectCountry: via timezone → $ccFromTz');
        return ccFromTz;
      }
    } catch (e) {
      debugPrint('DetectCountry: timezone lookup failed: $e');
    }


    // ۲. locale
    final localeCode = WidgetsBinding.instance.window.locale.countryCode;
    debugPrint('DetectCountry: locale = $localeCode');
    return (localeCode ?? '').toLowerCase();
  }

  /// آیا کاربر در یکی از کشورهای include شده است؟
  bool isSmartCountry(String countryCode) {
    if (!smartModeEnabled || !includeEnabled) return false;
    final code = countryCode.toLowerCase();
    final ok = includeTimezones.map((c) => c.toLowerCase()).contains(code);
    debugPrint('isSmartCountry($code) → $ok '
        '(smartMode=$smartModeEnabled, includeEnabled=$includeEnabled, list=$includeTimezones)');
    return ok;
  }
}
