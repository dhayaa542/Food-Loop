module.exports = (sequelize, DataTypes) => {
    const Order = sequelize.define('Order', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        buyerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Users',
                key: 'id',
            },
        },
        partnerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Partners',
                key: 'id',
            },
        },
        totalAmount: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        status: {
            type: DataTypes.ENUM('Pending', 'Ready', 'Completed', 'Cancelled'),
            defaultValue: 'Pending',
        },
    });

    return Order;
};
