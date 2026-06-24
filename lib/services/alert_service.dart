import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../core/sound_helper.dart';
import '../models/scan_result.dart';

class AlertService {
  AlertService({
    AudioPlayer? audioPlayer,
  }) : _audioPlayer = audioPlayer ?? AudioPlayer();

  final AudioPlayer _audioPlayer;

  Future<void> play(ScanStatus status) async {
    switch (status) {
      case ScanStatus.success:
        await _playAsset('sounds/success.wav', fallbackBeeps: 1);
      case ScanStatus.duplicate:
        await _playAsset('sounds/duplicate.wav', fallbackBeeps: 3);
      case ScanStatus.invalid:
      case ScanStatus.error:
        await _playAsset('sounds/error.wav', fallbackBeeps: 2);
      case ScanStatus.ready:
        break;
    }
  }

  Future<void> _playAsset(String path, {required int fallbackBeeps}) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (_) {
      for (var index = 0; index < fallbackBeeps; index++) {
        await SoundHelper.fallbackBeep();
        await Future<void>.delayed(const Duration(milliseconds: 90));
      }
    }
  }

  void dispose() {
    unawaited(_audioPlayer.dispose());
  }
}

