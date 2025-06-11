import 'package:flutter/material.dart';
import 'package:projeto/Calendario.dart';
import 'package:projeto/PaginaInicial.dart';
import 'package:projeto/Perfil.dart';
import 'package:projeto/main.dart';

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topo: imagem à esquerda e botão à direita
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                      MaterialPageRoute(builder: (context) => const MyApp()), // ou outra página que queiras no main.dart
                    );
                  },

                ),
              ],
            ),
          ),
        ],
      ),
      // Barra inferior com ícones
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
