# Socket.IO Routes Documentation

## Overview
This document lists all available Socket.IO routes in the clean, minimal socket.io server.

## Route Format
All routes follow the pattern: `category:action` (e.g., `session:start`)

## NGROK
ngrok start --config=./ngrok.yml socketio


---

## 🔗 Connection Routes

### `connection:welcome`
**Type:** Auto-emitted on connection  
**Description:** Welcome message sent automatically when a client connects  
**Response:** 
```json
{
  "success": true,
  "data": {
    "message": "Welcome to the socket.io server!",
    "socketId": "socket_id_here",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

---

## 📋 Session Management Routes

### `session:start`
**Description:** Start a new session  
**Request Data:**
```json
{
  "sessionId": "optional_session_id",
  "metadata": {
    "clientId": "optional_client_id",
    "userAgent": "optional_user_agent"
  }
}
```
**Response:** `session:started`
```json
{
  "success": true,
  "data": {
    "sessionId": "generated_session_id",
    "startTime": 1234567890,
    "status": "active",
    "metadata": {
      "clientId": "socket_id",
      "userAgent": "browser_info"
    }
  },
  "timestamp": 1234567890
}
```

### `session:end`
**Description:** End an existing session  
**Request Data:**
```json
{
  "sessionId": "session_id_to_end"
}
```
**Response:** `session:ended`
```json
{
  "success": true,
  "data": {
    "sessionId": "session_id",
    "endTime": 1234567890,
    "status": "ended"
  },
  "timestamp": 1234567890
}
```

### `session:pause`
**Description:** Pause an active session  
**Request Data:**
```json
{
  "sessionId": "session_id_to_pause"
}
```
**Response:** `session:paused`
```json
{
  "success": true,
  "data": {
    "sessionId": "session_id",
    "status": "paused",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `session:resume`
**Description:** Resume a paused session  
**Request Data:**
```json
{
  "sessionId": "session_id_to_resume"
}
```
**Response:** `session:resumed`
```json
{
  "success": true,
  "data": {
    "sessionId": "session_id",
    "status": "active",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

---

## 🎤 Audio Processing Routes

### `audio:start`
**Description:** Start audio streaming for a session  
**Request Data:**
```json
{
  "sessionId": "session_id"
}
```
**Response:** `audio:started`
```json
{
  "success": true,
  "data": {
    "sessionId": "session_id",
    "status": "streaming",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `audio:stop`
**Description:** Stop audio streaming for a session  
**Request Data:**
```json
{
  "sessionId": "session_id"
}
```
**Response:** `audio:stopped`
```json
{
  "success": true,
  "data": {
    "sessionId": "session_id",
    "status": "stopped",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `audio:chunk`
**Description:** Process audio chunk data  
**Request Data:**
```json
{
  "sessionId": "session_id",
  "seq": 1,
  "base64": "base64_encoded_audio_data",
  "mimeType": "audio/webm"
}
```
**Response:** `audio:chunk:processed`
```json
{
  "success": true,
  "data": {
    "sessionId": "session_id",
    "seq": 1,
    "processedAt": 1234567890
  },
  "timestamp": 1234567890
}
```

---

## ⚙️ Configuration Routes

### `config:update`
**Description:** Update system configuration  
**Request Data:**
```json
{
  "key": "configuration_key",
  "value": "new_value",
  "category": "vad|stt|diarization|llm|tts|pipeline"
}
```
**Response:** `config:updated`
```json
{
  "success": true,
  "data": {
    "category": "category_name",
    "key": "configuration_key",
    "value": "new_value",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `config:get`
**Description:** Get current configuration  
**Request Data:**
```json
{
  "category": "optional_category_filter"
}
```
**Response:** `config:data`
```json
{
  "success": true,
  "data": {
    "category": "category_name",
    "config": {
      "key1": "value1",
      "key2": "value2"
    },
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `config:reset`
**Description:** Reset configuration to defaults  
**Request Data:**
```json
{
  "category": "optional_category_to_reset"
}
```
**Response:** `config:reset`
```json
{
  "success": true,
  "data": {
    "category": "category_name",
    "action": "reset",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

---

## 📊 System Monitoring Routes

### `system:status`
**Description:** Get server status information  
**Request Data:** `{}`
**Response:** `system:status`
```json
{
  "success": true,
  "data": {
    "status": "online",
    "uptime": 3600,
    "connections": 5,
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `system:health`
**Description:** Get server health information  
**Request Data:** `{}`
**Response:** `system:health`
```json
{
  "success": true,
  "data": {
    "health": "healthy",
    "memory": {
      "rss": 12345678,
      "heapTotal": 12345678,
      "heapUsed": 12345678,
      "external": 12345678
    },
    "uptime": 3600,
    "connections": 5,
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

### `system:stats`
**Description:** Get detailed server statistics  
**Request Data:** `{}`
**Response:** `system:stats`
```json
{
  "success": true,
  "data": {
    "connections": 5,
    "uptime": 3600,
    "memory": {
      "rss": 12345678,
      "heapTotal": 12345678,
      "heapUsed": 12345678,
      "external": 12345678
    },
    "platform": "win32",
    "nodeVersion": "v18.0.0",
    "timestamp": 1234567890
  },
  "timestamp": 1234567890
}
```

---

## 🔄 Broadcast Routes

### `command:process`
**Type:** Broadcast only  
**Description:** Send commands to processing workers  
**Data:**
```json
{
  "sessionId": "session_id",
  "action": "process_webm|process_pcm|configure",
  "data": {
    "filePath": "path_to_file",
    "mimeType": "audio/webm",
    "base64": "base64_data"
  },
  "timestamp": 1234567890
}
```

---

## 📝 Error Response Format

All routes can return error responses in this format:
```json
{
  "success": false,
  "error": "Error message description",
  "code": "optional_error_code",
  "timestamp": 1234567890
}
```

---

## 🚀 Usage Examples

### JavaScript Client
```javascript
// Connect to server
const socket = io('http://localhost:3001');

// Start a session
socket.emit('session:start', {
  sessionId: 'my_session_123',
  metadata: {
    clientId: 'client_456'
  }
});

// Listen for responses
socket.on('session:started', (response) => {
  if (response.success) {
    console.log('Session started:', response.data);
  } else {
    console.error('Error:', response.error);
  }
});

// Start audio streaming
socket.emit('audio:start', { sessionId: 'my_session_123' });

// Send audio chunk
socket.emit('audio:chunk', {
  sessionId: 'my_session_123',
  seq: 1,
  base64: 'base64_encoded_audio_data',
  mimeType: 'audio/webm'
});
```

### Python Client
```python
import socketio

sio = socketio.Client()

@sio.event
def connect():
    print('Connected to server')
    # Start a session
    sio.emit('session:start', {
        'sessionId': 'my_session_123',
        'metadata': {'clientId': 'client_456'}
    })

@sio.event
def session_started(response):
    if response['success']:
        print('Session started:', response['data'])
    else:
        print('Error:', response['error'])

sio.connect('http://localhost:3001')
```

---

## 📋 Route Summary

| Category | Routes | Count |
|----------|--------|-------|
| Connection | `connection:welcome` | 1 |
| Session | `session:start`, `session:end`, `session:pause`, `session:resume` | 4 |
| Audio | `audio:start`, `audio:stop`, `audio:chunk` | 3 |
| Config | `config:update`, `config:get`, `config:reset` | 3 |
| System | `system:status`, `system:health`, `system:stats` | 3 |
| Broadcast | `command:process` | 1 |
| **Total** | | **15** |

---

*Last updated: $(date)*
