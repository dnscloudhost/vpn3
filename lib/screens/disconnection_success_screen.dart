// lib/screens/disconnection_success_screen.dart

import 'package:flutter/material.dart';

class DisconnectionSuccessScreen extends StatelessWidget {
  const DisconnectionSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تعریف رنگ‌های اصلی مطابق با تصویر
    const Color primaryTextColor = Color(0xFF4CAF50); // سبز
    const Color secondaryTextColor = Colors.white70;
    const Color backgroundColor = Color(0xFF0F142E); // پس‌زمینه سرمه‌ای تیره

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'PREMIUM VPN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // آیکن تیک
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryTextColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryTextColor.withOpacity(0.5),
                    blurRadius: 20.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 40),

            // متن اصلی
            const Text(
              'Disconnected Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // متن توضیحات
            const Text(
              'Your VPN connection has been terminated.',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 60), // فاصله تا پایین صفحه
          ],
        ),
      ),
    );
  }
}