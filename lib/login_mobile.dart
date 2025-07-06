import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/teste.dart';
import 'package:projeto/config.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login(String email, String password) async {
    final uri = Uri.parse('${Config.baseUrl}/api/auth/login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final int idType = user['id_type'];

        if (idType == 3) {
          // Bloqueia recepcionista
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recepcionistas não têm acesso à aplicação móvel.")),
          );
          return;
        }

        // Guarda os dados em sessão
        Session.email = user['email'];
        Session.password = password;
        Session.nome = user['name'];
        Session.categoria = user['categoria'];
        Session.instructor = user['instructor'] ?? 'A definir';
        Session.veiculo = user['veiculo'];
        Session.aulas = user['aulas'];
        Session.firstlogin = user['first_login'];
        Session.id_type = user['id_type'];
        Session.aulas = user['aulas'];

        print("✅ Login com sucesso: ${user['name']}");
        print("🟡 first_login = ${Session.firstlogin}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PaginaInicial()),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${error['error']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de rede: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // espaço extra opcional
                Image.asset('assets/GO_DRIVING Logotipo vertical.png', width: 100),
                const SizedBox(height: 10),
                Image.asset('assets/perfil.png', width: 100),
                const SizedBox(height: 20),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password é obrigatória';
                    }
                    final specialCharRegex = RegExp(r'[<>_\W]');
                    if (specialCharRegex.hasMatch(value)) {
                      return 'A password não pode conter caracteres especiais';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botão Login
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      login(email, password);
                    }
                  },
                  child: const Text('Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}