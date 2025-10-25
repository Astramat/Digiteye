import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService with ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  bool _isSpeaking = false;
  String _language = "en-US";
  String? _voiceName;
  String _lastError = "";

  bool get isInitialized => _initialized;
  bool get isSpeaking => _isSpeaking;
  String get language => _language;
  String? get voiceName => _voiceName;
  String get lastError => _lastError;

  Future<void> init({
    String language = "en-US",
    double rate = 0.5,
    double pitch = 1.0,
    double volume = 1.0,
    String? voiceName,
  }) async {
    if (_initialized) return;

    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setErrorHandler((msg) {
      _lastError = msg ?? 'Unknown TTS error';
      _isSpeaking = false;
      notifyListeners();
    });

    // Apply config
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
    await _tts.setPitch(pitch.clamp(0.5, 2.0));
    await _tts.setVolume(volume.clamp(0.0, 1.0));

    if (voiceName != null && voiceName.isNotEmpty) {
      try {
        await _tts.setVoice({"name": voiceName});
        _voiceName = voiceName;
      } catch (_) {}
    }

    _language = language;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> speak(String text, {bool interrupt = true}) async {
    if (text.trim().isEmpty) return false;
    await init();
    try {
      if (interrupt) {
        await _tts.stop();
      }
      final res = await _tts.speak(text);
      return res == 1 || res == null;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    await init();
    try {
      await _tts.setLanguage(langCode);
      _language = langCode;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to set language: $e';
      notifyListeners();
    }
  }

  Future<void> setVoiceByName(String name) async {
    await init();
    try {
      await _tts.setVoice({"name": name});
      _voiceName = name;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to set voice: $e';
      notifyListeners();
    }
  }

  Future<String?> pickVoiceByKeyword(String keyword) async {
    await init();
    final voices = await getVoices();
    final lower = keyword.toLowerCase();
    final match = voices.firstWhere(
      (v) {
        final name = (v['name'] ?? '').toString().toLowerCase();
        final locale = (v['locale'] ?? '').toString().toLowerCase();
        return name.contains(lower) && locale == _language.toLowerCase();
      },
      orElse: () => const {},
    );
    if (match.isNotEmpty) {
      final name = match['name']?.toString();
      if (name != null && name.isNotEmpty) {
        await setVoiceByName(name);
        return name;
      }
    }
    return null;
  }

  Future<List<dynamic>> getVoices() async {
    await init();
    try {
      final v = await _tts.getVoices;
      return v ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> setRate(double rate) async {
    await init();
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  Future<void> setPitch(double pitch) async {
    await init();
    await _tts.setPitch(pitch.clamp(0.5, 2.0));
  }

  Future<void> setVolume(double volume) async {
    await init();
    await _tts.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
