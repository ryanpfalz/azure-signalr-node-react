const express = require("express");
const cors = require("cors");
const path = require("path");

class Server {
    constructor() {
        this.app = express();
        this.port = process.env.PORT || 80;
        this.middlewares();
        this.routes();
    }

    middlewares() {
        this.app.use(cors());
        this.app.use(express.json());

        // Pick up React index.html file
        this.app.use(
            express.static(path.join(__dirname, "../../client/build"))
        );
    }

    // endpoints
    routes() {
        this.app.use("/", require("../routes/messaging"));
        this.app.use("/", require("../routes/signalr"));
    }

    listen() {
        this.app.listen(this.port, () => {
            console.log("Server running on port: ", this.port);
        });
    }
}

module.exports = Server;
