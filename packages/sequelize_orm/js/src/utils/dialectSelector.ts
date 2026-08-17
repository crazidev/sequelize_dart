import { ConnectionError } from './sequelizeExports';

export function selectDialect(dialect: string): any {
  switch (dialect) {
    case 'postgres': {
      const pg = require('@sequelize/postgres');
      return pg.PostgresDialect || pg.default?.PostgresDialect || pg;
    }
    case 'mysql': {
      const mysql = require('@sequelize/mysql');
      return mysql.MySqlDialect || mysql.default?.MySqlDialect || mysql;
    }
    case 'mariadb': {
      const mariadb = require('@sequelize/mariadb');
      return mariadb.MariaDbDialect || mariadb.default?.MariaDbDialect || mariadb;
    }
    case 'sqlite': {
      const sqlite = require('@sequelize/sqlite3');
      return sqlite.SqliteDialect || sqlite.default?.SqliteDialect || sqlite;
    }
    default: {
      const pg = require('@sequelize/postgres');
      return pg.PostgresDialect || pg.default?.PostgresDialect || pg;
    }
  }
}
