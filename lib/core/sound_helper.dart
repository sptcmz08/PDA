import 'package:flutter/services.dart';

class SoundHelper {
  const SoundHelper._();

  static Future<void> fallbackBeep() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.mediumImpact();
  }
}
