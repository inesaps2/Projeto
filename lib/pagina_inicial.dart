import 'package:flutter/material.dart';
import 'package:projeto/calendario.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/perfil.dart';
import 'package:projeto/main.dart';

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  final String? proximaAula = 'Quarta-feira, 22 Maio • 15:00';

  final List<Map<String, String>> instrutores = const [
    {'nome': 'Pedro Gregório', 'categoria': 'B'},
    {'nome': 'Pedro Monteiro', 'categoria': 'B'},
    {'nome': 'António Carvalho', 'categoria': 'B'},
    {'nome': 'Sérgio Costa', 'categoria': 'B'},
  ];

  final List<String> horariosAulas = const [
    'Segunda-feira: 14:00 - 15:00 / 17:00 - 18:00',
    'Terça-feira: 08:00 - 12:00 / 14:00 - 18:00',
    'Quarta-feira: 08:00 - 12:00 / 14:00 - 18:00',
    'Quinta-feira: 08:00 - 12:00 / 18:00 - 19:00',
    'Sexta-feira: 08:00 - 12:00 / 19:00 - 20:00',
    'Sábado: 10:00 - 11:00',
  ];

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
            // 🔹 Conteúdo com padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Topo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/GO_DRIVING Logotipo FINAL.png',
                        width: 150,
                        height: 150,
                      ),
                      IconButton(
                        icon: const Icon(Icons.login_outlined),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MyApp()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Próxima aula
                  Text(
                    proximaAula != null
                        ? 'Próxima aula: $proximaAula'
                        : 'Não tens nenhuma aula marcada.',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  // Lista de Instrutores
                  const Text(
                    'Instrutores da Escola:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...instrutores.map((instrutor) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(instrutor['nome']!),
                      subtitle: Text('Categoria: ${instrutor['categoria']}'),
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
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Rodapé com fundo azul total
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
                  Text('Horário de abertura:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Segunda a Sexta: 09h00 - 20h00', style: TextStyle(color: Colors.white)),
                  Text('Sábado: 09h00 - 13h00', style: TextStyle(color: Colors.white)),
                  Text('Domingo: Fechado', style: TextStyle(color: Colors.white)),
                  Text('Contacto:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('271 023 755', style: TextStyle(color: Colors.white)),
                  Text('Endereço:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Rua Dr, Francisco Piçarra de Matos 7 - Cave, 6300-693 Guarda', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16ADC2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaginaInicial()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Calendario()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.home, index: 0, currentIndex: 0),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.calendar_month_outlined, index: 1, currentIndex: 0),
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

  Widget _buildNavIcon({required IconData icon, required int index, required int currentIndex}) {
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
