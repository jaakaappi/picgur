import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({super.key, required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool isPlaying = true;
  bool isMuted = true;

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.url);

    _initializeVideoPlayerFuture = _controller.initialize().then((value) async {
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          return !snapshot.hasData || snapshot.connectionState == ConnectionState.waiting
              ?
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              Stack(alignment: AlignmentDirectional.bottomEnd, children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        icon: _controller.value.isPlaying
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.play_arrow),
                        onPressed: () async {
                          isPlaying ? await _controller.pause() : await _controller.play();
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                      )),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(isMuted == true ? Icons.volume_off : Icons.volume_up),
                        onPressed: () async {
                          await _controller.setVolume(isMuted ? 100 : 0);
                          setState(() {
                            isMuted = !isMuted;
                          });
                        },
                      ))
                ])
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }
}
