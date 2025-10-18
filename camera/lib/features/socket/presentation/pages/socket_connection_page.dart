import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/services/socket_service.dart';
import '../../../stream/presentation/pages/stream_page.dart';

/// Page pour afficher le statut de connexion Socket.IO
class SocketConnectionPage extends StatefulWidget {
  const SocketConnectionPage({super.key});

  @override
  State<SocketConnectionPage> createState() => _SocketConnectionPageState();
}

class _SocketConnectionPageState extends State<SocketConnectionPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialiser avec l'URL par défaut
    _urlController.text = context.read<SocketService>().serverUrl;

    // Connexion automatique désactivée - l'utilisateur doit cliquer manuellement
  }

  /// Tentative de connexion automatique
  void _autoConnect() {
    final socketService = context.read<SocketService>();
    if (!socketService.isConnected && !socketService.isConnecting) {
      if (kDebugMode) {
        print('Tentative de connexion automatique...');
      }
      socketService.connect();
    }
  }

  /// Construit un bouton d'URL rapide
  Widget _buildQuickUrlButton(String label, String url) {
    return ElevatedButton(
      onPressed: () {
        _urlController.text = url;
        context.read<SocketService>().connect(serverUrl: url);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }

  /// Construit le bouton de détection automatique d'IP
  Widget _buildAutoIPButton() {
    return ElevatedButton(
      onPressed: () async {
        await _updateWithLocalIP();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: const Text('IP auto'),
    );
  }

  /// Teste la connectivité au serveur
  void _testConnectivity() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Test de connectivité...'),
              ],
            ),
          ),
    );

    // Tester la connexion
    context.read<SocketService>().connect(serverUrl: url);

    // Fermer le dialog après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  /// Détecte l'IP locale automatiquement
  Future<String?> _getLocalIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            if (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.') ||
                addr.address.startsWith('172.')) {
              return addr.address;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur détection IP: $e');
      }
    }
    return null;
  }

  /// Met à jour l'URL avec l'IP locale détectée
  Future<void> _updateWithLocalIP() async {
    final ip = await _getLocalIP();
    if (ip != null) {
      _urlController.text = 'http://$ip:3000';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('IP locale détectée: $ip'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de détecter l\'IP locale'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    print("DISPOSE CONNECTION PAGE");
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion Socket.IO'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Champ pour l'URL du serveur
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL du serveur Socket.IO',
                      hintText: 'http://localhost:3000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 32),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final url = _urlController.text.trim();
                          if (url.isNotEmpty) {
                            context.read<SocketService>().connect(
                              serverUrl: url,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Veuillez d\'abord cliquer sur "IP auto" ou entrer une URL',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Se connecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<SocketService>().disconnect();
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Se déconnecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _testConnectivity();
                        },
                        icon: const Icon(Icons.network_check),
                        label: const Text('Tester'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Bouton de navigation vers la page de streaming
                  Consumer<SocketService>(
                    builder: (context, socketService, child) {
                      final isConnected = socketService.isConnected;
                      final isConnecting = socketService.isConnecting;

                      if (kDebugMode) {
                        print(
                          '🔄 Interface - isConnected: $isConnected, isConnecting: $isConnecting',
                        );
                      }

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        child: ElevatedButton.icon(
                          onPressed:
                              isConnected && !isConnecting
                                  ? () {
                                    if (kDebugMode) {
                                      print(
                                        '🚀 Navigation vers StreamPage - Connexion confirmée',
                                      );
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const StreamPage(),
                                      ),
                                    );
                                  }
                                  : null,
                          icon:
                              isConnecting
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Icon(
                                    isConnected
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                  ),
                          label: Text(
                            isConnecting
                                ? 'Connexion en cours...'
                                : isConnected
                                ? 'Aller à la page de streaming'
                                : 'Connectez-vous d\'abord',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isConnected ? Colors.blue : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Statut de connexion
                  Consumer<SocketService>(
                    builder: (context, socketService, child) {
                      Color statusColor;
                      IconData statusIcon;
                      String statusText;

                      if (socketService.isConnecting) {
                        statusColor = Colors.orange;
                        statusIcon = Icons.sync;
                        statusText = 'CONNEXION...';
                      } else if (socketService.isConnected) {
                        statusColor = Colors.green;
                        statusIcon = Icons.wifi;
                        statusText = 'CONNECTÉ';
                      } else {
                        statusColor = Colors.red;
                        statusIcon = Icons.wifi_off;
                        statusText = 'DÉCONNECTÉ';
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: Column(
                          children: [
                            if (socketService.isConnecting)
                              const SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            else
                              Icon(statusIcon, size: 56, color: statusColor),
                            const SizedBox(height: 24),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Serveur: ${socketService.serverUrl}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (socketService.connectionError != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Erreur: ${socketService.connectionError}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
