require("dotenv").config()
const express = require("express")
const cors = require("cors")
const bodyParser = require("body-parser")
const db = require("./database")

const app = express()

// Middleware
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// CREATE - Add new product
app.post("/api/products", (req, res) => {
  const { name, quantity, unit, price, imagePath } = req.body

  if (!name || quantity === undefined || !price) {
    return res.status(400).json({ error: "Missing required fields" })
  }

  const now = new Date().toISOString()
  const query = `
    INSERT INTO products (name, quantity, unit, price, imagePath, createdAt, updatedAt)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `

  db.run(query, [name, quantity, unit || "units", price, imagePath || null, now, now], function (err) {
    if (err) {
      return res.status(500).json({ error: err.message })
    }
    res.status(201).json({
      id: this.lastID,
      name,
      quantity,
      unit: unit || "units",
      price,
      imagePath,
      createdAt: now,
      updatedAt: now,
    })
  })
})

// READ - Get all products
app.get("/api/products", (req, res) => {
  const query = "SELECT * FROM products ORDER BY createdAt DESC"

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: err.message })
    }
    res.json(rows)
  })
})

// READ - Get single product
app.get("/api/products/:id", (req, res) => {
  const { id } = req.params
  const query = "SELECT * FROM products WHERE id = ?"

  db.get(query, [id], (err, row) => {
    if (err) {
      return res.status(500).json({ error: err.message })
    }
    if (!row) {
      return res.status(404).json({ error: "Product not found" })
    }
    res.json(row)
  })
})

// UPDATE - Edit product
app.put("/api/products/:id", (req, res) => {
  const { id } = req.params
  const { name, quantity, unit, price, imagePath } = req.body

  if (!name || quantity === undefined || !price) {
    return res.status(400).json({ error: "Missing required fields" })
  }

  const now = new Date().toISOString()
  const query = `
    UPDATE products
    SET name = ?, quantity = ?, unit = ?, price = ?, imagePath = ?, updatedAt = ?
    WHERE id = ?
  `

  db.run(query, [name, quantity, unit || "units", price, imagePath || null, now, id], function (err) {
    if (err) {
      return res.status(500).json({ error: err.message })
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: "Product not found" })
    }
    res.json({
      id: Number.parseInt(id),
      name,
      quantity,
      unit: unit || "units",
      price,
      imagePath,
      updatedAt: now,
    })
  })
})
app.delete('/api/products/:id', (req, res) => {
  const { id } = req.params;
  db.run(`DELETE FROM products WHERE id = ?`, [id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Product deleted successfully' });
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
