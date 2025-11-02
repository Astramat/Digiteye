/**
 * Simple Session Manager
 * 
 * Minimal session management for socket.io
 */

export interface SessionData {
    sessionId: string;
    startTime: number;
    endTime?: number;
    status: 'active' | 'paused' | 'ended';
    metadata: {
        clientId?: string;
        userAgent?: string;
        [key: string]: any;
    };
}

export class SessionManager {
    private sessions: Map<string, SessionData> = new Map();

    /**
     * Create a new session
     */
    public createSession(metadata?: any): SessionData {
        const sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        const session: SessionData = {
            sessionId,
            startTime: Date.now(),
            status: 'active',
            metadata: metadata || {}
        };

        this.sessions.set(sessionId, session);
        console.log(`🆕 [SESSION MANAGER] Session created: ${sessionId}`);
        
        return session;
    }

    /**
     * Get session by ID
     */
    public getSession(sessionId: string): SessionData | undefined {
        return this.sessions.get(sessionId);
    }

    /**
     * Update session
     */
    public updateSession(sessionId: string, updates: Partial<SessionData>): boolean {
        const session = this.sessions.get(sessionId);
        if (!session) return false;

        const updatedSession = { ...session, ...updates };
        this.sessions.set(sessionId, updatedSession);
        
        console.log(`🔄 [SESSION MANAGER] Session updated: ${sessionId}`);
        return true;
    }

    /**
     * End session
     */
    public endSession(sessionId: string): boolean {
        const session = this.sessions.get(sessionId);
        if (!session) return false;

        session.status = 'ended';
        session.endTime = Date.now();
        
        console.log(`🏁 [SESSION MANAGER] Session ended: ${sessionId}`);
        return true;
    }

    /**
     * Pause session
     */
    public pauseSession(sessionId: string): boolean {
        return this.updateSession(sessionId, { status: 'paused' });
    }

    /**
     * Resume session
     */
    public resumeSession(sessionId: string): boolean {
        return this.updateSession(sessionId, { status: 'active' });
    }

    /**
     * Delete session
     */
    public deleteSession(sessionId: string): boolean {
        const deleted = this.sessions.delete(sessionId);
        if (deleted) {
            console.log(`🗑️ [SESSION MANAGER] Session deleted: ${sessionId}`);
        }
        return deleted;
    }

    /**
     * Get all sessions
     */
    public getAllSessions(): SessionData[] {
        return Array.from(this.sessions.values());
    }

    /**
     * Get session count
     */
    public getSessionCount(): number {
        return this.sessions.size;
    }

    /**
     * Get active sessions
     */
    public getActiveSessions(): SessionData[] {
        return Array.from(this.sessions.values()).filter(session => session.status === 'active');
    }
}