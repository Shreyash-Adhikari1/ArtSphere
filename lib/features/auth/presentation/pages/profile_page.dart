import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/themes/theme_notifier.dart';
import 'package:artsphere/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:artsphere/features/auth/presentation/pages/login_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/follow/presentation/viewmodels/follow_viewmodel.dart';
import 'package:artsphere/features/follow/presentation/widgets/follow_list_modal.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/post_details_modal.dart';
import 'package:artsphere/features/post/presentation/widgets/profile_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(userViewModelProvider.notifier).getProfile();
      await ref.read(postViewModelProvider.notifier).loadMyPosts();
    });
  }

  Future<void> _confirmLogout() async {
    final choice = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Choose how you want to logout."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 0),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 1),
            child: const Text("Lock app (Fingerprint)"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 2),
            child: const Text("Sign out"),
          ),
        ],
      ),
    );

    if (choice == null || choice == 0) return;

    if (choice == 1) {
      await ref
          .read(userViewModelProvider.notifier)
          .logout(preserveToken: true);
    } else if (choice == 2) {
      await ref
          .read(userViewModelProvider.notifier)
          .logout(preserveToken: false);
    }

    if (!mounted) return;
    AppRoutes.pushAndRemoveUntil(context, LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final userVm = ref.read(userViewModelProvider.notifier);

    final themeMode = ref.watch(themeModeProvider);
    final themeVm = ref.read(themeModeProvider.notifier);

    final isDark = themeMode == ThemeMode.dark;

    final bioAvailable = userState.biometricAvailable == true;
    final bioEnabled = userState.biometricEnabled == true;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        actions: [
          PopupMenuButton<_ProfileMenuAction>(
            icon: const Icon(Icons.settings, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (action) async {
              if (action == _ProfileMenuAction.editProfile) {
                AppRoutes.push(context, const EditProfilePage());
              } else if (action == _ProfileMenuAction.logout) {
                await _confirmLogout();
              } else if (action == _ProfileMenuAction.toggleDarkMode) {
                await themeVm.toggleDarkMode(!isDark);
              } else if (action == _ProfileMenuAction.toggleBiometric) {
                if (!bioAvailable) return;
                await userVm.setBiometricEnabled(!bioEnabled);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _ProfileMenuAction.toggleDarkMode,
                child: Row(
                  children: [
                    Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 18),
                    const SizedBox(width: 10),
                    Text(isDark ? "Dark mode: ON" : "Dark mode: OFF"),
                  ],
                ),
              ),

              if (bioAvailable)
                PopupMenuItem(
                  value: _ProfileMenuAction.toggleBiometric,
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        bioEnabled
                            ? "Fingerprint login: ON"
                            : "Fingerprint login: OFF",
                      ),
                    ],
                  ),
                ),

              const PopupMenuItem(
                value: _ProfileMenuAction.editProfile,
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 10),
                    Text("Edit profile"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _ProfileMenuAction.logout,
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Logout", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userState.status == UserStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : userState.userEntity == null
          ? const Center(child: Text("No user data"))
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(userViewModelProvider.notifier).getProfile();
                await ref.read(postViewModelProvider.notifier).loadMyPosts();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _ProfileHeader()),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  const SliverToBoxAdapter(child: _ProfileTabs()),
                  const SliverToBoxAdapter(child: Divider(height: 1)),
                  ProfilePostGrid(
                    posts: ref.watch(postViewModelProvider).myPosts,
                    loading: ref.watch(postViewModelProvider).myPostsLoading,
                    onTapPost: (post) => showPostDetailsModal(context, post),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            ),
    );
  }
}

enum _ProfileMenuAction { toggleDarkMode, toggleBiometric, editProfile, logout }

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  String? _resolveAvatarUrl(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }
    final fileName = avatar.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userVm = ref.read(userViewModelProvider.notifier);
    final followVm = ref.read(followViewModelProvider.notifier);

    final userState = ref.watch(userViewModelProvider);
    final user = userState.userEntity!;
    final avatarUrl = _resolveAvatarUrl(user.avatar);

    final posts = user.postCount ?? 0;
    final following = user.followingCount ?? 0;
    final followers = user.followerCount ?? 0;

    final myUserId = user.userId;

    Future<void> openFollowers() async {
      await followVm.loadMyFollowers();

      await showFollowListModal(
        context: context,
        mode: FollowListMode.followers,
        userId: null,
      );

      await userVm.getProfile();
    }

    Future<void> openFollowing() async {
      await followVm.loadMyFollowing();

      await showFollowListModal(
        context: context,
        mode: FollowListMode.following,
        userId: null,
      );

      await userVm.getProfile();
    }

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF58529),
                      Color(0xFFDD2A7B),
                      Color(0xFF8134AF),
                      Color(0xFF515BD4),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  padding: const EdgeInsets.all(2),
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
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(title: "Posts", value: posts.toString()),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: myUserId == null ? null : openFollowers,
                      child: _ProfileStat(
                        title: "Followers",
                        value: followers.toString(),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: myUserId == null ? null : openFollowing,
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
            "@${user.username}",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.fullName,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
            Text(
              user.bio!,
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
                child: OutlinedButton(
                  onPressed: () {
                    AppRoutes.push(context, const EditProfilePage());
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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
