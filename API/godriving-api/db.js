const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: process.env.DB_HOST,  
  port: process.env.DB_PORT,  
  user: process.env.DB_USER,  
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
});

connection.connect((err) => {
  if (err) {
    console.error('❌ Erro ao conectar à base de dados:', err);
  } else {
    console.log(`✅ Conectado com sucesso na base de dados: ${process.env.DB_DATABASE}`);
  }
});

module.exports = connection;
