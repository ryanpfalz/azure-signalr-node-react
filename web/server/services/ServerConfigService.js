const Mutex = require("../util/MutexLock");
const Config = require("../config/serverConfig.json");

class ServerConfigService {
    constructor() {
        this.mutex = new Mutex();
    }

    async getConfiguration() {
        if (this.app) {
            return this.app;
        }

        await this.mutex.acquire();

        try {
            if (!this.app) {
                this.app = Config;
            }
        } finally {
            this.mutex.release();
        }

        return this.app;
    }
}

const serverConfigService = new ServerConfigService();

module.exports = serverConfigService;
