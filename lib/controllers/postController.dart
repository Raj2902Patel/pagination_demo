import 'package:flutter/cupertino.dart';
import 'package:pagination_flutter/models/postModel.dart';
import 'package:pagination_flutter/repositories/postRepository.dart';

class PostProvider with ChangeNotifier {
  final _postRepo = PostRepository();

  final List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> refreshPosts() async {
    posts.clear();
    _page = 1;
    _hasMore = true;
    notifyListeners();
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      List<PostModel> newPosts = await _postRepo.fetchPosts(_page, _limit);

      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        _posts.addAll(newPosts);
        _page++;
      }
    } catch (error) {
      print("Error Fetching Data: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
