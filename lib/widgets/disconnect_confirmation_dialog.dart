// lib/widgets/disconnect_confirmation_dialog.dart

import 'package:flutter/material.dart';

class DisconnectConfirmationDialog extends StatelessWidget {
  const DisconnectConfirmationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تعریف رنگ‌های اصلی
    const Color dialogBackgroundColor = Color(0xFF2A2D4A);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;
    const Color yesButtonColor = Colors.white;
    const Color yesButtonTextColor = Color(0xFF1A1C33);
    const Color noButtonColor = Color(0xFF383B5B);

    return Dialog(
      backgroundColor: Colors.transparent, // برای اعمال کردن borderRadius
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: dialogBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ارتفاع دیالوگ به اندازه محتوا باشد
          children: [
            // آیکن قفل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.shield_outlined, // یک آیکن مشابه
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),

            // متن اصلی
            const Text(
              'Disconnect VPN?',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // متن توضیحات
            const Text(
              'Are you sure you want to disconnect\nthe VPN connection?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // دکمه‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // دکمه NO
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // با مقدار false به صفحه قبل برمی‌گردیم یعنی "تایید نشد"
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: noButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'NO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // دکمه YES
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // با مقدار true به صفحه قبل برمی‌گردیم یعنی "تایید شد"
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yesButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'YES',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: yesButtonTextColor,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// یک تابع کمکی برای نمایش آسان دیالوگ
Future<bool?> showDisconnectConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const DisconnectConfirmationDialog();
    },
  );
}