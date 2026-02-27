import { USER, PASSWORD, HOST } from './Const.js';
import Sequelize from 'sequelize';

const db = new Sequelize({
  dialect: 'mysql',
  host: HOST,
  database: 'storage',
  username: USER,
  password: PASSWORD,
  logging: false,
  define: {
    timestamps: false,
    freezeTableName: true,
  },
});

export default db;
