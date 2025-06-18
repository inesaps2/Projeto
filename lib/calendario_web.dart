import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/registar_utilizador.dart';
import 'package:projeto/teste.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:projeto/main.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/perfil.dart';

class CalendarioWeb extends StatefulWidget {
  const CalendarioWeb({super.key});

  @override
  State<CalendarioWeb> createState() => _CalendarioWebState();
}

Set<String> _horariosAceites = {};

String gerarChaveDiaHora(DateTime data, int hora) {
  final dataFormatada = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  return '${dataFormatada}_$hora';
}

class _CalendarioWebState extends State<CalendarioWeb> {
  final TextEditingController _instrutorController = TextEditingController();

  int? _idInstrutorSelecionado;

  void onInstrutorSelecionado(int id) {
    setState(() {
      _idInstrutorSelecionado = id;
    });
    print('Instrutor selecionado com id: $_idInstrutorSelecionado');
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<int, String>> _eventos = {};

  Future<void> _verificarInstrutor() async {
    final nomeInstrutor = _instrutorController.text.trim();

    if (nomeInstrutor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do instrutor.')),
      );
      return;
    }

    try {
      final uri = Uri.parse('http://localhost:3000/api/instrutores?nome=$nomeInstrutor');
      final response = await http.get(uri);

      print('Body completo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Resposta do backend (instrutor): $data');

        if (data != null && data['existe'] == true) {
          final id_instructor = data['id'];  // pega o id do instrutor
          print('Instrutor selecionado com id: $id_instructor');
          setState(() {
            _idInstrutorSelecionado = id_instructor;  // atualiza o estado com o id
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Instrutor "$nomeInstrutor" encontrado!')),
          );
          await _carregarAulasDoInstrutor(nomeInstrutor);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Instrutor "$nomeInstrutor" não encontrado.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao verificar instrutor.')),
        );
      }
    } catch (e) {
      print('Erro na verificação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão com o servidor.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _carregarAulasMarcadas();
  }

  Future<void> _carregarAulasMarcadas() async {
    final uri = Uri.parse('http://localhost:3000/aulas?email=${Session.email}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Dados recebidos: $data');
      final Map<DateTime, Map<int, String>> novosEventos = {};

      for (var aula in data) {
        final dt = DateTime.parse(aula['data_hora']);
        final key = DateTime(dt.year, dt.month, dt.day);
        final hora = dt.hour;
        final nome = aula['nome_aluno'] ?? '';

        if (!novosEventos.containsKey(key)) {
          novosEventos[key] = {};
        }
        novosEventos[key]![hora] = nome;
      }

      print('Eventos carregados:');
      novosEventos.forEach((key, value) {
        print('$key -> $value');
      });

      setState(() {
        _eventos = novosEventos;
      });
    } else {
      print('Erro ao carregar aulas: ${response.statusCode}');
    }
  }

  Future<void> _carregarAulasDoInstrutor(String nomeInstrutor) async {
    final uri = Uri.parse('http://localhost:3000/api/aulas?instrutor=$nomeInstrutor');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Aulas do instrutor recebidas: $data');

      //Pegar id do instrutor da primeira aula, se existir
      if (data.isNotEmpty && _idInstrutorSelecionado == null) {
        final primeiroId = data.first['id_instructor'];
        setState(() {
          _idInstrutorSelecionado = primeiroId;
        });
        print('ID do instrutor definido a partir das aulas: $primeiroId');
      }

      final Map<DateTime, Map<int, String>> novosEventos = {};

      for (var aula in data) {
        final dt = DateTime.parse(aula['data_hora']);
        final key = DateTime(dt.year, dt.month, dt.day);
        final hora = dt.hour;
        final nome = aula['nome_aluno'] ?? '';

        if (!novosEventos.containsKey(key)) {
          novosEventos[key] = {};
        }
        novosEventos[key]![hora] = nome;

        final class_status = aula['class_status'] ?? '';
        final diaHoraKey = '${dt.year}-${dt.month}-${dt.day}_$hora';
        if (class_status == 'aceite') {
          _horariosAceites.add(diaHoraKey);
        }
      }

      setState(() {
        _eventos = novosEventos;
      });
    } else {
      print('Erro ao carregar aulas do instrutor: ${response.statusCode}');
    }
  }

