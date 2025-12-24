// services/voice_service.dart
// Lightweight voice input service stub.
// Replace with a real speech-to-text implementation when needed.

typedef OnTranscript = void Function(String text);

class VoiceService {
  VoiceService();

  /// Returns whether voice input is available on this platform.
  Future<bool> isAvailable() async {
    // Stub: return false to indicate not available by default.
    return Future.value(false);
  }

  /// Start listening and call [onTranscript] with recognized text.
  /// This implementation immediately returns without doing anything.
  Future<void> startListening(OnTranscript onTranscript) async {
    // Stub: not implemented. In a real implementation, connect to
    // a speech recognition plugin and stream transcripts to the
    // provided callback.
    return Future.value();
  }

  /// Stop listening if the implementation supports it.
  Future<void> stopListening() async {
    return Future.value();
  }
}
