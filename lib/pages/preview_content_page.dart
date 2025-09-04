import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'add_description_page.dart';

class PreviewContentPage extends StatefulWidget {
  final File file;
  final bool isVideo;
  final bool transformHorizontally;

  const PreviewContentPage({required this.file, required this.isVideo, required this.transformHorizontally, super.key});

  @override
  State<PreviewContentPage> createState() => _PreviewContentPageState();
}

class _PreviewContentPageState extends State<PreviewContentPage> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  Future<bool> _confirmClose() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Discard media?"),
            content: const Text("Are you sure you want to discard this media?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Discard"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget buildPreview() {
    final childWidget = Center(
      child: widget.isVideo
          ? (_videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : const CircularProgressIndicator())
          : Image.file(widget.file, fit: BoxFit.contain),
    );

    if (widget.transformHorizontally) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159),
        child: childWidget,
      );
    } else {
      return childWidget; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: widget.isVideo
                ? (_videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : const CircularProgressIndicator())
                : Image.file(widget.file, fit: BoxFit.contain),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                _confirmClose();
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
              onPressed: () {
                _videoController?.pause();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDescriptionPage(mediaFile: widget.file),
                  ),
                ).then((_) {
                  if (_videoController != null && _videoController!.value.isInitialized) {
                    _videoController!.play();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
