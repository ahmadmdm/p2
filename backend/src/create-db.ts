const { Client } = require('pg');

async function createDatabase() {
  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    password: 'postgres',
    port: 5432,
    database: 'postgres', // Connect to default db
  });

  try {
    await client.connect();
    console.log('Connected to postgres...');

    const res = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = 'pos_db'",
    );
    if (res.rowCount === 0) {
      await client.query('CREATE DATABASE pos_db');
      console.log('Database pos_db created successfully.');
    } else {
      console.log('Database pos_db already exists.');
    }
  } catch (err) {
    console.error('Error creating database:', err);
  } finally {
    await client.end();
  }
}

createDatabase();
