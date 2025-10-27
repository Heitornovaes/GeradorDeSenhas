import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importe nosso widget customizado
import 'package:meu_gerador_senhas/widgets/custom_text_field.dart';

// Importe as telas que vamos usar
import 'package:meu_gerador_senhas/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Chave para o formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estado para controlar o loading
  bool _isLoading = false;

  // Estado para controlar a visibilidade da senha
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função de utilidade para mostrar SnackBar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Função para lidar com o Login
  Future<void> _login() async {
    // 1. Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Ativar o loading
    setState(() {
      _isLoading = true;
    });

    // 3. Lógica do Firebase (AGORA COM TRY-CATCH)
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Tenta fazer o login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 4. Se o login deu certo, navegar para Home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 5. Lidar com erros do Firebase
      String errorMessage = 'Ocorreu um erro. Tente novamente.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O e-mail fornecido não é válido.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Credenciais inválidas. Verifique seu e-mail e senha.';
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      // Lidar com outros erros
      _showErrorSnackBar('Um erro inesperado ocorreu.');
    }

    // 6. Parar o loading (seja em sucesso ou erro)
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para lidar com o Registro
  Future<void> _register() async {
    // 1. Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Ativar o loading
    setState(() {
      _isLoading = true;
    });

    // 3. Lógica do Firebase (AGORA COM TRY-CATCH)
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Tenta criar o usuário
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 4. Se o registro deu certo, navegar para Home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 5. Lidar com erros do Firebase
      String errorMessage = 'Ocorreu um erro. Tente novamente.';
      if (e.code == 'weak-password') {
        errorMessage = 'A senha é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este e-mail já está em uso.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O e-mail fornecido não é válido.';
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      // Lidar com outros erros
      _showErrorSnackBar('Um erro inesperado ocorreu.');
    }

    // 6. Parar o loading (seja em sucesso ou erro)
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor de fundo com base na imagem do PDF
    final Color backgroundColor = const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Ícone e Título
                Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bem-vindo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Faça login para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Campo de Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    if (!EmailValidator.validate(email)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),

                // 3. Campo de Senha
                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  icon: Icons.lock_outline_rounded,
                  isPassword: !_isPasswordVisible, // Controla visibilidade
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    if (password.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Botões (Entrar e Registrar)
                // Usamos um 'if' para mostrar o loading ou os botões
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Botão Entrar
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botão Registrar
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white, // Cor diferente
                          foregroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        child: const Text(
                          'Registrar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}