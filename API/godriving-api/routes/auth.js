const express = require('express');
const router = express.Router();
const connection = require('../db'); // Conexão com o banco de dados MySQL
const bcrypt = require('bcrypt'); // Biblioteca para encriptação de senhas

// ===============================
// 🧾 ROTA: Registo de utilizador
// ===============================
router.post('/register', (req, res) => {
  const { name, id_type, email, password, category, instructor, associated_car } = req.body;

  console.log('📥 Pedido recebido em /register');
  console.log('Dados recebidos:', req.body);

  // Verificar se já existe um utilizador com este email
  connection.query('SELECT * FROM user WHERE email = ?', [email], (err, results) => {
    if (err) {
      console.error('❌ Erro na verificação de email:', err);
      return res.status(500).json({ error: 'Erro no banco' });
    }

    if (results.length > 0) {
      console.log('⚠ Email já registrado');
      return res.status(400).json({ error: 'Email já registrado' });
    }

    // Função assíncrona autoexecutável para registar o utilizador
    (async () => {
      try {
        const hashedPassword = await bcrypt.hash(password, 10); // Encripta a password
        console.log('🔒 Password encriptada:', hashedPassword);

        // Inserção na base de dados
        connection.query(
          'INSERT INTO user (name, id_type, email, password, category, instructor, associated_car) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            name,
            id_type,
            email,
            hashedPassword,
            category || null,
            instructor || null,
            associated_car,
            id_type == 1 || id_type == 2
          ],
          (err, results) => {
            if (err) {
              console.error('❌ Erro no INSERT:', err);
              return res.status(500).json({ error: 'Erro ao criar usuário' });
            }

            console.log('✅ Usuário criado com sucesso');
            res.status(201).json({ message: 'Usuário criado com sucesso!' });
          }
        );
      } catch (err) {
        console.error('❌ Erro ao hashear password:', err);
        res.status(500).json({ error: 'Erro ao processar o registo' });
      }
    })();
  });
});

// ====================
// 🔐 Login do utilizador
// ====================
router.post('/login', (req, res) => {
  console.log('Dados recebidos:', req.body);
  const { email, password } = req.body;

  // Verificar se o utilizador existe
  connection.query('SELECT * FROM user WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ error: 'Erro no banco' });
    if (results.length === 0) return res.status(400).json({ error: 'Email não encontrado' });

    const user = results[0];
    console.log('Senha recebida:', password);
    console.log('Hash armazenado:', user.password);

    // Verificar se a password está correta
    const passwordMatch = await bcrypt.compare(password, user.password);
    console.log('Password correta?', passwordMatch);

    if (!passwordMatch) return res.status(401).json({ error: 'Senha incorreta' });

    // Contar aulas concluídas (caso seja aluno)
    connection.query(
      "SELECT COUNT(*) AS aulas_concluidas FROM classes WHERE id_student = ? AND class_status = 'concluída'",
      [user.id],
      (err2, aulasResult) => {
        if (err2) {
          console.error('Erro ao contar aulas concluídas:', err2);
          return res.status(500).json({ error: 'Erro no banco ao contar aulas' });
        }

        const aulasConcluidas = aulasResult[0].aulas_concluidas;

        // Retorna os dados do utilizador
        res.json({
          message: 'Login efetuado com sucesso',
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            id_type: user.id_type,
            alterar_password: user.alterar_password,
            instructor: user.instructor || 'A definir',
            category: user.category || 'A definir',
            associated_car: user.associated_car || 'A definir',
            aulas: aulasConcluidas,
            first_login: user.first_login || 0,
          },
        });
      }
    );
  });
});

// ========================================
// 🔐 Alterar password do utilizador
// ========================================
router.put('/alterar_password', async (req, res) => {
  console.log('📡 [PUT] /api/auth/alterar_password');
  console.log('📦 Corpo do pedido:', req.body);

  const { email, antiga_password, nova_password } = req.body;

  // Verifica se o utilizador existe
  connection.query('SELECT * FROM user WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ error: 'Erro no servidor' });
    if (results.length === 0) return res.status(404).json({ error: 'Utilizador não encontrado' });

    const user = results[0];

    // Verifica se a password atual está correta
    const match = await bcrypt.compare(antiga_password, user.password);
    if (!match) return res.status(401).json({ error: 'Password atual incorreta' });

    // Encripta e atualiza nova password
    const hashed = await bcrypt.hash(nova_password, 10);
    connection.query(
      'UPDATE user SET password = ?, first_login = 0 WHERE email = ?',
      [hashed, email],
      err => {
        if (err) return res.status(500).json({ error: 'Erro ao atualizar password' });
        res.json({ message: 'Password atualizada com sucesso' });
      }
    );
  });
});

// ============================================
// 🗑 Apagar utilizador (recepcionista/admin)
// ============================================
router.delete('/utilizadores/:email', async (req, res) => {
  const { email } = req.params;

  if (!email) {
    return res.status(400).json({ error: 'Email é obrigatório.' });
  }

  try {
    // 1. Busca o utilizador
    const [rows] = await connection.promise().query(
      'SELECT id, id_type FROM user WHERE email = ?',
      [email]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Utilizador não encontrado.' });
    }

    const userId = rows[0].id;
    const userType = rows[0].id_type;

    // 2. Apaga aulas associadas (se for aluno ou instrutor)
    await connection.promise().query(
      'DELETE FROM classes WHERE id_instructor = ? OR id_student = ?',
      [userId, userId]
    );

    // 3. Apaga horários bloqueados (se for instrutor)
    await connection.promise().query(
      'DELETE FROM blocked_schedules WHERE id_instructor = ?',
      [userId]
    );

    // 4. Apaga o utilizador
    const [result] = await connection.promise().query(
      'DELETE FROM user WHERE id = ?',
      [userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Utilizador não encontrado ao apagar.' });
    }

    // 5. Sucesso
    res.status(200).json({ message: 'Utilizador e dados relacionados apagados com sucesso.' });
  } catch (err) {
    console.error('Erro ao apagar utilizador:', err);
    res.status(500).json({ error: 'Erro interno ao apagar utilizador.' });
  }
});

module.exports = router;
