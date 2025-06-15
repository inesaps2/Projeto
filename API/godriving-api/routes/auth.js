const express = require('express');
const router = express.Router();
const connection = require('../db');
const bcrypt = require('bcrypt');

// Registo de utilizador
router.post('/register', async (req, res) => {
  const { name, email, password, id_type, category, associated_car } = req.body;

  connection.query('SELECT * FROM user WHERE email = ?', [email], async (err, results) => {
    if (err) return res.status(500).json({ error: 'Erro no banco' });
    if (results.length > 0) return res.status(400).json({ error: 'Email já registado' });

    const hashedPassword = await bcrypt.hash(password, 10);

    connection.query(
      'INSERT INTO user (name, email, password, id_type, category, associated_car) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, id_type, category, associated_car],
      (err, results) => {
        if (err) return res.status(500).json({ error: 'Erro ao criar utilizador' });
        res.status(201).json({ message: 'Utilizador criado com sucesso!' });
      }
    );
  });
});

// Login de usuário
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

    res.json({ message: 'Login efetuado com sucesso', user: { id: user.id, name: user.name, email: user.email, id_type: user.id_type } });
  });
});

module.exports = router;
