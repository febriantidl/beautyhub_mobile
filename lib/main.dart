import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BeautyHubApp());
}

class BeautyHubApp extends StatelessWidget {
  const BeautyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title        : 'BeautyHub',
      debugShowCheckedModeBanner: false,
      theme        : ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E8C), // Pink BeautyHub
        ),
        useMaterial3: true,
        fontFamily  : 'Roboto',
      ),
      // Splash screen — cek apakah sudah login
      home: const SplashScreen(),
    );
  }
}

// ─── Splash Screen — cek token ──────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // animasi splash
    final loggedIn = await ApiService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE91E8C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / ikon aplikasi
            Container(
              width : 100,
              height: 100,
              decoration: BoxDecoration(
                color       : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                size : 64,
                color: Color(0xFFE91E8C),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BeautyHub',
              style: TextStyle(
                fontSize  : 32,
                fontWeight: FontWeight.bold,
                color     : Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan MUA terbaik untuk kamu',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}