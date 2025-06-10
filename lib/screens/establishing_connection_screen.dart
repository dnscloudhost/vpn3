// lib/screens/establishing_connection_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_v2ray/flutter_v2ray.dart';

import '../controllers/settings_controller.dart';
import '../services/admob_service.dart';
import '../data/locations.dart';
import 'connection_success_screen.dart';

class EstablishingConnectionScreen extends StatefulWidget {

  final FlutterV2ray flutterV2ray;
  final LocationConfig config;
  final List<String> bypassedApps;
  final ValueChanged<LocationConfig>? onConnected;

  const EstablishingConnectionScreen({
    Key? key,
    required this.flutterV2ray,
    required this.config,
    required this.bypassedApps,
    this.onConnected,
  }) : super(key: key);

  @override
  State<EstablishingConnectionScreen> createState() =>
      _EstablishingConnectionScreenState();
}


class _EstablishingConnectionScreenState
    extends State<EstablishingConnectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 2),
    )..repeat();

    // شبیه‌سازی فرآیند اتصال
    _simulateConnectionProcess();
  }

  @override
  void dispose() {

    _controller.dispose();
    super.dispose();
  }


  Future<void> _simulateConnectionProcess() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) await _startConnectionProcess();
  }

  Future<void> _startConnectionProcess() async {
    final reachable = await _checkServerReachable(widget.config.link);
    if (!mounted) return;
    if (!reachable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server is unreachable')),
      );
      Navigator.pop(context);
      return;
    }

    final ok = await _connectToConfig(widget.config);
    if (!mounted) return;
    if (!ok) {
      Navigator.pop(context);
      return;
    }

    // Test connectivity through the VPN before proceeding
    final connected = await _testVpnConnection();
    if (!mounted) return;
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to establish VPN connection')),
      );
      await widget.flutterV2ray.stopV2Ray();
      Navigator.pop(context);
      return;
    }

    widget.onConnected?.call(widget.config);
    await Future.delayed(const Duration(seconds: 2));
    if (SettingsController.instance.settings.showAdmobAds) {
      await AdMobService.instance.showConnectAd();
      AdMobService.instance.loadInterstitial(AdSlot.connectInterstitial);
    }
    if (mounted) {
      // پس از اتمام "فرآیند اتصال"، به صفحه موفقیت بروید
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConnectionSuccessScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // تعریف رنگ‌ها

    const backgroundColor = Color(0xFF0F142E);
    const iconCircleColor = Color(0xFF1B3A5A);
    const iconColor = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mahan VPN',
          style: TextStyle(

            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // برای حذف دکمه بازگشت
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // ویجت انیمیشن چرخش
            RotationTransition(
              turns: _controller,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconCircleColor,
                ),
                child: const Icon(

                  Icons.vpn_key_outlined,
                  color: iconColor,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // متن‌های وضعیت
            const Text(
              'Establishing Secure Connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait while we connect to our premium\nservers',
              textAlign: TextAlign.center,
              style: TextStyle(

                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ad will be shown shortly...',
              style: TextStyle(

                color: Colors.white54,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(flex: 4),
            // جایگاه تبلیغ
            Container(
              height: 60,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(

                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Ad Space',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Future<bool> _checkServerReachable(String link) async {
    try {
      final uri = Uri.parse(Uri.decodeFull(link.trim()));
      final socket = await Socket.connect(
        uri.host,
        uri.port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _testVpnConnection() async {
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


  Future<bool> _connectToConfig(LocationConfig cfg) async {
    // ensure core is initialized for a fresh connection
    await widget.flutterV2ray.initializeV2Ray(
      notificationIconResourceType: 'mipmap',
      notificationIconResourceName: 'ic_launcher',
    );
    final granted = await widget.flutterV2ray.requestPermission();
    if (!granted) return false;

    // stop any existing tunnel before starting a new one
    await widget.flutterV2ray.stopV2Ray();

    final link = Uri.decodeFull(cfg.link.trim());
    final parsed = FlutterV2ray.parseFromURL(link);
    final config = _applyV2RayConfigTweaks(parsed.getFullConfiguration());

    try {
      await widget.flutterV2ray.startV2Ray(
        remark: cfg.country,
        config: config,
        proxyOnly: false,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to connect: $e');
      return false;
    }
  }

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

    if (widget.bypassedApps.isNotEmpty) {
      final routing = Map<String, dynamic>.from(m['routing'] ?? {});
      routing['domainStrategy'] = routing['domainStrategy'] ?? 'IPIfNonMatch';
      final rules = List<Map<String, dynamic>>.from(routing['rules'] ?? []);
      rules.removeWhere(
            (r) =>
        r['type'] == 'field' &&
            r['outboundTag'] == 'direct' &&
            r.containsKey('app'),
      );
      rules.insert(0, {
        'type': 'field',
        'outboundTag': 'direct',
        'app': widget.bypassedApps,
      });
      routing['rules'] = rules;
      m['routing'] = routing;
    }

    return json.encode(m);
  }
}