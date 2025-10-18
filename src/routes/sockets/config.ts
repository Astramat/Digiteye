import { Socket } from "socket.io";
import type { HandlerContext, ConfigUpdate, PipelineConfig, SocketResponse } from "../../types";

/**
 * Configuration Management Handlers
 * 
 * Handles configuration updates:
 * - config:update - Update configuration
 * - config:get - Get configuration
 * - config:reset - Reset configuration
 */

export function config_update(socket: Socket, data: ConfigUpdate, context: HandlerContext) {
  try {
    console.log(`⚙️ [CONFIG] Config update: ${data.category}.${data.key} = ${data.value}`);
    
    // Send configuration update to Python workers
    context.broadcast("command:process", {
      sessionId: "global", // Global configuration
      action: "configure",
      data: {
        key: data.key,
        value: data.value,
        category: data.category
      },
      timestamp: Date.now()
    });

    // Also update configuration in voice processor if available (fallback)
    if (context.voiceProcessor) {
      context.voiceProcessor.updateConfig(data.key, data.value);
    }

    const response: SocketResponse = {
      success: true,
      data: {
        category: data.category,
        key: data.key,
        value: data.value,
        timestamp: Date.now()
      },
      timestamp: Date.now()
    };

    socket.emit("config:updated", response);
    console.log(`✅ [CONFIG] Configuration updated: ${data.category}.${data.key}`);
    
  } catch (error) {
    console.error(`❌ [CONFIG] Failed to update configuration:`, error);
    socket.emit("config:updated", {
      success: false,
      error: error instanceof Error ? error.message : String(error),
      timestamp: Date.now()
    });
  }
}

export function config_get(socket: Socket, data: { category?: string }, context: HandlerContext) {
  try {
    console.log(`📋 [CONFIG] Getting configuration for category: ${data.category || 'all'}`);
    
    // Get configuration from voice processor if available
    let config: any = {};
    if (context.voiceProcessor) {
      config = context.voiceProcessor.getConfig(data.category);
    }

    const response: SocketResponse = {
      success: true,
      data: {
        category: data.category || 'all',
        config: config,
        timestamp: Date.now()
      },
      timestamp: Date.now()
    };

    socket.emit("config:data", response);
    console.log(`✅ [CONFIG] Configuration retrieved for category: ${data.category || 'all'}`);
    
  } catch (error) {
    console.error(`❌ [CONFIG] Failed to get configuration:`, error);
    socket.emit("config:data", {
      success: false,
      error: error instanceof Error ? error.message : String(error),
      timestamp: Date.now()
    });
  }
}

export function config_reset(socket: Socket, data: { category?: string }, context: HandlerContext) {
  try {
    console.log(`🔄 [CONFIG] Resetting configuration for category: ${data.category || 'all'}`);
    
    // Reset configuration in voice processor if available
    if (context.voiceProcessor) {
      context.voiceProcessor.resetConfig(data.category);
    }

    const response: SocketResponse = {
      success: true,
      data: {
        category: data.category || 'all',
        action: 'reset',
        timestamp: Date.now()
      },
      timestamp: Date.now()
    };

    socket.emit("config:reset", response);
    console.log(`✅ [CONFIG] Configuration reset for category: ${data.category || 'all'}`);
    
  } catch (error) {
    console.error(`❌ [CONFIG] Failed to reset configuration:`, error);
    socket.emit("config:reset", {
      success: false,
      error: error instanceof Error ? error.message : String(error),
      timestamp: Date.now()
    });
  }
}
