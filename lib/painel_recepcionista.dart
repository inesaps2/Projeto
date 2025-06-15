import 'package:flutter/material.dart';
import 'registar_aluno.dart';

class PainelRecepcionista extends StatelessWidget {
  const PainelRecepcionista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/GO_DRIVING Logotipo FINAL.png',
              height: 40,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Painel da Recepcionista',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Calendário'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16ADC2),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistarAluno()),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Registar Aluno'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16ADC2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}