module.exports = (sequelize, DataTypes) => {
    const Offer = sequelize.define('Offer', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        partnerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Partners', // Note: Sequelize table names are pluralized by default
                key: 'id',
            },
        },
        title: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT,
        },
        price: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        originalPrice: {
            type: DataTypes.DECIMAL(10, 2),
        },
        quantity: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
        },
        pickupTime: {
            type: DataTypes.STRING,
        },
        status: {
            type: DataTypes.ENUM('Active', 'Sold Out', 'Expired'),
            defaultValue: 'Active',
        },
        imageUrl: {
            type: DataTypes.STRING,
        },
    });

    return Offer;
};
