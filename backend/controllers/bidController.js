const db = require('../config/db');
const Bid = db.Bid;
const Offer = db.Offer;
const User = db.User;
const AuctionParticipant = db.AuctionParticipant;

// Place a new bid
exports.placeBid = async (req, res) => {
    try {
        const { offerId, amount } = req.body;
        const userId = req.user.id; // From auth middleware

        // Validate offer
        const offer = await Offer.findByPk(offerId);
        if (!offer) {
            return res.status(404).json({ message: 'Offer not found' });
        }

        // Validate amount
        // Ideally check if amount > current highest bid
        const highestBid = await Bid.findOne({
            where: { offerId },
            order: [['amount', 'DESC']],
        });

        if (highestBid && parseFloat(amount) <= parseFloat(highestBid.amount)) {
            return res.status(400).json({ message: 'Bid amount must be higher than the current highest bid.' });
        }

        // Also check if amount > offer price (starting price)
        if (parseFloat(amount) < parseFloat(offer.price)) {
            return res.status(400).json({ message: 'Bid amount must be at least the starting price.' });
        }

        const newBid = await Bid.create({
            offerId,
            userId,
            amount
        });

        res.status(201).json(newBid);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get all bids for an offer
exports.getBids = async (req, res) => {
    try {
        const { offerId } = req.params;

        const bids = await Bid.findAll({
            where: { offerId },
            include: [{ model: User, attributes: ['name'] }], // Include bidder name
            order: [['amount', 'DESC']],
        });

        res.json(bids);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.joinLobby = async (req, res) => {
    try {
        const { offerId } = req.params;
        const userId = req.user.id;

        // Check if already joined
        const existing = await AuctionParticipant.findOne({
            where: { offerId, userId }
        });

        if (!existing) {
            await AuctionParticipant.create({
                offerId,
                userId
            });
        }

        // Return current count
        const count = await AuctionParticipant.count({
            where: { offerId }
        });

        res.json({ count });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.getLobbyStatus = async (req, res) => {
    try {
        const { offerId } = req.params;

        const count = await AuctionParticipant.count({
            where: { offerId }
        });

        res.json({ count });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
