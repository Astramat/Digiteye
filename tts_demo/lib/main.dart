import 'package:flutter/material.dart';
import 'tts_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS Demo (Clean)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TtsDemoPage(),
    );
  }
}

class TtsDemoPage extends StatefulWidget {
  const TtsDemoPage({super.key});

  @override
  State<TtsDemoPage> createState() => _TtsDemoPageState();
}

class _TtsDemoPageState extends State<TtsDemoPage> {
  final TtsService _tts = TtsService();
  final TextEditingController _textCtrl =
      TextEditingController(text: "Hello, how are you?");
  String _status = "Initializing…";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.init(language: "en-US");
      await _tts.pickVoiceByKeyword("male");

      setState(() => _status = "Ready");
    } catch (e) {
      setState(() => _status = "Init failed: $e");
    }
  }

  Future<void> _speakTest() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final ok = await _tts.speak(text);
    if (!ok) {
      final msg = _tts.lastError.isEmpty ? 'speak() failed' : _tts.lastError;
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
      setState(() => _status = "Error");
    } else {
      setState(() => _status = "Speaking…");
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text-to-Speech')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _speakTest,
              child: const Text('Test'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textCtrl,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Text to speak',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
