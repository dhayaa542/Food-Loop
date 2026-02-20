const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

const sequelize = new Sequelize(
    process.env.DB_NAME || 'foodloop_db',
    process.env.DB_USER || 'root',
    process.env.DB_PASS || 'password',
    {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 3306,
        dialect: 'mysql',
        logging: false,
    }
);

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Import models
db.User = require('../models/User')(sequelize, Sequelize);
db.Partner = require('../models/Partner')(sequelize, Sequelize);
db.Offer = require('../models/Offer')(sequelize, Sequelize);
db.Order = require('../models/Order')(sequelize, Sequelize);
db.OrderItem = require('../models/OrderItem')(sequelize, Sequelize);

// Associations
// User - Partner (One-to-One)
db.User.hasOne(db.Partner, { foreignKey: 'userId', onDelete: 'CASCADE' });
db.Partner.belongsTo(db.User, { foreignKey: 'userId' });

// Partner - Offer (One-to-Many)
db.Partner.hasMany(db.Offer, { foreignKey: 'partnerId' });
db.Offer.belongsTo(db.Partner, { foreignKey: 'partnerId' });

// User (Buyer) - Order (One-to-Many)
db.User.hasMany(db.Order, { foreignKey: 'buyerId' }); // Assuming buyer is a User
db.Order.belongsTo(db.User, { foreignKey: 'buyerId', as: 'Buyer' });

// Partner - Order (One-to-Many)
db.Partner.hasMany(db.Order, { foreignKey: 'partnerId' });
db.Order.belongsTo(db.Partner, { foreignKey: 'partnerId' });

// Order - OrderItem (One-to-Many)
db.Order.hasMany(db.OrderItem, { foreignKey: 'orderId', onDelete: 'CASCADE' });
db.OrderItem.belongsTo(db.Order, { foreignKey: 'orderId' });

// Offer - OrderItem (One-to-Many) - To track which offer was ordered
db.Offer.hasMany(db.OrderItem, { foreignKey: 'offerId' });
db.OrderItem.belongsTo(db.Offer, { foreignKey: 'offerId' });

// Bid Model
db.Bid = require('../models/Bid')(sequelize, Sequelize);
db.AuctionParticipant = require('../models/AuctionParticipant')(sequelize, Sequelize);

// Associations
db.Partner.hasMany(db.Offer, { foreignKey: 'partnerId' });
db.Offer.belongsTo(db.Partner, { foreignKey: 'partnerId' });

db.Offer.hasMany(db.Bid, { foreignKey: 'offerId' });
db.Bid.belongsTo(db.Offer, { foreignKey: 'offerId' });

db.User.hasMany(db.Bid, { foreignKey: 'userId' });
db.Bid.belongsTo(db.User, { foreignKey: 'userId' });

db.Offer.hasMany(db.AuctionParticipant, { foreignKey: 'offerId' });
db.AuctionParticipant.belongsTo(db.Offer, { foreignKey: 'offerId' });

db.User.hasMany(db.AuctionParticipant, { foreignKey: 'userId' });
db.AuctionParticipant.belongsTo(db.User, { foreignKey: 'userId' });

module.exports = db;
