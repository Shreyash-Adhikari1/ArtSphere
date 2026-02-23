import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/presentation/widgets/challenge_card.dart';
import 'package:flutter/material.dart';

class ChallengeListSection extends StatelessWidget {
  final List<ChallengeEntity> challenges;
  final String emptyText;

  /// Shows edit/delete menu on the card (for My Challenges tab)
  final bool showOwnerControls;

  /// Whether we should show submit button (Discover tab)
  /// For closed challenges we force false anyway.
  final bool showSubmitButton;

  const ChallengeListSection({
    super.key,
    required this.challenges,
    required this.emptyText,
    required this.showOwnerControls,
    required this.showSubmitButton,
  });

  bool _isOpen(ChallengeEntity c) {
    final endsAt = c.endsAt;
    if (endsAt == null) return true;
    return endsAt.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      // Important: keep it scrollable so RefreshIndicator can pull
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              emptyText,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    final open = challenges.where(_isOpen).toList();
    final closed = challenges.where((c) => !_isOpen(c)).toList();

    Widget buildCard(ChallengeEntity c, {required bool isOpen}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ChallengeCard(
              challenge: c,
              showOwnerControls: showOwnerControls,
              showSubmitButton: isOpen ? showSubmitButton : false,
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionHeader(
          title: "Open challenges",
          subtitle: "Join before the deadline.",
          count: open.length,
        ),
        const SizedBox(height: 10),

        if (open.isEmpty)
          const _EmptyBox(text: "Nothing here yet.")
        else
          ...open.map((c) => buildCard(c, isOpen: true)),

        const SizedBox(height: 14),

        _SectionHeader(
          title: "Closed challenges",
          subtitle: "Explore completed prompts.",
          count: closed.length,
        ),
        const SizedBox(height: 10),

        if (closed.isEmpty)
          const _EmptyBox(text: "Nothing here yet.")
        else
          ...closed.map((c) => buildCard(c, isOpen: false)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          "$count items",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
