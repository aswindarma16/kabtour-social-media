import 'dart:convert';
import 'dart:io';

import 'package:kabtour_social_media/globals.dart';
import 'package:path_provider/path_provider.dart';

import '../models/post.dart';

Future<List<Post>> loadPosts(String? userName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/posts.json');

  if (await file.exists()) {
    final data = json.decode(await file.readAsString()) as List;

    if (userName == null) {
      return data.map((e) => Post.fromJson(e)).toList();
    }
    else {
      return data.map((e) => Post.fromJson(e)).toList().where((p) => p.user == userName).toList();
    }
  }
  return [];
}

Future<void> savePosts(List<Post> posts) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/posts.json');
  await file.writeAsString(
    json.encode(posts.map((e) => e.toJson()).toList()),
  );
}

Future<String> savePost({
  required String userName,
  required String description,
  required String mediaFilePath
}) async {
  try {
    final posts = await loadPosts(null);

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: userName,
      description: description,
      mediaPath: mediaFilePath,
      date: DateTime.now(),
      archived: false
    );

    posts.add(newPost);
    await savePosts(posts);

    return "success";
  } catch (e) {
    return generalErrorMessage;
  }
}

Future<String> deletePost(String postId) async {
  try {
    final posts = await loadPosts(null);
    posts.removeWhere((p) => p.id == postId);
    await savePosts(posts);
    return "success";
  } on Exception {
    return generalErrorMessage;
  }
}

Future<String> archivePost(String postId, bool archive) async {
  try {
    final posts = await loadPosts(null);
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      posts[index].archived = archive;
      await savePosts(posts);
    }

    return "success";
  } on Exception {
    return generalErrorMessage;
  }
}

Future<String> editPost(String newDescription, String oldPostId) async {
  try {
    final posts = await loadPosts(null);
    final index = posts.indexWhere((p) => p.id == oldPostId);

    if (index != -1) {
      posts[index].description = newDescription;
      await savePosts(posts);

      return "success";
    } else {
      return "No post found!";
    }
  } catch (e) {
    return generalErrorMessage;
  }
}
