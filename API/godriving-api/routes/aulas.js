const express = require('express');
const router = express.Router();
const connection = require('../db'); // ligação à base de dados MySQL

// ✅ Marcar aula (com verificação de conflito de horário)
router.post('/aulas', async (req, res) => {
    const { email, nomeAluno, data, hora } = req.body;

    if (!email || !nomeAluno || !data || !hora) {
      return res.status(400).json({ error: 'Faltam dados obrigatórios.' });
    }

    try {
      // 🔍 Obter aluno
      const [rowsAluno] = await connection.promise().query(
        'SELECT id, instructor FROM user WHERE email = ? AND id_type = 1',
        [email]
      );
      if (rowsAluno.length === 0) {
        return res.status(404).json({ error: 'Aluno não encontrado ou não é aluno.' });
      }

      const idStudent = rowsAluno[0].id;
      const nomeInstrutor = rowsAluno[0].instructor;

      if (!nomeInstrutor) {
        return res.status(400).json({ error: 'Aluno não tem instrutor atribuído.' });
      }

      // 🔍 Obter ID do instrutor
      const [rowsInstrutor] = await connection.promise().query(
        'SELECT id FROM user WHERE name = ? AND id_type = 2',
        [nomeInstrutor]
      );
      if (rowsInstrutor.length === 0) {
        return res.status(404).json({ error: 'Instrutor não encontrado.' });
      }

      const idInstrutor = rowsInstrutor[0].id;
      const dateTime = `${data} ${hora}:00`;
      const requestedDateTime = new Date(dateTime);

      // 🚫 Verificar se o horário está dentro de um período bloqueado
      const [blockedPeriods] = await connection.promise().query(
        `SELECT * FROM blocked_schedules
         WHERE id_instructor = ?
         AND date_start <= ?
         AND date_end >= ?`,
        [idInstrutor, dateTime, dateTime]
      );

      if (blockedPeriods.length > 0) {
        const reason = blockedPeriods[0].reason;
        let reasonMessage = 'O horário está bloqueado';

        // Adicionar mensagem mais descritiva com base no motivo
        switch(reason) {
          case 'ferias':
            reasonMessage = 'O instrutor está de férias neste período.';
            break;
          case 'exame':
            reasonMessage = 'O instrutor está em exame neste horário.';
            break;
          case 'outro':
            reasonMessage = 'Este horário está indisponível.';
            break;
        }

        return res.status(409).json({
          error: reasonMessage,
          blocked: true,
          reason: reason
        });
      }

      // 🚫 Verificar se o instrutor já tem aula nesse horário
      const [aulaExistente] = await connection.promise().query(
        'SELECT id FROM classes WHERE id_instructor = ? AND time = ?',
        [idInstrutor, dateTime]
      );
      if (aulaExistente.length > 0) {
        return res.status(409).json({ error: 'O instrutor já tem uma aula marcada nesse horário.' });
      }

      // 🧾 Inserir aula
      await connection.promise().query(
        'INSERT INTO classes (id_student, id_instructor, time, nome_aluno) VALUES (?, ?, ?, ?)',
        [idStudent, idInstrutor, dateTime, nomeAluno]
      );

      res.status(201).json({
        message: 'Aula marcada com sucesso.',
        aula: {
          nomeAluno,
          data,
          hora,
        }
      });

    } catch (err) {
      console.error('❌ Erro ao marcar aula:', err);

      // Se for um erro de horário bloqueado, retornar a mensagem específica
      if (err.blocked) {
        return res.status(409).json({
          error: err.message || 'Este horário está bloqueado.',
          blocked: true,
          reason: err.reason
        });
      }

      // Para erros de conflito (aula já existente)
      if (err.code === 'ER_DUP_ENTRY' || (err.message && err.message.includes('ER_DUP_ENTRY'))) {
        return res.status(409).json({
          error: 'O instrutor já tem uma aula marcada nesse horário.'
        });
      }

      // Para outros erros, retornar mensagem genérica
      res.status(500).json({
        error: 'Erro ao marcar aula. Por favor, tente novamente.'
     });
    }
});


