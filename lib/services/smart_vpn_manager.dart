// lib/services/smart_vpn_manager.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../data/locations.dart';

/// مدیریت اتصال به سرورهای Smart پیش از نمایش تبلیغ
class SmartVpnManager {
  SmartVpnManager._() : _v2ray = FlutterV2ray(onStatusChanged: (_) {});
  static final SmartVpnManager instance = SmartVpnManager._();

  final FlutterV2ray _v2ray;
  List<LocationConfig> _smartServers = [];
  LocationConfig? _active;
  Timer? _autoDisconnectTimer;

  /// تعیین لیست سرورهای Smart
  void setSmartServers(List<LocationConfig> servers) {
    _smartServers = servers;
  }

  /// اتصال به اولین سرور Smart و زمان‌بندی قطع خودکار پس از ۵ دقیقه
  Future<void> connectSmart() async {
    if (_smartServers.isEmpty) return;
    final cfg = _smartServers.first;
    _active = cfg;

    final link = Uri.decodeFull(cfg.link.trim());
    final parsed = FlutterV2ray.parseFromURL(link);
    final config = _applyV2RayConfigTweaks(parsed.getFullConfiguration());
    await _v2ray.startV2Ray(
      remark: cfg.country,

      config: config,
      proxyOnly: true,
    );
    final ok = await _testConnection();
    if (!ok) {
      await disconnectSmart();
      return;
    }
    _autoDisconnectTimer?.cancel();
    _autoDisconnectTimer = Timer(const Duration(minutes: 5), disconnectSmart);
  }

  /// قطع اتصال Smart
  Future<void> disconnectSmart() async {
    await _v2ray.stopV2Ray();
    _active = null;
  }

  /// آیا Smart در حال حاضر متصل است؟
  bool get isConnected => _active != null;

  String _applyV2RayConfigTweaks(String rawJson) {
    final m = json.decode(rawJson) as Map<String, dynamic>;
    m['stats'] = m['stats'] ?? {};
    final policy = Map<String, dynamic>.from(m['policy'] ?? {});
    final levels = Map<String, dynamic>.from(policy['levels'] ?? {});
    final level0 = Map<String, dynamic>.from(levels['0'] ?? {});
    level0['statsUserUplink'] = true;
    level0['statsUserDownlink'] = true;
    levels['0'] = level0;
    policy['levels'] = levels;
    m['policy'] = policy;
    return json.encode(m);
  }

  Future<bool> _testConnection() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client
          .getUrl(Uri.parse('https://www.google.com/generate_204'));
      final resp = await req.close();
      await resp.drain();
      return resp.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}