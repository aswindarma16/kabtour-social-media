import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../globals.dart';
import '../models/post.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  VideoPlayerController? _videoController;

  bool get isVideo {
    final path = widget.post.mediaPath.toLowerCase();
    
    return availableVideoFormat.any((ext) => path.endsWith(ext));
  }

  @override
  void initState() {
    super.initState();
    if (isVideo) {
      _videoController = VideoPlayerController.file(File(widget.post.mediaPath))
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

  Widget mediaPreview(BuildContext context) {
    // taking only max half of the screen
    final maxHeight = MediaQuery.of(context).size.height / 2;

    if (isVideo) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        final size = _videoController!.value.size;
        final aspectRatio = size.width / size.height;

        // Calculate height and width respecting maxHeight
        final height = size.height > maxHeight ? maxHeight : size.height;
        final width = height * aspectRatio;

        return Center(
          child: SizedBox(
            height: height,
            width: width,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      final imageFile = File(widget.post.mediaPath);

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.file(imageFile),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logo/kabtour_logo.png", height: 32),
                const SizedBox(width: 8),
                const Text(
                  "Kabtour",
                  style: TextStyle(
                    color: kabtourGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mediaPreview(context),
          
              const SizedBox(height: 25),
          
              // Post description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${widget.post.user} ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: widget.post.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 8),
          
              // Post date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Posted on ${formatPostDate(widget.post.date.toLocal())}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
