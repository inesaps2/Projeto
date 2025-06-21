import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/calendario.dart';
import 'package:projeto/perfil.dart';
import 'package:projeto/main.dart';

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  List<String> instrutoresExistentes = [];

  final List<String> horariosAulas = const [
    'Segunda-feira:',
    '14:00 - 15:00 / 17:00 - 18:00 / 18:00 - 19:00',
    'Terça-feira:',
    '14:00 - 15:00 / 17:00 - 18:00',
    'Quarta-feira:',
    '14:00 - 15:00 / 17:00 - 18:00 / 18:00 - 19:00',
    'Quinta-feira:',
    '14:00 - 15:00 / 17:00 - 18:00',
    'Sexta-feira:',
    '14:00 - 15:00 / 17:00 - 18:00 / 19:00 - 20:00',
    'Sábado:',
    '10:00 - 11:00',
  ];

  @override
  void initState() {
    super.initState();
    fetchInstrutores();
  }

  void fetchInstrutores() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/instrutores');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          instrutoresExistentes =
              data.map<String>((item) => item['name'] as String).toList();
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
        title: const Text('Página Inicial'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      'assets/GO_DRIVING Logotipo FINAL.png',
                      width: 150,
                      height: 50,
                    ),
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
            ),
            const SizedBox(height: 24),

            // Lista de Instrutores
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // margem à esquerda
              child: Text(
                'Instrutores:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            instrutoresExistentes.isEmpty
                ? const CircularProgressIndicator()
                : Column(
              children: instrutoresExistentes.map((nome) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(nome),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Horários das aulas
            Padding(
              padding: const EdgeInsets.only(left: 16.0), // margem à esquerda
              child: Text(
                'Horário das Aulas de Código:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),
            ...horariosAulas.map(
                  (linha) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                child: Text(linha),
              ),
            ),
            const SizedBox(height: 30),

            // Rodapé
            Container(
              width: double.infinity,
              color: const Color(0xFF16ADC2),
              padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Informações da Escola:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text('Horário de abertura:',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Segunda a Sexta: 09h00 - 20h00',
                      style: TextStyle(color: Colors.white)),
                  Text('Sábado: 09h00 - 13h00',
                      style: TextStyle(color: Colors.white)),
                  Text('Domingo: Fechado',
                      style: TextStyle(color: Colors.white)),
                  SizedBox(height: 12),
                  Text('Contacto:',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('271 023 755', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 12),
                  Text('Endereço:',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    'Rua Dr, Francisco Piçarra de Matos 7 - Cave, 6300-693 Guarda',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16ADC2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const PaginaInicial()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Calendario()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Perfil()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.home, index: 0, currentIndex: 0),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
                icon: Icons.calendar_month_outlined, index: 1, currentIndex: 0),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.person, index: 2, currentIndex: 0),
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
