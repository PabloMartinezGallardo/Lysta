import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mis_listas/core/utils/ui_helpers.dart';

class PlayButton extends StatefulWidget {
  final String path;
  const PlayButton(this.path, {super.key});
  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  final _player = AudioPlayer();
  StreamSubscription? _sub;
  bool playing = false;

  @override
  void initState() {
    super.initState();
    _sub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => playing = false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (playing) {
      await _player.stop();
      if (mounted) setState(() => playing = false);
    } else {
      try {
        await _player.play(DeviceFileSource(widget.path));
        if (mounted) setState(() => playing = true);
      } catch (_) {
        if (mounted) snack(context, 'No se pudo reproducir el audio');
      }
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: playing ? 'Parar' : 'Reproducir',
        icon: Icon(playing ? Icons.stop_circle_outlined : Icons.play_circle_outline),
        onPressed: _toggle,
      );
}