// ✅ Obter aulas do instrutor de um aluno ou por nome de instrutor (recepcionista)
router.get('/aulas', async (req, res) => {
  const { email } = req.query;

  if (!email) {
    return res.status(400).json({ error: 'Email é obrigatório.' });
  }

  try {
    // 🔍 Obter o utilizador e o seu tipo
    const [rowsUser] = await connection.promise().query(
      'SELECT id, id_type FROM user WHERE email = ?',
      [email]
    );

    if (rowsUser.length === 0) {
      return res.status(404).json({ error: 'Utilizador não encontrado.' });
    }

    const { id, id_type } = rowsUser[0];

    let idInstrutor;

    if (id_type === 1) {
      // É aluno → obter o instrutor associado
      const [rowsAluno] = await connection.promise().query(
        'SELECT instructor FROM user WHERE email = ?',
        [email]
      );

      const nomeInstrutor = rowsAluno[0].instructor;
      if (!nomeInstrutor) {
        return res.status(400).json({ error: 'Aluno não tem instrutor atribuído.' });
      }

      const [rowsInstrutor] = await connection.promise().query(
        'SELECT id FROM user WHERE name = ? AND id_type = 2',
        [nomeInstrutor]
      );

      if (rowsInstrutor.length === 0) {
        return res.status(400).json({ error: 'Instrutor não encontrado.' });
      }

      idInstrutor = rowsInstrutor[0].id;
    } else if (id_type === 2) {
      // É instrutor → usar o seu próprio ID
      idInstrutor = id;
    } else {
      return res.status(403).json({ error: 'Tipo de utilizador inválido.' });
    }

    // 🔍 Buscar todas as aulas do instrutor
    const [rows] = await connection.promise().query(`
      SELECT
        c.id,
        id_student,
        id_instructor,
        nome_aluno,
        DATE_FORMAT(time, '%Y-%m-%d %H:%i:%s') AS data_hora,
        c.class_status
      FROM classes c
      WHERE id_instructor = ?
    `, [idInstrutor]);

    res.json(rows);

  } catch (error) {
    console.error('❌ Erro ao obter aulas:', error);
    res.status(500).json({ error: 'Erro ao obter aulas.' });
  }
});


router.get('/aulas/recepcionista', async (req, res) => {
  const { email, instrutor } = req.query;

  try {
    let idInstrutor;

    if (instrutor) {
      // Caso recepcionista informe o nome do instrutor para filtrar
      const [rowsInstrutor] = await connection.promise().query(
        'SELECT id FROM user WHERE name = ? AND id_type = 2',
        [instrutor]
      );


      if (rowsInstrutor.length === 0) {
        return res.status(404).json({ error: 'Instrutor não encontrado.' });
      }

      idInstrutor = rowsInstrutor[0].id;

    } else if (email) {

      // Verifica se é um aluno e busca o instrutor diretamente pelo email
      const [rowsAluno] = await connection.promise().query(
        `SELECT i.id AS id_instrutor
         FROM user a
         JOIN user i ON a.instructor = i.name
         WHERE a.email = ? AND a.id_type = 1 AND i.id_type = 2`,
        [email]

      );


      if (rowsAluno.length === 0) {
        return res.status(404).json({ error: 'Instrutor não encontrado para esse aluno.' });
      }

      idInstrutor = rowsAluno[0].id_instrutor;
    } else {
      return res.status(400).json({ error: 'Email ou instrutor são obrigatórios.' });
    }

    const [rows] = await connection.promise().query(`
  SELECT
    c.id,
    c.id_student,
    c.id_instructor,
    c.nome_aluno,
    DATE_FORMAT(c.time, '%Y-%m-%d %H:%i:%s') AS data_hora,
    c.class_status,
    bs.reason
  FROM classes c
  LEFT JOIN blocked_schedules bs
    ON bs.id_instructor = c.id_instructor
   AND c.time BETWEEN bs.date_start AND bs.date_end
  WHERE c.id_instructor = ?
  ORDER BY c.time ASC
`, [idInstrutor]);

res.json(rows);

  } catch (error) {
    console.error('❌ Erro ao obter aulas:', error);
    res.status(500).json({ error: 'Erro ao obter aulas.' });
  }
});


