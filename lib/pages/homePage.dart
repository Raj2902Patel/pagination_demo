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

  @override
  void initState() {
    super.initState();
    postProvider = PostProvider();
  }

  @override
  void dispose() {
    super.dispose();
    postProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.2),
        title: const Text("HomePage"),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (context) => postProvider..fetchPosts(),
        child: Consumer<PostProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !postProvider.isLoading) {
                      postProvider.fetchPosts();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await provider.refreshPosts();
                    },
                    child: ListView.builder(
                      itemCount:
                          provider.posts.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.posts.length &&
                            provider.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.0),
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
    );
  }
}
