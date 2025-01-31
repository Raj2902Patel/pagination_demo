import 'package:flutter/material.dart';
import 'package:pagination_flutter/models/postModel.dart';
import 'package:pagination_flutter/repositories/postRepository.dart';

class PostProvider with ChangeNotifier {
  final _postRepo = PostRepository();

  final List<PostModel> _posts = [];
  final List<PostModel> _filteredPosts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  String _searchQuery = "";

  List<PostModel> get posts => _searchQuery.isEmpty ? _posts : _filteredPosts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  Future<void> refreshPosts() async {
    _posts.clear();
    _filteredPosts.clear();
    _page = 1;
    _hasMore = true;
    _searchQuery = "";
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

      if (_searchQuery.isNotEmpty) {
        _applySearchFilter();
      }
    } catch (error) {
      print("Error Fetching Data: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applySearchFilter() {
    _filteredPosts.clear();
    _filteredPosts.addAll(
      _posts.where(
        (post) => post.name.toLowerCase().contains(_searchQuery.toLowerCase()),
      ),
    );
    notifyListeners();
  }

  void searchPosts(String query) {
    _searchQuery = query;
    _applySearchFilter();
  }

  void clearSearch() {
    _searchQuery = "";
    _filteredPosts.clear();
    notifyListeners();
  }
}
