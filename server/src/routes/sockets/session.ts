import { Socket } from "socket.io";
import type { HandlerContext, SocketResponse } from "../../types";

/**
 * Session Management Handlers
 * 
 * Clean session handlers with English logging
 */

export function session_start(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`🆕 [SESSION] Starting session request:`, data);
        
        const sessionId = data.sessionId || `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        const response: SocketResponse = {
            success: true,
            data: {
                sessionId,
                startTime: Date.now(),
                status: 'active',
                metadata: {
                    clientId: socket.id,
                    userAgent: socket.handshake.headers['user-agent']
                }
            },
            timestamp: Date.now()
        };

        socket.emit("session:started", response);
        console.log(`✅ [SESSION] Session started: ${sessionId}`);

    } catch (error) {
        console.error(`❌ [SESSION] Failed to start session:`, error);
        socket.emit("session:started", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function session_end(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`🏁 [SESSION] Ending session: ${data.sessionId}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                sessionId: data.sessionId,
                endTime: Date.now(),
                status: 'ended'
            },
            timestamp: Date.now()
        };
        
        socket.emit("session:ended", response);
        console.log(`✅ [SESSION] Session ended: ${data.sessionId}`);
        
    } catch (error) {
        console.error(`❌ [SESSION] Failed to end session:`, error);
        socket.emit("session:ended", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function session_pause(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`⏸️ [SESSION] Pausing session: ${data.sessionId}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                sessionId: data.sessionId,
                status: 'paused',
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };
        
        socket.emit("session:paused", response);
        console.log(`✅ [SESSION] Session paused: ${data.sessionId}`);
        
    } catch (error) {
        console.error(`❌ [SESSION] Failed to pause session:`, error);
        socket.emit("session:paused", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function session_resume(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`▶️ [SESSION] Resuming session: ${data.sessionId}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                sessionId: data.sessionId,
                status: 'active',
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };
        
        socket.emit("session:resumed", response);
        console.log(`✅ [SESSION] Session resumed: ${data.sessionId}`);
        
    } catch (error) {
        console.error(`❌ [SESSION] Failed to resume session:`, error);
        socket.emit("session:resumed", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}