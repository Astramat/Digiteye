import express from "express";
import cors from "cors";
import http from "node:http";
import { Server } from "socket.io";
import { SocketManager } from "./socket_manager";

console.log("🚀 [SOCKET.IO] Starting clean socket.io server...");

// Initialize Express app
const app = express();

// Apply middleware
app.use(cors({
    origin: process.env.NODE_ENV === 'production' 
        ? process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000']
        : true,
    credentials: true
}));
app.use(express.json());

// Basic health check
app.get("/", (req, res) => {
    res.json({ 
        status: "ok", 
        message: "Socket.IO server is running",
        timestamp: Date.now()
    });
});

// Create HTTP server
const server = http.createServer(app);

// Create Socket.IO server
const io = new Server(server, {
    cors: {
        origin: process.env.NODE_ENV === 'production' 
            ? process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000']
            : true,
        credentials: true
    },
    maxHttpBufferSize: 10 * 1024 * 1024, // 10MB
    perMessageDeflate: false,
    allowEIO3: true,
    transports: ['websocket', 'polling']
});

// Create SocketManager
const socketManager = new SocketManager(io);

console.log("🎤 [SOCKET.IO] Socket.IO endpoints enabled");

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`🎉 [SOCKET.IO] Server running on port ${PORT}`);
    console.log(`🌐 [SOCKET.IO] CORS enabled for development`);
    console.log(`🔗 [SOCKET.IO] SocketManager initialized with ${socketManager.getConnectionCount()} connections`);
});

// Graceful shutdown
const gracefulShutdown = async (signal: string) => {
    console.log(`\n🛑 [SOCKET.IO] Received ${signal}, shutting down gracefully...`);
    process.exit(0);
};

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

// Error handling
process.on('uncaughtException', (error) => {
    console.error('❌ [SOCKET.IO] Uncaught Exception:', error);
    gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ [SOCKET.IO] Unhandled Rejection at:', promise, 'reason:', reason);
    gracefulShutdown('unhandledRejection');
});