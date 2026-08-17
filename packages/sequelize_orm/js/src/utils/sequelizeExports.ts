const core = require('@sequelize/core');

export const Sequelize: any = typeof core === 'function' ? core : (core.Sequelize || core.default || core);
export const DataTypes: any = Sequelize.DataTypes || core.DataTypes;
export const Op: any = Sequelize.Op || core.Op;
export const sql: any = Sequelize.sql || core.sql;
export const Model: any = Sequelize.Model || core.Model;
export const ConnectionError: any = Sequelize.ConnectionError || core.ConnectionError;