// ✅ Verificar se um instrutor existe pelo nome
router.get('/instrutores', async (req, res) => {
  const { nome } = req.query;

  try {
    if (nome) {
      const [rows] = await connection.promise().query(
        'SELECT id FROM user WHERE name = ? AND id_type = 2',
        [nome]
      );

      res.json({ existe: rows.length > 0 });
    } else {
      const [rows] = await connection.promise().query(
        'SELECT name FROM user WHERE id_type = 2 ORDER BY name ASC'
      );

      res.json(rows);  // Retorna todos os nomes
    }
  } catch (err) {
    console.error('❌ Erro ao lidar com instrutores:', err);
    res.status(500).json({ error: 'Erro ao obter dados dos instrutores.' });
  }
});




router.put('/classes/status', async (req, res) => {
    console.log('📦 Corpo do pedido:', req.body);
    const { id_instructor, data, hora, novo_status } = req.body;

    if (!id_instructor || !data || !hora || !novo_status) {
        console.log('❌ Dados incompletos:', { id_instructor, data, hora, novo_status });
        return res.status(400).json({ error: 'Dados incompletos.' });
    }

    try {
        // Formatar a data e hora corretamente
        const dateTime = `${data} ${hora.padStart(2, '0')}:00:00`;
        console.log('🕒 Data/hora formatada:', dateTime);

        const query = `
            UPDATE classes
            SET class_status = ?
            WHERE id_instructor = ? AND time = ?
        `;
        console.log('🔍 Query:', query, [novo_status, id_instructor, dateTime]);

        const [result] = await connection.promise().query(query, [
            novo_status,
            id_instructor,
            dateTime
        ]);

        console.log('✅ Resultado da query:', result);

        if (result.affectedRows === 0) {
            console.log('⚠  Nenhuma aula encontrada para atualizar');
            return res.status(404).json({
                error: 'Aula não encontrada para atualizar.',
                debug: {
                    id_instructor,
                    data,
                    hora,
                    dateTime,
                    novo_status
                }
            });
        }

        console.log('✅ Status atualizado com sucesso');
        res.status(200).json({
            success: true,
            message: 'Status atualizado com sucesso',
            data: {
                id_instructor,
                dateTime,
                status: novo_status
            }
        });

    } catch (error) {
        console.error('❌ Erro ao atualizar status:', error);
        res.status(500).json({
            error: 'Erro ao atualizar status da aula',
            details: error.message
      });
    }
});


// Apagar aula
router.delete('/aulas/rec/:id', async (req, res) => {
  const id = req.params.id;

  try {
    const [result] = await connection.promise().query('DELETE FROM classes WHERE id = ?', [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Aula não encontrada com ID ${id}' });
    }
    res.status(200).json({ message: 'Aula removida com sucesso' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao remover aula' });
  }
});


router.delete('/aulas/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const [rows] = await connection.promise().query('SELECT time FROM classes WHERE id = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Aula não encontrada' });
    }

    const dataHoraAula = new Date(rows[0].time);
    const agora = new Date();
    const diferencaHoras = (dataHoraAula - agora) / (1000 * 60 * 60);

    if (diferencaHoras < 24) {
      return res.status(403).json({ error: 'A aula só pode ser apagada com pelo menos 24 horas de antecedência.' });
    }

    const [deleteResult] = await connection.promise().query('DELETE FROM classes WHERE id = ?', [id]);
    res.status(200).json({ message: 'Aula apagada com sucesso' });

  } catch (err) {
    console.error('Erro ao apagar aula:', err);
    res.status(500).json({ error: 'Erro interno ao apagar aula' });
  }
});


router.post('/concluir/:id', (req, res) => {
  const aulaId = req.params.id;

  connection.query(
    'UPDATE classes SET class_status = ? WHERE id = ?',
    ['concluída', aulaId],
    (err, result) => {
      if (err) {
        console.error('Erro ao marcar aula como concluída:', err);
        return res.status(500).json({ error: 'Erro no servidor' });
      }
      res.status(200).json({ message: 'Aula marcada como concluída' });
    }
  );
});


