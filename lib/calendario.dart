import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/teste.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:projeto/main.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/perfil.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<int, Map<String, dynamic>>> _eventos = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _carregarAulasMarcadas();
  }

  Future<void> _carregarAulasMarcadas() async {
    final uri = Uri.parse('http://10.0.2.2:3000/api/aulas?email=${Session.email}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Dados recebidos: $data');
      final Map<DateTime, Map<int, Map<String, dynamic>>> novosEventos = {};

      for (var aula in data) {
        final dt = DateTime.parse(aula['data_hora']);
        final key = DateTime(dt.year, dt.month, dt.day);
        final hora = dt.hour;
        final name = aula['nome_aluno'] ?? aula['nome_estudante'] ?? '';
        final id = aula['id'];
        final status = aula['class_status'] ?? 'pendente';

        if (!novosEventos.containsKey(key)) {
          novosEventos[key] = {};
        }
        novosEventos[key]![hora] = {
          'name': name,
          'id': id,
          'status': status,
        };
      }

      setState(() {
        _eventos = novosEventos;
      });
    } else {
      print('Erro ao carregar aulas: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aulas')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/GO_DRIVING Logotipo FINAL.png',
                    width: 150,
                    height: 50,
                  ),
                  if (_selectedDay?.weekday != DateTime.sunday)
                    ElevatedButton(
                      onPressed: () {
                        final nomeController = TextEditingController();
                        int horaSelecionada = 9;

                        final isSabado = _selectedDay!.weekday == DateTime.saturday;
                        final horasDisponiveis = isSabado
                            ? List.generate(5, (index) => 9 + index)   // 9 a 13
                            : List.generate(11, (index) => 9 + index); // 9 a 19

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
                                    items: horasDisponiveis.map((hora) {
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
                                    if (nome.isEmpty) return;

                                    final uri = Uri.parse('http://10.0.2.2:3000/api/aulas');
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 11,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final hora = 9 + index;
                  final dia = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                  final eventosDoDia = _eventos[dia] ?? {};
                  final evento = eventosDoDia[hora];
                  final nomeAluno = evento?['name'];
                  final aulaId = evento?['id'];
                  final status = evento?['status'];

                  final isDomingo = dia.weekday == DateTime.sunday;
                  final isSabado = dia.weekday == DateTime.saturday;
                  final horaForaDoHorarioSabado = isSabado && hora >= 14 && hora <= 19;
                  final isHoraBloqueada = isDomingo || horaForaDoHorarioSabado;

                  final foiMarcadoPorEsteAluno = nomeAluno != null && nomeAluno == Session.nome;

                  return Container(
                    decoration: isHoraBloqueada
                        ? BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    )
                        : null,
                    child: ListTile(
                      title: Text('$hora:00'),
                      subtitle: nomeAluno != null ? Text('Marcado por: $nomeAluno') : null,
                      trailing: (aulaId != null)
                          ? (Session.id_type == 1 && foiMarcadoPorEsteAluno)
                          ? Builder(builder: (context) {
                        final agora = DateTime.now();
                        final dataHoraAula = DateTime(dia.year, dia.month, dia.day, hora);
                        final diferenca = dataHoraAula.difference(agora);
                        final podeApagar = diferenca.inHours >= 24;

                        return IconButton(
                          icon: Icon(Icons.delete, color: podeApagar ? Colors.red : Colors.grey),
                          tooltip: podeApagar ? 'Apagar aula' : 'Só pode apagar com 24h de antecedência',
                          onPressed: podeApagar
                              ? () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Apagar Aula'),
                                content: Text('Tem certeza que quer apagar a aula das $hora:00?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apagar')),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final uri = Uri.parse('http://10.0.2.2:3000/api/aulas/$aulaId');
                              final response = await http.delete(uri);

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Aula apagada com sucesso.")),
                                );
                                _carregarAulasMarcadas();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Erro ao apagar aula.")),
                                );
                              }
                            }
                          }
                              : null,
                        );
                      })
                          : (Session.id_type == 2)
                          ? (status == 'concluída')
                          ? Text('Concluída', style: TextStyle(color: Colors.green))
                          : ElevatedButton(
                        child: const Text('Concluída'),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Marcar Aula como Concluída'),
                              content: Text('Confirmar que a aula das $hora:00 foi concluída?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final uri = Uri.parse('http://10.0.2.2:3000/api/aulas/concluir/$aulaId');
                            final response = await http.post(uri);

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Aula marcada como concluída.")),
                              );
                              _carregarAulasMarcadas();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Erro ao marcar aula como concluída.")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      )
                          : null
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16ADC2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaginaInicial()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.home, index: 0, currentIndex: 1),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.calendar_month_outlined, index: 1, currentIndex: 1),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(icon: Icons.person, index: 2, currentIndex: 1),
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