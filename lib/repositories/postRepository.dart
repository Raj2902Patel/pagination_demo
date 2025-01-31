import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pagination_flutter/models/postModel.dart';

class PostRepository {
  static const String _baseURL =
      "https://jsonplaceholder.typicode.com/comments";

  Future<List<PostModel>> fetchPosts(int page, int limit) async {
    final response =
        await http.get(Uri.parse('$_baseURL?_page=$page&_limit=$limit'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      return jsonResponse.map((data) => PostModel.fromJson(data)).toList();
    } else {
      throw Exception("Something Went Wrong!");
    }
  }
}
