import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../globals.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import 'post_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = loadPosts(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
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
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load posts"));
          }

          final posts = (snapshot.data ?? []).where((p) => !p.archived).toList();

          if (posts.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Builder(
                    builder: (_) {
                      final file = File(post.mediaPath);
                      if (!file.existsSync()) {
                        return Container();
                      }

                      final lowerPath = post.mediaPath.toLowerCase();
                      final isVideo = availableVideoFormat.any((ext) => lowerPath.endsWith(ext));

                      if (isVideo) {
                        return FutureBuilder<File?>(
                          future: generateThumbnail(post.mediaPath),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                color: Color.fromARGB(255, 219, 240, 228),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: const CircularProgressIndicator(color: kabtourGreen),
                                ),
                              );
                            }

                            final thumbFile = snapshot.data;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                thumbFile == null ? Container() : Opacity(
                                  opacity: 0.5,
                                  child: Image.file(
                                    thumbFile, fit: BoxFit.cover,
                                    width: double.infinity
                                  )
                                ),
                                  
                                const Icon(Icons.play_circle_fill,
                                    color: Colors.white, size: 60),
                              ],
                            );
                          }
                        );
                      } else {
                        return Image.file(file, fit: BoxFit.cover);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
