import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'calendario_web.dart';

class RegistarUtilizador extends StatefulWidget {
  const RegistarUtilizador({super.key});

  @override
  State<RegistarUtilizador> createState() => _RegistarUtilizadorState();
}

class _RegistarUtilizadorState extends State<RegistarUtilizador> {
  bool showRegisterAlunoFields = false;
  bool showRegisterInstrutorFields = false;
  bool showCalendar = false; // nova variável para o calendário

  final _formKeyAluno = GlobalKey<FormState>();
  final _formKeyInstrutor = GlobalKey<FormState>();

  // Aluno controllers
  final TextEditingController nomeAlunoController = TextEditingController();
  final TextEditingController emailAlunoController = TextEditingController();
  final TextEditingController passwordAlunoController = TextEditingController();
  String? categoriaSelecionada;
  String? instrutorSelecionado;
  final List<String> categorias = ['A', 'B', 'C', 'D'];
  List<String> instrutoresExistentes = [];

  // Instrutor controllers
  final TextEditingController nomeInstrutorController = TextEditingController();
  final TextEditingController emailInstrutorController = TextEditingController();
  final TextEditingController passwordInstrutorController = TextEditingController();

  @override
  void dispose() {
    nomeAlunoController.dispose();
    emailAlunoController.dispose();
    passwordAlunoController.dispose();
    nomeInstrutorController.dispose();
    emailInstrutorController.dispose();
    passwordInstrutorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchInstrutores();
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
          'name': nomeAlunoController.text,
          'email': emailAlunoController.text,
          'password': passwordAlunoController.text,
          'category': categoriaSelecionada,
          'instrutor': instrutorSelecionado,
          'id_type': 1, // id_type fixo para aluno
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
          SnackBar(
              content: Text('Erro: ${jsonDecode(response.body)['error']}')),
        );
      }
    }
  }

  void registrarInstrutor() async {
    if (_formKeyInstrutor.currentState!.validate()) {
      final url = Uri.parse('http://localhost:3000/api/auth/register');

      print('--- A ENVIAR DADOS (Instrutor) ---');
      print('Nome: ${nomeInstrutorController.text}');
      print('Email: ${emailInstrutorController.text}');
      print('Password: default123');
      print('id_type: 2');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nomeInstrutorController.text,
          'email': emailInstrutorController.text,
          'password': passwordInstrutorController.text,
          'id_type': 2
        }),
      );

      print('--- RESPOSTA DO SERVIDOR ---');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instrutor registado com sucesso!')),
        );
        fetchInstrutores();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: ${jsonDecode(response.body)['error']}')),
        );
      }
    }
  }

  void fetchInstrutores() async {
    final url = Uri.parse('http://localhost:3000/api/instrutores');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          instrutoresExistentes = data.map((item) => item['name'] as String).toList();
        });
      } else {
        print('Erro ao buscar instrutores: ${response.body}');
      }
    } catch (e) {
      print('Erro ao conectar ao servidor: $e');
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarioWeb()),
                      );
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
                        showCalendar = false;
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
                        showCalendar = false;
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
                          if (value == null || value
                              .trim()
                              .isEmpty) {
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
                          if (value == null || value
                              .trim()
                              .isEmpty) {
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
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return '*Campo obrigatório';
                          }
                          if (value
                              .trim()
                              .length < 6) {
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
                            .map((cat) =>
                            DropdownMenuItem(
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
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          instrutorSelecionado = val;
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '*Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: registrarAluno,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16ADC2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                          ),
                          child: const Text('Registar Aluno'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Instrutores registados:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...instrutoresExistentes.map((name) => Text('- $name')).toList(),

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
                          if (value == null || value
                              .trim()
                              .isEmpty) {
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
                          if (value == null || value
                              .trim()
                              .isEmpty) {
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
                        controller: passwordInstrutorController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return '*Campo obrigatório';
                          }
                          if (value
                              .trim()
                              .length < 6) {
                            return 'A password deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: registrarInstrutor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16ADC2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                          ),
                          child: const Text('Registar Instrutor'),
                        ),
                      ),
                    ],
                  ),
                ),

              // Área do Calendário
              if (showCalendar)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const CalendarioWeb(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}