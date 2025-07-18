import 'package:flutter/material.dart';
import 'login_web.dart';
import 'registar_recepcionista.dart';

class PaginaInicialWeb extends StatelessWidget {
  const PaginaInicialWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/GO_DRIVING Logotipo vertical.png', height: 100),
              const SizedBox(height: 40),
              const Text(
                'Bem-vindo(a)!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginWeb()),
                  );
                },
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: Color(0xFF16ADC2),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistarRecepcionista()),
                  );
                },
                child: const Text('Registar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
