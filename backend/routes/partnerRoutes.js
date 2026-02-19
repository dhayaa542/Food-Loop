const express = require('express');
const router = express.Router();
const partnerController = require('../controllers/partnerController');
const auth = require('../middleware/auth');

// @route   GET api/partners/profile
// @desc    Get partner profile
// @access  Private (Partner)
router.get('/profile', auth, partnerController.getPartnerProfile);

// @route   POST api/partners/offers
// @desc    Create an offer
// @access  Private (Partner)
router.post('/offers', auth, partnerController.createOffer);

// @route   GET api/partners/offers
// @desc    Get partner's offers
// @access  Private (Partner)
router.get('/offers', auth, partnerController.getOffers);

// @route   GET api/partners/orders
// @desc    Get partner's orders
// @access  Private (Partner)
router.get('/orders', auth, partnerController.getOrders);

// @route   PUT api/partners/orders/:id/status
// @desc    Update order status
// @access  Private (Partner)
router.put('/orders/:id/status', auth, partnerController.updateOrderStatus);

module.exports = router;
