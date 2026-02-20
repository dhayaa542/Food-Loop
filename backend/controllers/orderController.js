const db = require('../config/db');
const Order = db.Order;
const Offer = db.Offer;
const OrderItem = db.OrderItem;
const Partner = db.Partner;

exports.createOrder = async (req, res) => {
    try {
        const { partnerId, items, totalAmount } = req.body;

        // Validate partner
        const partner = await Partner.findByPk(partnerId);
        if (!partner) return res.status(404).json({ msg: 'Partner not found' });

        // Create Order
        const order = await Order.create({
            buyerId: req.user.id,
            partnerId,
            totalAmount,
            status: 'Pending',
        });

        // Create Order Items and update offer quantity
        for (const item of items) {
            const offer = await Offer.findByPk(item.offerId);
            if (offer) {
                if (offer.quantity < item.quantity) {
                    return res.status(400).json({ msg: `Not enough quantity for ${offer.title}` });
                }

                await OrderItem.create({
                    orderId: order.id,
                    offerId: item.offerId,
                    quantity: item.quantity,
                    price: item.price,
                });

                // Decrement quantity
                offer.quantity -= item.quantity;
                if (offer.quantity === 0) offer.status = 'Sold Out';
                await offer.save();
            }
        }

        res.json(order);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.getMyOrders = async (req, res) => {
    try {
        const orders = await Order.findAll({
            where: { buyerId: req.user.id },
            include: [{
                model: Partner,
                attributes: ['businessName', 'imageUrl'],
                include: [{ model: db.User, attributes: ['email'] }]
            }],
            order: [['createdAt', 'DESC']],
        });
        res.json(orders);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.getAllOrdersAdmin = async (req, res) => {
    try {
        const orders = await Order.findAll({
            include: [
                { model: db.User, as: 'Buyer', attributes: ['id', 'name', 'email'] },
                { model: Partner, attributes: ['businessName'] }
            ],
            order: [['createdAt', 'DESC']],
        });
        res.json(orders);
    } catch (err) {
        console.error('Get all orders admin error:', err);
        res.status(500).send('Server Error');
    }
};
