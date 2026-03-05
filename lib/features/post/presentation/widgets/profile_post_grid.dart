import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';

class ProfilePostGrid extends StatelessWidget {
  const ProfilePostGrid({
    super.key,
    required this.posts,
    required this.loading,
    this.onTapPost,
    this.onLongPressPost, // ✅ add
  });

  final List<PostEntity> posts;
  final bool loading;
  final void Function(PostEntity post)? onTapPost;
  final void Function(PostEntity post)? onLongPressPost; // ✅ add

  String _resolvePostMediaUrl(PostEntity post) {
    final media = (post.media ?? '').trim();
    if (media.isEmpty) return '';

    if (media.startsWith('http://') || media.startsWith('https://')) {
      return media;
    }

    if (media.startsWith('/uploads/')) {
      return '${ApiEndpoints.mediaServerUrl}$media';
    }

    final fileName = media.split('/').last;

    final looksLikeChallengeSubmission =
        fileName.startsWith('challenge-submissions-') ||
        media.contains('challenge-submissions');

    final base =
        (post.isChallengeSubmission == true || looksLikeChallengeSubmission)
        ? ApiEndpoints.challengeSubmissions
        : ApiEndpoints.postImages;

    return '$base/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text("No posts yet")),
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
          final media = post.media;

          if (media == null || media.trim().isEmpty) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.image_not_supported)),
            );
          }

          final url = _resolvePostMediaUrl(post);

          return InkWell(
            onTap: () => onTapPost?.call(post),
            onLongPress: () => onLongPressPost?.call(post), // ✅ add
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
