import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistarAluno extends StatefulWidget {
  const RegistarAluno({super.key});

  @override
  State<RegistarAluno> createState() => _RegistarAlunoState();
}

class _RegistarAlunoState extends State<RegistarAluno> {
  bool showRegisterAlunoFields = false;
  bool showRegisterInstrutorFields = false;

  final _formKeyAluno = GlobalKey<FormState>();
  final _formKeyInstrutor = GlobalKey<FormState>();

  // Aluno controllers
  final TextEditingController nomeAlunoController = TextEditingController();
  final TextEditingController emailAlunoController = TextEditingController();
  final TextEditingController passwordAlunoController = TextEditingController();
  String? categoriaSelecionada;
  String? instrutorSelecionado;
  final List<String> categorias = ['A', 'B', 'C', 'D'];
  final List<String> instrutores = ['Pedro 1', 'Pedro 2', 'António', 'Sérgio'];

  // Instrutor controllers
  final TextEditingController nomeInstrutorController = TextEditingController();
  final TextEditingController emailInstrutorController = TextEditingController();

  @override
  void dispose() {
    nomeAlunoController.dispose();
    emailAlunoController.dispose();
    passwordAlunoController.dispose();
    nomeInstrutorController.dispose();
    emailInstrutorController.dispose();
    super.dispose();
  }

  void registrarAluno() async {
    if (_formKeyAluno.currentState!.validate()) {
      final url = Uri.parse('http://localhost:3000/api/auth/register');

      print('--- A ENVIAR DADOS ---');
      print('Nome: ${nomeAlunoController.text}');
      print('Email: ${emailAlunoController.text}');
      print('Password: ${passwordAlunoController.text}');
      print('Categoria: $categoriaSelecionada');
      print('Instrutor: $instrutorSelecionado');
      print('id_type: 1');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nomeAlunoController.text,
          'email': emailAlunoController.text,
          'password': passwordAlunoController.text,
          'category': categoriaSelecionada,
          'instrutor': instrutorSelecionado,
          'id_type': 1,  // id_type fixo para aluno
        }),
      );

      print('--- RESPOSTA DO SERVIDOR ---');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno registado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${jsonDecode(response.body)['error']}')),
        );
      }
    }
  }


  void registrarInstrutor() {
    if (_formKeyInstrutor.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instrutor registado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/GO_DRIVING Logotipo FINAL.png', height: 40),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                // ação perfil
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Página Inicial',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navegar Calendário
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Calendário'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16ADC2),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showRegisterAlunoFields = true;
                        showRegisterInstrutorFields = false;
                      });
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Registar Aluno'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16ADC2),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showRegisterInstrutorFields = true;
                        showRegisterAlunoFields = false;
                      });
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('Registar Instrutor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16ADC2),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Formulário Aluno
              if (showRegisterAlunoFields)
                Form(
                  key: _formKeyAluno,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo: Aluno',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      const Text('Nome'),
                      TextFormField(
                        controller: nomeAlunoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '*Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text('Email'),
                      TextFormField(
                        controller: emailAlunoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '*Campo obrigatório';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text('Password'),
                      TextFormField(
                        controller: passwordAlunoController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '*Campo obrigatório';
                          }
                          if (value.trim().length < 6) {
                            return 'A password deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),

                      const Text('Categoria'),
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: categorias
                            .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            categoriaSelecionada = val;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '*Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text('Instrutor'),
                      DropdownButtonFormField<String>(
                        value: instrutorSelecionado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: instrutores
                            .map((ins) => DropdownMenuItem(
                          value: ins,
                          child: Text(ins),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            instrutorSelecionado = val;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '*Campo obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: registrarAluno,
                          child: const Text('Registar Aluno'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16ADC2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Formulário Instrutor
              if (showRegisterInstrutorFields)
                Form(
                  key: _formKeyInstrutor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo: Instrutor',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      const Text('Nome'),
                      TextFormField(
                        controller: nomeInstrutorController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '*Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text('Email'),
                      TextFormField(
                        controller: emailInstrutorController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '*Campo obrigatório';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: registrarInstrutor,
                          child: const Text('Registar Instrutor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16ADC2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
