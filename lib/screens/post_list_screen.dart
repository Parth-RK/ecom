// lib/screens/post_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Add this import
import '../blocs/post_bloc.dart'; // Adjust the path as necessary
import '../models/post.dart';
import 'user_form_screen.dart';
import 'post_detail_screen.dart';
import 'audio_player_screen.dart';

class PostListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reddit Style Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.music_note),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AudioPlayerScreen()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          switch (state.status) {
            case PostStatus.loading:
              return Center(child: CircularProgressIndicator());
            case PostStatus.success:
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text('u${post.id}'),
                          ),
                          title: Text('u/user${post.id}'),
                          subtitle: Text('2h ago'),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(post.body),
                            ],
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_upward),
                              onPressed: () {},
                            ),
                            Text('${post.votes}'),
                            IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(post: post),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                post.saved ? Icons.bookmark : Icons.bookmark_border,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            case PostStatus.failure:
              return Center(child: Text(state.error));
            default:
              return Center(child: Text('Please fetch posts'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show user form dialog or modal instead of navigation
        },
        child: Icon(Icons.add),
      ),
    );
  }
}