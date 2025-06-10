// lib/screens/settings_screen.dart

import 'dart:ui'; // [FIX] برای استفاده از BackdropFilter اضافه شد
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/settings_controller.dart';
import 'split_tunnel_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance.settings;
    const backgroundColor = Color(0xFF0F142E);
    const accentColor = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      // [UI-FIX] ساختار body برای قرار دادن فوتر در پایین صفحه تغییر کرد
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                _buildSectionHeader('General'),
                _buildSettingsItem(
                  icon: Icons.call_split_rounded,
                  title: 'Split Tunnel',
                  subtitle: 'Select apps to bypass VPN',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SplitTunnelScreen(
                          flutterV2ray: FlutterV2ray(onStatusChanged: (_) {})),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionHeader('About & Support'),
                _buildSettingsItem(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    if (settings.privacyPolicyLink.isNotEmpty) {
                      _launchURL(settings.privacyPolicyLink);
                    }
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Support',
                  subtitle: 'Get help and support',
                  onTap: () {
                    // TODO: صفحه contact_support_screen.dart را بسازید
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About App',
                  subtitle: 'App information and credits',
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
              ],
            ),
          ),

          // [UI-FIX] فوتر به پایین صفحه منتقل شد
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Text(
                  'Mahan VPN',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${settings.appVersion}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Lato',
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // [UI-FIX] این ویجت برای داشتن ظاهر شیشه‌ای و گرادیانتی بازطراحی شد
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Icon(icon, color: Colors.white70, size: 24),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}