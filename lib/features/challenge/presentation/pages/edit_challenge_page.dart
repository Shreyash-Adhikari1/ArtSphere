import 'dart:io';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditChallengePage extends ConsumerStatefulWidget {
  final ChallengeEntity initial;
  const EditChallengePage({super.key, required this.initial});

  @override
  ConsumerState<EditChallengePage> createState() => _EditChallengePageState();
}

class _EditChallengePageState extends ConsumerState<EditChallengePage> {
  static const _pink = Color(0xFFC974A6);

  late final TextEditingController _title;
  late final TextEditingController _desc;

  DateTime? _endsAt;
  String? _newCoverPath;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial.challengeTitle ?? "");
    _desc = TextEditingController(
      text: widget.initial.challengeDescription ?? "",
    );
    _endsAt = widget.initial.endsAt;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickEndsAt() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (_endsAt ?? now).isBefore(now) ? now : (_endsAt ?? now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(
      () =>
          _endsAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
    );
  }

  Future<void> _pickNewCover() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() => _newCoverPath = x.path);
  }

  Future<void> _save() async {
    final id = widget.initial.challengeId;
    if (id == null || id.trim().isEmpty) return;

    // Only send fields that changed
    String? title;
    String? desc;
    DateTime? endsAt;

    if (_title.text.trim() != (widget.initial.challengeTitle ?? "")) {
      title = _title.text.trim();
    }

    if (_desc.text.trim() != (widget.initial.challengeDescription ?? "")) {
      desc = _desc.text.trim();
    }

    if (_endsAt != widget.initial.endsAt) {
      endsAt = _endsAt;
    }

    final vm = ref.read(challengeViewModelProvider.notifier);

    final updated = await vm.editChallenge(
      EditChallengeUsecaseParams(
        challengeId: id,
        challengeTitle: title,
        challengeDescription: desc,
        endsAt: endsAt,
      ),
    );

    if (!mounted) return;

    if (updated != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Challenge updated ✅")));
    } else {
      final err =
          ref.read(challengeViewModelProvider).errorMessage ??
          "Failed to update challenge";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }

    // NOTE: cover image edit is not wired because your backend edit doesn’t accept media.
    // When you add it, we’ll patch this page to upload media too.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: const Text(
          "Edit Challenge",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        children: [
          const Text("Title", style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          TextField(
            controller: _title,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _desc,
            minLines: 4,
            maxLines: 7,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickEndsAt,
            icon: const Icon(Icons.event_outlined),
            label: Text(
              _endsAt == null
                  ? "Pick end date"
                  : "${_endsAt!.year}/${_endsAt!.month.toString().padLeft(2, '0')}/${_endsAt!.day.toString().padLeft(2, '0')}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 14),

          // Optional: show cover change UI (not wired)
          OutlinedButton.icon(
            onPressed: _pickNewCover,
            icon: const Icon(Icons.image_outlined),
            label: const Text("Change cover (not saved yet)"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          if (_newCoverPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(File(_newCoverPath!), fit: BoxFit.cover),
              ),
            ),
          ],

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: state.actionLoading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: state.actionLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Save changes",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
