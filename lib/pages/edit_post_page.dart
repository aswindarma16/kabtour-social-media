import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../globals.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

enum EditStatus { idle, loading, error }

class EditPostPage extends StatefulWidget {
  final Post post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _descriptionController;
  VideoPlayerController? _videoController;
  final ValueNotifier<EditStatus> _statusNotifier = ValueNotifier(EditStatus.idle);
  String? _errorMessage;

  bool get isVideo {
    final path = widget.post.mediaPath.toLowerCase();
    
    return availableVideoFormat.any((ext) => path.endsWith(ext));
  }

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.post.description);

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
    _descriptionController.dispose();
    _statusNotifier.dispose();
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
      appBar: AppBar(title: const Text("Edit Post")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                mediaPreview(context),
                    
                const SizedBox(height: 16),
                    
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Edit description...",
                  ),
                ),
                    
                const SizedBox(height: 16),
                    
                ValueListenableBuilder<EditStatus>(
                  valueListenable: _statusNotifier,
                  builder: (_, status, __) {
                    if (status == EditStatus.error && _errorMessage != null) {
                      return Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                    
                ValueListenableBuilder<EditStatus>(
                  valueListenable: _statusNotifier,
                  builder: (_, status, __) {
                    final isLoading = status == EditStatus.loading;
                    
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          _statusNotifier.value = EditStatus.loading;
                    
                          final navigator = Navigator.of(context);
                    
                          String editPostResponse = await editPost(_descriptionController.text, widget.post.id);
                    
                          if (!mounted) return;
                    
                          if(editPostResponse == "success") {
                            _statusNotifier.value = EditStatus.idle;
                            navigator.pop();
                          }
                          else {
                            _errorMessage = "Post not found";
                            _statusNotifier.value = EditStatus.error;
                          }
                        },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Save"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
