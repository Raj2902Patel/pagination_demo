import 'package:flutter/material.dart';
import 'package:pagination_flutter/controllers/postController.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PostProvider postProvider;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    postProvider = PostProvider();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    postProvider.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !postProvider.isLoading) {
      postProvider.fetchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => postProvider..fetchPosts(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.withOpacity(0.2),
          title: const Text("PAGINATION & SEARCHING"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) => postProvider.searchPosts(query),
                decoration: InputDecoration(
                  hintText: "Search Posts...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<PostProvider>(
                builder: (context, provider, child) {
                  return Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          _scrollListener();
                          return false;
                        },
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await provider.refreshPosts();
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: provider.posts.length +
                                ((provider.hasMore &&
                                        provider.searchQuery.isEmpty)
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              if (index == provider.posts.length &&
                                  provider.hasMore &&
                                  provider.searchQuery.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: SizedBox(
                                      height: 24.0,
                                      width: 24.0,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.0),
                                    ),
                                  ),
                                );
                              }

                              final post = provider.posts[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text("${index + 1}"),
                                  ),
                                  title: Text(post.name),
                                  subtitle: Text(post.email),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (provider.posts.isEmpty && provider.isLoading)
                        Container(
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
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
}
