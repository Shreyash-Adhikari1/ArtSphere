import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';

void showPostDetailsModal(BuildContext context, PostEntity post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PostDetailsSheet(post: post),
  );
}

class _PostDetailsSheet extends ConsumerWidget {
  const _PostDetailsSheet({required this.post});

  final PostEntity post;

  static const _pink = Color(0xFFC974A6);

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
    final postState = ref.watch(postViewModelProvider);
    final vm = ref.read(postViewModelProvider.notifier);

    // ✅ always use latest post copy (so likeCount/likedBy updates inside modal too)
    PostEntity currentPost = post;
    final id = post.postId;
    if (id != null) {
      final match = postState.discoverPosts.where((p) => p.postId == id);
      if (match.isNotEmpty) currentPost = match.first;
      final match2 = postState.myPosts.where((p) => p.postId == id);
      if (match2.isNotEmpty) currentPost = match2.first;
    }

    final userState = ref.watch(userViewModelProvider);
    final myUserId = userState.userEntity?.userId;

    final postId = currentPost.postId ?? "";
    final likeBusy = postId.isNotEmpty && (postState.likeBusy[postId] == true);

    final isLiked =
        myUserId != null &&
        (currentPost.likedBy ?? const []).contains(myUserId);

    final imageUrl = _resolvePostMediaUrl(currentPost);
    final avatarUrl = _resolveAvatarUrl(currentPost.author?.avatar);

    Future<void> toggleLike() async {
      if (likeBusy) return;
      if (myUserId == null) return;

      await vm.toggleLike(
        post: currentPost,
        currentlyLiked: isLiked,
        myUserId: myUserId,
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.98,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      _AvatarCircle(url: avatarUrl, size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "@${currentPost.author?.username ?? 'unknown'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Body scroll
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                    children: [
                      // Post media (original, not “IG cloned”)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: imageUrl == null
                              ? Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.image, size: 42),
                                  ),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 42),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Actions row (like + comment count on left, save on right)
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
                          Text(
                            "${currentPost.likeCount ?? 0}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 14),

                          const Icon(Icons.mode_comment_outlined, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            "${currentPost.commentCount ?? 0}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed: () {
                              // TODO: bookmark later
                            },
                            icon: const Icon(Icons.bookmark_border, size: 26),
                          ),
                        ],
                      ),

                      // Caption
                      if ((currentPost.caption ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          currentPost.caption!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      const Text(
                        "Comments",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),

                      // ✅ Comments list placeholder (UI ready)
                      // You will wire this to a CommentViewModel later.
                      _CommentsPlaceholder(),

                      const SizedBox(height: 80), // room for input bar
                    ],
                  ),
                ),

                // Comment input bar (UI only; hook it later)
                _CommentInputBar(
                  onSend: (text) {
                    // TODO: call commentViewModel.addComment(postId, text)
                    // also update post.commentCount in PostViewModel if you want optimistic delta
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this widget with your real comments list once you wire backend.
    return Column(
      children: List.generate(6, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AvatarCircle(url: null, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6ED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@user",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "This is a placeholder comment. Wire backend later 👀",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CommentInputBar extends StatefulWidget {
  const _CommentInputBar({required this.onSend});
  final void Function(String text) onSend;

  @override
  State<_CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<_CommentInputBar> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void send() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => send(),
              decoration: InputDecoration(
                hintText: "Write a comment…",
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFFFF6ED),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(onPressed: send, icon: const Icon(Icons.send_rounded)),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: url == null
            ? Icon(Icons.person, size: size * 0.55, color: Colors.black54)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: size * 0.55,
                  color: Colors.black54,
                ),
              ),
      ),
    );
  }
}
