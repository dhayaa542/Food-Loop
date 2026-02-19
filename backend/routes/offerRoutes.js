const express = require('express');
const router = express.Router();
const offerController = require('../controllers/offerController');

// @route   GET api/offers
// @desc    Get all active offers
// @access  Public
router.get('/', offerController.getAllOffers);

// @route   GET api/offers/:id
// @desc    Get offer by ID
// @access  Public
router.get('/:id', offerController.getOfferById);

module.exports = router;
