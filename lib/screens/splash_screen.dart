import 'dart:async'; // <--- CORRIGIDO AQUI
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importa as telas que agora existem
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
    // Inicia a verificação após um tempo (ex: 3 segundos)
    Timer(const Duration(seconds: 3), () {
      _checkUserAndRedirect();
    });
  }

  Future<void> _checkUserAndRedirect() async {
    // Evita erro se a tela for destruída
    if (!mounted) return;

    // 1. Verificar se deve mostrar a introdução
    final prefs = await SharedPreferences.getInstance();
    
    // A chave 'showIntro' será definida como 'false' na IntroScreen
    // Se for a primeira vez, o valor será 'null', então usamos '?? true'
    final bool showIntro = prefs.getBool('showIntro') ?? true; 

    if (showIntro) {
      // Redireciona para IntroScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    } else {
      // 2. Se não precisa mostrar intro, verificar login
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    // Evita erro se a tela for destruída
    if (!mounted) return;

    // 2. Verificar se o usuário está logado no Firebase
    User? user = FirebaseAuth.instance.currentUser;

    // LÓGICA IF/ELSE CORRIGIDA AQUI
    if (user != null) {
      // Usuário logado, vai para Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Usuário não logado, vai para Login
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
          // ATENÇÃO: Troque pelo NOME EXATO do seu arquivo .json
          'assets/animations/loading.json', 
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}