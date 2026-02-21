import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/features/auth/presentation/pages/user_profile_page.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/presentation/viewmodels/follow_viewmodel.dart';

enum FollowListMode { followers, following }

/// If [userId] is null => loads MY followers/following
/// If [userId] is provided => loads THAT user's followers/following
Future<void> showFollowListModal({
  required BuildContext context,
  required FollowListMode mode,
  String? userId,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FollowListSheet(mode: mode, userId: userId),
  );
}

class _FollowListSheet extends ConsumerStatefulWidget {
  const _FollowListSheet({required this.mode, this.userId});

  final FollowListMode mode;
  final String? userId;

  @override
  ConsumerState<_FollowListSheet> createState() => _FollowListSheetState();
}

class _FollowListSheetState extends ConsumerState<_FollowListSheet> {
  static const _bgCard = Color(0xFFFFF6ED);

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final vm = ref.read(followViewModelProvider.notifier);

    // Load correct list
    if (widget.userId == null) {
      if (widget.mode == FollowListMode.followers) {
        await vm.loadMyFollowers();
      } else {
        await vm.loadMyFollowing();
      }
    } else {
      if (widget.mode == FollowListMode.followers) {
        await vm.loadUserFollowers(widget.userId!);
      } else {
        await vm.loadUserFollowing(widget.userId!);
      }
    }
  }

  void _goToProfile(BuildContext context, String userId) {
    // Optional: close modal before navigating to avoid stacked UIs
    Navigator.pop(context);
    AppRoutes.push(context, UserProfilePage(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followViewModelProvider);
    final vm = ref.read(followViewModelProvider.notifier);

    final myUserId = ref.watch(userViewModelProvider).userEntity?.userId;
    final bool isMyList = widget.userId == null;

    final bool loading = isMyList
        ? (widget.mode == FollowListMode.followers
              ? state.loadingMyFollowers
              : state.loadingMyFollowing)
        : (widget.mode == FollowListMode.followers
              ? state.loadingUserFollowers
              : state.loadingUserFollowing);

    final List<FollowEntity> items = isMyList
        ? (widget.mode == FollowListMode.followers
              ? state.myFollowers
              : state.myFollowing)
        : (widget.mode == FollowListMode.followers
              ? state.userFollowers
              : state.userFollowing);

    final String title = widget.mode == FollowListMode.followers
        ? "Followers"
        : "Following";

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? const Center(child: Text("No users found"))
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final row = items[i];

                          // followers list => show follower
                          // following list => show following
                          final displayUser =
                              widget.mode == FollowListMode.followers
                              ? row.follower
                              : row.following;

                          final targetUserId = displayUser?.userId;
                          final username = displayUser?.username ?? "user";

                          final isMe =
                              myUserId != null &&
                              targetUserId != null &&
                              myUserId == targetUserId;

                          final currentlyFollowing = row.isFollowedByMe == true;

                          final busy =
                              targetUserId != null &&
                              (state.followBusy[targetUserId] == true);

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: targetUserId == null
                                ? null
                                : () => _goToProfile(context, targetUserId),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _bgCard,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: targetUserId == null
                                        ? null
                                        : () => _goToProfile(
                                            context,
                                            targetUserId,
                                          ),
                                    child: const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Color(0xFFEFEFEF),
                                      child: Icon(Icons.person, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "@$username",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),

                                  if (!isMe && targetUserId != null)
                                    ElevatedButton(
                                      onPressed: busy
                                          ? null
                                          : () async {
                                              await vm.toggleFollow(
                                                targetUserId: targetUserId,
                                                currentlyFollowing:
                                                    currentlyFollowing,
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentlyFollowing
                                            ? Colors.grey.shade300
                                            : Colors.black,
                                        foregroundColor: currentlyFollowing
                                            ? Colors.black
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (busy)
                                            const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else
                                            Icon(
                                              currentlyFollowing
                                                  ? Icons.check
                                                  : Icons.person_add,
                                              size: 16,
                                              color: currentlyFollowing
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          const SizedBox(width: 8),
                                          Text(
                                            currentlyFollowing
                                                ? "Following"
                                                : "Follow",
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
