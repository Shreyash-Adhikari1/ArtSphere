import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';

class PostcardWidget extends ConsumerWidget {
  const PostcardWidget({super.key, required this.post});

  final PostEntity post;

  static const _pink = Color(0xFFC974A6);

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  double _calculateAspectRatio(PostEntity post) {
    if (post.mediaType == "portrait_16_9") return 9 / 16;
    return 3 / 4;
  }

  String? _resolvePostMediaUrl(PostEntity post) {
    final media = post.media;
    if (media == null || media.trim().isEmpty) return null;

    if (media.startsWith('http://') || media.startsWith('https://'))
      return media;
    if (media.startsWith('/uploads/')) return '${ApiEndpoints.baseUrl}$media';

    final fileName = media.split('/').last;

    final base = (post.isChallengeSubmission == true)
        ? ApiEndpoints.challengeSubmissions
        : ApiEndpoints.postImages;

    return '$base/$fileName';
  }

  String? _resolveAvatarUrl(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://'))
      return avatar;

    final fileName = avatar.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userViewModelProvider);
    final myUserId = userState.userEntity?.userId;

    final vm = ref.read(postViewModelProvider.notifier);
    final state = ref.watch(postViewModelProvider);

    PostEntity currentPost = post;
    final id = post.postId;
    if (id != null) {
      final match = state.discoverPosts.where((p) => p.postId == id);
      if (match.isNotEmpty) currentPost = match.first;
    }

    final postId = currentPost.postId ?? "";
    final likeBusy = postId.isNotEmpty && (state.likeBusy[postId] == true);

    final isLiked =
        myUserId != null &&
        (currentPost.likedBy ?? const []).contains(myUserId);

    final imageUrl = _resolvePostMediaUrl(currentPost);
    final avatarUrl = _resolveAvatarUrl(currentPost.author?.avatar);

    void goToProfile() {
      final userId = currentPost.author?.userId;
      if (userId == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigate to user profile: $userId")),
      );
    }

    Future<void> toggleLike() async {
      if (likeBusy) return;
      if (myUserId == null) return;

      await vm.toggleLike(
        post: currentPost,
        currentlyLiked: isLiked,
        myUserId: myUserId,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: goToProfile,
                child: _AvatarCircle(url: avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: goToProfile,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@${currentPost.author?.username ?? 'unknown'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (currentPost.createdAt != null)
                        Text(
                          _formatTime(currentPost.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AspectRatio(
              aspectRatio: _calculateAspectRatio(currentPost),
              child: GestureDetector(
                onDoubleTap: toggleLike,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image, size: 40),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    if (likeBusy)
                      Container(color: Colors.black.withOpacity(0.04)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (currentPost.caption != null && currentPost.caption!.isNotEmpty)
            Text(
              currentPost.caption!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),

          const SizedBox(height: 10),

          Row(
            children: [
              IconButton(
                onPressed: likeBusy ? null : toggleLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 26,
                  color: isLiked ? _pink : Colors.black,
                ),
              ),
              Text("${currentPost.likeCount ?? 0}"),

              const SizedBox(width: 14),

              IconButton(
                onPressed: () {
                  // TODO: open comments modal for currentPost.postId
                  // You'll wire this next.
                },
                icon: const Icon(Icons.mode_comment_outlined, size: 24),
              ),
              Text("${currentPost.commentCount ?? 0}"),

              const Spacer(),

              IconButton(
                onPressed: () {
                  // TODO: save/bookmark action
                },
                icon: const Icon(Icons.bookmark_border, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 36,
        height: 36,
        color: Colors.grey.shade200,
        child: url == null
            ? const Icon(Icons.person, size: 20, color: Colors.black54)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.black54,
                  );
                },
              ),
      ),
    );
  }
}
