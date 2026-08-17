const esbuild = require('esbuild');

esbuild.build({
  entryPoints: ['src/bridge_server_quickjs.ts'],
  bundle: true,
  platform: 'node',
  target: 'node18',
  outfile: '../lib/src/bridge/bridge_server_quickjs.bundle.js',
  external: [
    'fsevents',
    'sqlite3',
    '@sequelize/mssql',
    '@sequelize/db2-ibmi',
    '@sequelize/db2',
    '@sequelize/snowflake',
    '@sequelize/oracle',
  ],
  format: 'cjs',
  conditions: ['require', 'node', 'default'],
}).then(() => {
  console.log('⚡ QuickJS bundle built successfully!');
}).catch((err) => {
  console.error(err);
  process.exit(1);
});
