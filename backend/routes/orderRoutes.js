const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const auth = require('../middleware/auth');

// @route   POST api/orders
// @desc    Create an order (Buyer)
// @access  Private (Buyer)
router.post('/', auth, orderController.createOrder);

// @route   GET api/orders
// @desc    Get my orders (Buyer)
// @access  Private (Buyer)
router.get('/', auth, orderController.getMyOrders);

// @route   GET api/orders/admin
// @desc    Get all orders (Admin)
// @access  Private (Admin)
router.get('/admin', auth, orderController.getAllOrdersAdmin);

module.exports = router;
