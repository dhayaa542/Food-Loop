const axios = require('axios');

const testBidding = async () => {
    try {
        const uniqueEmail = `bidder_${Date.now()}@example.com`;

        // 1. Register User
        const registerRes = await axios.post('http://localhost:5001/api/auth/register', {
            name: 'Test Bidder',
            email: uniqueEmail,
            password: 'password123',
            role: 'Buyer',
            phone: '1234567890',
            address: '123 Street'
        });
        const token = registerRes.data.token;
        const userId = registerRes.data.user.id;
        console.log(`Registered User ID: ${userId}`);

        // 2. Get an Offer (assuming seed_data created some)
        const offersRes = await axios.get('http://localhost:5001/api/offers');
        if (offersRes.data.length === 0) {
            console.error('No offers found to bid on.');
            return;
        }
        const offerId = offersRes.data[0].id;
        const minBid = offersRes.data[0].price; // Assuming price is minBid
        console.log(`Found Offer ID: ${offerId} with price: ${minBid}`);

        // 3. Place a Bid (Valid)
        const bidAmount = parseFloat(minBid) + 10;
        console.log(`Placing bid of: ${bidAmount}`);

        try {
            const bidRes = await axios.post(
                'http://localhost:5001/api/bids',
                { offerId, amount: bidAmount },
                { headers: { 'x-auth-token': token } }
            );
            console.log('Bid Placed Successfully:', bidRes.data);
        } catch (bidErr) {
            console.error('Bid Failed:', bidErr.response ? bidErr.response.data : bidErr.message);
        }

        // 4. Place a Lower Bid (Should Fail)
        try {
            const lowerBid = parseFloat(minBid) - 5;
            console.log(`Attempting lower bid: ${lowerBid}`);
            await axios.post(
                'http://localhost:5001/api/bids',
                { offerId, amount: lowerBid },
                { headers: { 'x-auth-token': token } }
            );
        } catch (bidErr) {
            console.log('Low Bid correctly rejected:', bidErr.response ? bidErr.response.data.message : bidErr.message);
        }

        // 5. Get Bids for Offer
        const getBidsRes = await axios.get(`http://localhost:5001/api/bids/${offerId}`);
        console.log(`Fetched ${getBidsRes.data.length} bids for offer ${offerId}`);
        console.log(getBidsRes.data);

    } catch (error) {
        console.error('Test Failed:', error.response ? error.response.data : error.message);
    }
};

testBidding();
