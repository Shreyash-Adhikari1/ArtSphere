import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(userViewModelProvider.notifier)
          .getUsersProfile(widget.userId);
      await ref
          .read(postViewModelProvider.notifier)
          .loadUserPosts(widget.userId);
    });
  }

  @override
  void didUpdateWidget(covariant UserProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      Future.microtask(() async {
        await ref
            .read(userViewModelProvider.notifier)
            .getUsersProfile(widget.userId);
        await ref
            .read(postViewModelProvider.notifier)
            .loadUserPosts(widget.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final postState = ref.watch(postViewModelProvider);
    debugPrint("🟣 userPosts length in UI: ${postState.userPosts.length}");
    debugPrint("🟣 userPostsLoading: ${postState.userPostsLoading}");
    final user = userState.viewingUserEntity;

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
                await ref
                    .read(userViewModelProvider.notifier)
                    .getUsersProfile(widget.userId);
                await ref
                    .read(postViewModelProvider.notifier)
                    .loadUserPosts(widget.userId);
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
                      onFollow: () {
                        // TODO: wire follow/unfollow later
                      },
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
  });

  final String? avatar;
  final String username;
  final String fullName;
  final String? bio;
  final int posts;
  final int followers;
  final int following;
  final VoidCallback onFollow;

  String? _resolveAvatarUrl(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://'))
      return avatar;
    final fileName = avatar.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveAvatarUrl(avatar);

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
                    _ProfileStat(
                      title: "Followers",
                      value: followers.toString(),
                    ),
                    _ProfileStat(
                      title: "Following",
                      value: following.toString(),
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC974A6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Follow",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
        Icon(icon, color: active ? Colors.black : Colors.grey.shade500),
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
