// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/settings_controller.dart';
import '../screens/split_tunnel_screen.dart'; // مسیر صحیح را وارد کنید

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance.settings;
    const accentColor = Color(0xFF00E5FF);

    return Drawer(
      backgroundColor: const Color(0xFF0F142E), // رنگ پس‌زمینه اصلی
      child: Column(
        children: [
          _buildDrawerHeader(settings.appVersion, accentColor),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () => Navigator.pop(context), // بستن منو
                ),
                _buildDrawerItem(
                  icon: Icons.store_rounded,
                  title: 'Store',
                  onTap: () {
                    // TODO: ناوبری به صفحه فروشگاه
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Support',
                  onTap: () {
                    // TODO: ناوبری به صفحه پشتیبانی
                  },
                ),
                const Divider(color: Colors.white12, indent: 20, endIndent: 20),
                _buildDrawerItem(
                  icon: Icons.share_rounded,
                  title: 'Share App',
                  onTap: () {
                    // TODO: منطق اشتراک‌گذاری اپ
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    if (settings.privacyPolicyLink.isNotEmpty) {
                      _launchURL(settings.privacyPolicyLink);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
                _buildDrawerItem( // گزینه Split Tunnel اضافه شد
                  icon: Icons.call_split_rounded,
                  title: 'Split Tunnel',
                  onTap: () {
                    Navigator.pop(context); // ابتدا منو را ببند
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SplitTunnelScreen(
                          flutterV2ray: FlutterV2ray(onStatusChanged: (_) {}),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(String appVersion, Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mahan VPN',
            style: TextStyle(
              fontFamily: 'Lato',
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Free & VIP VPN application for all users',
            style: TextStyle(
              fontFamily: 'Lato',
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter() {
    final settings = SettingsController.instance.settings;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Version ${settings.appVersion}',
            style: const TextStyle(
              fontFamily: 'Lato',
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '© 2024 Mahan VPN',
            style: TextStyle(
              fontFamily: 'Lato',
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
      onTap: onTap,
    );
  }
}