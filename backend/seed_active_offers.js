const db = require('./config/db');

const seedActiveOffers = async () => {
    try {
        console.log('Connecting to database...');
        await db.sequelize.authenticate();
        console.log('Database connected.');

        const partner = await db.Partner.findOne();
        if (!partner) {
            console.error('No partners found! Run the main seed_data.js first.');
            process.exit(1);
        }

        console.log(`Seeding active offers for Partner: ${partner.businessName} (ID: ${partner.id})`);

        const offers = [
            {
                title: "Bulk Order: 50x Butter Chicken",
                description: "Cater your event with our premium butter chicken. Includes naan.",
                price: 12000,
                originalPrice: 15000,
                quantity: 1,
                pickupTime: "12:00 PM - 03:00 PM",
                status: "Active",
                imageUrl: "https://loremflickr.com/320/240/food,chicken?random=10"
            },
            {
                title: "Bulk Order: 30x Veg Pizza",
                description: "Large veg pizzas for office parties.",
                price: 9000,
                originalPrice: 12000,
                quantity: 1,
                pickupTime: "01:00 PM - 04:00 PM",
                status: "Active",
                imageUrl: "https://loremflickr.com/320/240/food,pizza?random=11"
            },
            {
                title: "Grand Biryani Feast (100 pax)",
                description: "Authentic Hyderabadi biryani for large gatherings.",
                price: 25000,
                originalPrice: 30000,
                quantity: 1,
                pickupTime: "12:30 PM - 03:30 PM",
                status: "Active",
                imageUrl: "https://loremflickr.com/320/240/food,biryani?random=12"
            }
        ];

        for (const offer of offers) {
            await db.Offer.create({
                partnerId: partner.id,
                ...offer
            });
            console.log(`Created Bulk Offer: ${offer.title}`);
        }

        console.log('Successfully seeded 3 Bulk Active offers!');
        process.exit(0);

    } catch (error) {
        console.error('Error seeding active offers:', error);
        process.exit(1);
    }
};

seedActiveOffers();
