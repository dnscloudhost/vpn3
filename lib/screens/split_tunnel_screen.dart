// lib/screens/split_tunnel_screen.dart

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:device_apps/device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/split_tunnel_info_dialog.dart'; // <-- پاپ‌آپ جدید اضافه شد

class AppInfo {
  final String packageName;
  final String appName;
  final Uint8List? appIcon;
  bool isBypassed;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.appIcon,
    this.isBypassed = false,
  });
}

// [PERFORMANCE-FIX] این تابع بهینه شد تا فقط اپ‌های کاربر را بخواند
Future<List<Application>> _fetchInstalledAppsInBackground(Map<String, dynamic> params) async {
  final RootIsolateToken? token = params['token'] as RootIsolateToken?;
  if (token != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  } else if (kDebugMode) {
    debugPrint("_fetchInstalledAppsInBackground: no token, plugin may not work.");
  }
  try {
    return await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false, // <-- تغییر اصلی برای افزایش سرعت
      onlyAppsWithLaunchIntent: true, // <-- برای لیست خلوت‌تر
    );
  } catch (e) {
    debugPrint("Error fetching apps: $e");
    return [];
  }
}

class SplitTunnelScreen extends StatefulWidget {
  final FlutterV2ray flutterV2ray;
  const SplitTunnelScreen({Key? key, required this.flutterV2ray}) : super(key: key);

  @override
  State<SplitTunnelScreen> createState() => _SplitTunnelScreenState();
}

class _SplitTunnelScreenState extends State<SplitTunnelScreen> {
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  String _searchTerm = '';

  static const String _prefKey = 'bypassed_packages';

  @override
  void initState() {
    super.initState();
    // نمایش پاپ‌آپ توضیحات در ابتدای ورود به صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(context: context, builder: (_) => const SplitTunnelInfoDialog());
    });
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final bypassed = prefs.getStringList(_prefKey) ?? [];

    final token = RootIsolateToken.instance;
    final apps = await compute(_fetchInstalledAppsInBackground, {'token': token});

    // منطق شما دست نخورده باقی مانده است
    final infos = apps
        .map((app) => AppInfo(
      packageName: app.packageName,
      appName: app.appName,
      appIcon: app is ApplicationWithIcon ? app.icon : null,
      isBypassed: bypassed.contains(app.packageName),
    ))
        .toList()
      ..sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    if (mounted) {
      setState(() {
        _allApps = infos;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final term = _searchTerm.toLowerCase();
    setState(() {
      _filteredApps = _allApps.where((app) {
        return app.appName.toLowerCase().contains(term) ||
            app.packageName.toLowerCase().contains(term);
      }).toList();
    });
  }

  Future<void> _saveAndExit() async {
    final prefs = await SharedPreferences.getInstance();
    final selected =
    _allApps.where((a) => a.isBypassed).map((a) => a.packageName).toList();
    await prefs.setStringList(_prefKey, selected);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F142E);
    const accentColor = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Split Tunnel',
            style: TextStyle(
                fontFamily: 'Lato',
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: accentColor),
            onPressed: _saveAndExit,
            tooltip: 'Save & Exit',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (v) {
                _searchTerm = v;
                _applyFilter();
              },
              style: const TextStyle(fontFamily: 'Lato', color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: TextStyle(
                    fontFamily: 'Lato', color: Colors.white.withOpacity(0.5)),
                prefixIcon:
                Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: accentColor))
                : _filteredApps.isEmpty
                ? Center(
                child: Text('No apps found.',
                    style: TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.white.withOpacity(0.7))))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _filteredApps.length,
              itemBuilder: (_, i) {
                final app = _filteredApps[i];
                return _AppListItem(
                  app: app,
                  accentColor: accentColor,
                  onTap: () {
                    setState(() => app.isBypassed = !app.isBypassed);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ویجت جدید و حرفه‌ای برای نمایش هر اپ در لیست
class _AppListItem extends StatelessWidget {
  final AppInfo app;
  final Color accentColor;
  final VoidCallback onTap;

  const _AppListItem({
    required this.app,
    required this.accentColor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1B3A5A).withOpacity(0.5),
                    const Color(0xFF0F142E).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  app.appIcon != null
                      ? Image.memory(app.appIcon!, width: 40, height: 40)
                      : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Text(app.appName[0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.appName,
                            style: const TextStyle(
                                fontFamily: 'Lato',
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          app.packageName,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // چک‌باکس مربعی سفارشی
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: app.isBypassed
                          ? accentColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: app.isBypassed
                            ? Colors.transparent
                            : Colors.white54,
                        width: 2,
                      ),
                    ),
                    child: app.isBypassed
                        ? const Icon(Icons.check,
                        color: Colors.black, size: 18)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}