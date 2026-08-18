const core = require('@sequelize/core');
let errors: any = {};
try {
  errors = require('@sequelize/core/_non-semver-use-at-your-own-risk_/errors/index.js');
} catch (_) {}

export const Sequelize: any = typeof core === 'function' ? core : (core.Sequelize || core.default || core);
export const DataTypes: any = Sequelize.DataTypes || core.DataTypes;
export const Op: any = Sequelize.Op || core.Op;
export const sql: any = Sequelize.sql || core.sql;
export const Model: any = Sequelize.Model || core.Model;

export class SequelizeConnectionError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'SequelizeConnectionError';
  }
}

export const ConnectionError: any =
  errors.ConnectionError ||
  core.ConnectionError ||
  SequelizeConnectionError;