router.post('/bloquear-horario', async (req, res) => {
  const body = req.body || {};
  const { id_instructor, date_start, date_end, reason } = req.body;

  if (!id_instructor || !date_start || !date_end || !reason) {
    return res.status(400).json({ error: 'Faltam dados' });
  }

  try {
    const query = `
      INSERT INTO blocked_schedules (id_instructor, date_start, date_end, reason)
      VALUES (?, ?, ?, ?)
    `;
    await connection.promise().query(query, [id_instructor, date_start, date_end, reason]);

    res.status(200).json({ message: 'Bloqueio registado com sucesso.' });
  } catch (error) {
    console.error('Erro ao bloquear horário:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});


// ✅ Obter horários bloqueados de um instrutor
router.get('/blocked-schedules', async (req, res) => {
  const { instructorId } = req.query;
  if (!instructorId) {
    return res.status(400).json({ error: 'instructorId é obrigatório.' });
  }
  try {
    const [rows] = await connection.promise().query(
      `SELECT id, id_instructor, date_start, date_end, reason
       FROM blocked_schedules
       WHERE id_instructor = ?
       ORDER BY date_start ASC`,
      [instructorId]
    );
    res.json(rows);
  } catch (err) {
    console.error('Erro ao buscar horários bloqueados:', err);
    res.status(500).json({ error: 'Erro ao buscar horários bloqueados.'});
  }
});


// Ver horários que estão bloqueados
router.get('/aulas-bloqueadas', async (req, res) => {
  const { email, instructor } = req.query;

  try {
    let idInstructor;

    if (instructor) {
      const [rowsInstrutor] = await connection.promise().query(
        'SELECT id FROM user WHERE name = ? AND id_type = 2',
        [instructor]
      );

      if (rowsInstrutor.length === 0) {
        return res.status(404).json({ error: 'Instrutor não encontrado.' });
      }

      idInstructor = rowsInstrutor[0].id;
    } else if (email) {
      const [rowsAluno] = await connection.promise().query(
        `SELECT i.id AS id_instrutor
         FROM user a
         JOIN user i ON a.instructor = i.name
         WHERE a.email = ? AND a.id_type = 1 AND i.id_type = 2`,
        [email]
      );

      if (rowsAluno.length === 0) {
        return res.status(404).json({ error: 'Instrutor não encontrado para esse aluno.' });
      }

      idInstructor = rowsAluno[0].id_instructor;
    } else {
      return res.status(400).json({ error: 'Email ou nome do instrutor são obrigatórios.' });
    }

    // Buscar todos os bloqueios do instrutor
    const [rows] = await connection.promise().query(`
      SELECT
        NULL AS id,
        NULL AS id_student,
        id_instructor,
        NULL AS nome_aluno,
        DATE_FORMAT(date_start, '%Y-%m-%d %H:%i:%s') AS data_hora,
        NULL AS class_status,
        reason
      FROM blocked_schedules
      WHERE id_instructor = ?
    `, [idInstructor]);

    res.json(rows);

  } catch (error) {
    console.error('❌ Erro ao obter bloqueios:', error);
    res.status(500).json({ error: 'Erro ao obter bloqueios.' });
  }
});


// ✅ Obter todos os utilizadores com id_type, name e email
router.get('/utilizadores', async (req, res) => {
  try {
    const [rows] = await connection.promise().query(`
      SELECT
        u.id,
        u.id_type,
        u.name,
        u.email,
        u.category,
        u.instructor,
        u.associated_car
      FROM user u
      ORDER BY u.id ASC
    `);

    res.json(rows);
  } catch (err) {
    console.error('Erro ao buscar utilizadores:', err);
    res.status(500).json({ error: 'Erro ao buscar utilizadores.' });
  }
});


router.put('/utilizadores/:email', async (req, res) => {
  const email = req.params.email;
  const { name, category, instructor, associated_car } = req.body;

  try {
    const [result] = await connection.promise().query(`
      UPDATE user
      SET name = ?, category = ?, instructor = ?, associated_car = ?
      WHERE email = ?
    `, [name, category, instructor, associated_car, email]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Utilizador não encontrado' });
    }

    res.json({ message: 'Utilizador atualizado com sucesso' });
  } catch (err) {
    console.error('Erro ao atualizar utilizador:', err);
    res.status(500).json({ error: 'Erro ao atualizar utilizador.' });
  }
});


module.exports = router;