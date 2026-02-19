const db = require('../config/db');
const Offer = db.Offer;
const Partner = db.Partner;

exports.getAllOffers = async (req, res) => {
    try {
        const offers = await Offer.findAll({
            where: { status: 'Active' },
            include: [{ model: Partner, attributes: ['businessName', 'cuisine', 'rating'] }],
            order: [['createdAt', 'DESC']],
        });
        res.json(offers);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.getOfferById = async (req, res) => {
    try {
        const offer = await Offer.findByPk(req.params.id, {
            include: [{ model: Partner, attributes: ['businessName', 'cuisine', 'rating', 'address'] }],
        });
        if (!offer) return res.status(404).json({ msg: 'Offer not found' });
        res.json(offer);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