  Future<void> _atualizarStatusAula(DateTime data, int hora, String novoStatus) async {
    if (_idInstrutorSelecionado == null) {
      print('Erro: Nenhum instrutor selecionado');
      return;
    }

    try {
      // Formata a data e hora para o formato esperado pelo banco
      final dataFormatada = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      final horaFormatada = hora.toString().padLeft(2, '0');
      final dataHora = '$dataFormatada $horaFormatada:00:00.000'; // Adiciona milissegundos

      print('Enviando requisição para: http://localhost:3000/api/classes/status');
      print('Dados: ${{
        'id_instructor': _idInstrutorSelecionado,
        'data': dataFormatada,
        'hora': horaFormatada,
        'novo_status': novoStatus
      }}');

      final response = await http.put(
        Uri.parse('http://localhost:3000/api/classes/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_instructor': _idInstrutorSelecionado,
          'data': dataFormatada,
          'hora': horaFormatada,
          'novo_status': novoStatus,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Resposta do servidor: $responseData');

        // Atualiza a interface sem recarregar tudo
        setState(() {
          final diaHoraKey = gerarChaveDiaHora(data, hora);
          if (novoStatus == 'aceite') {
            _horariosAceites.add(diaHoraKey);
          } else if (novoStatus == 'recusada') {
            _horariosAceites.remove(diaHoraKey);
          }
        });

        // Mostra mensagem de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  novoStatus == 'aceite'
                      ? 'Aula aceita com sucesso!'
                      : 'Aula recusada com sucesso!'
              ),
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body)?['error'] ?? 'Erro desconhecido';
        print('Erro ao atualizar status: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $error')),
          );
        }
      }
    } catch (e) {
      print('Erro na requisição: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      }
    }
  }

  void _mostrarDialogoMarcarAula(int horaSelecionada) {
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Marcar Aulaaaa'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final nome = nomeController.text.trim();
                if (nome.isEmpty) return;

                final uri = Uri.parse('http://localhost:3000/api/aulas');
                final resp = await http.post(
                  uri,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'email': Session.email,
                    'nomeAluno': nome,
                    'data': _selectedDay!.toIso8601String().split('T')[0],
                    'hora': horaSelecionada.toString(),
                  }),
                );

                Navigator.pop(context);
                if (resp.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Aula marcada com sucesso!")),
                  );
                  _carregarAulasMarcadas();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erro ao marcar aula.")),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16ADC2),
        title: const Text('Calendário'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegistarUtilizador()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _instrutorController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Instrutor',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _verificarInstrutor,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                    child: const Text('Ver Horário'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final nomeController = TextEditingController();
                      int horaSelecionada = 9;

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Marcar Aula'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nomeController,
                                  decoration: const InputDecoration(labelText: 'Nome'),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<int>(
                                  value: horaSelecionada,
                                  decoration: const InputDecoration(labelText: 'Hora'),
                                  items: List.generate(11, (index) => 9 + index).map((hora) {
                                    return DropdownMenuItem<int>(
                                      value: hora,
                                      child: Text('$hora:00'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    horaSelecionada = value!;
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  final nome = nomeController.text.trim();
                                  if (nome.isEmpty || _selectedDay == null) return;

                                  final uri = Uri.parse('http://localhost:3000/api/aulas');
                                  final resp = await http.post(
                                    uri,
                                    headers: {'Content-Type': 'application/json'},
                                    body: jsonEncode({
                                      'email': Session.email,
                                      'nomeAluno': nome,
                                      'data': _selectedDay!.toIso8601String().split('T')[0],
                                      'hora': horaSelecionada.toString(),
                                    }),
                                  );

                                  Navigator.pop(context);
                                  if (resp.statusCode == 201) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Aula marcada com sucesso!")),
                                    );
                                    _carregarAulasMarcadas();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Erro ao marcar aula.")),
                                    );
                                  }
                                },
                                child: const Text('Confirmar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16ADC2)),
                    child: const Text('Marcar Aula'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                locale: 'pt_PT',
                eventLoader: (day) {
                  final dia = DateTime(day.year, day.month, day.day);
                  return _eventos.containsKey(dia) ? [1] : [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarFormat: CalendarFormat.week,
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF16ADC2),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedDay != null)
                Text(
                  '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 16),
              if (_selectedDay != null)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 11,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final hora = 9 + index;
                    final dia = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    );
                    final eventosDoDia = _eventos[dia] ?? {};
                    final nomeAluno = eventosDoDia[hora];
                    final diaHoraKey = gerarChaveDiaHora(dia, hora);
                    final aceite = _horariosAceites.contains(diaHoraKey);

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: aceite ? Colors.green[100] : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$hora:00', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                if (nomeAluno != null)
                                  Text('Marcado por: $nomeAluno', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          if (nomeAluno != null && !aceite)
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    print('Aceitar aula - Instrutor: $_idInstrutorSelecionado, Data: ${_selectedDay.toString().split(' ')[0]}, Hora: $hora');
                                    if (_idInstrutorSelecionado != null && _selectedDay != null) {
                                      await _atualizarStatusAula(_selectedDay!, hora, 'aceite');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Aceitar'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_idInstrutorSelecionado != null && _selectedDay != null) {
                                      await _atualizarStatusAula(_selectedDay!, hora, 'recusada');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Recusar'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}