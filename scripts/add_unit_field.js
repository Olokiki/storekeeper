const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../storekeeper.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err);
    process.exit(1);
  }
  console.log('Connected to database');
  addUnitField();
});

function addUnitField() {
  db.run(`
    ALTER TABLE products ADD COLUMN unit TEXT DEFAULT 'units'
  `, (err) => {
    if (err) {
      if (err.message.includes('duplicate column')) {
        console.log('Unit column already exists');
      } else {
        console.error('Error adding unit column:', err);
      }
    } else {
      console.log('Unit column added successfully');
    }
    db.close();
  });
}