// lib/screens/home_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/locations.dart';
import '../services/admob_service.dart';
import '../services/server_api.dart';
import '../controllers/settings_controller.dart';
import '../widgets/ad_preparing_overlay.dart';
import '../screens/establishing_connection_screen.dart';
import '../widgets/disconnect_confirmation_dialog.dart';
import '../widgets/app_drawer.dart';
import 'disconnection_success_screen.dart';
import 'locations_screen.dart';

import 'split_tunnel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // ... تمام متغیرهای شما بدون تغییر ...
  late final FlutterV2ray flutterV2ray;
  final ValueNotifier<V2RayStatus> status = ValueNotifier(V2RayStatus());
  String? coreVersion;
  Timer? _ticker;
  Duration _duration = Duration.zero;
  Timer? _limitTimer;
  String _currentServer = 'Select Server';
  String _currentCity = '';
  String? _currentLink;
  String _currentCode = 'default';
  final String vpnAppName = 'Mahan VPN';
  List<String> _bypassedAppPackages = [];

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // تمام منطق اصلی شما در initState دست نخورده باقی می‌ماند
    _init();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // ... تمام توابع منطقی شما تا متد build بدون تغییر ...
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _bypassedAppPackages = prefs.getStringList('bypassed_packages') ?? [];
    if (allConfigs.isNotEmpty) {
      final first = allConfigs.first;
      _currentServer = first.country;
      _currentCity = first.city;
      _currentLink = first.link;
      _currentCode = first.countryCode;
    }
    flutterV2ray = FlutterV2ray(onStatusChanged: (s) {
      if (!mounted) return;
      status.value = s;
      _handleTicker(s);
    });
    await flutterV2ray.initializeV2Ray(
      notificationIconResourceType: 'mipmap',
      notificationIconResourceName: 'ic_launcher',
    );
    if (!mounted) return;
    coreVersion = await flutterV2ray.getCoreVersion();
    setState(() {});
    final settings = SettingsController.instance.settings;
    if (settings.showAdmobAds) {
      AdMobService.instance
        ..loadInterstitial(AdSlot.splashOpen)
        ..loadInterstitial(AdSlot.connectInterstitial)
        ..loadInterstitial(AdSlot.disconnectInterstitial);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _limitTimer?.cancel();
    status.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTicker(V2RayStatus s) {
    _ticker?.cancel();
    if (s.state == 'CONNECTED') {
      _duration = Duration.zero;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _duration += const Duration(seconds: 1));
      });
    } else {
      _limitTimer?.cancel();
      setState(() => _duration = Duration.zero);
    }
  }

  Future<void> _toggleConnection() async {
    if (status.value.state == 'CONNECTED') {
      await _startDisconnectFlow();
    } else {
      await _startConnectFlow();
    }
  }

  Future<void> _startConnectFlow() async {
    final settings = SettingsController.instance.settings;
    if (_currentLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a server first.')),
      );
      return;
    }
    String link = _currentLink!;
    String remark = _currentServer;
    String code = _currentCode;
    String city = _currentCity;
    if (link == 'auto' && allConfigs.isNotEmpty) {
      final best = allConfigs.first;
      link = best.link;
      remark = best.country;
      code = best.countryCode;
      city = best.city;
    }
    final delayConnect = settings.delayBeforeConnect ?? 0;
    if (delayConnect > 0) {
      await Future.delayed(Duration(milliseconds: delayConnect));
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstablishingConnectionScreen(
          flutterV2ray: flutterV2ray,
          config: LocationConfig(
            id: -1,
            country: remark,
            city: city,
            link: link,
            countryCode: code,
            serverType: 'free',
          ),
          bypassedApps: _bypassedAppPackages,
          onConnected: (cfg) {
            setState(() {
              _currentServer = cfg.country;
              _currentCity = cfg.city;
              _currentLink = cfg.link;
              _currentCode = cfg.countryCode;
            });
            _scheduleLimitTimer();
          },
        ),
      ),
    );
  }

  Future<void> _startDisconnectFlow() async {
    final confirm = await showDisconnectConfirmationDialog(context);
    if (confirm != true) return;
    final settings = SettingsController.instance.settings;
    final delayDisc = settings.delayBeforeDisconnect ?? 0;
    if (delayDisc > 0) {
      await Future.delayed(Duration(milliseconds: delayDisc));
    }

    Future<void>? discAdLoad;
    if (settings.showAdmobAds) {
      discAdLoad =
          AdMobService.instance.loadInterstitial(AdSlot.disconnectInterstitial);
    }
    if (settings.showAdmobAds) {
      if (discAdLoad != null) await discAdLoad;
      await AdMobService.instance.showDisconnectAd();
    }
    Future<void>? pageFuture;
    if (mounted) {
      pageFuture = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DisconnectionSuccessScreen(),
        ),
      );
    }
    await flutterV2ray.stopV2Ray();
    if (settings.showAdmobAds) {
      unawaited(
        AdMobService.instance.loadInterstitial(AdSlot.connectInterstitial),
      );
    }
    if (pageFuture != null) await pageFuture;
  }

  void _scheduleLimitTimer() {
    _limitTimer?.cancel();
    final set = SettingsController.instance.settings;
    final dur = Duration(
      hours: set.connectionLimitHours ?? 0,
      minutes: set.connectionLimitMinutes ?? 0,
    );
    _limitTimer = Timer(dur, () {
      if (mounted && status.value.state == 'CONNECTED') {
        _startDisconnectFlow();
      }
    });
  }

  String _formatDuration(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:' +
          '${(d.inMinutes % 60).toString().padLeft(2, '0')}:' +
          '${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  String _formatBytes(int b) {
    if (b <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(b) / math.log(1024)).floor().clamp(0, units.length - 1);
    final value =
    i == 0 ? b.toString() : (b / math.pow(1024, i)).toStringAsFixed(1);
    return '$value ${units[i]}';
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
    if (_bypassedAppPackages.isNotEmpty) {
      final routing = Map<String, dynamic>.from(m['routing'] ?? {});
      routing['domainStrategy'] = routing['domainStrategy'] ?? 'IPIfNonMatch';
      final rules = List<Map<String, dynamic>>.from(routing['rules'] ?? []);
      rules.removeWhere((r) =>
      r['type'] == 'field' &&
          r['outboundTag'] == 'direct' &&
          r.containsKey('app'));
      rules.insert(0, {
        'type': 'field',
        'outboundTag': 'direct',
        'app': _bypassedAppPackages,
      });
      routing['rules'] = rules;
      m['routing'] = routing;
    }
    return jsonEncode(m);
  }

  Widget _buildFlag() {
    final code = _currentCode.toLowerCase();
    if (code == 'globe' || code == 'default' || code == 'error') {
      return const Icon(Icons.public_rounded, size: 38, color: Colors.white);
    }
    final path = 'assets/flags/$code.svg';
    return SvgPicture.asset(path, width: 38, height: 38);
  }

  // ===================================================================
  // ▼▼▼ بخش UI با آخرین تغییرات و رفع اشکالات ▼▼▼
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F142E);
    const accentColor = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,

      // 1️⃣ پراپرتی drawer اضافه شد
      drawer: const AppDrawer(),

      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // [BUG FIX] این ValueListenableBuilder به اینجا منتقل شد تا تمام ویجت‌های
          // وابسته به وضعیت اتصال (آمار، تایمر، دکمه و ...) همزمان آپدیت شوند.
          child: ValueListenableBuilder<V2RayStatus>(
            valueListenable: status,
            builder: (context, v2rayStatus, child) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTopStatusCard(v2rayStatus, accentColor),

                  // [UI FIX] فاصله بین کارت بالا و دکمه افزایش یافت
                  const Spacer(flex: 3),

                  _buildPowerButton(v2rayStatus, accentColor),

                  // [UI FIX] فاصله بین دکمه و ویجت‌های پایینی افزایش یافت
                  const Spacer(flex: 2),

                  _buildTransferStats(v2rayStatus, accentColor),

                  const Spacer(flex: 1), // ایجاد فضای بیشتر برای جلوگیری از overflow

                  _buildServerSelector(),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,


      // ▼▼▼ این بخش برای حل مشکل باز نشدن منو اصلاح شد ▼▼▼
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white70),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      // ▲▲▲ تغییرات در اینجا تمام می‌شود ▲▲▲

      title: Text(
        vpnAppName,
        style: const TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon:
          const Icon(Icons.shield_outlined, color: Colors.white70),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTopStatusCard(V2RayStatus v2rayStatus, Color accentColor) {
    final bool isConnected = v2rayStatus.state == 'CONNECTED';
    final String duration = isConnected ? _formatDuration(_duration) : '00:00:00';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: isConnected ? accentColor : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'SECURELY CONNECTED' : 'NOT CONNECTED',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      color: isConnected ? accentColor : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // [UI FIX] متن حذف شده بازگردانده شد
              Text(
                'Auto Disconnected after 60 minutes',
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              // [UI FIX] ظاهر دکمه جایزه بهبود یافت
              _buildRewardButton(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardButton(Color accentColor) {
    return Material(
      color: accentColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          // TODO: منطق دریافت جایزه
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            'Get more time',
            style: TextStyle(
              fontFamily: 'Lato',
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerButton(V2RayStatus v2rayStatus, Color accentColor) {
    bool isConnected = v2rayStatus.state == 'CONNECTED';
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _toggleConnection,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F142E),
              boxShadow: [
                BoxShadow(
                  color: isConnected
                      ? accentColor.withOpacity(0.3)
                      : Colors.transparent,
                  blurRadius: _animation.value,
                  spreadRadius: _animation.value * 1.5,
                )
              ],
            ),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B3A5A), Color(0xFF0F142E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                color: isConnected ? accentColor : Colors.white,
                size: 70,
              ),
              const SizedBox(height: 12),
              Text(
                isConnected ? 'TAP TO DISCONNECT' : 'TAP TO CONNECT',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferStats(V2RayStatus v2rayStatus, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GradientStatCard(
            icon: Icons.arrow_downward_rounded,
            value: _formatBytes(v2rayStatus.download),
            label: 'DOWNLOAD',
            accentColor: accentColor,
          ),
          _GradientStatCard(
            icon: Icons.arrow_upward_rounded,
            value: _formatBytes(v2rayStatus.upload),
            label: 'UPLOAD',
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildServerSelector() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final loc = await Navigator.push<LocationConfig>(
          context,
          MaterialPageRoute(builder: (_) => const LocationsScreen()),
        );
        if (loc == null || !mounted) return;
        if (status.value.state == 'CONNECTED' &&
            (_currentLink != loc.link || _currentLink == 'auto')) {
          await flutterV2ray.stopV2Ray();
        }
        setState(() {
          _currentServer = loc.country;
          _currentCity = loc.city;
          _currentLink = loc.link;
          _currentCode = loc.countryCode;
        });
        if (loc.link == 'auto') {
          _toggleConnection();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 75,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1B3A5A).withOpacity(0.5),
                  const Color(0xFF0F142E).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                _buildFlag(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT SERVER',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 11,
                            letterSpacing: 1,
                            color: Colors.white70),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_currentServer' +
                            (_currentCity.isNotEmpty ? ' • $_currentCity' : ''),
                        style: const TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// [FINAL DESIGN] ویجت نهایی برای آمار دانلود/آپلود
class _GradientStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const _GradientStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // [UI FIX] ابعاد کارت کوچک‌تر شد
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.3),
            accentColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // گوشه‌های گردتر
        border: Border.all(color: accentColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontFamily: 'Lato',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontFamily: 'Lato',
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}
