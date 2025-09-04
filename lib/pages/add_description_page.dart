import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/authentication_bloc.dart';
import '../repositories/post_repository.dart';
import 'main_page.dart';

enum PostStatus { idle, loading, success, error }

class AddDescriptionPage extends StatefulWidget {
  final File mediaFile;

  const AddDescriptionPage({required this.mediaFile, super.key});

  @override
  AddDescriptionPageState createState() => AddDescriptionPageState();
}

class AddDescriptionPageState extends State<AddDescriptionPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ValueNotifier<PostStatus> _statusNotifier = ValueNotifier(PostStatus.idle);
  String? _errorMessage;
  String? userName;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationBloc>().state;
    if (authState is AuthenticationAuthenticated) {
      userName = authState.userData.userName;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write a description...",
              ),
            ),

            const SizedBox(height: 16),

            ValueListenableBuilder<PostStatus>(
              valueListenable: _statusNotifier,
              builder: (context, status, _) {
                if (status == PostStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Error: $_errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            ValueListenableBuilder<PostStatus>(
              valueListenable: _statusNotifier,
              builder: (context, status, _) {
                if (status == PostStatus.loading) {
                  return const CircularProgressIndicator();
                }

                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          _statusNotifier.value = PostStatus.loading;

                          final navigator = Navigator.of(context);
                      
                          String savePostResponse = await savePost(
                            description: _descriptionController.text,
                            mediaFilePath: widget.mediaFile.path,
                            userName: userName!
                          );
                      
                          if(savePostResponse == "success") {
                            _statusNotifier.value = PostStatus.success;
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const MainPage()),
                              (_) => false,
                            );
                          }
                          else {
                            _statusNotifier.value = PostStatus.error;
                            _errorMessage = savePostResponse;
                          }
                        },
                        child: const Text("Post"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
