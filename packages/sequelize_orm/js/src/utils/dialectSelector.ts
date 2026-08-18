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
      const err = new Error(
        'SQLite3 is currently not supported but we are working on using build hook or providing custom script for downloading the operating system specific sqlite3 native drivers since we cannot package it with sequelize_orm package.'
      );
      err.name = 'SequelizeConnectionError';
      throw err;
    }
    default: {
      const pg = require('@sequelize/postgres');
      return pg.PostgresDialect || pg.default?.PostgresDialect || pg;
    }
  }
}
