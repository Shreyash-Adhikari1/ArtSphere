import 'dart:io';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// If you don't have it, add to pubspec:
// image_picker: ^1.0.7 (or latest)
import 'package:image_picker/image_picker.dart';

void showCreateChallengeModal({required BuildContext context}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreateChallengeSheet(),
  );
}

class _CreateChallengeSheet extends ConsumerStatefulWidget {
  const _CreateChallengeSheet();

  @override
  ConsumerState<_CreateChallengeSheet> createState() =>
      _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends ConsumerState<_CreateChallengeSheet> {
  static const _pink = Color(0xFFC974A6);

  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _endsAt;
  String? _imagePath;

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
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(
      () =>
          _endsAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() => _imagePath = x.path);
  }

  bool get _canSubmit =>
      _title.text.trim().isNotEmpty &&
      _desc.text.trim().isNotEmpty &&
      _endsAt != null &&
      _imagePath != null;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final vm = ref.read(challengeViewModelProvider.notifier);

    final created = await vm.createChallenge(
      CreateChallengeUsecaseParams(
        challengeTitle: _title.text.trim(),
        challengeDescription: _desc.text.trim(),
        challengeMedia: _imagePath!, // required in your domain
        endsAt: _endsAt!,
      ),
    );

    if (!mounted) return;

    if (created != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Challenge created ✅")));
    } else {
      final err =
          ref.read(challengeViewModelProvider).errorMessage ??
          "Failed to create challenge";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              Row(
                children: [
                  const Text(
                    "Create a Challenge",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text(
                "Title",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  hintText: 'e.g. "Car photography — composition challenge"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (_) => setState(() {}),
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
                  hintText: "Describe the rules, what to submit, tips, etc...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndsAt,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        _endsAt == null
                            ? "Ends at"
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text("Cover image"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              if (_imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (state.actionLoading || !_canSubmit)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pink,
                    disabledBackgroundColor: Colors.grey.shade300,
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
                          "Create Challenge",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
