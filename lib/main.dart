import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meu_gerador_senhas/firebase_options.dart';
import 'package:meu_gerador_senhas/screens/splash_screen.dart'; 

void main() async {
  // Garante que o Flutter e os Widgets estejam prontos
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inicializa o Firebase usando o arquivo que o 'flutterfire' criou
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerador de Senhas',
      theme: ThemeData(
        // Você pode alterar as cores principais aqui
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Nossa primeira tela
    );
  }
}