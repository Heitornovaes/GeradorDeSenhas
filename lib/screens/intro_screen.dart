import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:meu_gerador_senhas/screens/login_screen.dart'; 


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
  final PageController _pageController = PageController();

  bool _isLastPage = false;
  
  bool _dontShowAgain = false;

  
  final List<IntroPageItem> _pages = [
    IntroPageItem(
      lottieAsset: 'assets/animations/intro1.json',
      title: 'Bem-vindo ao App', 
      subtitle: 'Aprenda a usar o app passo a passo', 
    ),
    IntroPageItem(
      lottieAsset: 'assets/animations/intro2.json',
      title: 'Funcionalidades',
      subtitle: 'Explore as diversas funcionalidades.', 
    ),
    IntroPageItem(
      lottieAsset: 'assets/animations/intro3.json',
      title: 'Vamos começar?', 
      subtitle: 'Pronto para usar o seu app com segurança.', 
    ),
  ];

  @override
  void initState() {
    super.initState();
    
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

  
  Future<void> _onDone() async {
    
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showIntro', false);
    }

    if (!mounted) return;

    
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
            
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: buildNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  
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


  Widget buildNavigation() {
    return Column(
      children: [
        
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
              const Text('Não mostrar essa introdução novamente.'), 
            ],
          ),
        
        const SizedBox(height: 16),

        // Indicador de página 
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
            
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: const Text('Voltar'), 
            ),
            
           
            TextButton(
              onPressed: _isLastPage
                  ? _onDone 
                  : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
              child: Text(_isLastPage ? 'Concluir' : 'Avançar'), 
            ),
          ],
        ),
      ],
    );
  }
}