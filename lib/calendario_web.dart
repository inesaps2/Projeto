import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto/registar_utilizador.dart';
import 'package:projeto/teste.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:projeto/main.dart';
import 'package:projeto/pagina_inicial.dart';
import 'package:projeto/perfil.dart';
import 'package:projeto/config.dart';

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
  final Map<String, Map<String, dynamic>> _horariosBloqueados = {};
  int? _idInstrutorSelecionado;

  void InstrutorSelecionado(int id) {
    print('InstrutorSelecionado: Instrutor com id $id selecionado');

    // Limpa os horários bloqueados antigos
    setState(() {
      _horariosBloqueados.clear();
      _idInstrutorSelecionado = id;
    });

    print('InstrutorSelecionado: ID do instrutor atualizado para: $_idInstrutorSelecionado');
    _carregarHorariosBloqueados();
  }

  Future<void> _carregarHorariosBloqueados() async {
    if (_idInstrutorSelecionado == null) {
      print('ID do instrutor não definido, não é possível carregar horários bloqueados');
      return;
    }

    print('=== INÍCIO _carregarHorariosBloqueados ===');
    print('Carregando horários bloqueados para o instrutor $_idInstrutorSelecionado');

    try {
      final url = Uri.parse('${Config.baseUrl}/api/blocked-schedules?instructorId=$_idInstrutorSelecionado');
      print('URL da requisição: $url');

      final response = await http.get(url);

      print('Resposta da API de horários bloqueados:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode != 200) {
        print('Erro na API: ${response.statusCode} - ${response.body}');
        return;
      }

      if (response.statusCode == 200) {
        final List<dynamic> blocos = jsonDecode(response.body);
        print('Blocos recebidos: ${blocos.length}');

        final Map<String, Map<String, dynamic>> novosBloqueios = {};

        for (var bloco in blocos) {
          try {
            final dataInicio = DateTime.parse(bloco['date_start']).toLocal();
            final dataFim = DateTime.parse(bloco['date_end']).toLocal();
            final motivo = bloco['reason'] ?? 'indefinido';

            print('Bloco de ${dataInicio} até ${dataFim} - Motivo: $motivo');

            // Para cada dia no intervalo
            var dataAtual = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
            final dataFimAjustada = DateTime(dataFim.year, dataFim.month, dataFim.day).add(const Duration(days: 1));

            while (dataAtual.isBefore(dataFimAjustada)) {
              final chaveData = '${dataAtual.year}-${dataAtual.month.toString().padLeft(2, '0')}-${dataAtual.day.toString().padLeft(2, '0')}';

              // Se for o mesmo dia, verifica as horas
              if (dataInicio.year == dataFim.year &&
                  dataInicio.month == dataFim.month &&
                  dataInicio.day == dataFim.day) {
                // Bloqueia apenas no intervalo de horas específico
                for (var h = dataInicio.hour; h < dataFim.hour; h++) {
                  novosBloqueios.putIfAbsent(chaveData, () => {})[h.toString()] = motivo;
                  print('  - Bloqueado $chaveData às $h:00 - Motivo: $motivo');
                }
              } else if (dataAtual.isAtSameMomentAs(DateTime(dataInicio.year, dataInicio.month, dataInicio.day))) {
                // Primeiro dia do bloco
                for (var h = dataInicio.hour; h < 24; h++) {
                  novosBloqueios.putIfAbsent(chaveData, () => {})[h.toString()] = motivo;
                  print('  - Bloqueado $chaveData às $h:00 (primeiro dia) - Motivo: $motivo');
                }
              } else if (dataAtual.isAtSameMomentAs(DateTime(dataFim.year, dataFim.month, dataFim.day))) {
                // Último dia do bloco
                for (var h = 0; h < dataFim.hour; h++) {
                  novosBloqueios.putIfAbsent(chaveData, () => {})[h.toString()] = motivo;
                  print('  - Bloqueado $chaveData às $h:00 (último dia) - Motivo: $motivo');
                }
              } else {
                // Dias intermediários (bloqueia o dia inteiro)
                novosBloqueios[chaveData] = {'fullDay': true, 'reason': motivo};
                print('  - Bloqueado dia inteiro: $chaveData - Motivo: $motivo');
              }

              dataAtual = dataAtual.add(const Duration(days: 1));
            }
          } catch (e) {
            print('Erro ao processar bloco $bloco: $e');
          }
        }

        print('Total de dias com horários bloqueados: ${novosBloqueios.length}');

        setState(() {
          _horariosBloqueados.clear();
          _horariosBloqueados.addAll(novosBloqueios);
        });
      } else {
        print('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao carregar horários bloqueados: $e');
    }
  }

  bool _estaBloqueado(DateTime data, int hora) {
    if (_horariosBloqueados.isEmpty) {
      print('_estaBloqueado(${data.toString()}, $hora): Nenhum horário bloqueado carregado');
      return false;
    }

    final chaveData = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    print('_estaBloqueado: Verificando chaveData: $chaveData, hora: $hora');

    final bloqueiosDoDia = _horariosBloqueados[chaveData];

    if (bloqueiosDoDia == null) {
      print('_estaBloqueado: Nenhum bloqueio para esta data');
      return false;
    }

    // Se for um bloqueio de dia inteiro
    if (bloqueiosDoDia['fullDay'] == true) {
      final motivo = bloqueiosDoDia['reason'] ?? 'sem motivo especificado';
      print('_estaBloqueado: Dia inteiro bloqueado - Motivo: $motivo');
      return true;
    }

    // Se for um bloqueio por hora específica
    final horaBloqueada = bloqueiosDoDia[hora.toString()];
    if (horaBloqueada != null) {
      print('_estaBloqueado: Hora $hora bloqueada - Motivo: $horaBloqueada');
      return true;
    }

    print('_estaBloqueado: Hora $hora não está bloqueada');
    return false;
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<int, Map<String, dynamic>>> _eventos = {};

  Future<void> _verificarInstrutor() async {
    final nomeInstrutor = _instrutorController.text.trim();

    if (nomeInstrutor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do instrutor.')),
      );
      return;
    }

    try {
      final uri = Uri.parse('${Config.baseUrl}/api/instrutores?nome=$nomeInstrutor');
      final response = await http.get(uri);

      print('Body completo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Resposta do backend (instrutor): $data');

        if (data != null && data['existe'] == true) {
          final id_instructor = data['id'];  //pega o id do instrutor
          print('Instrutor selecionado com id: $id_instructor');

          bool idMudou = _idInstrutorSelecionado != id_instructor;

          setState(() {
            _idInstrutorSelecionado = id_instructor;  //atualiza o estado com o id
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Instrutor "$nomeInstrutor" encontrado!')),
          );

          if (idMudou) {
            await _carregarHorariosBloqueados();
          }

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
    final uri = Uri.parse('${Config.baseUrl}/aulas/recepcionista?email=${Session.email}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Dados recebidos: $data');
      final Map<DateTime, Map<int, Map<String, dynamic>>> novosEventos = {};
      final Set<String> novosHorariosAceites = {};

      for (var aula in data) {
        final dt = DateTime.parse(aula['data_hora']);
        final key = DateTime(dt.year, dt.month, dt.day);
        final hora = dt.hour;
        final nome = aula['nome_aluno'] ?? '';
        final status = aula['class_status'] ?? '';

        if (!novosEventos.containsKey(key)) {
          novosEventos[key] = {};
        }

        novosEventos[key]![hora] = {
          'nome': nome,
          'status': status,
        };

        final diaHoraKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}_$hora';

        if (status == 'aceite') {
          novosHorariosAceites.add(diaHoraKey);
        }
      }

      print('Eventos carregados:');
      novosEventos.forEach((key, value) {
        print('$key -> $value');
      });

      setState(() {
        _eventos = novosEventos;
        _horariosAceites = novosHorariosAceites;
      });
    } else {
      print('Erro ao carregar aulas: ${response.statusCode}');
    }
  }

  Future<void> _carregarAulasDoInstrutor(String nomeInstrutor) async {
    final uri = Uri.parse('${Config.baseUrl}/api/aulas/recepcionista?instrutor=$nomeInstrutor');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Aulas do instrutor recebidas: $data');

      // Pegar id do instrutor da primeira aula, se existir
      if (data.isNotEmpty) {
        final primeiroId = data.first['id_instructor'];
        bool idMudou = _idInstrutorSelecionado != primeiroId;

        if (idMudou) {
          setState(() {
            _idInstrutorSelecionado = primeiroId;
          });
          // Carrega os horários bloqueados após definir o ID do instrutor
          _carregarHorariosBloqueados();
          print('ID do instrutor definido a partir das aulas: $primeiroId');
        }
      }

      final Map<DateTime, Map<int, Map<String, dynamic>>> novosEventos = {};
      final Set<String> novosHorariosAceites = {};

      for (var aula in data) {
        final dt = DateTime.parse(aula['data_hora']);
        final key = DateTime(dt.year, dt.month, dt.day);
        final hora = dt.hour;
        final nome = aula['nome_aluno'] ?? '';
        final status = aula['class_status'] ?? '';
        final id = aula['id']; // Adicionando o ID da aula

        if (!novosEventos.containsKey(key)) {
          novosEventos[key] = {};
        }

        novosEventos[key]![hora] = {
          'nome': nome,
          'status': status,
          'id': id, // Armazenando o ID da aula
        };

        // Corrigir a chave da hora com padding correto
        final diaHoraKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}_$hora';
        print('Hora: $hora | Aceite: ${status == 'aceite'} | Status: $status');

        if (status == 'aceite') {
          novosHorariosAceites.add(diaHoraKey);
        }
      }

      setState(() {
        _eventos = novosEventos;
        _horariosAceites = novosHorariosAceites;
      });
    } else {
      print('Erro ao carregar aulas do instrutor: ${response.statusCode}');
    }
  }

  Future<void> _atualizarStatusAula(DateTime data, int hora, String novoStatus) async {
    if (_idInstrutorSelecionado == null) return;

    final dataFormatada = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    final horaFormatada = hora.toString().padLeft(2, '0');

    try {
      late final http.Response response;

      // Obtém o ID da aula do evento
      final idAula = _eventos[DateTime(data.year, data.month, data.day)]?[hora]?['id'];

      if (idAula == null) {
        throw Exception('ID da aula não encontrado');
      }

      if (novoStatus == 'recusada') {
        response = await http.delete(
          Uri.parse('${Config.baseUrl}/api/aulas/rec/$idAula'),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        // Para aceitar, usamos PUT
        response = await http.put(
          Uri.parse('${Config.baseUrl}/api/classes/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_instructor': _idInstrutorSelecionado,
            'id': idAula, // Usando o ID correto da aula
            'data': dataFormatada,
            'hora': horaFormatada,
            'novo_status': novoStatus,
          }),
        );
      }

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Resposta do servidor: $responseData');

        // Recarrega as aulas para atualizar a lista
        await _carregarAulasDoInstrutor(_instrutorController.text.trim());

        // Mostra mensagem de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  novoStatus == 'aceite'
                      ? 'Aula aceita com sucesso!'
                      : 'Aula recusada e removida com sucesso!'
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body)?['error'] ?? 'Erro desconhecido';
        print('Erro ao atualizar status: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro na requisição: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarDialogoMarcarAula(int horaSelecionada) {
    final nomeController = TextEditingController();

    // Verifica se o horário está bloqueado
    if (_selectedDay != null && _estaBloqueado(_selectedDay!, horaSelecionada)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este horário está bloqueado e não pode ser agendado.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Marcar Aula'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final nome = nomeController.text.trim();
                if (nome.isEmpty) return;

                // Verifica novamente se o horário ainda não foi bloqueado
                if (_selectedDay != null && _estaBloqueado(_selectedDay!, horaSelecionada)) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Este horário foi bloqueado recentemente e não pode mais ser agendado.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final uri = Uri.parse('${Config.baseUrl}/api/aulas');
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
                  final errorMessage = jsonDecode(resp.body)?['error'] ?? 'Erro ao marcar aula';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
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

  void _mostrarDialogoBloquearIntervalo(int idInstrutor) {
    DateTime? dataInicio;
    DateTime? dataFim;
    int horaInicio = 9;
    int horaFim = 19;
    String motivoSelecionado = 'exame'; // Valor padrão

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Bloquear Horas e Dias'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motivo
                    const Text('Motivo:'),
                    DropdownButton<String>(
                      value: motivoSelecionado,
                      isExpanded: true,
                      items: ['exame', 'ferias', 'outro'].map((motivo) {
                        return DropdownMenuItem<String>(
                          value: motivo,
                          child: Text(motivo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            motivoSelecionado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Data Início
                    Row(
                      children: [
                        const Text('Data Início:'),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final dataSelecionada = await showDatePicker(
                              context: context,
                              initialDate: dataInicio ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (dataSelecionada != null) {
                              setStateDialog(() {
                                dataInicio = dataSelecionada;
                                if (dataFim != null && dataFim!.isBefore(dataInicio!)) {
                                  dataFim = dataInicio;
                                }
                              });
                            }
                          },
                          child: Text(
                            dataInicio != null
                                ? '${dataInicio!.day}/${dataInicio!.month}/${dataInicio!.year}'
                                : 'Selecionar',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),

                    // Data Fim
                    Row(
                      children: [
                        const Text('Data Fim:'),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final dataSelecionada = await showDatePicker(
                              context: context,
                              initialDate: dataFim ?? dataInicio ?? DateTime.now(),
                              firstDate: dataInicio ?? DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (dataSelecionada != null) {
                              setStateDialog(() {
                                dataFim = dataSelecionada;
                              });
                            }
                          },
                          child: Text(
                            dataFim != null
                                ? '${dataFim!.day}/${dataFim!.month}/${dataFim!.year}'
                                : 'Selecionar',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Hora Início
                    Row(
                      children: [
                        const Text('Hora Início:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: horaInicio,
                          items: List.generate(11, (index) => 9 + index).map((hora) {
                            return DropdownMenuItem<int>(
                              value: hora,
                              child: Text('$hora:00'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null && value <= horaFim) {
                              setStateDialog(() {
                                horaInicio = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Hora Fim
                    Row(
                      children: [
                        const Text('Hora Fim:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: horaFim,
                          items: List.generate(11, (index) => 9 + index).map((hora) {
                            return DropdownMenuItem<int>(
                              value: hora,
                              child: Text('$hora:00'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null && value >= horaInicio) {
                              setStateDialog(() {
                                horaFim = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (dataInicio == null || dataFim == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecione o intervalo de datas.')),
                      );
                      return;
                    }
                    if (horaInicio > horaFim) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hora início não pode ser maior que hora fim.')),
                      );
                      return;
                    }

                    final dataHoraInicio = DateTime(
                      dataInicio!.year,
                      dataInicio!.month,
                      dataInicio!.day,
                      horaInicio,
                    );

                    final dataHoraFim = DateTime(
                      dataFim!.year,
                      dataFim!.month,
                      dataFim!.day,
                      horaFim,
                    );

                    print('Motivo: $motivoSelecionado');
                    print('De $dataHoraInicio a $dataHoraFim');

                    await bloquearHorario(
                      idInstrutor: idInstrutor,
                      dataInicio: dataHoraInicio,
                      dataFim: dataHoraFim,
                      motivo: motivoSelecionado,
                    );

                    await _carregarHorariosBloqueados();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bloqueio enviado com sucesso!')),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> bloquearHorario({
    required int idInstrutor,
    required DateTime dataInicio,
    required DateTime dataFim,
    required String motivo, // usar "ferias", "exame" ou "outro"
  }) async {
    final uri = Uri.parse('${Config.baseUrl}/api/aulas/bloquear-horario');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_instructor': idInstrutor,
        'date_start': dataInicio.toIso8601String(),
        'date_end': dataFim.toIso8601String(),
        'reason': motivo,
      }),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
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
                      if (_idInstrutorSelecionado != null) {
                        _mostrarDialogoBloquearIntervalo(_idInstrutorSelecionado!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, selecione um instrutor.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Bloquear Horário'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  print('Dia selecionado: $selectedDay');
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
                  defaultBuilder: (context, day, focusedDay) {
                    final dia = DateTime(day.year, day.month, day.day);
                    final eventosDoDia = _eventos[dia];
                    if (eventosDoDia != null && eventosDoDia.containsKey(13)) {
                      // Dia com aula marcada às 13h
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400], // Cinzento claro
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }
                    return null; // Usa o padrão se não for às 13h
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
                      final nomeAluno = eventosDoDia[hora]?['nome'];
                      final diaHoraKey = gerarChaveDiaHora(dia, hora);
                      final aceite = _horariosAceites.contains(diaHoraKey);
                      print('Hora: $hora | Aceite: $aceite | Status: ${_eventos[dia]?[hora]}');

                      // Verificar se é domingo, sábado entre 14 e 19 ou horário bloqueado
                      bool bloquear = false;
                      if (dia.weekday == DateTime.sunday) {
                        bloquear = true;
                      } else if (dia.weekday == DateTime.saturday && hora >= 14 && hora <= 19) {
                        bloquear = true;
                      }

                      final estaBloqueado = _estaBloqueado(dia, hora);

                      Color? corDeFundo;
                      if (hora == 13 || bloquear) {
                        corDeFundo = Colors.grey[300];
                      } else if (estaBloqueado) {
                        corDeFundo = Colors.orange[100];
                      } else if (nomeAluno != null && aceite) {
                        corDeFundo = const Color(0xFFB2F2BB);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: corDeFundo,
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
                                  Row(
                                    children: [
                                      Text(
                                        '$hora:00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _estaBloqueado(dia, hora) ? Colors.orange[800] : Colors.black,
                                        ),
                                      ),
                                      if (_estaBloqueado(dia, hora))
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.lock_outline, size: 16, color: Colors.orange[800]),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Indisponível',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange[800],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (nomeAluno != null && !_estaBloqueado(dia, hora))
                                    Text(
                                      'Marcado por: $nomeAluno',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (nomeAluno != null && !bloquear && !_estaBloqueado(dia, hora))
                              Row(
                                children: [
                                  if (!aceite)
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_idInstrutorSelecionado != null && _selectedDay != null) {
                                          await _atualizarStatusAula(_selectedDay!, hora, 'aceite');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Aceitar'),
                                    ),
                                  if (!aceite) const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_idInstrutorSelecionado != null && _selectedDay != null) {
                                        await _atualizarStatusAula(_selectedDay!, hora, 'recusada');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: Text(aceite ? 'Apagar' : 'Recusar'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                ),
            ],
          ),
        ),
      ),
    );
  }
}