import 'dart:async';
import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/presentation/pages/challenge_details_page.dart';
import 'package:artsphere/features/challenge/presentation/pages/edit_challenge_page.dart';
import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChallengeCard extends ConsumerStatefulWidget {
  final ChallengeEntity challenge;
  final bool showSubmitButton;
  final bool showOwnerControls;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.showSubmitButton,
    required this.showOwnerControls,
  });

  @override
  ConsumerState<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends ConsumerState<ChallengeCard> {
  static const _pink = Color(0xFFC974A6);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // tick countdown every second (lightweight for a few cards)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _resolveChallengeMediaUrl(String? media) {
    if (media == null || media.trim().isEmpty) return null;
    if (media.startsWith('http://') || media.startsWith('https://'))
      return media;
    if (media.startsWith('/uploads/')) return '${ApiEndpoints.baseUrl}$media';

    final fileName = media.split('/').last;

    // ✅ If you have a dedicated endpoint, use it
    // If not, adjust to your backend route.
    // Common: ApiEndpoints.challengeImages
    final base = ApiEndpoints.challengeImages;
    return '$base/$fileName';
  }

  String _countdownText(DateTime? endsAt) {
    if (endsAt == null) return "No deadline";
    final diff = endsAt.difference(DateTime.now());
    if (diff.isNegative) return "Ended";

    final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;

    if (d > 0) return "$d d $h h left";
    if (diff.inHours > 0) return "${diff.inHours} h $m m left";
    if (diff.inMinutes > 0) return "${diff.inMinutes} m $s s left";
    return "$s s left";
  }

  bool get _isOpen {
    final endsAt = widget.challenge.endsAt;
    return endsAt == null ? true : endsAt.isAfter(DateTime.now());
  }

  void _goDetails() {
    final id = widget.challenge.challengeId;
    if (id == null) return;
    AppRoutes.push(context, ChallengeDetailsPage(challengeId: id));
  }

  Future<void> _confirmDelete() async {
    final id = widget.challenge.challengeId;
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete challenge"),
        content: const Text("Are you sure you want to delete this challenge?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final vm = ref.read(challengeViewModelProvider.notifier);
    await vm.deleteChallenge(id);
  }

  void _edit() {
    AppRoutes.push(context, EditChallengePage(initial: widget.challenge));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final cover = _resolveChallengeMediaUrl(c.challengeMedia);
    final username = c.challengerId?.username ?? "user";

    final state = ref.watch(challengeViewModelProvider);
    final id = c.challengeId ?? "";
    final busy = id.isNotEmpty && (state.busyById[id] == true);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          if (cover != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  ),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 170,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image, size: 44)),
              ),
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  c.challengeTitle ?? "Untitled challenge",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (widget.showOwnerControls)
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == "edit") _edit();
                    if (v == "delete") _confirmDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(value: "delete", child: Text("Delete")),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "@$username",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _Pill(
                icon: Icons.timer_outlined,
                text: _countdownText(c.endsAt),
                color: _isOpen ? _pink : Colors.grey,
              ),
              const SizedBox(width: 10),
              _Pill(
                icon: Icons.grid_on_rounded,
                text: "${c.submissionCount ?? 0} submissions",
                color: Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goDetails,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "View challenge",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              if (widget.showSubmitButton && _isOpen) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy
                        ? null
                        : () {
                            // Placeholder until submissions feature is ready
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Submit flow coming soon 👀"),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Submit",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Pill({required this.icon, required this.text, required this.color});

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
          Icon(icon, size: 16, color: color),
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
