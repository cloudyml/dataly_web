import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class replay10 extends StatelessWidget {
  const replay10({
    Key? key,
    required VideoPlayerController? videoController,
  })  : _videoController = videoController,
        super(key: key);

  final VideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        final currentPosition = await _videoController!.position;
        final newPosition = currentPosition! - Duration(seconds: 10);
        _videoController!.seekTo(newPosition);
      }),
      child: Icon(
        Icons.replay_10,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
