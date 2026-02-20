const db = require('./config/db');

const checkRecentOrder = async () => {
    try {
        await db.sequelize.authenticate();
        console.log('Connected.');

        // Get latest order
        const order = await db.Order.findOne({
            order: [['createdAt', 'DESC']],
            include: [{ model: db.Partner, include: [db.User] }]
        });

        if (!order) {
            console.log('❌ No orders found in database.');
        } else {
            console.log('\n✅ LATEST ORDER DETAILS:');
            console.log(`Order ID: ${order.id}`);
            console.log(`Total Amount: ${order.totalAmount}`);
            console.log(`Status: ${order.status}`);
            console.log(`Created At: ${order.createdAt}`);

            console.log('\n✅ THIS ORDER WAS SENT TO:');
            console.log(`Partner Name: ${order.Partner.businessName}`);
            console.log(`Partner Email: ${order.Partner.User.email}  <-- LOGIN WITH THIS`);
            console.log(`Partner Password: password123`);
        }

        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};

checkRecentOrder();
