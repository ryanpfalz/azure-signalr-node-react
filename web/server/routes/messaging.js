const express = require("express");
const router = express.Router();
const serverHttpClient = require("../services/ServerHttpClient");
const serverConfigService = require("../services/ServerConfigService");

const API_MESSAGING = "/api/messages";

router.get(API_MESSAGING, async (req, res) => {
    const config = await serverConfigService.getConfiguration();
    var value = await serverHttpClient.get(config.broadcastFunctionUrl);
    res.send(value);
});

module.exports = router;
