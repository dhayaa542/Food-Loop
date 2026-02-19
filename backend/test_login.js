const axios = require('axios');

const testLogin = async () => {
    try {
        const response = await axios.post('http://localhost:5001/api/auth/login', {
            email: 'aarav@example.com',
            password: 'password123'
        });
        console.log('Login Successful!');
        console.log('Token:', response.data.token);
        console.log('User:', response.data.user);
    } catch (error) {
        if (error.response) {
            console.error('Login Failed:', error.response.status, error.response.data);
        } else {
            console.error('Login Error:', error.message);
        }
    }
};

testLogin();
