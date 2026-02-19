
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const User = db.User;
const Partner = db.Partner;

exports.register = async (req, res) => {
    try {
        const { name, email, password, role, phone, address, businessName, cuisine } = req.body;

        // Check if user exists
        let user = await User.findOne({ where: { email } });
        if (user) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Create user
        user = await User.create({
            name,
            email,
            password: password,
            role,
            phone,
            address,
        });

        // If partner, create partner profile
        if (role === 'Partner') {
            await Partner.create({
                userId: user.id,
                businessName: businessName || name, // Default to user name if not provided
                cuisine: cuisine,
                isOnline: true,
            });
        }

        // Create token
        const payload = {
            user: {
                id: user.id,
                role: user.role,
            },
        };

        jwt.sign(
            payload,
            process.env.JWT_SECRET,
            { expiresIn: '7d' },
            (err, token) => {
                if (err) throw err;
                res.json({ token, user: { id: user.id, name: user.name, email: user.email, role: user.role } });
            }
        );
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user exists
        let user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(400).json({ message: 'Invalid Credentials' });
        }

        // Check password
        // Check password
        if (password !== user.password) {
            return res.status(400).json({ message: 'Invalid Credentials' });
        }

        // Create token
        const payload = {
            user: {
                id: user.id,
                role: user.role,
            },
        };

        jwt.sign(
            payload,
            process.env.JWT_SECRET,
            { expiresIn: '7d' },
            (err, token) => {
                if (err) throw err;
                res.json({ token, user: { id: user.id, name: user.name, email: user.email, role: user.role } });
            }
        );
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.forgotPassword = async (req, res) => {
    // In a real app, this would send an email with a reset token.
    // For this dev version, we will just simulate it or allow direct password reset via a specific endpoint.
    // Let's implement a simple "reset password" that takes email and new password directly for now, 
    // effectively combining forgot/reset for ease of use in this dev stage.
    return res.status(200).json({ message: 'Please use the reset-password endpoint with your email and new password.' });
};

exports.resetPassword = async (req, res) => {
    try {
        const { email, newPassword } = req.body;

        // Check if user exists
        let user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Update password (plain text as requested)
        user.password = newPassword;
        await user.save();

        res.json({ message: 'Password updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
