import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Service pour gérer la connexion Socket.IO
class SocketService extends ChangeNotifier {
  static SocketService? _instance;
  io.Socket? _socket;
  bool _isConnected = false;
  // Assurez-vous que l'URL par défaut est sans slash final pour être propre.
  String _serverUrl = 'http://localhost:3000';
  String? _connectionError;
  final Map<String, List<Function(dynamic)>> _listeners = {};
  bool _isConnecting = false;

  /// Singleton pattern pour éviter les multi-instances
  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// URL du serveur Socket.IO
  String get serverUrl => _serverUrl;

  /// Statut de connexion
  bool get isConnected => _isConnected;

  /// Statut de connexion en cours
  bool get isConnecting => _isConnecting;

  /// Erreur de connexion
  String? get connectionError => _connectionError;

  // ---------------------------------------------------------------------------
  // Méthodes de Gestion de Connexion
  // ---------------------------------------------------------------------------

  /// Initialise la connexion Socket.IO
  void connect({String? serverUrl}) {
    // 1. Mettre à jour l'URL et la nettoyer si elle est fournie
    if (serverUrl != null) {
      // Nettoyage: retirer le slash de fin si présent
      _serverUrl =
          serverUrl.endsWith('/')
              ? serverUrl.substring(0, serverUrl.length - 1)
              : serverUrl;
    }

    // 2. Fermer l'ancienne connexion AVANT de vérifier l'état
    // Cela garantit que toute tentative est basée sur un état "clean".
    if (_socket != null) {
      disconnect();
    }

    // 3. Empêcher les tentatives multiples/superflues (après nettoyage)
    if (_isConnecting || _isConnected) {
      if (kDebugMode) {
        print('Connexion déjà en cours ou établie');
      }
      return;
    }

    // 4. Lancer la nouvelle connexion
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();

      if (kDebugMode) {
        print('🔄 Tentative de connexion à: $_serverUrl');
        print('🔄 Plateforme: ${kIsWeb ? "Web" : "Mobile"}');
      }

      _socket = io.io(
        _serverUrl,
        io.OptionBuilder()
            // 🎯 CORRECTION: WebSocket en premier pour la performance
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .setTimeout(30000) // Timeout de 30 secondes
            .setReconnectionAttempts(10) // Plus de tentatives
            .setReconnectionDelay(2000) // Délai plus long
            .setReconnectionDelayMax(10000) // Délai max
            .setExtraHeaders({
              'ngrok-skip-browser-warning': 'true',
              'User-Agent': 'Flutter-Mobile-App',
              'Accept': '*/*',
              'Cache-Control': 'no-cache',
            })
            .enableForceNew() // Forcer une nouvelle connexion
            .build(),
      );

      _setupEventListeners();

      // connect() est redondant avec enableAutoConnect(), mais conservé pour l'assurance.
      _socket?.connect();
    } catch (e) {
      _connectionError = 'Erreur lors de la connexion: $e';
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Déconnecte du serveur Socket.IO
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    _connectionError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Écouteurs d'Événements
  // ---------------------------------------------------------------------------

  /// Configure les écouteurs d'événements Socket.IO
  void _setupEventListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionError = null;
      if (kDebugMode) {
        print('✅ Connecté au serveur Socket.IO: $_serverUrl');
        print('✅ Transport utilisé: ${_socket?.io.engine?.transport?.name}');
        print('✅ État de connexion: $_isConnected');
      }
      notifyListeners();

      // Forcer une mise à jour immédiate
      Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    });

    // Listener pour confirmer que la connexion est vraiment établie (Alias de onConnect)
    _socket?.on('connect', (_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionError = null;
      if (kDebugMode) {
        print('✅ Événement connect reçu - Connexion confirmée');
      }
      notifyListeners();
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      _isConnecting = false;
      if (kDebugMode) {
        print('Déconnecté du serveur Socket.IO');
      }
      notifyListeners();
    });

    _socket?.onConnectError((error) {
      _isConnected = false;
      _isConnecting = false;

      // Gestion spécifique des erreurs mobiles
      String errorMessage = 'Erreur de connexion: $error';
      if (error.toString().contains('Failed host lookup')) {
        errorMessage =
            'Impossible de résoudre l\'adresse du serveur. Vérifiez votre connexion internet.';
      } else if (error.toString().contains('Connection refused')) {
        errorMessage = 'Connexion refusée. Le serveur est-il démarré ?';
      } else if (error.toString().contains('timeout')) {
        errorMessage =
            'Timeout de connexion. Le serveur met trop de temps à répondre.';
      }

      _connectionError = errorMessage;
      if (kDebugMode) {
        print('❌ Erreur de connexion Socket.IO: $error');
        print('❌ URL tentée: $_serverUrl');
        print('❌ Type d\'erreur: ${error.runtimeType}');
        print('❌ Message utilisateur: $errorMessage');
      }
      notifyListeners();
    });

    _socket?.onError((error) {
      _isConnected = false;
      _isConnecting = false;
      _connectionError = 'Erreur Socket.IO: $error';
      if (kDebugMode) {
        print('Erreur Socket.IO: $error');
      }
      notifyListeners();
    });

    // Réenregistrer tous les listeners existants
    _reRegisterListeners();
  }

  /// Réenregistre tous les listeners après une reconnexion
  void _reRegisterListeners() {
    for (final event in _listeners.keys) {
      for (final listener in _listeners[event]!) {
        _socket?.on(event, listener);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Gestion des Listeners Clients
  // ---------------------------------------------------------------------------

  /// Ajoute un listener générique pour un événement
  void addSocketListener(String event, Function(dynamic) callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);

    // Si le socket est connecté, enregistrer immédiatement
    if (_isConnected && _socket != null) {
      _socket!.on(event, callback);
    }
  }

  /// Supprime un listener spécifique pour un événement
  void removeSocketListener(String event, Function(dynamic) callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
      if (_listeners[event]!.isEmpty) {
        _listeners.remove(event);
      }
    }

    // Supprimer du socket si connecté
    if (_isConnected && _socket != null) {
      _socket!.off(event, callback);
    }
  }

  /// Supprime tous les listeners pour un événement
  void removeAllSocketListenersForEvent(String event) {
    if (_listeners.containsKey(event)) {
      _listeners.remove(event);
    }

    // Supprimer du socket si connecté
    if (_isConnected && _socket != null) {
      _socket!.off(event);
    }
  }

  /// Supprime tous les listeners Socket.IO
  void removeAllSocketListeners() {
    _listeners.clear();

    // Supprimer du socket si connecté
    if (_isConnected && _socket != null) {
      _socket!.clearListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Communication
  // ---------------------------------------------------------------------------

  /// Envoie un message au serveur
  void emit(String event, dynamic data) {
    if (_isConnected && _socket != null) {
      _socket!.emit(event, data);
    } else if (kDebugMode) {
      print('⚠️ Tentative d\'émission ($event) sans connexion établie.');
    }
  }

  // ---------------------------------------------------------------------------
  // Méthodes Dépréciées (Compatibilité)
  // ---------------------------------------------------------------------------

  /// Écoute un événement du serveur (méthode de compatibilité)
  @Deprecated('Utilisez addSocketListener à la place')
  void on(String event, Function(dynamic) callback) {
    addSocketListener(event, callback);
  }

  /// Arrête d'écouter un événement (méthode de compatibilité)
  @Deprecated(
    'Utilisez removeSocketListener ou removeAllSocketListenersForEvent à la place',
  )
  void off(String event, [Function(dynamic)? callback]) {
    if (callback != null) {
      removeSocketListener(event, callback);
    } else {
      removeAllSocketListenersForEvent(event);
    }
  }

  // ---------------------------------------------------------------------------
  // Fin de Vie
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
