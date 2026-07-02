const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

// Khởi tạo bộ kết nối cơ sở dữ liệu thông qua các biến môi trường động
const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

// Cổng giao tiếp dùng để kiểm tra sức khỏe ứng dụng
app.get('/healthz', (req, res) => {
    res.status(200).json({ status: 'ok' });
});

// Cổng giao tiếp dùng để truy vấn danh sách dữ liệu
app.get('/items', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM items');
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Cổng giao tiếp dùng để chèn thêm thông tin mới
app.post('/items', async (req, res) => {
    try {
        const { name } = req.body;
        const result = await pool.query('INSERT INTO items (name) VALUES ($1) RETURNING *', [name]);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});