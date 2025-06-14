import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'login_selector.dart';
import 'login_recepcionista.dart';
import 'painel_recepcionista.dart';
import 'PaginaInicial_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16ADC2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // Localização
      supportedLocales: const [Locale('pt', 'PT')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('pt', 'PT'),

      title: 'App com Calendário',

      // Página inicial alterada
      home: const PaginaInicialWeb(),

      // Rotas
      routes: {
        '/painelRecepcionista': (context) => PainelRecepcionista(),
      },
    );
  }
}
