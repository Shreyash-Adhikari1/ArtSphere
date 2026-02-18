import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePostGrid extends ConsumerWidget {
  const ProfilePostGrid({
    super.key,
    required this.posts,
    this.loading = false,
    this.emptyText = "No posts yet",
    this.onTapPost,
  });

  final List<PostEntity> posts;
  final bool loading;
  final String emptyText;
  final void Function(PostEntity post)? onTapPost;

  String _resolvePostMediaUrl(PostEntity post) {
    final media = post.media;
    if (media == null || media.trim().isEmpty) return "";

    // Full URL
    if (media.startsWith("http://") || media.startsWith("https://"))
      return media;

    // Already a backend path
    if (media.startsWith("/uploads/")) return "${ApiEndpoints.baseUrl}$media";

    final fileName = media.split("/").last;

    // Choose folder based on flag (important for challenge submissions)
    final base = (post.isChallengeSubmission == true)
        ? ApiEndpoints.challengeSubmissions
        : ApiEndpoints.postImages;

    return "$base/$fileName";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text(emptyText)),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(2),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final post = posts[index];
          final url = _resolvePostMediaUrl(post);

          if (url.isEmpty) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.image_not_supported)),
            );
          }

          return InkWell(
            onTap: () => onTapPost?.call(post),
            child: Container(
              color: Colors.grey.shade200,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          );
        }, childCount: posts.length),
      ),
    );
  }
}
