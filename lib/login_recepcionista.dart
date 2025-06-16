import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projeto/registar_utilizador.dart';

class LoginRecepcionista extends StatefulWidget {
  const LoginRecepcionista({super.key});

  @override
  State<LoginRecepcionista> createState() => _LoginRecepcionistaState();
}

class _LoginRecepcionistaState extends State<LoginRecepcionista> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> fazerLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensagem('Preencha todos os campos.');
      return;
    }

    try {
      print('A fazer pedido de login...');
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('Dados recebidos: $data');
        if (data['id_type'] == 3) {
          // ✅ É recepcionista
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RegistarUtilizador()),
          );
        } else {
          _mostrarMensagem('Apenas recepcionistas podem aceder à versão web.');
        }
      } else {
        _mostrarMensagem('Credenciais inválidas.');
      }
    } catch (e) {
      _mostrarMensagem('Erro ao conectar. Verifique sua rede ou servidor.');
    }
  }

  void _mostrarMensagem(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aviso'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Recepcionista')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: fazerLogin,
              child: const Text('Entrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16ADC2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
