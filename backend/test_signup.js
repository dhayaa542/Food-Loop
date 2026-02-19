const axios = require('axios');

const testSignup = async () => {
    try {
        const uniqueEmail = `testuser_${Date.now()}@example.com`;
        console.log(`Attempting to register with email: ${uniqueEmail}`);

        const response = await axios.post('http://localhost:5001/api/auth/register', {
            name: 'Test User',
            email: uniqueEmail,
            password: 'password123',
            role: 'Buyer',
            phone: '1234567890',
            address: 'Test Address'
        });
        console.log('Register Successful!');
        console.log('User:', response.data.user);

        // Try logging in immediately
        const loginResponse = await axios.post('http://localhost:5001/api/auth/login', {
            email: uniqueEmail,
            password: 'password123'
        });
        console.log('Immediate Login Successful!');

    } catch (error) {
        if (error.response) {
            console.error('Register/Login Failed:', error.response.status, error.response.data);
        } else {
            console.error('Error:', error.message);
        }
    }
};

testSignup();
