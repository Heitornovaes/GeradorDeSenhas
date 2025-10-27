import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Vamos criar esta tela no próximo passo
import 'package:meu_gerador_senhas/screens/login_screen.dart'; 

// Classe para guardar os dados de cada página
class IntroPageItem {
  final String lottieAsset;
  final String title;
  final String subtitle;

  IntroPageItem({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
  });
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  // Controlador para o PageView
  final PageController _pageController = PageController();

  // Estado para saber se está na última página
  bool _isLastPage = false;
  
  // Estado do checkbox
  bool _dontShowAgain = false;

  // Lista de páginas da introdução
  // ATENÇÃO: Troque os nomes dos assets pelos que você baixou!
  final List<IntroPageItem> _pages = [
    IntroPageItem(
      lottieAsset: 'assets/animations/intro1.json',
      title: 'Bem-vindo ao App', // [cite: 45]
      subtitle: 'Aprenda a usar o app passo a passo', // [cite: 45]
    ),
    IntroPageItem(
      lottieAsset: 'assets/animations/intro2.json',
      title: 'Funcionalidades', // [cite: 46]
      subtitle: 'Explore as diversas funcionalidades.', // [cite: 46]
    ),
    IntroPageItem(
      lottieAsset: 'assets/animations/intro3.json',
      title: 'Vamos começar?', // [cite: 47]
      subtitle: 'Pronto para usar o seu app com segurança.', // [cite: 48]
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Monitora a mudança de página
    _pageController.addListener(() {
      setState(() {
        _isLastPage = (_pageController.page?.round() == _pages.length - 1);
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Função chamada ao clicar em "Concluir"
  Future<void> _onDone() async {
    // 1. Salvar no SharedPreferences [cite: 35]
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showIntro', false);
    }

    if (!mounted) return;

    // 2. Redirecionar para Login
    // (O PDF [cite: 35] sugere Home, mas o usuário ainda não logou,
    // então o fluxo correto é ir para Login)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return buildPage(item);
                },
              ),
            ),
            
            // 2. Navegação (Indicador e Botões)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: buildNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que constrói o conteúdo de cada página
  Widget buildPage(IntroPageItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(item.lottieAsset, height: 300),
        const SizedBox(height: 32),
        Text(
          item.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            item.subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Widget que constrói a navegação inferior
  Widget buildNavigation() {
    return Column(
      children: [
        // Checkbox "Não mostrar novamente" [cite: 34]
        // Aparece apenas na última página
        if (_isLastPage)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _dontShowAgain,
                onChanged: (value) {
                  setState(() {
                    _dontShowAgain = value ?? false;
                  });
                },
              ),
              const Text('Não mostrar essa introdução novamente.'), // [cite: 34, 39]
            ],
          ),
        
        const SizedBox(height: 16),

        // Indicador de página (bolinhas)
        SmoothPageIndicator(
          controller: _pageController,
          count: _pages.length,
          effect: const WormEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.blue,
            dotColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        // Botões
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão Voltar [cite: 33]
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: const Text('Voltar'), // [cite: 40]
            ),
            
            // Botão Avançar / Concluir [cite: 33]
            TextButton(
              onPressed: _isLastPage
                  ? _onDone // Se for última página, chama _onDone
                  : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
              child: Text(_isLastPage ? 'Concluir' : 'Avançar'), // [cite: 41, 49]
            ),
          ],
        ),
      ],
    );
  }
}