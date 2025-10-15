import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart'; // Pour formater la date/heure plus joliment

List<CameraDescription> cameras = []; // Liste des caméras disponibles

Future<void> main() async {
  // Assurez-vous que les bindings de Flutter sont initialisés.
  WidgetsFlutterBinding.ensureInitialized();

  // Récupérer la liste des caméras disponibles.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(
      'Erreur lors de la récupération des caméras: ${e.code}, ${e.description}',
    );
    // Gérer l'erreur (ex: afficher un message à l'utilisateur)
  }

  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  CameraController? _controller;
  Timer? _timer;
  bool _isCapturing = false; // Nouvel état pour suivre si la capture est active
  final int _captureIntervalMilliseconds =
      1000; // Intervalle de capture : toutes les 1 seconde (1000ms)
  // REMPLACEZ 'VOTRE_IP_MAC' PAR L'ADRESSE IP DE VOTRE MAC !
  // Si vous testez sur un émulateur Android, utilisez 'http://10.0.2.2:5000/upload_image' pour atteindre votre machine hôte.
  final String _serverUrl = 'http://IP:5000/upload_image';

  // --- Nouvelles variables pour les statistiques de session et les logs ---
  DateTime? _sessionStartTime;
  int _photosTakenInSession = 0;
  int _photosSentSuccessfullyInSession = 0;
  int _photosFailedToSendInSession = 0;
  int _sessionIDCounter = 0; // Compteur pour les IDs de session
  int _currentSessionID = 0; // ID de la session en cours

  final List<String> _sessionLogs =
      []; // Liste des logs pour toutes les sessions

  // Nouvelle liste pour suivre les tâches d'envoi en cours
  final List<Future<void>> _pendingUploads = [];
  // ----------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Observer les changements de cycle de vie de l'application
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      _showError('Aucune caméra disponible sur cet appareil.');
      return;
    }

    // Initialiser le contrôleur de caméra avec la première caméra disponible (souvent l'arrière).
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium, // Réglez la résolution selon vos besoins
      enableAudio: false, // Pas besoin d'audio pour des images fixes
    );

    // Attendre l'initialisation du contrôleur
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {}); // Rafraîchir l'UI
      }
    } on CameraException catch (e) {
      _showError(
        'Erreur d\'initialisation de la caméra: ${e.code}, ${e.description}',
      );
    }
  }

  void _startImageCapture() {
    if (!_isCapturing) {
      _timer?.cancel(); // Annuler un timer existant s'il y en a un

      _sessionIDCounter++;
      _currentSessionID = _sessionIDCounter;
      _sessionStartTime = DateTime.now();

      // --- Réinitialisation des statistiques de la session ---
      _photosTakenInSession = 0;
      _photosSentSuccessfullyInSession = 0;
      _photosFailedToSendInSession = 0;
      _pendingUploads.clear(); // Vider les uploads en attente
      // -------------------------------------------------------

      _sessionLogs.add(
        "Session $_currentSessionID lancée à ${DateFormat('HH:mm:ss').format(_sessionStartTime!)}",
      );

      _timer = Timer.periodic(
        Duration(milliseconds: _captureIntervalMilliseconds),
        (timer) {
          _takePictureAndSend();
        },
      );
      setState(() {
        _isCapturing = true;
      });
      print(
        'Capture d\'images démarrée (Session $_currentSessionID) toutes les ${_captureIntervalMilliseconds / 1000} secondes.',
      );
    }
  }

  Future<void> _stopImageCapture() async {
    // Rendre asynchrone pour attendre les uploads
    if (_isCapturing) {
      _timer?.cancel();
      setState(() {
        _isCapturing = false;
      });
      print('Capture d\'images arrêtée (Session $_currentSessionID).');

      // Attendre la fin de tous les uploads en cours avant de logger les stats finales
      if (_pendingUploads.isNotEmpty) {
        print('En attente de la fin de ${_pendingUploads.length} uploads...');
        await Future.wait(_pendingUploads).catchError((e) {
          print('Erreur lors de l\'attente des uploads: $e');
        });
        _pendingUploads.clear(); // Vider la liste après attente
        print('Tous les uploads en attente sont terminés.');
      }

      // --- Log des statistiques de la session ---
      if (_sessionStartTime != null) {
        final Duration sessionDuration = DateTime.now().difference(
          _sessionStartTime!,
        );

        _sessionLogs.add(
          "Session $_currentSessionID terminée à ${DateFormat('HH:mm:ss').format(DateTime.now())}",
        );
        _sessionLogs.add(
          "--- Fin de session de capture (Session $_currentSessionID) ---",
        );
        _sessionLogs.add('Durée: ${sessionDuration.inSeconds} secondes');
        _sessionLogs.add('Photos prises: $_photosTakenInSession');
        _sessionLogs.add(
          'Photos envoyées avec succès: $_photosSentSuccessfullyInSession',
        );
        _sessionLogs.add('Échecs d\'envoi: $_photosFailedToSendInSession');
        _sessionLogs.add('----------------------------------');

        // Afficher tous les logs dans la console pour le debug
        print('\n--- Historique des sessions ---');
        for (var logEntry in _sessionLogs) {
          print(logEntry);
        }
        print('-------------------------------\n');
      }
      // Mettre à jour l'UI pour afficher les nouveaux logs
      setState(() {});
    }
  }

  Future<void> _takePictureAndSend() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture) {
      // Ne rien faire si le contrôleur n'est pas prêt ou si une photo est déjà en cours de prise
      print(
        '[Session $_currentSessionID] Skipping capture: controller not ready or already taking picture.',
      );
      return;
    }

    try {
      final XFile file = await _controller!.takePicture();
      print('[Session $_currentSessionID] Photo prise: ${file.path}');
      _photosTakenInSession++; // Incrémenter le compteur de photos prises

      // Lancer l'envoi en arrière-plan sans attendre sa fin
      final uploadFuture = _sendImageToServer(file.path);
      _pendingUploads.add(
        uploadFuture,
      ); // Ajouter à la liste des tâches en cours

      // Nettoyer la liste une fois l'upload terminé
      uploadFuture.whenComplete(() => _pendingUploads.remove(uploadFuture));
    } on CameraException catch (e) {
      _showError(
        '[Session $_currentSessionID] Erreur lors de la prise de photo: ${e.code}, ${e.description}',
      );
      // Nous ne pouvons pas savoir si la photo a été "prise" si la capture a échoué.
      // Dans ce cas, nous n'incrémentons que les échecs d'envoi si la prise de photo elle-même a échoué.
      _photosFailedToSendInSession++;
    }
  }

  Future<void> _sendImageToServer(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));

      // --- AJOUT : Envoyer l'ID de session ---
      request.fields['session_id'] = _currentSessionID.toString();
      // ---------------------------------------

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Ce nom doit correspondre à 'image' dans request.files sur le serveur Python
          imagePath,
          filename: 'capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
          // contentType: MediaType('image', 'jpeg'), // Le package http peut deviner le type
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print(
          '[Session $_currentSessionID] Image envoyée avec succès au serveur.',
        );
        _photosSentSuccessfullyInSession++; // Incrémenter le compteur de succès
        final responseBody = await response.stream.bytesToString();
        print('[Session $_currentSessionID] Réponse du serveur: $responseBody');
      } else {
        print(
          '[Session $_currentSessionID] Échec de l\'envoi de l\'image. Code: ${response.statusCode}',
        );
        _photosFailedToSendInSession++; // Incrémenter le compteur d'échecs
        final responseBody = await response.stream.bytesToString();
        print('[Session $_currentSessionID] Réponse du serveur: $responseBody');
      }
    } catch (e) {
      print(
        '[Session $_currentSessionID] Erreur lors de l\'envoi de l\'image: $e',
      );
      _photosFailedToSendInSession++; // Incrémenter le compteur d'échecs
      _showError(
        '[Session $_currentSessionID] Impossible de se connecter au serveur Python. Vérifiez l\'adresse IP et que le serveur est en marche.',
      );
    } finally {
      // Optionnel: Supprimer le fichier local après envoi pour économiser de l'espace
      // try {
      //   await File(imagePath).delete();
      //   print('[Session $_currentSessionID] Fichier local supprimé: $imagePath');
      // } catch (e) {
      //   print('[Session $_currentSessionID] Erreur lors de la suppression du fichier local: $e');
      // }
    }
  }

  void _showError(String message) {
    print('ERREUR: $message');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Redémarrer ou arrêter la caméra si l'application est en arrière-plan/premier plan
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _stopImageCapture(); // Arrêter le timer et loguer les stats
      print('Caméra et capture arrêtées car l\'application est inactive.');
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(); // Réinitialiser et redémarrer la caméra
      // Ne pas redémarrer automatiquement la capture, l'utilisateur doit le faire
      print('Caméra relancée car l\'application est reprise.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _timer?.cancel(); // Arrêter le timer
    // Assurez-vous d'attendre les uploads restants lors de la fermeture complète si nécessaire
    // ou de gérer leur annulation. Pour l'instant, ils peuvent continuer en arrière-plan.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      // Afficher un indicateur de chargement tant que la caméra n'est pas prête
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Initialisation de la caméra..."),
              ],
            ),
          ),
        ),
      );
    }

    // Afficher l'aperçu de la caméra une fois qu'elle est prête
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Capture Caméra Automatique')),
        body: Column(
          // Utilisez un Column pour l'aperçu et les logs
          children: [
            Expanded(
              // L'aperçu prendra l'espace restant
              flex: 2, // Donne plus de place à l'aperçu de la caméra
              child: Center(child: CameraPreview(_controller!)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Historique des sessions :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              // Les logs prendront le reste de l'espace
              flex: 1,
              child: ListView.builder(
                reverse: true, // Affiche les logs les plus récents en bas
                itemCount: _sessionLogs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    child: Text(_sessionLogs[index]),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "startBtn", // Ajoutez un heroTag unique
              onPressed: _isCapturing ? null : _startImageCapture,
              backgroundColor: _isCapturing ? Colors.grey : Colors.green,
              child: const Icon(Icons.play_arrow),
            ),
            FloatingActionButton(
              heroTag: "stopBtn", // Ajoutez un heroTag unique
              onPressed: _isCapturing ? _stopImageCapture : null,
              backgroundColor: _isCapturing ? Colors.red : Colors.grey,
              child: const Icon(Icons.stop),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
