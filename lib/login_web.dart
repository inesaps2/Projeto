import 'package:flutter/material.dart';
import 'PaginaInicial.dart';

class LoginWeb extends StatelessWidget {
  const LoginWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Versão Web')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo à versão Web'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PaginaInicial()),
                );
              },
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Aqui você colocaria o código para abrir a página de registro
              },
              child: const Text('Registar novo utilizador'),
            ),
          ],
        ),
      ),
    );
  }
}
