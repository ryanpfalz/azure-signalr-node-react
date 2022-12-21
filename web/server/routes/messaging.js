const express = require("express");
const router = express.Router();
const serverHttpClient = require("../services/ServerHttpClient");

const API_MESSAGING = "/api/messages";

router.post(API_MESSAGING, async (req, res) => {
    var value = await serverHttpClient.post(API_MESSAGING, req.body);
    res.send(value);
});

module.exports = router;
