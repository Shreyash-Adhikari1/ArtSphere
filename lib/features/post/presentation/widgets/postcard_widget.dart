import 'dart:math' as math;

import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/shake/shake_providers.dart';
import 'package:artsphere/features/auth/presentation/pages/user_profile_page.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/post_details_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostcardWidget extends ConsumerStatefulWidget {
  const PostcardWidget({super.key, required this.post});
  final PostEntity post;

  @override
  ConsumerState<PostcardWidget> createState() => _PostcardWidgetState();
}

class _PostcardWidgetState extends ConsumerState<PostcardWidget>
    with SingleTickerProviderStateMixin {
  static const _pink = Color(0xFFC974A6);

  // Cooldown to avoid shake-like spam
  static const Duration _shakeCooldown = Duration(milliseconds: 1500);
  DateTime? _lastShakeLikeAt;

  // Heart pop animation
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  // Visibility key
  late final Key _visibilityKey;

  // ✅ Stable subscription (so we DON'T listen inside build)
  ProviderSubscription<AsyncValue<void>>? _shakeSub;

  @override
  void initState() {
    super.initState();

    _visibilityKey = ValueKey(
      "postcard-${widget.post.postId ?? widget.hashCode}",
    );

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.elasticOut));

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    // ✅ Listen once. Read fresh state at event time.
    _shakeSub = ref.listenManual<AsyncValue<void>>(shakeStreamProvider, (
      prev,
      next,
    ) async {
      if (!next.hasValue) return;

      final activeId = ref.read(activePostFocusProvider);
      final myId = ref.read(userViewModelProvider).userEntity?.userId;
      if (myId == null) return;

      final postState = ref.read(postViewModelProvider);
      final vm = ref.read(postViewModelProvider.notifier);

      final currentPost = _currentPostFromState(postState);
      final currentId = currentPost.postId;

      // Only the active/visible card reacts
      if (currentId == null || activeId != currentId) return;

      final isLiked = (currentPost.likedBy ?? const []).contains(myId);
      if (isLiked) return; // like-only

      final likeBusy = (postState.likeBusy[currentId] == true);
      if (likeBusy) return;

      if (!_cooldownReady()) return;
      _lastShakeLikeAt = DateTime.now();

      await vm.toggleLike(
        post: currentPost,
        currentlyLiked: false,
        myUserId: myId,
      );

      _playLikedFeedback();
    });
  }

  @override
  void dispose() {
    _shakeSub?.close();
    _anim.dispose();
    super.dispose();
  }

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

  bool _cooldownReady() {
    final last = _lastShakeLikeAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= _shakeCooldown;
  }

  void _playLikedFeedback() {
    HapticFeedback.lightImpact();
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure shake listener provider is created (single global listener)
    ref.watch(shakeServiceProvider);

    final userState = ref.watch(userViewModelProvider);
    final myUserId = userState.userEntity?.userId;

    final vm = ref.read(postViewModelProvider.notifier);
    final state = ref.watch(postViewModelProvider);

    final currentPost = _currentPostFromState(state);

    final postId = currentPost.postId ?? "";
    final likeBusy = postId.isNotEmpty && (state.likeBusy[postId] == true);

    final isLiked =
        myUserId != null &&
        (currentPost.likedBy ?? const []).contains(myUserId);

    final imageUrl = _resolvePostMediaUrl(currentPost);
    final avatarUrl = _resolveAvatarUrl(currentPost.author?.avatar);

    final width = MediaQuery.of(context).size.width;
    final horizontal = math.min(20.0, math.max(12.0, width * 0.045));
    final padding = math.min(16.0, math.max(12.0, width * 0.04));

    void goToProfile() {
      final userId = currentPost.author?.userId;
      if (userId == null) return;
      AppRoutes.push(context, UserProfilePage(userId: userId));
    }

    Future<void> toggleLike() async {
      if (likeBusy) return;
      if (myUserId == null) return;

      final wasLiked = isLiked;
      await vm.toggleLike(
        post: currentPost,
        currentlyLiked: wasLiked,
        myUserId: myUserId,
      );

      if (!wasLiked) {
        _playLikedFeedback();
      }
    }

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        final id = currentPost.postId;
        if (id == null) return;

        final visible = info.visibleFraction;

        // debug
        debugPrint("VISIBLE $id -> $visible");

        final focus = ref.read(activePostFocusProvider);

        // If this card is more visible than the current focus, take focus.
        // (0.05 margin avoids rapid flip-flop)
        if (visible >= 0.25 && visible > focus.fraction + 0.05) {
          ref.read(activePostFocusProvider.notifier).state = ActivePostFocus(
            postId: id,
            fraction: visible,
          );
          return;
        }

        // If THIS card is the active one but it becomes mostly hidden, clear focus.
        if (focus.postId == id && visible < 0.15) {
          ref.read(activePostFocusProvider.notifier).state =
              ActivePostFocus.empty;
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: 10),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6ED),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
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
                const Icon(Icons.vibration, size: 18, color: Colors.black38),
              ],
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
                          child: const Center(
                            child: Icon(Icons.image, size: 40),
                          ),
                        ),

                      if (likeBusy)
                        Container(color: Colors.black.withOpacity(0.04)),

                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _anim,
                          builder: (context, _) {
                            final opacity = _opacity.value;
                            if (opacity <= 0.01) return const SizedBox.shrink();
                            return Center(
                              child: Opacity(
                                opacity: (1 - (_anim.value * 0.7)).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Transform.scale(
                                  scale: 1.0 + (_scale.value - 1.0),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 92,
                                    color: _pink.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (currentPost.caption != null && currentPost.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  currentPost.caption!,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                IconButton(
                  onPressed: likeBusy ? null : toggleLike,
                  splashRadius: 22,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 26,
                    color: isLiked ? _pink : Colors.black87,
                  ),
                ),
                Text(
                  "${currentPost.likeCount ?? 0}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => showPostDetailsModal(context, currentPost),
                  splashRadius: 22,
                  icon: const Icon(Icons.mode_comment_outlined, size: 24),
                ),
                Text(
                  "${currentPost.commentCount ?? 0}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  splashRadius: 22,
                  icon: const Icon(Icons.bookmark_border, size: 26),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PostEntity _currentPostFromState(PostState state) {
    PostEntity currentPost = widget.post;
    final id = widget.post.postId;
    if (id == null) return currentPost;

    PostEntity? found;

    found = state.discoverPosts.cast<PostEntity?>().firstWhere(
      (p) => p?.postId == id,
      orElse: () => null,
    );
    found ??= state.followingPosts.cast<PostEntity?>().firstWhere(
      (p) => p?.postId == id,
      orElse: () => null,
    );
    found ??= state.myPosts.cast<PostEntity?>().firstWhere(
      (p) => p?.postId == id,
      orElse: () => null,
    );
    found ??= state.userPosts.cast<PostEntity?>().firstWhere(
      (p) => p?.postId == id,
      orElse: () => null,
    );

    if (found != null) currentPost = found;
    return currentPost;
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
