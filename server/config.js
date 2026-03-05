import { USER, PASSWORD, HOST, PORT, DATABASE } from './Const.js';
import Sequelize from 'sequelize';

const db = new Sequelize({
  dialect: 'mysql',
  host: HOST,
  port: PORT,
  database: DATABASE,
  username: USER,
  password: PASSWORD,
  logging: false,
  define: {
    timestamps: false,
    freezeTableName: true,
  },
});

export default db;
