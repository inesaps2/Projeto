const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config();

const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);

// Teste
app.get('/ping', (req, res) => {
  res.status(200).json({ message: 'pong' });
});

app.get('/', (req, res) => {
  res.send('API do GoDriving está no ar!');
});

app.use((err, req, res, next) => {
  console.error('Erro inesperado:', err);
  res.status(500).json({ error: 'Erro interno do servidor' });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor iniciado na porta ${PORT}`);
});
