import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projeto/config.dart';

class RegistarRecepcionista extends StatefulWidget {
  const RegistarRecepcionista({super.key});

  @override
  State<RegistarRecepcionista> createState() => _RegistarRecepcionistaState();
}

class _RegistarRecepcionistaState extends State<RegistarRecepcionista> {
  // Controladores para os campos do formulário
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void registarRecepcionista() async {
    /// Regista uma nova rececionista na base de dados
    /// Valida o formulário e envia os dados para a API
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('${Config.baseUrl}/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nomeController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'id_type': 3 // Valor fixo que identifica um utilizador como rececionista
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recepcionista registada com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${jsonDecode(response.body)['error']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registar Recepcionista')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Registo da Recepcionista', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Campo para inserir o nome da rececionista
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? '*Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),

              // Campo para inserir o email com validação de formato
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return '*Campo obrigatório';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return !emailRegex.hasMatch(value) ? 'Email inválido' : null;
                },
              ),
              const SizedBox(height: 15),

              // Campo para a password com mínimo de 6 caracteres
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'A password deve ter pelo menos 6 caracteres',
              ),
              const SizedBox(height: 30),

              // Botão para submeter o formulário
              ElevatedButton(
                onPressed: registarRecepcionista,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16ADC2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Registar Recepcionista'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
