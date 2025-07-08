import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projeto/config.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  List<Map<String, dynamic>> utilizadores = [];
  List<String> instructors = [];
  final List<String> categories = ['A', 'B', 'C', 'D', 'E'];
  final List<String> veiculos = ['Opel Corsa', 'Kia Rio', 'Kia Stonic', 'BMW'];
  bool carregando = true;

  //Função para converter id_type para texto
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

  @override
  void initState() {
    super.initState();
    _buscarUtilizadores();
  }

  Future<void> _buscarUtilizadores() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/utilizadores'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          utilizadores = data.map<Map<String, dynamic>>((item) => {
            'id_type': item['id_type'],
            'name': item['name'],
            'email': item['email'],
            'category': item['category'],
            'instructor': item['instructor'],
            'associated_car': item['associated_car'],
          }).toList();
          // Get unique instructors (only those with id_type = 2)
          instructors = data
              .where((user) => user['id_type'] == 2)
              .map((user) => user['name'] as String)
              .toSet()
              .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil')),
        body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String? emailSelecionado;
                    Map<String, dynamic>? utilizadorSelecionado;

                    // Controllers fora do builder para manter estado
                    TextEditingController nomeController = TextEditingController();
                    TextEditingController categoriaController = TextEditingController();
                    TextEditingController instrutorController = TextEditingController();
                    TextEditingController veiculoController = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: const Text('Selecionar Email'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: emailSelecionado,
                                    items: utilizadores.map<DropdownMenuItem<String>>((user) {
                                      return DropdownMenuItem<String>(
                                        value: user['email'],
                                        child: Text(user['email']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        emailSelecionado = value;
                                        utilizadorSelecionado = utilizadores.firstWhere(
                                              (user) => user['email'] == value,
                                          orElse: () => {},
                                        );

                                        // Atualiza os controllers com os valores do utilizador selecionado
                                        nomeController.text = utilizadorSelecionado?['name'] ?? '';
                                        categoriaController.text = utilizadorSelecionado?['category'] ?? '';
                                        instrutorController.text = utilizadorSelecionado?['instructor'] ?? '';
                                        veiculoController.text = utilizadorSelecionado?['associated_car'] ?? '';
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  if (utilizadorSelecionado != null) ...[
                                    TextField(
                                      controller: nomeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: categoriaController.text.isNotEmpty ? categoriaController.text : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Categoria',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: categories.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          categoriaController.text = newValue;
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: instrutorController.text.isNotEmpty ? instrutorController.text : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Instrutor',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: instructors.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          instrutorController.text = newValue;
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: veiculoController.text.isNotEmpty ? veiculoController.text : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Veículo',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: veiculos.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          veiculoController.text = newValue;
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (emailSelecionado != null) {
                                      final url = Uri.parse('${Config.baseUrl}/api/utilizadores/$emailSelecionado');

                                      final response = await http.put(
                                        url,
                                        headers: {'Content-Type': 'application/json'},
                                        body: jsonEncode({
                                          'name': nomeController.text,
                                          'category': categoriaController.text,
                                          'instructor': instrutorController.text,
                                          'associated_car': veiculoController.text,
                                        }),
                                      );

                                      if (response.statusCode == 200) {
                                        // Mostrar SnackBar de sucesso
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Utilizador atualizado com sucesso!'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );

                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Erro ao atualizar: ${response.body}'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Text('Editar Perfil'),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Lista de Utilizadores:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                carregando
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Tipo de Utilizador')),
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Email')),
                        ],
                        rows: utilizadores.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(tipoUtilizador(user['id_type']))),
                              DataCell(Text(user['name'] ?? '')),
                              DataCell(Text(user['email'] ?? '')),
                            ],
                          );
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
