import { USER, PASSWORD, HOST, PORT, DATABASE } from './Const.js';
import Sequelize from 'sequelize';

console.log(`DB config: host=${HOST} port=${PORT} database=${DATABASE} user=${USER}`);

const db = new Sequelize({
  dialect: 'mysql',
  host: HOST,
  port: PORT,
  database: DATABASE,
  username: USER,
  password: PASSWORD,
  logging: (msg) => console.log('[Sequelize]', msg),
  define: {
    timestamps: false,
    freezeTableName: true,
  },
});

export default db;
