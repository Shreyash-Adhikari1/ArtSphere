import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/profile_post_grid.dart';
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
    });
  }

  String? _resolveChallengeMediaUrl(String? media) {
    if (media == null || media.trim().isEmpty) return null;
    if (media.startsWith('http://') || media.startsWith('https://'))
      return media;
    if (media.startsWith('/uploads/')) return '${ApiEndpoints.baseUrl}$media';

    final fileName = media.split('/').last;
    final base = ApiEndpoints.challengeImages;
    return '$base/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);
    final vm = ref.read(challengeViewModelProvider.notifier);

    final c = state.activeChallenge;

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
      body: state.detailsLoading && c == null
          ? const Center(child: CircularProgressIndicator())
          : c == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? "Challenge not found"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          vm.loadChallengeDetails(widget.challengeId),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  vm.loadChallengeDetails(widget.challengeId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  // cover
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

                  // Submit button placeholder
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Submit modal coming soon 👀"),
                        ),
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
                    child: const Text(
                      "Submit to this challenge",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Submissions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),

                  // ✅ ready to plug in later with real submission posts
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6ED),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      "Submissions feed will show here (we’ll connect it when submissions feature is done).",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Placeholder grid (no crash, already styled)
                  ProfilePostGrid(
                    posts: const [],
                    loading: false,
                    onTapPost: (_) {},
                  ),
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
