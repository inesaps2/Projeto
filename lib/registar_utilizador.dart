import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projeto/main.dart';
import 'package:projeto/pagina_inicial_web.dart';
import 'package:projeto/perfil_web.dart';
import 'calendario_web.dart';
import 'package:projeto/editar_perfil.dart';
import 'package:projeto/config.dart';


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
  final TextEditingController veiculoAlunoController = TextEditingController();
  String? categoriaSelecionada;
  String? instrutorSelecionado;
  final List<String> categorias = ['A', 'B', 'C', 'D'];
  final List<String> veiculos = ['Opel Corsa', 'Kia Rio', 'Kia Stonic', 'BMW'];
  String? veiculoSelecionado;
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
    veiculoAlunoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchInstrutores();
  }

  void registrarAluno() async {
    if (_formKeyAluno.currentState!.validate()) {
      final url = Uri.parse('${Config.baseUrl}/api/auth/register');

      print('--- A ENVIAR DADOS ---');
      print('Nome: ${nomeAlunoController.text}');
      print('Email: ${emailAlunoController.text}');
      print('Password: ${passwordAlunoController.text}');
      print('Categoria: $categoriaSelecionada');
      print('Instrutor: $instrutorSelecionado');
      print('Veículo: $veiculoSelecionado');
      print('id_type: 1');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nomeAlunoController.text,
          'email': emailAlunoController.text,
          'password': passwordAlunoController.text,
          'category': categoriaSelecionada,
          'instructor': instrutorSelecionado,
          'associated_car': veiculoSelecionado,
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
      final url = Uri.parse('${Config.baseUrl}/api/auth/register');

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
    final url = Uri.parse('${Config.baseUrl}/api/instrutores');
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
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarPerfil()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilWeb()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.login_outlined),
              tooltip: 'Sair',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApp()),
                );
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
              if (!showRegisterAlunoFields && !showRegisterInstrutorFields && !showCalendar)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Número de instrutores: ${instrutoresExistentes.length}'),
                      ],
                    ),
                  ),
                ),
              if (!showRegisterAlunoFields && !showRegisterInstrutorFields && !showCalendar)
                Column(
                  children: [
                    Card(
                      // seu cartão atual aqui
                    ),
                    InformacoesDetalhadas(
                      instrutores: instrutoresExistentes,
                      horariosAulas: [
                        'Segunda-feira: 14:00 - 15:00 / 17:00 - 18:00 / 18:00 - 19:00',
                        'Terça-feira: 14:00 - 15:00 / 17:00 - 18:00',
                        'Quarta-feira: 14:00 - 15:00 / 17:00 - 18:00 / 18:00 - 19:00',
                        'Quinta-feira: 14:00 - 15:00 / 17:00 - 18:00',
                        'Sexta-feira: 14:00 - 15:00 / 17:00 - 18:00 / 19:00 - 20:00',
                        'Sábado: 10:00 - 11:00',
                      ],
                    ),
                  ],
                ),

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
                      const SizedBox(height: 12),

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
                      DropdownButtonFormField<String>(
                        value: instrutorSelecionado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: instrutoresExistentes
                            .map((instrutor) => DropdownMenuItem(
                          value: instrutor,
                          child: Text(instrutor),
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
                      const SizedBox(height: 12),
                      const Text('Veículo'),
                      DropdownButtonFormField<String>(
                        value: veiculoSelecionado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: veiculos
                            .map((veiculo) => DropdownMenuItem(
                          value: veiculo,
                          child: Text(veiculo),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            veiculoSelecionado = val;
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16ADC2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                          ),
                          child: const Text('Registar Aluno'),
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

class InformacoesDetalhadas extends StatelessWidget {
  final List<String> instrutores;
  final List<String> horariosAulas;

  const InformacoesDetalhadas({
    Key? key,
    required this.instrutores,
    required this.horariosAulas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Lista de Instrutores
          const Text(
            'Instrutores:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...instrutores.map((instrutor) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(instrutor),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Horários das aulas
          const Text(
            'Horário das Aulas de Código:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...horariosAulas.map((linha) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(linha),
          )),

          const SizedBox(height: 30),

          // Rodapé azul com informações da escola
          Container(
            width: double.infinity,
            color: const Color(0xFF16ADC2),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Informações da Escola:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text('Horário de funcionamento:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Segunda a Sexta: 09h00 - 20h00', style: TextStyle(color: Colors.white)),
                Text('Segunda a Sexta: 09h00 - 20h00', style: TextStyle(color: Colors.white)),
                Text('Sábado: 09h00 - 13h00', style: TextStyle(color: Colors.white)),
                Text('Domingo: Fechado', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                Text('Contacto:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('271 023 755', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                Text('Endereço:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Rua Dr, Francisco Piçarra de Matos 7 - Cave, 6300-693 Guarda', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
