import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/follow/presentation/viewmodels/follow_viewmodel.dart';
import 'package:artsphere/features/follow/presentation/widgets/follow_list_modal.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/post_details_modal.dart';
import 'package:artsphere/features/post/presentation/widgets/profile_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  Future<void> _loadAll(String userId) async {
    await ref.read(userViewModelProvider.notifier).getUsersProfile(userId);
    await ref.read(postViewModelProvider.notifier).loadUserPosts(userId);

    // IMPORTANT: always refresh follow status for correctness
    await ref.read(followViewModelProvider.notifier).refreshIsFollowing(userId);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadAll(widget.userId));
  }

  @override
  void didUpdateWidget(covariant UserProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      Future.microtask(() => _loadAll(widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final postState = ref.watch(postViewModelProvider);
    final user = userState.viewingUserEntity;

    final followState = ref.watch(followViewModelProvider);
    final followVm = ref.read(followViewModelProvider.notifier);

    final myUserId = userState.userEntity?.userId;
    final viewingUserId = widget.userId;
    final isMe = myUserId != null && myUserId == viewingUserId;

    // ✅ tri-state follow status
    final bool? cached = followState.isFollowingCache[viewingUserId];
    final bool statusUnknown = cached == null;
    final bool currentlyFollowing = cached == true;

    // ✅ busy if request running OR unknown status (so user can’t tap wrong state)
    final bool busy =
        (followState.followBusy[viewingUserId] == true) || statusUnknown;

    Future<void> openFollowers() async {
      await showFollowListModal(
        context: context,
        mode: FollowListMode.followers,
        userId: viewingUserId,
      );

      // resync button + counts after modal closes
      await ref
          .read(followViewModelProvider.notifier)
          .refreshIsFollowing(viewingUserId);
      await ref
          .read(userViewModelProvider.notifier)
          .getUsersProfile(viewingUserId);
    }

    Future<void> openFollowing() async {
      await showFollowListModal(
        context: context,
        mode: FollowListMode.following,
        userId: viewingUserId,
      );

      await ref
          .read(followViewModelProvider.notifier)
          .refreshIsFollowing(viewingUserId);
      await ref
          .read(userViewModelProvider.notifier)
          .getUsersProfile(viewingUserId);
    }

    Future<void> onFollowPressed() async {
      if (isMe) return;

      // ✅ re-read current status at click time (prevents stale value bugs)
      final bool nowFollowing =
          ref.read(followViewModelProvider).isFollowingCache[viewingUserId] ==
          true;

      await followVm.toggleFollow(
        targetUserId: viewingUserId,
        currentlyFollowing: nowFollowing,
      );

      // refresh counts (optional but makes header accurate)
      await ref
          .read(userViewModelProvider.notifier)
          .getUsersProfile(viewingUserId);

      // keep cache aligned with server (safe)
      await ref
          .read(followViewModelProvider.notifier)
          .refreshIsFollowing(viewingUserId);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: Text(
          user == null ? "Profile" : "@${user.username}",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: (userState.status == UserStatus.loading && user == null)
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text("User not found"))
          : RefreshIndicator(
              onRefresh: () async {
                await _loadAll(viewingUserId);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _UserProfileHeader(
                      avatar: user.avatar,
                      username: user.username,
                      fullName: user.fullName,
                      bio: user.bio,
                      posts: user.postCount ?? 0,
                      followers: user.followerCount ?? 0,
                      following: user.followingCount ?? 0,
                      onFollowersTap: openFollowers,
                      onFollowingTap: openFollowing,
                      showFollowButton: !isMe,
                      followBusy: busy,
                      followStatusUnknown: statusUnknown,
                      currentlyFollowing: currentlyFollowing,
                      onFollow: onFollowPressed,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  const SliverToBoxAdapter(child: _ProfileTabs()),
                  const SliverToBoxAdapter(child: Divider(height: 1)),
                  ProfilePostGrid(
                    posts: postState.userPosts,
                    loading: postState.userPostsLoading,
                    onTapPost: (post) {
                      showPostDetailsModal(context, post);
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            ),
    );
  }
}

class _UserProfileHeader extends StatelessWidget {
  const _UserProfileHeader({
    required this.avatar,
    required this.username,
    required this.fullName,
    required this.bio,
    required this.posts,
    required this.followers,
    required this.following,
    required this.onFollow,
    required this.onFollowersTap,
    required this.onFollowingTap,
    required this.showFollowButton,
    required this.currentlyFollowing,
    required this.followBusy,
    required this.followStatusUnknown,
  });

  final String? avatar;
  final String username;
  final String fullName;
  final String? bio;
  final int posts;
  final int followers;
  final int following;

  final VoidCallback onFollow;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  final bool showFollowButton;
  final bool currentlyFollowing;
  final bool followBusy;
  final bool followStatusUnknown;

  String? _resolveAvatarUrl(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }
    final fileName = avatar.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveAvatarUrl(avatar);

    final String buttonText = followStatusUnknown
        ? "Loading..."
        : (currentlyFollowing ? "Following" : "Follow");

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 38,
                          color: Colors.black54,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(title: "Posts", value: posts.toString()),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFollowersTap,
                      child: _ProfileStat(
                        title: "Followers",
                        value: followers.toString(),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFollowingTap,
                      child: _ProfileStat(
                        title: "Following",
                        value: following.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "@$username",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fullName,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (bio != null && bio!.trim().isNotEmpty) ...[
            Text(
              bio!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            const SizedBox(height: 14),
          ],

          if (showFollowButton)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: followBusy ? null : onFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentlyFollowing
                          ? Colors.grey.shade300
                          : const Color(0xFFC974A6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (followBusy) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          buttonText,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: currentlyFollowing
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _TabIcon(icon: Icons.grid_on_rounded, active: true),
          _TabIcon(icon: Icons.favorite_border),
          _TabIcon(icon: Icons.bookmark_border),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _TabIcon({required this.icon, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: active ? Colors.black : Colors.grey),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 28,
          color: active ? Colors.black : Colors.transparent,
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
