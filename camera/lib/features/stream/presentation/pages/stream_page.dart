import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../shared/services/permission_service.dart';
import '../../../../shared/services/socket_service.dart';
import '../../../../shared/services/streaming_service.dart';

/// Page de streaming vidéo avec chat LLM
class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isStreaming = false;
  bool _isProcessing = false;
  bool _permissionsGranted = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
    _checkPermissions();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _removeSocketListeners();
    super.dispose();
  }

  /// Configure les listeners Socket.IO
  void _setupSocketListeners() {
    final socketService = context.read<SocketService>();

    // Listener pour les réponses LLM
    socketService.addSocketListener('llm:response', (data) {
      setState(() {
        _isProcessing = false;
        _messages.add(
          ChatMessage(
            text: data['response'] ?? data.toString(),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });

    // Listener pour les erreurs
    socketService.addSocketListener('llm:error', (data) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur LLM: ${data['error'] ?? data}'),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Listener pour le statut de streaming
    socketService.addSocketListener('stream_status', (data) {
      setState(() {
        _isStreaming = data['streaming'] ?? false;
      });
    });
  }

  /// Supprime les listeners Socket.IO
  void _removeSocketListeners() {
    final socketService = context.read<SocketService>();
    socketService.removeAllSocketListenersForEvent('llm:response');
    socketService.removeAllSocketListenersForEvent('llm:error');
    socketService.removeAllSocketListenersForEvent('stream_status');
    socketService.removeAllSocketListenersForEvent('server_ready');
  }

  /// Vérifie les permissions au démarrage
  Future<void> _checkPermissions() async {
    final hasPermissions =
        await PermissionService.instance.hasCameraAndMicrophonePermissions();
    setState(() {
      _permissionsGranted = hasPermissions;
    });

    // Si les permissions sont déjà accordées, initialiser immédiatement la caméra
    if (hasPermissions) {
      await _initializeCamera();
    }
  }

  /// Demande les permissions caméra et microphone
  Future<void> _requestPermissions() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      final status =
          await PermissionService.instance
              .requestCameraAndMicrophonePermissions();

      if (status == PermissionStatus.granted) {
        setState(() {
          _permissionsGranted = true;
        });

        // Initialiser la caméra
        await _initializeCamera();
      } else {
        setState(() {
          _permissionsGranted = false;
        });

        if (mounted) {
          _showPermissionError(status);
        }
      }
    } catch (e) {
      setState(() {
        _permissionsGranted = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la demande de permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  /// Initialise la caméra
  Future<void> _initializeCamera() async {
    if (kDebugMode) {
      print('🎥 DEBUG: Début initialisation caméra');
    }
    
    final streamingService = context.read<StreamingService>();
    final success = await streamingService.initializeCamera();

    if (kDebugMode) {
      print('🎥 DEBUG: Initialisation caméra: $success');
      print('🎥 DEBUG: isCameraInitialized: ${streamingService.isCameraInitialized}');
      print('🎥 DEBUG: cameraController: ${streamingService.cameraController != null}');
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'initialisation de la caméra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Affiche l'erreur de permission
  void _showPermissionError(PermissionStatus status) {
    final message = PermissionService.instance.getPermissionErrorMessage(
      status,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permissions requises'),
            content: Text(message),
            actions: [
              if (status == PermissionStatus.permanentlyDenied)
                TextButton(
                  onPressed: () {
                    PermissionService.instance.openAppSettingsPage();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ouvrir les paramètres'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  /// Envoie un message au LLM
  void _sendMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty || !context.read<SocketService>().isConnected) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isProcessing = true;
    });

    // Envoyer le message via Socket.IO
    context.read<SocketService>().emit('llm:message', {
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _chatController.clear();
    _scrollToBottom();
  }

  /// Bascule le streaming
  Future<void> _toggleStreaming() async {
    final socketService = context.read<SocketService>();
    if (!socketService.isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Non connecté au serveur')));
      return;
    }

    if (!_permissionsGranted) {
      await _requestPermissions();
      return;
    }

    final streamingService = context.read<StreamingService>();

    if (_isStreaming) {
      // Arrêter le streaming
      await streamingService.stopStreaming();
      setState(() {
        _isStreaming = false;
      });
    } else {
      print("censé stream");
      // Démarrer le streaming
      setState(() {
        _isStreaming = true;
        _isInitializing = true;
      });
      
      try {
        await streamingService.startStreaming();
        setState(() {
          _isInitializing = false;
        });
      } catch (e) {
        setState(() {
          _isStreaming = false;
          _isInitializing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du démarrage: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Fait défiler vers le bas
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Vérifie si on est sur Chrome/web
  bool get _isWebChrome => kIsWeb;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Stream Video & Chat LLM'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          Consumer<SocketService>(
            builder: (context, socketService, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      socketService.isConnected ? Icons.wifi : Icons.wifi_off,
                      color:
                          socketService.isConnected ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      socketService.isConnected ? 'Connecté' : 'Déconnecté',
                      style: TextStyle(
                        color:
                            socketService.isConnected
                                ? Colors.green
                                : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isWebChrome ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  /// Layout pour mobile (vertical)
  Widget _buildMobileLayout() {
    return Column(
        children: [
          // Zone de streaming vidéo
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!, width: 2),
              ),
              child: _buildVideoArea(),
            ),
          ),

          // Zone de chat
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!, width: 1),
              ),
              child: Column(
                children: [
                  // Zone d'affichage des messages
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? const Center(
                              child: Text(
                                'Aucun message',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return _buildMessageBubble(message);
                              },
                            ),
                  ),

                  // Zone de saisie
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Tapez votre message...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Colors.grey[600]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Colors.grey[600]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isProcessing,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isProcessing ? null : _sendMessage,
                          icon:
                              _isProcessing
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bouton Start/Stop
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _isInitializing ? null : _toggleStreaming,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isStreaming ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isInitializing
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Initialisation...'),
                        ],
                      )
                      : Text(
                        _isStreaming ? 'STOP' : 'START',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      );
  }

  /// Layout pour web/Chrome (horizontal)
  Widget _buildWebLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Zone de streaming vidéo (gauche)
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!, width: 2),
              ),
              child: _buildVideoArea(),
            ),
          ),

          // Zone de chat (droite)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Zone de chat
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[600]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Zone d'affichage des messages
                        Expanded(
                          child: _messages.isEmpty
                              ? const Center(
                                child: Text(
                                  'Aucun message',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(12),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return _buildMessageBubble(message);
                                },
                              ),
                        ),

                        // Zone de saisie
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Tapez votre message...',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Colors.grey[600]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Colors.grey[600]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                  enabled: !_isProcessing,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _isProcessing ? null : _sendMessage,
                                icon: _isProcessing
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                    : const Icon(Icons.send, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton Start/Stop
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isInitializing ? null : _toggleStreaming,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isStreaming ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isInitializing
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Initialisation...'),
                          ],
                        )
                        : Text(
                          _isStreaming ? 'STOP' : 'START',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la zone vidéo
  Widget _buildVideoArea() {
    if (!_permissionsGranted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'STREAM VIDEO',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Permissions requises',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Consumer<StreamingService>(
      builder: (context, streamingService, child) {
        if (kDebugMode) {
          print('🎥 DEBUG: _buildVideoArea - _permissionsGranted: $_permissionsGranted');
          print('🎥 DEBUG: _buildVideoArea - _isInitializing: $_isInitializing');
          print('🎥 DEBUG: _buildVideoArea - _isStreaming: $_isStreaming');
          print('🎥 DEBUG: _buildVideoArea - isCameraInitialized: ${streamingService.isCameraInitialized}');
          print('🎥 DEBUG: _buildVideoArea - cameraController: ${streamingService.cameraController != null}');
        }
        
        // Si on est en train d'initialiser
        if (_isInitializing && 
            (!streamingService.isCameraInitialized || streamingService.cameraController == null)) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'STREAM VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Initialisation de la caméra...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        // Si la caméra est initialisée (que l'on stream ou non), afficher CameraPreview sur toutes plateformes
        if (streamingService.isCameraInitialized && streamingService.cameraController != null) {
          if (kDebugMode) {
            print('🎥 DEBUG: Affichage CameraPreview');
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(streamingService.cameraController!),
          );
        }
        
        // État par défaut (arrêté)
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'STREAM VIDEO',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Cliquez sur Start pour commencer',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construit une bulle de message
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const Icon(Icons.person, color: Colors.green, size: 20),
          ],
        ],
      ),
    );
  }
}

/// Modèle pour les messages de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
