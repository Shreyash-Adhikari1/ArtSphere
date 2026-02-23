import 'package:artsphere/features/post/presentation/widgets/post_details_modal.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:artsphere/features/submission/presentation/viewmodels/submission_view_model.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showMySubmissionSheet({
  required BuildContext context,
  required String challengeId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MySubmissionSheet(challengeId: challengeId),
  );
}

class _MySubmissionSheet extends ConsumerWidget {
  final String challengeId;
  const _MySubmissionSheet({required this.challengeId});

  static const _pink = Color(0xFFC974A6);

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete submission?"),
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
    return ok == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionState = ref.watch(submissionViewModelProvider);
    final submissionVm = ref.read(submissionViewModelProvider.notifier);

    final myUserId = ref.watch(userViewModelProvider).userEntity?.userId;

    final mySubmission = (myUserId == null)
        ? null
        : submissionState.submissions
              .cast()
              .where((s) => s.submitterId == myUserId)
              .toList()
              .isEmpty
        ? null
        : submissionState.submissions.firstWhere(
            (s) => s.submitterId == myUserId,
          );

    final busy =
        submissionState.actionStatus == SubmissionStatus.loading &&
        submissionState.action == SubmissionAction.delete;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                      "My submission",
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
              const SizedBox(height: 6),

              Expanded(
                child: mySubmission == null
                    ? const Center(child: Text("You haven’t submitted yet."))
                    : ListView(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                        children: [
                          // Reuse your post details modal on tap
                          InkWell(
                            onTap: () => showPostDetailsModal(
                              context,
                              mySubmission.submittedPost,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF6ED),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.image_outlined),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      mySubmission.submittedPost.caption
                                                  ?.trim()
                                                  .isEmpty ==
                                              false
                                          ? mySubmission.submittedPost.caption!
                                          : "View submission",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: busy
                                ? null
                                : () async {
                                    final id = mySubmission.submissionId;
                                    if (id == null || id.trim().isEmpty) return;

                                    final ok = await _confirmDelete(context);
                                    if (!ok) return;

                                    final deleted = await submissionVm
                                        .deleteSubmission(id);
                                    if (!context.mounted) return;

                                    if (deleted) {
                                      submissionVm.clearActionState();
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Submission deleted"),
                                        ),
                                      );
                                    } else {
                                      final msg =
                                          ref
                                              .read(submissionViewModelProvider)
                                              .actionErrorMessage ??
                                          "Delete failed";
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    }
                                  },
                            child: busy
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Delete submission",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
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
