import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meu_gerador_senhas/screens/login_screen.dart';
import 'package:meu_gerador_senhas/screens/new_password_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
   
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  
  Future<void> _deletePassword(String docId) async {
    
    await FirebaseFirestore.instance
        .collection('passwords')
        .doc(docId)
        .delete();
  }

  
  void _goToNewPasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
   
    final Color backgroundColor = const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Gerador de Senhas'),
        backgroundColor: const Color(0xFF0D47A1), 
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          
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
          
          _buildHeader(),
          
       
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
          
         
          Expanded(
            child: _buildPasswordList(),
          ),
        ],
      ),
  
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNewPasswordScreen,
        tooltip: 'Adicionar Senha',
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D47A1), 
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
          
          // Banner 
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
                  onPressed: () {}, 
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

  
  Widget _buildPasswordList() {
   
    if (_currentUser == null) {
      return const Center(child: Text('Erro: Usuário não logado.'));
    }

    
    return StreamBuilder<QuerySnapshot>(
      
      stream: FirebaseFirestore.instance
          .collection('passwords') 
         
          .where('userId', isEqualTo: _currentUser!.uid) 
          .snapshots(), 

     
      builder: (context, snapshot) {
        
      
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

       
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar senhas.'));
        }

        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyListWidget(); 
        }

        
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String label = data['label'] ?? 'Sem Rótulo';
            final String password = data['password'] ?? '*******';
            
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


  Widget _buildEmptyListWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
     
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