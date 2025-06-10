// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'controllers/settings_controller.dart';   // ← برای بارگذاری تنظیمات
import 'services/admob_service.dart';            // ← برای AdMob
import 'data/locations.dart';                    // ← allConfigs
import 'services/server_api.dart';               // ← loadAllServers
import 'screens/initializing_screen.dart';       // ← نقطهٔ شروع
import 'screens/home_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/policy_screen.dart';              // ← صفحهٔ Privacy Policy
import 'screens/about_screen.dart';               // ← صفحهٔ About
import 'screens/settings_screen.dart';            // ← صفحهٔ Settings
import 'screens/optimize_connection_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ▼▼▼ این بخش را اضافه کنید ▼▼▼
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: ["7642A2BCC64566FA42816F135CACDE10"],
  );
  MobileAds.instance.updateRequestConfiguration(configuration);
  // ▲▲▲

  // 1️⃣ بارگذاری تنظیمات از API و کش
  await SettingsController.instance.load();

  // 2️⃣ مقداردهی اولیهٔ AdMob SDK
  await AdMobService.instance.init();

  // • نمایش یک اسپلش اد (اختیاری)
  // await AdMobService.instance.showSplashAd();

  // 3️⃣ بارگذاری اولیهٔ سرورها (تا در سراسر اپ کش شوند)
  allConfigs = await ServerApi.loadAllServers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahan VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1B1B2F),
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
          background: const Color(0xFF1B1B2F),
        ),
      ),
      home: const InitializingScreen(),
      routes: {
        '/home':    (_) => const MainPage(),
        '/optimize':(_) => const OptimizeConnectionPage(),
        '/policy':  (_) => const PolicyScreen(),
        '/about':   (_) => const AboutScreen(),
      },
    );
  }
}

/// صفحهٔ اصلی ناوبری سه‌تبی
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomeScreen(),
    LocationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // تعریف رنگ‌های اصلی تم برنامه
    const backgroundColor = Color(0xFF0F142E);
    const accentColor = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      // بدنه اصلی برنامه بدون تغییر باقی می‌ماند
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // ▼▼▼ بخش نوار ناوبری با طراحی کاملاً جدید و حرفه‌ای ▼▼▼
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              // حذف کامل خط جدا کننده بالایی
              // border: Border(
              //   top: BorderSide(color: accentColor.withOpacity(0.2), width: 1.5),
              // ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: accentColor,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Lato'),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.public_rounded),
                  label: 'Locations',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}