// lib/widgets/split_tunnel_info_dialog.dart

import 'package:flutter/material.dart';

class SplitTunnelInfoDialog extends StatelessWidget {
  const SplitTunnelInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00E5FF);
    const dialogBackgroundColor = Color(0xFF2A2D4A);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: dialogBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How does Tunnel Split work?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Any app you select will no longer route its traffic through the VPN. After enabling it, disconnect and reconnect the VPN once.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}