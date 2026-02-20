const db = require('./config/db');

const seedData = async () => {
    try {
        await db.sequelize.sync({ alter: true }); // Ensure tables exist
        console.log('Database synced. Seeding data...');

        // Password hash
        const hashedPassword = 'password123';

        // 1. Create Buyers (Indian Names)
        const buyers = [
            { name: 'Aarav Patel', email: 'aarav@example.com', password: hashedPassword, role: 'Buyer', phone: '+91 9876543210', address: '12, MG Road, Bangalore' },
            { name: 'Diya Sharma', email: 'diya@example.com', password: hashedPassword, role: 'Buyer', phone: '+91 9876543211', address: '45, Park Street, Kolkata' },
            { name: 'Vihaan Gupta', email: 'vihaan@example.com', password: hashedPassword, role: 'Buyer', phone: '+91 9876543212', address: '78, Anna Salai, Chennai' },
            { name: 'Ananya Singh', email: 'ananya@example.com', password: hashedPassword, role: 'Buyer', phone: '+91 9876543213', address: '101, Connaught Place, Delhi' },
            { name: 'Rohan Kumar', email: 'rohan@example.com', password: hashedPassword, role: 'Buyer', phone: '+91 9876543214', address: '23, Linking Road, Mumbai' },
            // Demo Users
            { name: 'Demo Buyer', email: 'user@foodloop.com', password: 'user123', role: 'Buyer', phone: '+91 9000000001', address: 'Demo Address, City' },
            { name: 'Demo Partner', email: 'partner@foodloop.com', password: 'partner123', role: 'Partner', phone: '+91 9000000002', address: 'Demo Partner Address, City' },
            { name: 'Demo Admin', email: 'admin@foodloop.com', password: 'admin123', role: 'Admin', phone: '+91 9000000003', address: 'Admin HQ' },
            // Restored User
            { name: 'Rakshan', email: 'rakshan@gmail.com', password: 'Rakshan123', role: 'Buyer', phone: '1234567890', address: 'Sdfasfgfhg' },
        ];

        for (const buyer of buyers) {
            const [user, created] = await db.User.findOrCreate({
                where: { email: buyer.email },
                defaults: buyer
            });
            if (created) console.log(`Created Buyer: ${user.name}`);
            else {
                user.password = hashedPassword;
                await user.save();
                console.log(`Updated Buyer password: ${user.name}`);
            }
        }

        // --- Data Lists for Generation ---

        const cities = ['Bangalore', 'Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Kolkata', 'Pune', 'Ahmedabad'];

        const cuisines = [
            'North Indian', 'South Indian', 'Chinese', 'Biryani', 'Street Food',
            'Desserts', 'Beverages', 'Italian', 'Continental', 'Healthy Food'
        ];

        const businessNames = [
            'Spice Junction', 'Curry House', 'Tandoori Nights', 'Dosa Plaza', 'Biryani Paradise',
            'Chaat Corner', 'Sweet Cravings', 'The Foodie Hub', 'Taste of India', 'Urban cafe',
            'Masala Magic', 'Royal Kitchen', 'Flavours of Punjab', 'Coastal Bites', 'Cheesy Delights',
            'Green Leaf Veg', 'Mughlai Durbar', 'Street Treats', 'Chai Point', 'Bakers Galaxy'
        ];

        const foodItems = {
            'North Indian': [
                { name: 'Butter Chicken', price: 250 }, { name: 'Paneer Tikka Masala', price: 220 },
                { name: 'Dal Makhani', price: 180 }, { name: 'Chole Bhature', price: 150 },
                { name: 'Aloo Paratha', price: 80 }, { name: 'Rajma Chawal', price: 120 },
                { name: 'Malai Kofta', price: 240 }, { name: 'Kadai Paneer', price: 230 }
            ],
            'South Indian': [
                { name: 'Masala Dosa', price: 90 }, { name: 'Idli Sambar', price: 60 },
                { name: 'Vada Sambar', price: 70 }, { name: 'Uttapam', price: 100 },
                { name: 'Hyderabadi Haleem', price: 300 }, { name: 'Chicken Chettinad', price: 280 },
                { name: 'Appam with Stew', price: 150 }, { name: 'Pongal', price: 80 }
            ],
            'Chinese': [
                { name: 'Veg Hakka Noodles', price: 140 }, { name: 'Chicken Fried Rice', price: 180 },
                { name: 'Gobi Manchurian', price: 130 }, { name: 'Chilli Chicken', price: 200 },
                { name: 'Spring Rolls', price: 110 }, { name: 'Schezwan Noodles', price: 160 }
            ],
            'Biryani': [
                { name: 'Hyderabadi Chicken Biryani', price: 250 }, { name: 'Veg Biryani', price: 180 },
                { name: 'Mutton Biryani', price: 350 }, { name: 'Egg Biryani', price: 200 },
                { name: 'Ambur Biryani', price: 240 }, { name: 'Kolkata Biryani', price: 260 }
            ],
            'Street Food': [
                { name: 'Pani Puri', price: 50 }, { name: 'Bhel Puri', price: 60 },
                { name: 'Samosa Chaat', price: 70 }, { name: 'Pav Bhaji', price: 120 },
                { name: 'Vada Pav', price: 40 }, { name: 'Dahi Puri', price: 80 }
            ],
            'Desserts': [
                { name: 'Gulab Jamun', price: 60 }, { name: 'Rasmalai', price: 80 },
                { name: 'Chocolate Brownie', price: 120 }, { name: 'Fruit Salad', price: 100 },
                { name: 'Ice Cream Sundae', price: 150 }, { name: 'Jalebi', price: 50 }
            ],
            'Beverages': [
                { name: 'Masala Chai', price: 30 }, { name: 'Cold Coffee', price: 120 },
                { name: 'Fresh Lime Soda', price: 60 }, { name: 'Lassi', price: 80 },
                { name: 'Mango Smoothie', price: 140 }, { name: 'Oreo Shake', price: 160 }
            ],
            'Italian': [
                { name: 'Margherita Pizza', price: 250 }, { name: 'Pasta Alfredo', price: 220 },
                { name: 'Garlic Bread', price: 120 }, { name: 'Veg Lasagna', price: 280 },
                { name: 'Risotto', price: 300 }
            ],
            'Continental': [
                { name: 'Grilled Chicken', price: 350 }, { name: 'Fish and Chips', price: 320 },
                { name: 'Caesar Salad', price: 200 }, { name: 'Mashed Potatoes', price: 150 }
            ],
            'Healthy Food': [
                { name: 'Quinoa Salad', price: 250 }, { name: 'Oats Upma', price: 120 },
                { name: 'Fruit Bowl', price: 150 }, { name: 'Green Smoothie', price: 180 }
            ]

        };

        const adjectives = ['Spicy', 'Delicious', 'Authentic', 'Homestyle', 'Crispy', 'Fresh', 'Savory', 'Sweet', 'Tangy', 'Classic'];

        // --- 2. Generate Partners ---
        console.log('Generating Partners...');

        let partnerCount = 0;
        let offerCount = 0;

        for (let i = 0; i < businessNames.length; i++) {
            const bName = businessNames[i];
            const pCuisine = cuisines[i % cuisines.length]; // Assign cuisine cyclically
            const pCity = cities[i % cities.length];
            const pEmail = `partner${i + 1}@${bName.toLowerCase().replace(/\s/g, '')}.com`;

            // Create User for Partner
            const [user, created] = await db.User.findOrCreate({
                where: { email: pEmail },
                defaults: {
                    name: `Owner of ${bName}`,
                    email: pEmail,
                    password: hashedPassword,
                    role: 'Partner',
                    phone: `+91 98765432${(30 + i).toString().slice(-2)}`, // Generate somewhat unique phone
                    address: `${10 + i}, Market Road, ${pCity}`
                }
            });

            let partnerId;
            if (created) {
                const partner = await db.Partner.create({
                    userId: user.id,
                    businessName: bName,
                    cuisine: pCuisine,
                    rating: (3.5 + Math.random() * 1.5).toFixed(1), // Random rating 3.5 - 5.0
                    cuisine: pCuisine,
                    rating: (3.5 + Math.random() * 1.5).toFixed(1), // Random rating 3.5 - 5.0
                    isOnline: Math.random() > 0.1, // 90% chance online
                    openingHours: '10:00 AM - 11:00 PM',
                    imageUrl: `https://loremflickr.com/320/240/restaurant,building?random=${i}`
                });
                partnerId = partner.id;
                console.log(`Created Partner: ${bName}`);
                partnerCount++;
            } else {
                user.password = hashedPassword;
                await user.save();
                // Find existing partner record
                const existingPartner = await db.Partner.findOne({ where: { userId: user.id } });
                if (existingPartner) {
                    partnerId = existingPartner.id;
                } else {
                    // Should not happen normally if synced, but handle just in case
                    const partner = await db.Partner.create({
                        userId: user.id,
                        businessName: bName,
                        cuisine: pCuisine,
                        rating: (3.5 + Math.random() * 1.5).toFixed(1),
                        cuisine: pCuisine,
                        rating: (3.5 + Math.random() * 1.5).toFixed(1),
                        isOnline: true,
                        openingHours: '10:00 AM - 11:00 PM',
                        imageUrl: `https://loremflickr.com/320/240/restaurant,building?random=${i}`
                    });
                    partnerId = partner.id;
                }
                console.log(`Updated Partner User: ${bName}`);
            }

            // --- 3. Generate Offers for this Partner ---
            // Determine primary food category for this partner based on usage or random
            const partnerFoodCategories = [pCuisine];
            // Add 1-2 random other categories to make menu diverse
            while (partnerFoodCategories.length < 3) {
                const randomCat = cuisines[Math.floor(Math.random() * cuisines.length)];
                if (!partnerFoodCategories.includes(randomCat)) partnerFoodCategories.push(randomCat);
            }

            // Generate 15-20 offers per partner
            const numberOfOffers = 15 + Math.floor(Math.random() * 6);

            for (let j = 0; j < numberOfOffers; j++) {
                // Pick a category
                const cat = partnerFoodCategories[Math.floor(Math.random() * partnerFoodCategories.length)];
                const items = foodItems[cat];
                const baseItem = items[Math.floor(Math.random() * items.length)];

                // Construct a varied title
                const adj = adjectives[Math.floor(Math.random() * adjectives.length)];
                const title = `${adj} ${baseItem.name} ${j + 1}`; // j+1 ensures uniqueness if name repeats

                // Price Variation
                const originalPrice = baseItem.price + Math.floor(Math.random() * 50);
                const discount = Math.floor(Math.random() * 20) + 10; // 10 to 30% discount
                const price = Math.floor(originalPrice * (1 - discount / 100));

                const offerData = {
                    partnerId: partnerId,
                    title: title,
                    description: `Delicious ${baseItem.name} prepared with fresh ingredients. ${adj} taste guaranteed!`,
                    price: price,
                    originalPrice: originalPrice,
                    quantity: Math.floor(Math.random() * 20) + 5, // 5 to 25 items
                    pickupTime: `${Math.floor(Math.random() * 12) + 10}:00 - ${Math.floor(Math.random() * 10) + 14}:00`,
                    pickupTime: `${Math.floor(Math.random() * 12) + 10}:00 - ${Math.floor(Math.random() * 10) + 14}:00`,
                    status: Math.random() > 0.2 ? 'Active' : (Math.random() > 0.5 ? 'Sold Out' : 'Expired'),
                    imageUrl: `https://loremflickr.com/320/240/food,dish?random=${offerCount}` // Better random images
                };

                await db.Offer.create(offerData);
                offerCount++;
            }
        }

        console.log('-----------------------------------');
        console.log(`Seeding Completed Successfully!`);
        console.log(`Total Partners Processed: ${businessNames.length}`);
        console.log(`Total Offers Generated: ${offerCount}`);
        console.log('-----------------------------------');
        process.exit(0);

    } catch (error) {
        console.error('Error seeding data:', error);
        process.exit(1);
    }
};

seedData();
