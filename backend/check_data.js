const db = require('./config/db');

const checkData = async () => {
    try {
        console.log('Connecting to database...');
        await db.sequelize.authenticate();
        console.log('Database connected.');

        const partners = await db.Partner.findAll();
        console.log(`Total Partners: ${partners.length}`);
        partners.forEach(p => console.log(` - ID: ${p.id}, Name: ${p.businessName}`));

        const offers = await db.Offer.findAll();
        console.log(`Total Offers: ${offers.length}`);
        offers.forEach(o => console.log(` - ID: ${o.id}, Title: ${o.title}, Status: ${o.status}, PartnerId: ${o.partnerId}, Image: ${o.imageUrl}`));

        if (offers.length > 0) {
            console.log('Sample Offer JSON:', JSON.stringify(offers[0].toJSON(), null, 2));
        }

        process.exit(0);
    } catch (error) {
        console.error('Error checking data:', error);
        process.exit(1);
    }
};

checkData();
