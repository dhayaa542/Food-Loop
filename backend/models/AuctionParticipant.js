module.exports = (sequelize, DataTypes) => {
    const AuctionParticipant = sequelize.define('AuctionParticipant', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        offerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        joinedAt: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
        }
    }, {
        indexes: [
            {
                unique: true,
                fields: ['offerId', 'userId']
            }
        ]
    });

    return AuctionParticipant;
};
