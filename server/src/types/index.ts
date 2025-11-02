/**
 * Clean Socket.IO Types
 * 
 * Minimal types for socket.io operations
 */

export interface BaseResponse {
    success: boolean;
    timestamp: number;
    message?: string;
}

export interface SuccessResponse<T = any> extends BaseResponse {
    success: true;
    data: T;
}

export interface ErrorResponse extends BaseResponse {
    success: false;
    error: string;
    code?: string;
}

export type SocketResponse<T = any> = SuccessResponse<T> | ErrorResponse;

export interface HandlerContext {
    socket: any;
    io: any;
    broadcast: (event: string, data: any) => void;
    getSocket: (socketId: string) => any;
    getAllSockets: () => any[];
}