import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importa as telas que vamos usar
import 'package:meu_gerador_senhas/screens/login_screen.dart';
import 'package:meu_gerador_senhas/screens/new_password_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pega o usuário logado
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Função de Logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    
    // Navega de volta para o Login
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Função para deletar uma senha
  Future<void> _deletePassword(String docId) async {
    // Pega a referência do documento no Firestore e deleta
    await FirebaseFirestore.instance
        .collection('passwords')
        .doc(docId)
        .delete();
  }

  // Função para navegar para a tela de nova senha
  void _goToNewPasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor de fundo (um cinza claro, como no PDF)
    final Color backgroundColor = const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Gerador de Senhas'),
        backgroundColor: const Color(0xFF0D47A1), // Um tom de azul escuro
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Email do Usuário e Banner Premium
          _buildHeader(),
          
          // 2. Título "Minhas Senhas"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Minhas Senhas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 3. Lista de Senhas (com StreamBuilder)
          Expanded(
            child: _buildPasswordList(),
          ),
        ],
      ),
      // 4. Botão Flutuante (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNewPasswordScreen,
        tooltip: 'Adicionar Senha',
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget do Cabeçalho
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D47A1), // Azul escuro do AppBar
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Email do usuário
          if (_currentUser?.email != null)
            Text(
              _currentUser!.email!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 16),
          
          // Banner "GET PREMIUM"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.blue, size: 40),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GET PREMIUM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Proteja-se ainda mais',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {}, // Ação do botão "BUY"
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('BUY'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget da Lista de Senhas
  Widget _buildPasswordList() {
    // 1. Verificar se o usuário está logado
    if (_currentUser == null) {
      return const Center(child: Text('Erro: Usuário não logado.'));
    }

    // 2. Criar o StreamBuilder
    return StreamBuilder<QuerySnapshot>(
      // 3. Definir a 'stream' (a fonte dos dados)
      stream: FirebaseFirestore.instance
          .collection('passwords') // Acessa a coleção "passwords"
          // Filtra para mostrar APENAS senhas do usuário logado
          .where('userId', isEqualTo: _currentUser!.uid) 
          .snapshots(), // Pega atualizações em tempo real

      // 4. Definir o 'builder' (o que construir com os dados)
      builder: (context, snapshot) {
        
        // 5. Lidar com o estado de Carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 6. Lidar com Erros
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar senhas.'));
        }

        // 7. Lidar com Lista Vazia
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyListWidget(); // Mostra o widget de lista vazia
        }

        // 8. Se tudo deu certo, mostrar a lista
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            // Pega os dados do documento
            final data = docs[index].data() as Map<String, dynamic>;
            final String label = data['label'] ?? 'Sem Rótulo';
            final String password = data['password'] ?? '*******';
            
            // Pega o ID do documento
            final String docId = docs[index].id; 

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.vpn_key_outlined, color: Colors.grey),
                title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(password),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Deletar Senha',
                  onPressed: () => _deletePassword(docId),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget para quando a lista está vazia (página 10 do PDF)
  Widget _buildEmptyListWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Você pode usar uma imagem ou Lottie aqui
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum registro encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            'Adicione uma senha para começar!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}