import { Socket } from "socket.io";
import type { HandlerContext, SocketResponse } from "../../types";

/**
 * Audio Processing Handlers
 * 
 * Clean audio handlers with English logging
 */

export function audio_start(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`🎤 [AUDIO] Starting audio stream for session: ${data.sessionId}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                sessionId: data.sessionId,
                status: 'streaming',
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };

        socket.emit("audio:started", response);
        console.log(`✅ [AUDIO] Audio stream started for session: ${data.sessionId}`);
        
    } catch (error) {
        console.error(`❌ [AUDIO] Failed to start audio stream:`, error);
        socket.emit("audio:started", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function audio_stop(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`🛑 [AUDIO] Stopping audio stream for session: ${data.sessionId}`);
        
        const response: SocketResponse = {
            success: true,
            data: {
                sessionId: data.sessionId,
                status: 'stopped',
                timestamp: Date.now()
            },
            timestamp: Date.now()
        };

        socket.emit("audio:stopped", response);
        console.log(`✅ [AUDIO] Audio stream stopped for session: ${data.sessionId}`);
        
    } catch (error) {
        console.error(`❌ [AUDIO] Failed to stop audio stream:`, error);
        socket.emit("audio:stopped", {
            success: false,
            error: error instanceof Error ? error.message : String(error),
            timestamp: Date.now()
        });
    }
}

export function audio_chunk(socket: Socket, data: any, context: HandlerContext) {
    try {
        console.log(`📁 [AUDIO] Processing audio chunk #${data.seq} for session: ${data.sessionId}`);
        
        // Simple audio chunk processing
        if (!data.base64 || data.base64.length === 0) {
            console.warn(`⚠️ [AUDIO] Empty audio chunk #${data.seq}`);
            return;
        }

        const buf = Buffer.from(data.base64, "base64");
        console.log(`📁 [AUDIO] Chunk #${data.seq} processed (${buf.length}B)`);

        // Send acknowledgment
        socket.emit("audio:chunk:processed", {
            success: true,
            data: {
                sessionId: data.sessionId,
                seq: data.seq,
                processedAt: Date.now()
            },
            timestamp: Date.now()
        });
        
    } catch (error) {
        console.error(`❌ [AUDIO] Failed to process chunk #${data.seq}:`, error);
    }
}
