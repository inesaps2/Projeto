import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projeto/config.dart';

class ApagarContas extends StatefulWidget {
  const ApagarContas({super.key});

  @override
  State<ApagarContas> createState() => _ApagarContasState();
}

class _ApagarContasState extends State<ApagarContas> {
  List<Map<String, dynamic>> utilizadores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarUtilizadores();
  }

  String tipoUtilizador(int? idType) {
    switch (idType) {
      case 1:
        return 'Aluno';
      case 2:
        return 'Instrutor';
      case 3:
        return 'Recepcionista';
      default:
        return 'Desconhecido';
    }
  }

  Future<void> _buscarUtilizadores() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/utilizadores'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          utilizadores = data.map<Map<String, dynamic>>((item) => {
            'id': item['id'],
            'id_type': item['id_type'],
            'name': item['name'],
            'email': item['email'],
          }).toList();
          carregando = false;
        });
      } else {
        throw Exception('Erro ao buscar utilizadores');
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> _apagarConta(String email) async {
    try {
      final response = await http.delete(Uri.parse('${Config.baseUrl}/api/auth/utilizadores/$email'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilizador apagado com sucesso.'), backgroundColor: Colors.green),
        );
        _buscarUtilizadores(); // Atualiza a lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao apagar: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Erro ao apagar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de rede ao apagar utilizador.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Apagar Contas')),
        body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lista de Utilizadores:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                carregando
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Tipo')),
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: utilizadores.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(tipoUtilizador(user['id_type']))),
                            DataCell(Text(user['name'] ?? '')),
                            DataCell(Text(user['email'] ?? '')),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar'),
                                      content: Text('Apagar o utilizador "${user['email']}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Apagar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmar == true) {
                                    _apagarConta(user['email']);
                                  }
                                },
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
        );
    }
}
