import 'package:flutter/material.dart';
import 'package:projeto/calendario.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/main.dart';
import 'package:projeto/teste.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projeto/config.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool _avisoMostrado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Session.firstlogin == 1 && !_avisoMostrado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarAlerta();
        _avisoMostrado = true;
      });
    }
  }

  void _mostrarAlerta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso de Segurança'),
        content: const Text('Altere a password para a sua segurança.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoAlterarPassword() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // força o utilizador a responder
      builder: (context) {
        return const AlterarPasswordDialog();
      },
    );

    if (result == true) {
      setState(() {
        _avisoMostrado = false; // permite mostrar outro alerta se necessário
      });

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password alterada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/GO_DRIVING Logotipo FINAL.png',
                      width: 150,
                      height: 50,
                    ),
                    IconButton(
                      icon: const Icon(Icons.login_outlined),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MyApp()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                Center(
                  child: Image.asset('assets/perfil.png', width: 150, height: 150),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nome: ${Session.nome ?? "X"}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('Email: ${Session.email ?? "X@gmail.com"}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),

                      // Mostrar só se for aluno (id_type == 1)
                      if (Session.id_type == 1) ...[
                        Text('Categoria: ${Session.categoria ?? 'A definir'}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 5),
                        Text('Instrutor: ${Session.instructor ?? 'A definir'}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 5),
                        Text('Veículo: ${Session.veiculo ?? 'A definir'}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 5),
                        Text('Aulas: ${Session.aulas ?? 'X'}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 20),
                      ],
                      const SizedBox(height: 20),

                      // Botão para alterar password
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _mostrarDialogoAlterarPassword(),
                          child: const Text('Alterar Password'),
                        ),
                      ),

                      if (Session.firstlogin == 1)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: Colors.yellow[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Altere a password para a sua segurança.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.black87),
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
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16ADC2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 2,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const PaginaInicial()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Calendario()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.home, index: 0, currentIndex: 2),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
                icon: Icons.calendar_month_outlined, index: 1, currentIndex: 2),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.person, index: 2, currentIndex: 2),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
      {required IconData icon, required int index, required int currentIndex}) {
    final bool isSelected = index == currentIndex;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white24 : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    );
  }
}

// Widget do diálogo para alterar password
class AlterarPasswordDialog extends StatefulWidget {
  const AlterarPasswordDialog({super.key});

  @override
  State<AlterarPasswordDialog> createState() => _AlterarPasswordDialogState();
}

class _AlterarPasswordDialogState extends State<AlterarPasswordDialog> {
  final TextEditingController emailController =
  TextEditingController(text: Session.email);
  final TextEditingController antigaController = TextEditingController();
  final TextEditingController novaController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();

  String mensagem = '';

  Future<void> alterarPassword() async {
    final email = emailController.text.trim();
    final antiga = antigaController.text;
    final nova = novaController.text;
    final confirmar = confirmarController.text;

    if (email.isEmpty ||
        antiga.isEmpty ||
        nova.isEmpty ||
        confirmar.isEmpty) {
      setState(() => mensagem = 'Por favor, preencha todos os campos.');
      return;
    }

    if (email != Session.email || antiga != Session.password) {
      setState(() => mensagem = 'Email ou password antiga incorretos.');
      return;
    }

    if (nova != confirmar) {
      setState(() => mensagem = 'As passwords novas não coincidem.');
      return;
    }

    // Chamada HTTP para alterar a password
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/api/auth/alterar_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'antiga_password': antiga,
        'nova_password': nova,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        mensagem = 'Password alterada com sucesso.';
        Session.password = nova;
        Session.firstlogin = 0;
      });

      // Fecha o diálogo sinalizando sucesso
      Navigator.pop(context, true);
    } else {
      setState(() => mensagem = 'Erro ao alterar password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: antigaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password antiga'),
            ),
            TextField(
              controller: novaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova password'),
            ),
            TextField(
              controller: confirmarController,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: 'Confirmar nova password'),
            ),
            const SizedBox(height: 10),
            Text(mensagem, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: alterarPassword,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}