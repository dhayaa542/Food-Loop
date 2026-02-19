module.exports = (sequelize, DataTypes) => {
    const Partner = sequelize.define('Partner', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Users',
                key: 'id',
            },
        },
        businessName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        cuisine: {
            type: DataTypes.STRING,
        },
        rating: {
            type: DataTypes.FLOAT,
            defaultValue: 0.0,
        },
        isOnline: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        openingHours: {
            type: DataTypes.STRING,
        },
    });

    return Partner;
};
