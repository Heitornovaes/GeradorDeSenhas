import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordResultWidget extends StatelessWidget {
  final String password;

  const PasswordResultWidget({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    // Define a mensagem a ser mostrada
    final String displayPassword =
        (password.isEmpty) ? 'Senha não informada' : password;

    // A cor muda se a senha existir
    final Color displayColor =
        (password.isEmpty) ? Colors.grey : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texto (Senha ou Placeholder)
          Expanded(
            child: Text(
              displayPassword,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Botão de Copiar (só aparece se houver senha)
          if (password.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Copiar Senha',
              onPressed: () {
                // Copia para a área de transferência
                Clipboard.setData(ClipboardData(text: password));
                
                // Mostra um feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Senha copiada!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}