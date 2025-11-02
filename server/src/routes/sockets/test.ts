import { Socket } from "socket.io";
import type { HandlerContext, SocketResponse } from "../../types";
import { response } from "express";
import axios from "axios";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Helper to get current directory __dirname in ES module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function test(socket: Socket, data: any, context: HandlerContext) {
    console.log("test", data);
    socket.emit("response", { message: "Hello, world!" });
}

export function llm_message(socket: Socket, data: any, context: HandlerContext) {
    console.log("test", data);
    socket.emit("llm:response", { response: "Pokehontas is a good girl !" });
}

export function server_ready(socket: Socket, data: any, context: HandlerContext) {
    socket.emit("server:ready", { message: "Server is ready !" });
}

export function streaming_started(socket: Socket, data: any, context: HandlerContext) {
}

// Store audio buffers per socket
const audioBuffers = new Map<string, Buffer[]>();

export function audio_data(socket: Socket, data: any, context: HandlerContext) {
    return;
    console.log("audio_data", data);
    // data["amplitude"] == audio amplitude
    // data["max_amplitude"] == audio max amplitude
    // data["timestamp"] == timestamp
    
    // Initialize buffer array for this socket if it doesn't exist
    if (!audioBuffers.has(socket.id)) {
        audioBuffers.set(socket.id, []);
    }
    
    // Convert amplitude to buffer
    let audioChunk: Buffer;
    if (Buffer.isBuffer(data["amplitude"])) {
        audioChunk = data["amplitude"];
    } else if (typeof data["amplitude"] === "string") {
        audioChunk = Buffer.from(data["amplitude"], "base64");
    } else if (typeof data["amplitude"] === "number") {
        // Convert number to 16-bit PCM sample
        const int16 = new Int16Array(1);
        int16[0] = Math.round(data["amplitude"] * 32767); // Normalize to 16-bit range
        audioChunk = Buffer.from(int16.buffer);
    } else {
        audioChunk = Buffer.from("");
    }
    
    // Append chunk to socket's buffer
    const buffers = audioBuffers.get(socket.id)!;
    buffers.push(audioChunk);
    
    // socket.emit("audio:data", { 
    //     success: true, 
    //     message: "Audio chunk buffered",
    //     chunksCount: buffers.length 
    // });
    // save_audio(socket, data, context);
}

// Helper function to save aggregated audio (call this when streaming ends)
export function save_audio(socket: Socket, data: any, context: HandlerContext) {
    const buffers = audioBuffers.get(socket.id);
    
    if (!buffers || buffers.length === 0) {
        socket.emit("audio:saved", { 
            success: false, 
            message: "No audio data to save" 
        });
        return;
    }
    
    // Concatenate all buffers
    const completeAudio = Buffer.concat(buffers);
    
    // Save to disk
    const audioFolder = path.join(__dirname, "..", "..", "..", "audio");
    if (!fs.existsSync(audioFolder)) {
        fs.mkdirSync(audioFolder, { recursive: true });
    }
    
    const filename = `audio_${socket.id}_${Date.now()}.wav`;
    fs.writeFileSync(path.join(audioFolder, filename), completeAudio);
    
    // Clear buffer for this socket
    // audioBuffers.delete(socket.id);
    
    // socket.emit("audio:saved", { 
    //     success: true, 
    //     message: "Complete audio saved",
    //     filename: filename,
    //     totalChunks: buffers.length
    // });
}

// Clean up buffers when socket disconnects
export function cleanup_audio_buffer(socketId: string) {
    audioBuffers.delete(socketId);
}
export async function video_frame(socket: Socket, data: any, context: HandlerContext) {
    // Normalise l'entrée vers un Buffer
    const toBuffer = (input: any): Buffer => {
        if (Buffer.isBuffer(input)) return input;
        if (input?.type === "Buffer" && Array.isArray(input?.data)) return Buffer.from(input.data);
        if (typeof input === "string") {
            // suppose base64 si possible, sinon binaire brut
            try { return Buffer.from(input, "base64"); } catch { return Buffer.from(input); }
        }
        if (input instanceof Uint8Array) return Buffer.from(input);
        if (Array.isArray(input)) return Buffer.from(input);
        if (input?.buffer && typeof input.byteLength === "number") return Buffer.from(input);
        throw new Error("Invalid frame data: expected Buffer|base64 string|Uint8Array|number[]");
    };
    try {
        const framesFolder = path.join(__dirname, "..", "..", "..", "frames");
        await fs.promises.mkdir(framesFolder, { recursive: true });

        const buf = toBuffer(data?.data);
        const framePath = path.join(framesFolder, "frame.jpg");
        await fs.promises.writeFile(framePath, buf);

        // Prépare le formulaire multipart pour FastAPI (local uniquement)
        const formData = new FormData();
        formData.append("file", new Blob([buf], { type: "image/jpeg" }), "frame.jpg");
        if (data?.prompt) formData.append("prompt", String(data.prompt));
        else formData.append("prompt", "Describe this image in accurate, concise detail.");

        formData.append("max_new_tokens", String(data?.max_new_tokens ?? 128));
        formData.append("temperature", String(data?.temperature ?? 0.2));

        const apiUrl = process.env.CAPTION_API_URL ?? "http://127.0.0.1:8089/caption-file";
        const headers = typeof (formData as any).getHeaders === "function" ? (formData as any).getHeaders() : {};

        const resp = await axios.post(apiUrl, formData, { headers, timeout: 30_000 });
        const text: string = resp?.data?.text ?? "";
        console.log("text", text);

        socket.emit("llm:response", { response: text, at: Date.now(), source: "local" });
    } catch (err: any) {
        const message = err?.response?.data?.detail || err?.message || String(err);
        console.error("[VIDEO_FRAME] Error:", message);
        // socket.emit("llm:response", { error: message, at: Date.now(), source: "local" });
    }
}
