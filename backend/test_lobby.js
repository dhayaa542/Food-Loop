const axios = require('axios');

const testLobby = async () => {
    try {
        // 1. Register User A
        const userA = await registerUser('UserA');
        const tokenA = userA.token;

        // 2. Register User B
        const userB = await registerUser('UserB');
        const tokenB = userB.token;

        // 3. Get an Offer
        const offersRes = await axios.get('http://localhost:5001/api/offers');
        if (offersRes.data.length === 0) return console.error('No offers found');
        const offerId = offersRes.data[0].id;
        console.log(`Testing with Offer ID: ${offerId}`);

        // 4. User A Joins Lobby
        console.log('User A Joining Lobby...');
        const joinARes = await axios.post(
            `http://localhost:5001/api/bids/join/${offerId}`,
            {},
            { headers: { 'x-auth-token': tokenA } }
        );
        console.log('User A Joined. Count:', joinARes.data.count);

        // 5. User B Joins Lobby
        console.log('User B Joining Lobby...');
        const joinBRes = await axios.post(
            `http://localhost:5001/api/bids/join/${offerId}`,
            {},
            { headers: { 'x-auth-token': tokenB } }
        );
        console.log('User B Joined. Count:', joinBRes.data.count);

        // 6. Check Lobby Status anonymously
        const statusRes = await axios.get(`http://localhost:5001/api/bids/lobby/${offerId}`);
        console.log('Final Lobby Count (Public):', statusRes.data.count);

    } catch (err) {
        console.error('Test Failed:', err.response ? err.response.data : err.message);
    }
};

const registerUser = async (name) => {
    const email = `lobby_${name}_${Date.now()}@test.com`;
    const res = await axios.post('http://localhost:5001/api/auth/register', {
        name,
        email,
        password: 'password123',
        role: 'Buyer',
        phone: '1234445555',
        address: 'Test Addr'
    });
    return res.data;
};

testLobby();
