import { Socket } from "socket.io";
import type { HandlerContext, SocketResponse } from "../../types";

/**
 * System Handlers
 * 
 * Clean system handlers with English logging
 */

export function system_status(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`📊 [SYSTEM] Status request from client: ${socket.id}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                status: 'online',
                uptime: process.uptime(),
                connections: context.getAllSockets().length,
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };

        socket.emit("system:status", response);
        console.log(`✅ [SYSTEM] Status sent to client: ${socket.id}`);
        
    } catch (error) {
        console.error(`❌ [SYSTEM] Failed to get status:`, error);
        socket.emit("system:status", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function system_health(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`🏥 [SYSTEM] Health check request from client: ${socket.id}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                health: 'healthy',
                memory: process.memoryUsage(),
                uptime: process.uptime(),
                connections: context.getAllSockets().length,
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };

        socket.emit("system:health", response);
        console.log(`✅ [SYSTEM] Health check completed for client: ${socket.id}`);
        
    } catch (error) {
        console.error(`❌ [SYSTEM] Failed to get health status:`, error);
        socket.emit("system:health", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function system_stats(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`📈 [SYSTEM] Stats request from client: ${socket.id}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                connections: context.getAllSockets().length,
                uptime: process.uptime(),
                memory: process.memoryUsage(),
                platform: process.platform,
                nodeVersion: process.version,
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };

        socket.emit("system:stats", response);
        console.log(`✅ [SYSTEM] Stats sent to client: ${socket.id}`);
        
    } catch (error) {
        console.error(`❌ [SYSTEM] Failed to get stats:`, error);
        socket.emit("system:stats", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}
