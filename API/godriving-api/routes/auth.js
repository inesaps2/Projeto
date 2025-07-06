const express = require('express');
const router = express.Router();
const connection = require('../db'); // tua conexão MySQL
const bcrypt = require('bcrypt');

// Registo de utilizador (aluno ou instrutor)
router.post('/register', (req, res) => {
  const { name, id_type, email, password, category, instructor, associated_car} = req.body;

  console.log('📥 Pedido recebido em /register');
  console.log('Dados recebidos:', req.body);

  connection.query('SELECT * FROM user WHERE email = ?', [email], (err, results) => {
    if (err) {
      console.error('❌ Erro na verificação de email:', err);
      return res.status(500).json({ error: 'Erro no banco' });
    }

    if (results.length > 0) {
      console.log('⚠️ Email já registrado');
      return res.status(400).json({ error: 'Email já registrado' });
    }

(async () => {
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('🔒 Password encriptada:', hashedPassword);

    connection.query(
      'INSERT INTO user (name, id_type, email, password, category, instructor, associated_car) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        name,
        id_type,
        email,
        hashedPassword,
        category || null,     // <- coloca NULL se undefined
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


// Login
router.post('/login', (req, res) => {
  console.log('Dados recebidos:', req.body);
  const { email, password } = req.body;

  connection.query('SELECT * FROM user WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ error: 'Erro no banco' });
    if (results.length === 0) return res.status(400).json({ error: 'Email não encontrado' });

    const user = results[0];
    console.log('Senha recebida:', password);
    console.log('Hash armazenado:', user.password);

    const passwordMatch = await bcrypt.compare(password, user.password);
    console.log('Password correta?', passwordMatch);

    if (!passwordMatch) return res.status(401).json({ error: 'Senha incorreta' });

  connection.query(
      "SELECT COUNT(*) AS aulas_concluidas FROM classes WHERE id_student = ? AND class_status = 'concluída'",
      [user.id],
      (err2, aulasResult) => {
        if (err2) {
          console.error('Erro ao contar aulas concluídas:', err2);
          return res.status(500).json({ error: 'Erro no banco ao contar aulas' });
        }

        const aulasConcluidas = aulasResult[0].aulas_concluidas;

        res.json({
          message: 'Login efetuado com sucesso',
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            id_type: user.id_type,
            alterar_password: user.alterar_password,
            instructor: user.instructor || 'A definir',
            categoria: user.category || 'A definir',
            aulas: aulasConcluidas,
            first_login: user.first_login || 0,
          },
        });
      }
    );
  });
});


router.put('/alterar_password', async (req, res) => {
  console.log('📡 [PUT] /api/auth/alterar_password');
  console.log('📦 Corpo do pedido:', req.body);
  const { email, antiga_password, nova_password } = req.body;
  connection.query('SELECT * FROM user WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ error: 'Erro no servidor' });
    if (results.length === 0) return res.status(404).json({ error: 'Utilizador não encontrado' });

    const user = results[0];
    const match = await bcrypt.compare(antiga_password, user.password);
    if (!match) return res.status(401).json({ error: 'Password atual incorreta' });

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


module.exports = router;