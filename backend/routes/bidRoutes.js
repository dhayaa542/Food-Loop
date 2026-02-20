const express = require('express');
const router = express.Router();
const bidController = require('../controllers/bidController');
const auth = require('../middleware/auth'); // Middleware to checking logged in user

// @route   POST api/bids
// @desc    Place a bid
// @access  Private
router.post('/', auth, bidController.placeBid);

// @route   GET api/bids/:offerId
// @desc    Get bids for an offer
// @access  Public (or Private?) - Let's make it Public for now so anyone can see bids
router.get('/:offerId', bidController.getBids);

// @route   POST api/bids/join/:offerId
// @desc    Join a lobby for an offer
// @access  Private
router.post('/join/:offerId', auth, bidController.joinLobby);

// @route   GET api/bids/lobby/:offerId
// @desc    Get lobby status for an offer
// @access  Public (or Private?) - Public for now
router.get('/lobby/:offerId', bidController.getLobbyStatus);

module.exports = router;
