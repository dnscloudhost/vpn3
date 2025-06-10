// lib/screens/locations_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/settings_controller.dart';
import '../data/locations.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  // ... تمام منطق شما دست نخورده باقی می‌ماند ...
  String? _selectedServerLink;

  @override
  void initState() {
    super.initState();
    final initialServer = allConfigs.firstWhere(
            (loc) => loc.serverType.toLowerCase() != 'smart' && loc.link != 'auto',
        orElse: () => allConfigs.first);
    _selectedServerLink = initialServer.link;
  }

  List<LocationConfig> get _filteredServers {
    return allConfigs
        .where((loc) => loc.serverType.toLowerCase() != 'smart')
        .toList();
  }

  void _selectServer(LocationConfig loc) {
    setState(() => _selectedServerLink = loc.link);
    Navigator.pop(context, loc);
  }

  void _handleAutoConnectToggle() {
    final autoEnabled = SettingsController.instance.settings.autoConnectEnabled;
    if (!autoEnabled) return;

    final autoSelectConfig = LocationConfig(
      id: -99,
      country: "Auto-Select",
      city: "Fastest Server",
      link: "auto",
      countryCode: "globe",
      serverType: "auto",
    );
    Navigator.pop(context, autoSelectConfig);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F142E);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Server Locations',
            style: TextStyle(
                fontFamily: 'Lato',
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildAutoSelectCard(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
            child: Divider(color: Colors.white12, height: 1),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredServers.length,
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemBuilder: (context, index) {
                final loc = _filteredServers[index];
                return _ServerListItem(
                  location: loc,
                  isSelected: _selectedServerLink == loc.link,
                  onTap: () => _selectServer(loc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoSelectCard() {
    // این ویجت بدون تغییر باقی مانده است
    final autoEnabled = SettingsController.instance.settings.autoConnectEnabled;
    const accentColor = Color(0xFF00E5FF);

    return Opacity(
      opacity: autoEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: autoEnabled ? _handleAutoConnectToggle : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00796B).withOpacity(0.8),
                const Color(0xFF004D40).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: const Icon(Icons.flash_on_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto Connect',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Connect to the fastest server',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white70,
                            fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ویجت آیتم‌های لیست سرور با آخرین تغییرات درخواستی
class _ServerListItem extends StatelessWidget {
  final LocationConfig location;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServerListItem({
    Key? key,
    required this.location,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E5FF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // [FINAL UI] گرادیانت شیشه‌ای تیره مشابه کارت انتخاب سرور در صفحه اصلی
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1B3A5A).withOpacity(0.5),
                    const Color(0xFF0F142E).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withOpacity(0.9)
                      : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SvgPicture.asset(
                      'assets/flags/${location.countryCode.toLowerCase()}.svg',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      location.city.isNotEmpty
                          ? location.city
                          : location.country,
                      style: const TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // [FINAL UI] جایگزینی دکمه رادیویی با متن حرفه‌ای
                  Text(
                    'TAP TO CONNECT',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.5),
                    ),
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