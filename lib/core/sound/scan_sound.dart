import 'package:audioplayers/audioplayers.dart';

/// The double "ding" played when a Zawapay QR code is recognised.
///
/// It follows the phone: silent mode (iPhone switch, Android ringer set to
/// silent or vibrate) gives no sound, and the volume is the phone's own.
/// The vibration is done separately, so it is still felt in silent mode.
abstract final class ScanSound {
  static AudioPlayer? _player;

  static Future<void> play() async {
    try {
      final player = _player ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(
        AudioContextConfig(
          // Respect the silent mode, and only lower other sounds briefly.
          respectSilence: true,
          focus: AudioContextConfigFocus.duckOthers,
        ).build(),
      );
      await player.stop();
      await player.play(AssetSource('sounds/scan_success.wav'));
    } catch (_) {
      // No sound is never a reason to stop the payment.
    }
  }
}
