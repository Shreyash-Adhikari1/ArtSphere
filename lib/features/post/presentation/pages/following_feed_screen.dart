import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/postcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowingFeedScreen extends ConsumerStatefulWidget {
  const FollowingFeedScreen({super.key});

  @override
  ConsumerState<FollowingFeedScreen> createState() =>
      _FollowingFeedScreenState();
}

class _FollowingFeedScreenState extends ConsumerState<FollowingFeedScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postViewModelProvider.notifier).loadFollowingFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postViewModelProvider);

    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Text(
                "Following",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (state.followingLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(postViewModelProvider.notifier)
                              .loadFollowingFeed();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (state.followingPosts.isEmpty)
            const Expanded(
              child: Center(child: Text("No posts from following yet.")),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(postViewModelProvider.notifier)
                      .loadFollowingFeed();
                },
                child: ListView.builder(
                  itemCount: state.followingPosts.length,
                  itemBuilder: (context, index) {
                    final post = state.followingPosts[index];

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: PostcardWidget(post: post),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
