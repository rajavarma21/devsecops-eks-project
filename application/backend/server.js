const express = require("express");
const cors = require("cors");
const { createClient } = require("redis");

const app = express();

app.use(cors());

const PORT = process.env.PORT || 5000;
const REDIS_HOST = process.env.REDIS_HOST || "localhost";
const REDIS_PORT = process.env.REDIS_PORT || 6379;

const redisClient = createClient({
    socket: {
        host: REDIS_HOST,
        port: REDIS_PORT
    }
});

redisClient.on("error", (error) => {
    console.log("Redis error:", error.message);
});

async function startServer() {

    try {
        await redisClient.connect();
        console.log("Connected to Redis");
    } catch (error) {
        console.log("Redis connection failed:", error.message);
    }

    app.get("/", (req, res) => {
        res.json({
            message: "DevSecOps Backend is running",
            status: "success"
        });
    });

    app.get("/health", (req, res) => {
        res.json({
            status: "healthy"
        });
    });

    app.get("/api/info", async (req, res) => {

        let visits = 0;

        try {
            visits = await redisClient.incr("visits");
        } catch (error) {
            console.log("Redis unavailable");
        }

        res.json({
            application: "DevSecOps EKS Application",
            environment: process.env.ENVIRONMENT || "development",
            visits: visits
        });
    });

    app.listen(PORT, () => {
        console.log(`Backend running on port ${PORT}`);
    });
}

startServer();
