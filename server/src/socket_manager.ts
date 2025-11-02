import { Server as IOServer, Socket } from "socket.io";
import { readdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

// ES module equivalent of __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Clean Socket Manager
 * 
 * Minimal socket.io manager that:
 * - Auto-discovers handlers in routes/sockets/*.ts
 * - Converts function names (connection_welcome → connection:welcome)
 * - Provides unified socket communication interface
 * - Clean English logging
 */
export class SocketManager {
    private io: IOServer;
    private handlers: Map<string, Function> = new Map();
    private socketHandlers: Map<string, Socket> = new Map();

    constructor(io: IOServer) {
        this.io = io;
        this.loadHandlers();
        this.setupConnection();
    }

    /**
     * Auto-discover and load socket handlers from routes/sockets/
     */
    private async loadHandlers(): Promise<void> {
        const socketsDir = join(__dirname, "routes", "sockets");
        
        try {
            const files = readdirSync(socketsDir).filter(file => file.endsWith('.ts'));
            
            for (const file of files) {
                const modulePath = join(socketsDir, file);
                const moduleUrl = `file://${modulePath.replace(/\\/g, '/')}`;
                const module = await import(moduleUrl);
                
                // Extract handlers and convert naming convention
                Object.keys(module).forEach(exportName => {
                    if (typeof module[exportName] === 'function') {
                        const eventName = this.convertEventName(exportName);
                        this.handlers.set(eventName, module[exportName]);
                    }
                });
            }
            
            console.log(`🔗 [SOCKET MANAGER] Loaded ${this.handlers.size} handlers`);
        } catch (error) {
            console.error("❌ [SOCKET MANAGER] Failed to load handlers:", error);
        }
    }

    /**
     * Convert function names to socket event names
     * connection_welcome → connection:welcome
     */
    private convertEventName(functionName: string): string {
        return functionName.replace(/_/g, ':');
    }

    /**
     * Setup main connection handler and register all events
     */
    private setupConnection(): void {
        this.io.on("connection", (socket: Socket) => {
            console.log(`🔗 [SOCKET MANAGER] Client connected: ${socket.id}`);
            
            this.socketHandlers.set(socket.id, socket);
            
            // Register all discovered handlers
            this.handlers.forEach((handler, eventName) => {
                socket.on(eventName, (data: any) => {
                    this.executeHandler(handler, socket, data, eventName);
                });
            });

            // Send welcome message on connection
            this.sendWelcomeMessage(socket);

            // Handle disconnection
            socket.on("disconnect", () => {
                console.log(`🔗 [SOCKET MANAGER] Client disconnected: ${socket.id}`);
                this.socketHandlers.delete(socket.id);
            });
        });
    }

    /**
     * Execute handler with unified context
     */
    private executeHandler(handler: Function, socket: Socket, data: any, eventName: string): void {
        try {
            const context = {
                socket,
                io: this.io,
                broadcast: this.broadcast.bind(this),
                getSocket: this.getSocket.bind(this),
                getAllSockets: this.getAllSockets.bind(this)
            };

            handler.call(context, socket, data, context);
            console.log(`📡 [SOCKET MANAGER] Event handled: ${eventName}`);
        } catch (error) {
            console.error(`❌ [SOCKET MANAGER] Handler error for ${eventName}:`, error);
        }
    }

    /**
     * Broadcast to all connected sockets
     */
    public broadcast(event: string, data: any): void {
        this.io.emit(event, data);
    }

    /**
     * Get specific socket by ID
     */
    public getSocket(socketId: string): Socket | undefined {
        return this.socketHandlers.get(socketId);
    }

    /**
     * Get all connected sockets
     */
    public getAllSockets(): Socket[] {
        return Array.from(this.socketHandlers.values());
    }

    /**
     * Get IO server instance
     */
    public getIO(): IOServer {
        return this.io;
    }

    /**
     * Get connection count
     */
    public getConnectionCount(): number {
        return this.socketHandlers.size;
    }

    /**
     * Send welcome message on connection
     */
    private sendWelcomeMessage(socket: Socket): void {
        try {
            socket.emit("connection:welcome", {
                success: true,
                data: {
                    message: "Welcome to the socket.io server!",
                    socketId: socket.id,
                    timestamp: Date.now()
                },
                timestamp: Date.now()
            });
            
            console.log(`👋 [WELCOME] Welcome message sent to client: ${socket.id}`);
        } catch (error) {
            console.error(`❌ [WELCOME] Error sending welcome message:`, error);
        }
    }
}