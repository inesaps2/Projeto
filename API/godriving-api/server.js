const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config();

const authRoutes = require('./routes/auth');
const aulasRoutes = require('./routes/aulas');

const app = express();
const PORT = process.env.PORT || 3000;


// Middlewares
app.use(cors());
app.use(express.json());


// Logs de requisições para debugging
app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.url}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('Corpo do pedido:', req.body);
  }
  next();
});

// Rotas
app.use('/api/auth', authRoutes);
app.use('/api', aulasRoutes);
app.use('/api/aulas', aulasRoutes);

// Rota de teste
app.get('/ping', (req, res) => {
  res.status(200).json({ message: 'pong' });
});

app.get('/', (req, res) => {
  res.send('API do GoDriving está no ar!');
});

// Middleware de erro
app.use((err, req, res, next) => {
  console.error('Erro inesperado:', err);
  res.status(500).json({ error: 'Erro interno do servidor' });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor iniciado na porta ${PORT}`);
});

