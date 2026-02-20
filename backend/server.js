const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const db = require('./config/db');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} from ${req.ip}`);
    next();
});

// Routes (to be added)
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/partners', require('./routes/partnerRoutes'));
app.use('/api/orders', require('./routes/orderRoutes'));
app.use('/api/offers', require('./routes/offerRoutes'));
app.use('/api/bids', require('./routes/bidRoutes'));
app.use('/api/users', require('./routes/userRoutes'));

// Start the server immediately so it's always available
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);

    // Database Connection & Sync (Background)
    // db.sequelize.sync({ alter: true }) // Switched back to alter: true to persist data
    db.sequelize.authenticate()
        .then(() => {
            console.log('Database connected successfully.');
        })
        .catch((err) => {
            console.error('Database connection failed (will retry queries):', err.message);
        });
});
