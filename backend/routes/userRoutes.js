const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/auth');

// @route   PUT api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', authMiddleware, userController.updateProfile);

// @route   GET api/users
// @desc    Get all users (Admin)
// @access  Private (Admin - TODO: Add admin middleware)
router.get('/', authMiddleware, userController.getAllUsers);

module.exports = router;
