// lib/blocs/post_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';

enum PostStatus { initial, loading, success, failure }

class PostState {
  final PostStatus status;
  final List<Post> posts;
  final String error;

  PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.error = '',
  });
}

class PostBloc extends Cubit<PostState> {
  PostBloc() : super(PostState());

  Future<void> fetchPosts() async {
    emit(PostState(status: PostStatus.loading));
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final posts = json.map((post) => Post.fromJson(post)).toList();
        emit(PostState(status: PostStatus.success, posts: posts));
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      emit(PostState(status: PostStatus.failure, error: e.toString()));
    }
  }
}