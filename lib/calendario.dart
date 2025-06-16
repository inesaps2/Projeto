import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/teste.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:projeto/main.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/perfil.dart';

class Calendario extends StatefulWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> _horarios = ['9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19'];
  String _instrutorSelecionado = 'João';

  final List<String> _instrutores = ['João', 'Ana', 'Carlos', 'Sofia'];
  final List<String> _weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _marcarAula(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String nomeAluno = '';
        String? horaSelecionada;

        return AlertDialog(
          title: const Text('Marcar Aula'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nome do Aluno'),
                onChanged: (value) {
                  nomeAluno = value;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Hora'),
                items: _horarios.map((hora) {
                  return DropdownMenuItem(
                    value: hora,
                    child: Text('$hora:00'),
                  );
                }).toList(),
                onChanged: (value) {
                  horaSelecionada = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeAluno.isNotEmpty && horaSelecionada != null) {
                  final data = _selectedDay?.toIso8601String().split('T').first;
                  final instrutor = _instrutorSelecionado;

                  // Aqui podes fazer a chamada à API
                  print('📅 Aula marcada: Aluno: $nomeAluno, Data: $data, Hora: $horaSelecionada, Instrutor: $instrutor');

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aula marcada com sucesso!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16ADC2)),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month];
  }

  String _getDayOfWeekName(DateTime date) {
    const days = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aulas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logotipo
            Row(
              children: [
                Image.asset(
                  'assets/GO_DRIVING Logotipo FINAL.png',
                  width: 150,
                  height: 50,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Linha com dropdown + botão
            // Linha com dropdown + botão com margem e título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coluna com texto e dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instrutor:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _instrutorSelecionado,
                            items: _instrutores.map((instrutor) {
                              return DropdownMenuItem<String>(
                                value: instrutor,
                                child: Text(instrutor),
                              );
                            }).toList(),
                            onChanged: (novoInstrutor) {
                              setState(() {
                                _instrutorSelecionado = novoInstrutor!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Botão Marcar Aula à direita
                  ElevatedButton(
                    onPressed: () => _marcarAula(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16ADC2)),
                    child: const Text('Marcar Aula'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Calendário
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
              daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (date, locale) => _weekdays[date.weekday % 7],
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

            // Dia selecionado
            if (_selectedDay != null)
              Text(
                '${_selectedDay!.day} de ${_getMonthName(_selectedDay!.month)} - ${_getDayOfWeekName(_selectedDay!)}',
                style: const TextStyle(fontSize: 18),
              ),

            const SizedBox(height: 16),

            // Lista de horários disponíveis
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _horarios.length,
              itemBuilder: (context, index) {
                final hora = _horarios[index];
                return Card(
                  child: ListTile(
                    title: Text('$hora:00'),
                  ),
                );
              },
            ),
          ],
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
