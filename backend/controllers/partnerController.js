const db = require('../config/db');
const Partner = db.Partner;
const Offer = db.Offer;
const Order = db.Order;
const User = db.User;

exports.getPartnerProfile = async (req, res) => {
    try {
        const partner = await Partner.findOne({ where: { userId: req.user.id } });
        if (!partner) return res.status(404).json({ msg: 'Partner profile not found' });
        res.json(partner);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.createOffer = async (req, res) => {
    try {
        const { title, description, price, originalPrice, quantity, pickupTime, imageUrl } = req.body;

        // Get partner ID
        const partner = await Partner.findOne({ where: { userId: req.user.id } });
        if (!partner) return res.status(401).json({ msg: 'User is not a partner' });

        const newOffer = await Offer.create({
            partnerId: partner.id,
            title,
            description,
            price,
            originalPrice,
            quantity,
            pickupTime,
            imageUrl,
            status: 'Active'
        });

        res.json(newOffer);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.getOffers = async (req, res) => {
    try {
        const partner = await Partner.findOne({ where: { userId: req.user.id } });
        if (!partner) return res.status(401).json({ msg: 'User is not a partner' });

        const offers = await Offer.findAll({ where: { partnerId: partner.id }, order: [['createdAt', 'DESC']] });
        res.json(offers);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.getOrders = async (req, res) => {
    try {
        const partner = await Partner.findOne({ where: { userId: req.user.id } });
        if (!partner) return res.status(401).json({ msg: 'User is not a partner' });

        const orders = await Order.findAll({
            where: { partnerId: partner.id },
            include: [
                { model: User, as: 'Buyer', attributes: ['name'] },
                // { model: db.OrderItem, include: [Offer] } // Add this if you want items details
            ],
            order: [['createdAt', 'DESC']]
        });
        res.json(orders);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.updateOrderStatus = async (req, res) => {
    try {
        const { status } = req.body;
        const orderId = req.params.id;

        const partner = await Partner.findOne({ where: { userId: req.user.id } });
        if (!partner) return res.status(401).json({ msg: 'User is not a partner' });

        const order = await Order.findOne({ where: { id: orderId, partnerId: partner.id } });
        if (!order) return res.status(404).json({ msg: 'Order not found' });

        order.status = status;
        await order.save();

        res.json(order);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
