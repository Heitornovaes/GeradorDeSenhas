import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_gerador_senhas/screens/home_screen.dart';
import 'package:meu_gerador_senhas/screens/intro_screen.dart';
import 'package:meu_gerador_senhas/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      _checkUserAndRedirect();
    });
  }

  Future<void> _checkUserAndRedirect() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    
    final bool showIntro = prefs.getBool('showIntro') ?? true; 

    if (showIntro) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    } else {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    
    if (user != null) {
     
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
    
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          
          'assets/animations/loading.json', 
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}