import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/profile_post_grid.dart';
import 'package:artsphere/features/submission/presentation/pages/create_submission_page.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:artsphere/features/submission/presentation/viewmodels/submission_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showSubmitToChallengeModal({
  required BuildContext context,
  required String challengeId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SubmitToChallengeSheet(challengeId: challengeId),
  );
}

class _SubmitToChallengeSheet extends ConsumerStatefulWidget {
  final String challengeId;
  const _SubmitToChallengeSheet({required this.challengeId});

  @override
  ConsumerState<_SubmitToChallengeSheet> createState() =>
      _SubmitToChallengeSheetState();
}

class _SubmitToChallengeSheetState
    extends ConsumerState<_SubmitToChallengeSheet> {
  static const _pink = Color(0xFFC974A6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(postViewModelProvider.notifier).loadMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postViewModelProvider);

    final submissionState = ref.watch(submissionViewModelProvider);
    final submissionVm = ref.read(submissionViewModelProvider.notifier);

    final busy =
        submissionState.actionStatus == SubmissionStatus.loading &&
        submissionState.action == SubmissionAction.submitExisting;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, controller) {
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
                    const Text(
                      "Submit to challenge",
                      style: TextStyle(
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

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Pick one of your existing posts to submit.",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        elevation: 0,
                      ),
                      onPressed: busy
                          ? null
                          : () async {
                              Navigator.pop(context); // close picker sheet
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateSubmissionPage(
                                    challengeId: widget.challengeId,
                                  ),
                                ),
                              );
                            },
                      child: const Text(
                        "Create new post",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (busy)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: postState.myPostsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : postState.myPosts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "You don’t have any posts to submit yet.",
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Create-post submission coming next 👀",
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Create a new post"),
                              ),
                            ],
                          ),
                        ),
                      )
                    : CustomScrollView(
                        controller: controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 24),
                            sliver: ProfilePostGrid(
                              posts: postState.myPosts,
                              loading: false,
                              onTapPost: (post) async {
                                if (busy) return;

                                final postId = post.postId;
                                if (postId == null || postId.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Invalid post id"),
                                    ),
                                  );
                                  return;
                                }

                                final created = await submissionVm
                                    .submitExistingPost(
                                      challengeId: widget.challengeId,
                                      postId: postId,
                                    );

                                if (!mounted) return;

                                if (created != null) {
                                  submissionVm.clearActionState();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Submitted ✅"),
                                    ),
                                  );
                                } else {
                                  final msg =
                                      ref
                                          .read(submissionViewModelProvider)
                                          .actionErrorMessage ??
                                      "Submit failed";
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(msg)));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
