// lib/screens/optimize_connection_page.dart
//
// اسپلش دوم: نوار % + نکته‌ها + نمایش Interstitial «Smart-Connect»

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/admob_service.dart'; // سرویس مرکزی تبلیغ
import '../services/vpn_service.dart';

class OptimizeConnectionPage extends StatefulWidget {
  const OptimizeConnectionPage({super.key});

  @override
  State<OptimizeConnectionPage> createState() => _OptimizeConnectionPageState();
}

class _OptimizeConnectionPageState extends State<OptimizeConnectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _tipIndex = 0;

  // 4 نکتهٔ متغیر
  static const List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.security_outlined,
      'text':
      'Your connection is secured with military-grade encryption, protecting you on public Wi-Fi.',
    },
    {
      'icon': Icons.visibility_off_outlined,
      'text':
      'We hide your real IP address to keep your online identity and location private from trackers.',
    },
    {
      'icon': Icons.public_outlined,
      'text':
      'Access global servers to enjoy content and services from anywhere in the world without restrictions.',
    },
    {
      'icon': Icons.bolt_outlined,
      'text':
      'Our smart servers are optimized to provide you with the fastest and most stable connection possible.',
    },
  ];

  @override
  void initState() {
    super.initState();

    /* 1️⃣ Interstitial «Smart-Connect» (slot=splashOpen) را آماده می‌کنیم.
       اگر در InitializingScreen هم preload شده باشد، دوباره فراخوانی مشکلی ندارد. */
    AdMobService.instance.loadInterstitial(AdSlot.splashOpen);

    /* 2️⃣ انیمیشن نوار پیشرفت (۴ ثانیه) */
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((st) {
      if (st == AnimationStatus.completed) _proceed();
    });

    _ctrl.addListener(() {
      final percent = (_ctrl.value * 100).round();
      // هر 25٪ نکته را عوض کن
      setState(() => _tipIndex = (percent ~/ 25).clamp(0, _tips.length - 1));
    });

    _ctrl.forward();
  }

  /* بعد از 100٪:
     - Interstitial را نشان بده
     - سپس به Home برو */
  Future<void> _proceed() async {
    // این بخش دست‌نخورده باقی مانده تا با منطق AdMobService شما هماهنگ باشد
    final cancelled = await AdMobService.instance.showSplashAd(); // slot = splashOpen
    if (cancelled) {
      await VpnService.instance.disconnectSmart();
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_ctrl.value * 100).round();
    final tip = _tips[_tipIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00102A), Color(0xFF002142)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /* آیکن سپر */
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF0096D6), Color(0xFF004E7C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.shield_outlined,
                  color: Colors.white, size: 48),
            ),

            const SizedBox(height: 20),
            const Text(
              'Optimizing Connection…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato', // <-- اضافه شد
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: _CenteredProgress(value: _ctrl.value),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Lato', // <-- اضافه شد
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _TipCard(icon: tip['icon'], text: tip['text']),
            ),
          ],
        ),
      ),
    );
  }
}

/* نوار پروگرس که از 0→100٪ پر می‌شود */
class _CenteredProgress extends StatelessWidget {
  final double value;
  const _CenteredProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: Colors.white.withOpacity(0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
      ),
    );
  }
}

/* کارت نکته + آیکن */
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF002A4E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 32),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato', // <-- اضافه شد
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ads help keep our service free. Thank you for your support!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato', // <-- اضافه شد
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}