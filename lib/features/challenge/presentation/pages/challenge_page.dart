import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:artsphere/features/challenge/presentation/widgets/challenge_create_modal.dart';
import 'package:artsphere/features/challenge/presentation/widgets/challenge_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  int _tab = 0; // 0 = Discover, 1 = My Challenges

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = ref.read(challengeViewModelProvider.notifier);
      await vm.loadDiscoverChallenges();
      await vm.loadMyChallenges(); // preload so switching is instant
    });
  }

  Future<void> _openCreateModal() async {
    showCreateChallengeModal(context: context);
    final vm = ref.read(challengeViewModelProvider.notifier);
    await vm.loadDiscoverChallenges();
    await vm.loadMyChallenges();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UnderlineTab(
              label: "Discover",
              selected: _tab == 0,
              onTap: () => setState(() => _tab = 0),
            ),
            const SizedBox(width: 22),
            _UnderlineTab(
              label: "My Challenges",
              selected: _tab == 1,
              onTap: () => setState(() => _tab = 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: state.actionLoading ? null : _openCreateModal,
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: "Create challenge",
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [_DiscoverChallengesTab(), _MyChallengesTab()],
      ),
    );
  }
}

class _DiscoverChallengesTab extends ConsumerWidget {
  const _DiscoverChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeViewModelProvider);
    final vm = ref.read(challengeViewModelProvider.notifier);

    if (state.discoverLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.discoverChallenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => vm.loadDiscoverChallenges(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => vm.loadDiscoverChallenges(),
      child: ChallengeListSection(
        showSubmitButton: true,
        challenges: state.discoverChallenges,
        emptyText: "No challenges yet.",
        showOwnerControls: false,
      ),
    );
  }
}

class _MyChallengesTab extends ConsumerWidget {
  const _MyChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeViewModelProvider);
    final vm = ref.read(challengeViewModelProvider.notifier);

    if (state.myChallengesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.myChallenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => vm.loadMyChallenges(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => vm.loadMyChallenges(),
      child: ChallengeListSection(
        showSubmitButton: false,
        challenges: state.myChallenges,
        emptyText: "You haven't created any challenges yet.",
        showOwnerControls: true, // show edit/delete
      ),
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  static const _pink = Color(0xFFC974A6);

  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnderlineTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 18,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              color: selected ? _pink : Colors.grey.shade600,
            ),
            child: Text(label),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2,
            width: selected ? 44 : 0,
            decoration: BoxDecoration(
              color: _pink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
