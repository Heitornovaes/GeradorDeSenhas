import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar para o Clipboard
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para jsonDecode (embora não usemos mais para esta API)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  // Variáveis de estado
  double _passwordLength = 12.0;
  final double _minPasswordLength = 8.0;
  final double _maxPasswordLength = 20.0; // Limite da API

  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _optionsVisible = true;
  bool _isLoading = false;
  String _generatedPassword = 'Senha não informada';

  final TextEditingController _labelController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Função para mostrar SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // 1. GERAÇÃO DA SENHA (API PASSWORD.NINJA - CORRIGIDO v5)
  Future<void> _generatePassword() async {
    setState(() {
      _isLoading = true;
      _generatedPassword = 'Gerando...'; // Feedback visual
    });

    // Usando password.ninja/api/password
    final queryParams = {
      'minPassLength': _passwordLength.round().toString(),
      'maxLength': _passwordLength.round().toString(),
      'capitals': _includeUppercase.toString(),
      'symbols': _includeSymbols.toString(),
      'numAtEnd': _includeNumbers ? '3' : '0', // Adiciona números se solicitado
      // numOfPasswords=1 (padrão) retorna plain text segundo cURL example
    };

    if (!_includeUppercase && !_includeLowercase && !_includeNumbers && !_includeSymbols) {
      _showSnackBar('Selecione pelo menos um tipo de caractere.', isError: true);
      setState(() { _isLoading = false; _generatedPassword = 'Erro: Selecione opções'; });
      return;
    }

    // ENDPOINT CORRIGIDO AQUI: /api/password
    final uri = Uri.https('password.ninja', '/api/password', queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Sucesso - API retorna plain text para numOfPasswords=1
        String passwordResponse = response.body.trim();

         // Remove colchetes e aspas se houver (caso retorne ["senha"])
        passwordResponse = passwordResponse.replaceAll(RegExp(r'\["|"\]'), '');

        setState(() {
          _generatedPassword = passwordResponse.isNotEmpty ? passwordResponse : "Erro: API retornou vazio";
        });

      } else {
        // Erro do servidor
        _showSnackBar('Erro ao gerar senha (Servidor: ${response.statusCode}).', isError: true);
        setState(() { _generatedPassword = 'Erro na API (${response.statusCode})'; });
      }
    } catch (e) {
      // Erro de conexão
      _showSnackBar('Erro de conexão. Verifique sua internet.', isError: true);
       setState(() { _generatedPassword = 'Erro de conexão'; });
    }

    // Só para loading se não foi um erro de conexão/API
     if (_generatedPassword != 'Erro de conexão' && !_generatedPassword.startsWith('Erro na API')) {
         setState(() {
           _isLoading = false;
         });
     } else {
        // Se deu erro, para o loading e reseta a senha
         setState(() {
           _isLoading = false;
           _generatedPassword = 'Senha não informada'; // Reset visual
         });
     }
  }

 // --- O restante do código (salvar no Firestore, build, etc.) permanece igual ---
 // --- Apenas a função _generatePassword() foi atualizada ---

  // 2. SALVAR SENHA NO FIRESTORE (COM ALERTDIALOG)
  Future<void> _showSavePasswordDialog() async {
    if (_generatedPassword == 'Senha não informada' || _isLoading || _generatedPassword.startsWith("Erro")) {
      _showSnackBar('Gere uma senha válida antes de salvar.', isError: true);
      return;
    }
    _labelController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salvar senha'),
          content: TextField(
            controller: _labelController,
            decoration: const InputDecoration(labelText: 'Rótulo (ex: Senha do Email)',),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final label = _labelController.text.trim();
                if (label.isNotEmpty) {
                  Navigator.of(context).pop();
                  _savePasswordToFirestore(label);
                } else {
                   _showSnackBar('Por favor, insira um rótulo.', isError: true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePasswordToFirestore(String label) async {
    if (_currentUser == null) {
      _showSnackBar('Erro: Ninguém logado.', isError: true);
      return;
    }
    if (_generatedPassword == 'Senha não informada' || _generatedPassword.startsWith("Erro")) {
       _showSnackBar('Não é possível salvar uma senha inválida.', isError: true);
       return;
    }
    setState(() { _isLoading = true; });
    try {
      await FirebaseFirestore.instance.collection('passwords').add({
        'userId': _currentUser!.uid, 'label': label, 'password': _generatedPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _showSnackBar('Senha salva com sucesso!', isError: false);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Erro ao salvar no Firestore.', isError: true);
    } finally {
       if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF0F4F8);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Gerador de Senhas'),
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1,
        actions: [
          IconButton( icon: const Icon(Icons.info_outline), tooltip: 'Informações do App',
            onPressed: () => _showSnackBar('App Gerador de Senhas - Exercício Flutter.'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPasswordResultWidget(),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _optionsVisible = !_optionsVisible),
              child: Text(_optionsVisible ? 'Ocultar opções' : 'Mostrar opções'),
            ),
            AnimatedCrossFade(
              firstChild: _buildOptionsWidget(), secondChild: Container(),
              crossFadeState: _optionsVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _generatePassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox( width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white), )
                  : const Text('Gerar Senha'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _showSavePasswordDialog,
        tooltip: 'Salvar Senha',
        child: const Icon(Icons.save_outlined),
      ),
    );
  }

  Widget _buildPasswordResultWidget() {
    bool hasPassword = _generatedPassword != 'Senha não informada' && !_generatedPassword.startsWith("Erro");
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(12.0),
        boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, ), ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text( _generatedPassword,
              style: TextStyle( fontSize: 18,
                fontWeight: hasPassword ? FontWeight.bold : FontWeight.normal,
                color: hasPassword ? Colors.black : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis, maxLines: 1,
            ),
          ),
          IconButton( icon: const Icon(Icons.copy_outlined), tooltip: 'Copiar Senha',
            onPressed: () {
              if (hasPassword) {
                Clipboard.setData(ClipboardData(text: _generatedPassword));
                _showSnackBar('Senha copiada!', isError: false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tamanho da senha: ${_passwordLength.round()}'),
        Slider(
          value: _passwordLength, min: _minPasswordLength, max: _maxPasswordLength,
          divisions: (_maxPasswordLength - _minPasswordLength).round(),
          label: _passwordLength.round().toString(),
          onChanged: (value) => setState(() => _passwordLength = value.clamp(_minPasswordLength, _maxPasswordLength)),
        ),
        _buildSwitchTile('Incluir letras maiúsculas (ABC)', _includeUppercase, (val) => setState(() => _includeUppercase = val)),
        _buildSwitchTile('Incluir letras minúsculas (abc)', _includeLowercase, (val) => setState(() => _includeLowercase = val)),
        _buildSwitchTile('Incluir números (123)', _includeNumbers, (val) => setState(() => _includeNumbers = val)),
        _buildSwitchTile('Incluir símbolos (#@!)', _includeSymbols, (val) => setState(() => _includeSymbols = val)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title), value: value, onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor, dense: true, contentPadding: EdgeInsets.zero,
    );
  }
}