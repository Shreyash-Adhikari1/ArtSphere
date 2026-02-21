import 'package:artsphere/features/comment/presentation/viewmodels/comment_viewmodel.dart';
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

class _PostDetailsSheet extends ConsumerStatefulWidget {
  const _PostDetailsSheet({required this.post});
  final PostEntity post;

  @override
  ConsumerState<_PostDetailsSheet> createState() => _PostDetailsSheetState();
}

class _PostDetailsSheetState extends ConsumerState<_PostDetailsSheet> {
  static const _pink = Color(0xFFC974A6);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final postId = widget.post.postId;
      if (postId == null || postId.isEmpty) return;

      ref.read(commentViewModelProvider.notifier).loadComments(postId);
    });
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
  Widget build(BuildContext context) {
    final postState = ref.watch(postViewModelProvider);
    final postVm = ref.read(postViewModelProvider.notifier);

    final commentVm = ref.read(commentViewModelProvider.notifier);

    PostEntity currentPost = widget.post;
    final id = widget.post.postId;
    if (id != null) {
      final match = postState.discoverPosts.where((p) => p.postId == id);
      if (match.isNotEmpty) currentPost = match.first;
      final match2 = postState.myPosts.where((p) => p.postId == id);
      if (match2.isNotEmpty) currentPost = match2.first;
      final match3 = postState.userPosts.where((p) => p.postId == id);
      if (match3.isNotEmpty) currentPost = match3.first;
      final match4 = postState.followingPosts.where((p) => p.postId == id);
      if (match4.isNotEmpty) currentPost = match4.first;
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

      await postVm.toggleLike(
        post: currentPost,
        currentlyLiked: isLiked,
        myUserId: myUserId,
      );
    }

    Future<void> sendComment(String text) async {
      if (postId.isEmpty) return;

      final created = await commentVm.createComment(
        postId: postId,
        commentText: text,
      );

      if (created != null) {
        postVm.bumpCommentCount(postId, delta: 1);
        await commentVm.loadComments(postId);
      }
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

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                    children: [
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
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_border, size: 26),
                          ),
                        ],
                      ),

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

                      _PostCommentsSection(
                        postId: postId,
                        pink: _pink,
                        onDeleted: () =>
                            postVm.bumpCommentCount(postId, delta: -1),
                      ),

                      const SizedBox(height: 80),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                _CommentInputBar(onSend: sendComment),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostCommentsSection extends ConsumerStatefulWidget {
  const _PostCommentsSection({
    required this.postId,
    required this.pink,
    required this.onDeleted,
  });

  final String postId;
  final Color pink;
  final VoidCallback onDeleted;

  @override
  ConsumerState<_PostCommentsSection> createState() =>
      _PostCommentsSectionState();
}

class _PostCommentsSectionState extends ConsumerState<_PostCommentsSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(commentViewModelProvider.notifier).loadComments(widget.postId);
    });
  }

  String? _resolveAvatarUrl(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://'))
      return avatar;
    final fileName = avatar.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  Future<void> _confirmDelete(BuildContext context, VoidCallback onYes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete comment?"),
        content: const Text("This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (ok == true) onYes();
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentViewModelProvider);
    final commentVm = ref.read(commentViewModelProvider.notifier);
    final myUserId = ref.watch(userViewModelProvider).userEntity?.userId;

    if (commentState.commentsLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final comments = commentState.comments;

    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            "No comments yet",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      children: comments.map((c) {
        final commentId = c.commentId;
        final isMine = myUserId != null && c.userId?.userId == myUserId;

        final liked =
            myUserId != null && (c.likedBy ?? const []).contains(myUserId);
        final busy =
            commentId != null && (commentState.likeBusy[commentId] == true);

        final avatarUrl = _resolveAvatarUrl(c.userId?.avatar);
        final username = c.userId?.username ?? "user";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarCircle(url: avatarUrl, size: 28),
              const SizedBox(width: 10),

              // Compact comment body (no big box)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // username + text (compact)
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                        children: [
                          TextSpan(
                            text: "@$username ",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: c.commentText),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Actions row (like count + optional delete)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: busy || commentId == null || myUserId == null
                              ? null
                              : () => commentVm.toggleLike(
                                  comment: c,
                                  currentlyLiked: liked,
                                  myUserId: myUserId,
                                ),
                          child: Row(
                            children: [
                              Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: liked ? widget.pink : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${c.likeCount ?? 0}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (isMine && commentId != null) ...[
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () async {
                              await _confirmDelete(context, () async {
                                final ok = await commentVm.deleteComment(
                                  commentId,
                                );
                                if (ok) widget.onDeleted();
                              });
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
