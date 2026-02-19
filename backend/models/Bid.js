module.exports = (sequelize, DataTypes) => {
    const Bid = sequelize.define('Bid', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        offerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Offers',
                key: 'id',
            },
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Users',
                key: 'id',
            },
        },
        amount: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        timestamp: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
        }
    });

    return Bid;
};
