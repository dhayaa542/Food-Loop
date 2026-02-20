const db = require('./config/db');

const listPartners = async () => {
    try {
        await db.sequelize.authenticate();
        console.log('Connected.');

        const partners = await db.Partner.findAll({
            include: [{ model: db.User, attributes: ['email', 'name'] }]
        });

        console.log('\n--- VALID PARTNER CREDENTIALS ---');
        partners.forEach(p => {
            // Check if it's the demo partner, or just list them all
            if (p.User) {
                console.log(`Business: ${p.businessName}`);
                console.log(`Email: ${p.User.email}`);
                console.log(`Default Seed Password: password123 (or 'partner123' for Demo Partner)`);
                console.log('-------------------------------');
            }
        });

        // Check specifically for the demo partner
        const demo = partners.find(p => p.User && p.User.email === 'partner@foodloop.com');
        if (demo) {
            console.log('\n✅ RECOMMENDED FOR TESTING:');
            console.log(`Email: partner@foodloop.com`);
            console.log(`Password: partner123`);
        } else {
            console.log('\n⚠️ Demo Partner not found. Use any email above with password "password123".');
        }

        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};

listPartners();
