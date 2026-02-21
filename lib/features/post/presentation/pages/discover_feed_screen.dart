import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/postcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  @override
  void initState() {
    super.initState();

    // Load once after first frame (safe for Riverpod + context)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postViewModelProvider.notifier).loadDiscoverFeed();
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
                "Trending Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Loading
          if (state.discoverLoading)
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
                              .loadDiscoverFeed();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (state.discoverPosts.isEmpty)
            const Expanded(child: Center(child: Text("No posts yet.")))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(postViewModelProvider.notifier)
                      .loadDiscoverFeed();
                },
                child: ListView.builder(
                  itemCount: state.discoverPosts.length,
                  itemBuilder: (context, index) {
                    final post = state.discoverPosts[index];

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
