import 'package:flutter/material.dart';
import 'package:projeto/calendario.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/main.dart';
import 'package:projeto/teste.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilWeb extends StatefulWidget {
  const PerfilWeb({super.key});

  @override
  State<PerfilWeb> createState() => _PerfilWebState();
}

class _PerfilWebState extends State<PerfilWeb> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16ADC2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Perfil'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/GO_DRIVING Logotipo FINAL.png',
                    width: 150, height: 150),
              ],
            ),
          ),
          Center(
            child: Image.asset('assets/perfil.png', width: 150, height: 150),
          ),
          const SizedBox(height: 20),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
