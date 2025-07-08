import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teste.dart';
import 'package:projeto/config.dart';


class AlterarPassword extends StatefulWidget {
  const AlterarPassword({super.key});

  @override
  State<AlterarPassword> createState() => _AlterarPasswordState();
}

class _AlterarPasswordState extends State<AlterarPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordAntigaController = TextEditingController();
  final TextEditingController _novaPasswordController = TextEditingController();
  final TextEditingController _confirmarNovaPasswordController = TextEditingController();

  String mensagem = '';

  Future<void> alterarPassword() async {
    final email = _emailController.text;
    final antiga = _passwordAntigaController.text;
    final nova = _novaPasswordController.text;
    final confirmar = _confirmarNovaPasswordController.text;

    if (nova != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As novas passwords não coincidem')),
      );
      return;
    }

    final url = Uri.parse('${Config.baseUrl}/api/auth/alterar_password'); // emulador Android

    print('Enviando pedido PUT para: $url');
    print('Dados: $email | $antiga | $nova');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'antiga_password': antiga,
          'nova_password': nova,
        }),
      );

      print('Resposta da API: ${response.statusCode}');
      print('Corpo: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password alterada com sucesso!')),
        );
        Navigator.of(context).pop(); // Fecha o diálogo
      } else {
        final msg = jsonDecode(response.body)['error'] ?? 'Erro ao alterar a password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $msg')),
        );
      }
    } catch (e) {
      print('Erro na requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro na ligação ao servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordAntigaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password antiga'),
            ),
            TextField(
              controller: _novaPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova password'),
            ),
            TextField(
              controller: _confirmarNovaPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar nova password'),
            ),
            const SizedBox(height: 20),

            if (mensagem.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  mensagem,
                  style: TextStyle(
                    color: mensagem.contains('sucesso') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ElevatedButton(
              onPressed: alterarPassword,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
