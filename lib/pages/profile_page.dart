import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../blocs/authentication_bloc.dart';
import '../globals.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import 'edit_post_page.dart';
import 'post_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late Future<List<Post>> _postsFuture;
  late TabController _tabController;

  String? userName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);

    final authState = context.read<AuthenticationBloc>().state;
    if (authState is AuthenticationAuthenticated) {
      userName = authState.userData.userName;
    }

    _postsFuture = loadPosts(userName);
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = loadPosts(userName);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationBloc>().add(
                LogOut(),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    userName ?? "Unknown",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: kabtourGreen,
              tabs: const [
                Tab(text: "Posts"),
                Tab(text: "Archive"),
              ],
            ),
        
            Expanded(
              child: FutureBuilder<List<Post>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Failed to load posts"));
                  }
        
                  final posts = snapshot.data ?? [];
                  final visiblePosts = posts.where((p) => !p.archived).toList();
                  final archivedPosts = posts.where((p) => p.archived).toList();
        
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Posts Tab
                      _buildPostsGrid(visiblePosts, isArchiveTab: false),
                      // Archive Tab
                      _buildPostsGrid(archivedPosts, isArchiveTab: true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid(List<Post> posts, {required bool isArchiveTab}) {
    if (posts.isEmpty) {
      return const Center(child: Text("No posts"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onLongPress: () async {
            // Show options: Delete or Archive or Edit
            showModalBottomSheet(
              isScrollControlled: true,
              useSafeArea: true,
              context: context,
              builder: (context) {
                final padding = MediaQuery.of(context).padding.bottom;

                return Padding(
                  padding: EdgeInsets.only(bottom: padding > 0 ? padding : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: Text("Edit"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditPostPage(post: post)),
                          ).then((returnValue) {
                            _refreshPosts();
                          });
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.archive),
                        title: Text(isArchiveTab ? "Make Visible" : "Archive"),
                        onTap: () async {
                          Navigator.pop(context);
                  
                          String archiveResponse = await archivePost(post.id, isArchiveTab ? false : true);
                  
                          if(archiveResponse == "success") {
                            _refreshPosts();
                          }
                          else {
                            Fluttertoast.showToast(
                              msg: archiveResponse,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.black54,
                              textColor: Colors.white,
                              fontSize: 16.0
                            );
                          }
                        },
                      ),
                      isArchiveTab ? Container() : ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text("Delete"),
                        onTap: () async {
                          Navigator.pop(context);
                  
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Post"),
                              content: const Text("Are you sure you want to delete this post?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                              ],
                            ),
                          );
                  
                          if (confirm == true) {
                            String deleteResponse = await deletePost(post.id);
                  
                            if(deleteResponse == "success") {
                              Fluttertoast.showToast(
                                msg: "Post deleted",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.black54,
                                textColor: Colors.white,
                                fontSize: 16.0
                              );
                  
                              _refreshPosts();
                            }
                            else {
                              Fluttertoast.showToast(
                                msg: deleteResponse,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.black54,
                                textColor: Colors.white,
                                fontSize: 16.0
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
            );
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
            );
          },
          child: Builder(
            builder: (context) {
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
            }
          ),
        );
      },
    );
  }
}
