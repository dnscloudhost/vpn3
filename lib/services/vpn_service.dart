// lib/services/vpn_service.dart

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

import '../data/locations.dart';    // your `allConfigs` + LocationConfig
import 'server_api.dart';          // ServerApi.getSmartServers(...)

/// Manages “smart” VPN connections via the flutter_v2ray plugin.
class VpnService {
  // Singleton
  VpnService._()
      : _v2ray = FlutterV2ray(
    onStatusChanged: (status) {
      debugPrint('V2Ray status: $status');
    },
  );
  static final VpnService instance = VpnService._();

  final FlutterV2ray _v2ray;
  bool _isInited = false;
  LocationConfig? _activeServer;
  Timer? _autoDisconnectTimer;


  /// Connect to the first “smart” server and auto-disconnect after 5m.

  Future<bool> connectSmart() async {
    // 1️⃣ pull the smart list
    final smartList = ServerApi.getSmartServers(allConfigs);
    if (smartList.isEmpty) {
      debugPrint('VpnService: no smart servers to connect');

      return false;
    }

    // pick the first one
    final cfg = smartList.first;
    _activeServer = cfg;

    // 2️⃣ parse your share/link (vmess/vless) into a full V2Ray config

    final parser = FlutterV2ray.parseFromURL(cfg.link.trim());
    final config = _applyV2RayConfigTweaks(parser.getFullConfiguration());

    // 3️⃣ ensure V2Ray is ready & permitted only once
    if (!_isInited) {
      await _v2ray.initializeV2Ray(
        notificationIconResourceType: 'mipmap',
        notificationIconResourceName: 'ic_launcher',
      );
      _isInited = true;
    }
    final granted = await _v2ray.requestPermission();
    if (!granted) {
      debugPrint('VPN permission denied');
      return false;
    }

    // 4️⃣ start the tunnel

    try {
      await _v2ray.startV2Ray(
        remark: cfg.country,
        config: config,
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
      );
    } catch (e) {
      debugPrint('startV2Ray failed: $e');
      return false;
    }

    // quick connectivity test
    final ok = await _testConnection();
    if (!ok) {
      await disconnectSmart();
      return false;
    }

    // 5️⃣ auto-disconnect in 5 minutes
    _autoDisconnectTimer?.cancel();
    _autoDisconnectTimer = Timer(
      const Duration(minutes: 5),
      disconnectSmart,
    );
    return true;
  }

  /// Tear down the tunnel immediately.
  Future<void> disconnectSmart() async {
    await _v2ray.stopV2Ray();
    _activeServer = null;
    _autoDisconnectTimer?.cancel();
  }

  /// Is there currently an active “smart” connection?
  bool get isConnected => _activeServer != null;

  String _applyV2RayConfigTweaks(String rawJson, {List<String>? bypassedApps}) {
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

    final apps = bypassedApps ?? [];
    if (apps.isNotEmpty) {
      final routing = Map<String, dynamic>.from(m['routing'] ?? {});
      routing['domainStrategy'] = routing['domainStrategy'] ?? 'IPIfNonMatch';
      final rules = List<Map<String, dynamic>>.from(routing['rules'] ?? []);
      rules.removeWhere((r) =>
      r['type'] == 'field' && r['outboundTag'] == 'direct' && r.containsKey('app'));
      rules.insert(0, {
        'type': 'field',
        'outboundTag': 'direct',
        'app': apps,
      });
      routing['rules'] = rules;
      m['routing'] = routing;
    }

    return jsonEncode(m);
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
