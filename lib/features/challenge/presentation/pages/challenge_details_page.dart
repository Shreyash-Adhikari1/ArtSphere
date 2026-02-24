import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/post_details_modal.dart';
import 'package:artsphere/features/post/presentation/widgets/profile_post_grid.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:artsphere/features/submission/presentation/viewmodels/submission_view_model.dart';
import 'package:artsphere/features/submission/presentation/widgets/show_my_submission.dart';
import 'package:artsphere/features/submission/presentation/widgets/submit_to_challenge_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChallengeDetailsPage extends ConsumerStatefulWidget {
  final String challengeId;
  const ChallengeDetailsPage({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailsPage> createState() =>
      _ChallengeDetailsPageState();
}

class _ChallengeDetailsPageState extends ConsumerState<ChallengeDetailsPage> {
  static const _pink = Color(0xFFC974A6);

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(challengeViewModelProvider.notifier)
          .loadChallengeDetails(widget.challengeId);

      await ref
          .read(submissionViewModelProvider.notifier)
          .loadSubmissions(widget.challengeId);
    });
  }

  String? _resolveChallengeMediaUrl(String? media) {
    if (media == null || media.trim().isEmpty) return null;
    if (media.startsWith('http://') || media.startsWith('https://')) {
      return media;
    }
    if (media.startsWith('/uploads/')) return '${ApiEndpoints.baseUrl}$media';

    final fileName = media.split('/').last;
    return '${ApiEndpoints.challengeImages}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);
    final vm = ref.read(challengeViewModelProvider.notifier);

    final submissionState = ref.watch(submissionViewModelProvider);
    final submissionVm = ref.read(submissionViewModelProvider.notifier);

    final myUserId = ref.watch(userViewModelProvider).userEntity?.userId;

    final c = state.activeChallenge;

    final submissionsLoading =
        submissionState.status == SubmissionStatus.loading;

    final submissionPosts = submissionState.submissions
        .map((s) => s.submittedPost)
        .toList();

    // ✅ find my submission (if any)
    final mySubmission = (myUserId == null)
        ? null
        : submissionState.submissions
              .cast()
              .where((s) => s.submitterId == myUserId)
              .isEmpty
        ? null
        : submissionState.submissions.firstWhere(
            (s) => s.submitterId == myUserId,
          );

    final hasSubmitted = mySubmission != null;

    if (state.detailsLoading && c == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (c == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.2,
          title: const Text(
            "Challenge",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? "Challenge not found"),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await vm.loadChallengeDetails(widget.challengeId);
                    await submissionVm.loadSubmissions(widget.challengeId);
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: const Text(
          "Challenge",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.loadChallengeDetails(widget.challengeId);
          await submissionVm.loadSubmissions(widget.challengeId);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_resolveChallengeMediaUrl(c.challengeMedia) != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          _resolveChallengeMediaUrl(c.challengeMedia)!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image, size: 44),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),

                  Text(
                    c.challengeTitle ?? "Untitled challenge",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "@${c.challengerId?.username ?? "user"}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.event_outlined,
                        text: c.endsAt == null
                            ? "No deadline"
                            : "Ends on ${DateFormat.yMMMd().format(c.endsAt!)}",
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: Icons.grid_on_rounded,
                        text: "${c.submissionCount ?? 0} submissions",
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (c.challengeDescription != null &&
                      c.challengeDescription!.trim().isNotEmpty)
                    Text(
                      c.challengeDescription!,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ✅ Submit button (you can disable it if already submitted)
                  ElevatedButton(
                    onPressed: hasSubmitted
                        ? null
                        : () {
                            showSubmitToChallengeModal(
                              context: context,
                              challengeId: widget.challengeId,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(
                      hasSubmitted
                          ? "You already submitted ✅"
                          : "Submit to this challenge",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ✅ Submitted flag + View My Submission button
                  if (hasSubmitted) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6ED),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Submitted",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            showMySubmissionSheet(
                              context: context,
                              challengeId: widget.challengeId,
                            );
                          },
                          child: const Text(
                            "View my submission",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  const Text(
                    "Submissions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),

                  if (!submissionsLoading &&
                      submissionState.status == SubmissionStatus.failure)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6ED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submissionState.errorMessage ??
                                "Failed to load submissions",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pink,
                              elevation: 0,
                            ),
                            onPressed: () => submissionVm.loadSubmissions(
                              widget.challengeId,
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),

                  if (!submissionsLoading &&
                      submissionState.status == SubmissionStatus.success &&
                      submissionPosts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6ED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        "No submissions yet. Be the first!",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),

                  if (!submissionsLoading &&
                      submissionState.status == SubmissionStatus.success &&
                      submissionPosts.isNotEmpty)
                    const SizedBox(height: 6),
                ]),
              ),
            ),

            if (submissionsLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            if (!submissionsLoading &&
                submissionState.status == SubmissionStatus.success &&
                submissionPosts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                sliver: ProfilePostGrid(
                  posts: submissionPosts,
                  loading: false,
                  onTapPost: (post) => showPostDetailsModal(context, post),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
