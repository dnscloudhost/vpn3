// lib/screens/connection_success_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class ConnectionSuccessScreen extends StatefulWidget {
  const ConnectionSuccessScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionSuccessScreen> createState() => _ConnectionSuccessScreenState();
}

class _ConnectionSuccessScreenState extends State<ConnectionSuccessScreen> {
  Timer? _timer;
  int _connectionTimeInSeconds = 0;

  @override
  void initState() {
    super.initState();
    // شروع تایمر به محض ورود به صفحه
    _startTimer();
  }

  @override
  void dispose() {
    // حتما تایمر را در زمان خروج از صفحه متوقف کنید تا از نشت حافظه جلوگیری شود
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // هر ثانیه، یک واحد به زمان اتصال اضافه کرده و صفحه را آپدیت می‌کنیم
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _connectionTimeInSeconds++;
        });
      }
    });
  }

  void _shareConnection() {
    // TODO: در اینجا می‌توانید منطق اشتراک‌گذاری را پیاده‌سازی کنید
    // برای این کار معمولا از پکیج share_plus استفاده می‌شود
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share button clicked!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تعریف رنگ‌های اصلی مطابق با تصویر
    const Color primaryTextColor = Color(0xFF4CAF50); // سبز
    const Color secondaryTextColor = Colors.white70;
    const Color backgroundColor = Color(0xFF0F142E); // پس‌زمینه سرمه‌ای تیره
    const Color iconBackgroundColor = Color(0xFF2E7D32); // پس‌زمینه آیکن

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
        backgroundColor: Colors.transparent, // شفاف برای هماهنگی با پس‌زمینه
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
            const Spacer(flex: 2),

            // آیکن تیک سبز در دایره
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

            // متن "CONNECTED SUCCESSFULLY"
            const Text(
              'CONNECTED\nSUCCESSFULLY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // متن توضیحات
            const Text(
              'Your connection is now secure and encrypted',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
              ),
            ),
            const Spacer(flex: 1),

            // تایمر زمان اتصال
            const Text(
              'Connection time',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_connectionTimeInSeconds}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 3),

            // جایگاه تبلیغ بنری
            Container(
              height: 60,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Ad Space',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 40), // فاصله تا پایین صفحه
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _shareConnection,
        backgroundColor: const Color(0xFF1A237E), // رنگ دکمه اشتراک گذاری
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }
}