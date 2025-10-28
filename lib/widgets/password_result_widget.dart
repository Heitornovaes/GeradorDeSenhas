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
    final String displayPassword =
        (password.isEmpty) ? 'Senha não informada' : password;

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
          
          if (password.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Copiar Senha',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: password));
                
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