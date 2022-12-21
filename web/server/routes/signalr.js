const express = require("express");
const router = express.Router();
const serverHttpClient = require("../services/ServerHttpClient");
const serverConfigService = require("../services/ServerConfigService");

const SIGNALR_NEGOTIATE = "/signalr/negotiate";

router.get(SIGNALR_NEGOTIATE, async (req, res) => {
    const config = await serverConfigService.getConfiguration();
    var value = await serverHttpClient.get(config.negotiateFunctionUrl);
    res.send(value);
});

module.exports = router;
