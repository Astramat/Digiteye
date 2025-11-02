import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/services/socket_service.dart';

/// Exemple d'utilisation avancée du système Socket.IO
class SocketUsageExample extends StatefulWidget {
  const SocketUsageExample({super.key});

  @override
  State<SocketUsageExample> createState() => _SocketUsageExampleState();
}

class _SocketUsageExampleState extends State<SocketUsageExample> {
  final List<String> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _removeSocketListeners();
    super.dispose();
  }

  /// Configure les listeners Socket.IO
  void _setupSocketListeners() {
    final socketService = context.read<SocketService>();
    
    // Listener pour les messages généraux
    socketService.addSocketListener('message', (data) {
      setState(() {
        _messages.add('Message reçu: $data');
      });
    });

    // Listener pour les notifications
    socketService.addSocketListener('notification', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification: $data'),
          backgroundColor: Colors.blue,
        ),
      );
    });

    // Listener pour les erreurs
    socketService.addSocketListener('error', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $data'),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Listener pour les mises à jour de statut
    socketService.addSocketListener('status_update', (data) {
      setState(() {
        _messages.add('Statut mis à jour: $data');
      });
    });
  }

  /// Supprime les listeners Socket.IO
  void _removeSocketListeners() {
    final socketService = context.read<SocketService>();
    socketService.removeAllSocketListenersForEvent('message');
    socketService.removeAllSocketListenersForEvent('notification');
    socketService.removeAllSocketListenersForEvent('error');
    socketService.removeAllSocketListenersForEvent('status_update');
  }

  /// Envoie un message au serveur
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<SocketService>().emit('message', {
        'text': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'user': 'Flutter User',
      });
      _messageController.clear();
    }
  }

  /// Envoie une requête de statut
  void _requestStatus() {
    context.read<SocketService>().emit('get_status', {});
  }

  /// Envoie une requête de données
  void _requestData() {
    context.read<SocketService>().emit('get_data', {
      'type': 'user_data',
      'limit': 10,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Socket.IO'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Zone de saisie de message
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message à envoyer',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Boutons d'action
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _requestStatus,
                  icon: const Icon(Icons.info),
                  label: const Text('Demander le statut'),
                ),
                ElevatedButton.icon(
                  onPressed: _requestData,
                  icon: const Icon(Icons.data_object),
                  label: const Text('Demander des données'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<SocketService>().emit('ping', {});
                  },
                  icon: const Icon(Icons.network_ping),
                  label: const Text('Ping'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Liste des messages
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.message),
                      title: Text(_messages[index]),
                      dense: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exemple d'utilisation dans un autre widget
class AnotherWidget extends StatefulWidget {
  const AnotherWidget({super.key});

  @override
  State<AnotherWidget> createState() => _AnotherWidgetState();
}

class _AnotherWidgetState extends State<AnotherWidget> {
  @override
  void initState() {
    super.initState();
    
    // Exemple d'ajout de listener dans un autre widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketService = context.read<SocketService>();
      
      // Listener spécifique à ce widget
      socketService.addSocketListener('widget_specific_event', (data) {
        if (mounted) {
          // Traiter l'événement spécifique à ce widget
          debugPrint('Widget spécifique a reçu: $data');
        }
      });
    });
  }

  @override
  void dispose() {
    // Nettoyer les listeners spécifiques à ce widget
    final socketService = context.read<SocketService>();
    socketService.removeAllSocketListenersForEvent('widget_specific_event');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
