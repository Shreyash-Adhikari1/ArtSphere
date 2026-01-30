import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
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

    Future.microtask(() {
      ref.read(userViewModelProvider.notifier).getProfile();
      // later:
      // ref.read(postViewModelProvider.notifier).getMyPosts();
    });
  }

  String? _avatarToUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final s = raw.trim();

    // If it's a local file scheme, it's NOT a network image
    if (s.startsWith('file://')) return null;

    // Already a full URL
    if (s.startsWith('http://') || s.startsWith('https://')) return s;

    // Filename or relative path -> make it full
    final fileName = s.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    // final postState = ref.watch(postViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: navigate to settings
            },
          ),
        ],
      ),
      body: userState.status == UserStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : userState.userEntity == null
          ? const Center(child: Text("No user data"))
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(userViewModelProvider.notifier).getProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    /// PROFILE HEADER
                    _ProfileHeader(),

                    const SizedBox(height: 16),
                    const Divider(),

                    /// TABS (icons row like your design)
                    _ProfileTabs(),

                    const Divider(),

                    /// POSTS GRID
                    _PostsGrid(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userViewModelProvider).userEntity!;

    final avatar = user.avatar;
    final String? avatarUrl = (avatar == null || avatar.trim().isEmpty)
        ? null
        : (avatar.startsWith('http://') || avatar.startsWith('https://'))
        ? avatar
        : '${ApiEndpoints.profileImages}/${avatar.split('/').last}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),

              const SizedBox(width: 24),

              Text(
                "@${user.username}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(
                      title: "posts",
                      value: user.followerCount.toString(),
                    ),
                    _ProfileStat(
                      title: "following",
                      value: user.followingCount.toString(),
                    ),
                    _ProfileStat(
                      title: "followers",
                      value: user.postCount.toString(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          TextButton(
            onPressed: () {
              AppRoutes.push(context, const EditProfilePage());
            },
            child: const Text("Edit Profile"),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.grid_view_rounded),
          Icon(Icons.favorite_border),
          Icon(Icons.bookmark_border),
        ],
      ),
    );
  }
}

class _PostsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postViewModelProvider);

    if (postState.status == PostStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }

    final posts = postState.posts;

    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text("No posts yet"),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Image.network(post.media!, fit: BoxFit.cover);
      },
    );
  }
}
