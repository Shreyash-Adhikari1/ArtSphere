import 'dart:io';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:artsphere/features/submission/presentation/viewmodels/submission_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateSubmissionPage extends ConsumerStatefulWidget {
  final String challengeId;
  const CreateSubmissionPage({super.key, required this.challengeId});

  @override
  ConsumerState<CreateSubmissionPage> createState() =>
      _CreateSubmissionPageState();
}

class _CreateSubmissionPageState extends ConsumerState<CreateSubmissionPage> {
  static const _pink = Color(0xFFC974A6);

  final _captionCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String _visibility = "public";
  String _mediaType = "image";

  String? _mediaPath;

  @override
  void dispose() {
    _captionCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    final vm = ref.read(submissionViewModelProvider.notifier);
    final state = ref.read(submissionViewModelProvider);

    if (state.actionStatus == SubmissionStatus.loading) return;

    final mediaPath = _mediaPath;
    if (mediaPath == null || mediaPath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick an image first.")),
      );
      return;
    }

    final post = PostEntity(
      caption: _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
      tags: _parseTags(_tagsCtrl.text),
      visibility: _visibility,
      mediaType: _mediaType,
      // media is NOT required here because repo uses mediaPath for upload
      // author etc can be null in create request
    );

    final created = await vm.createNewPostAndSubmit(
      challengeId: widget.challengeId,
      post: post,
      mediaPath: mediaPath,
    );

    if (!mounted) return;

    if (created != null) {
      vm.clearActionState();
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Submitted ✅")));
    } else {
      final msg =
          ref.read(submissionViewModelProvider).actionErrorMessage ??
          "Submit failed";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(submissionViewModelProvider);
    final busy =
        submissionState.actionStatus == SubmissionStatus.loading &&
        submissionState.action == SubmissionAction.createAndSubmit;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create submission",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        elevation: 0.2,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          GestureDetector(
            onTap: () async {
              // TODO: connect your picker here (return a local file path)
              // For now, just show a snackbar.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Hook your media picker here 👀")),
              );
            },
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6ED),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: _mediaPath == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40),
                          SizedBox(height: 10),
                          Text("Tap to pick media"),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(File(_mediaPath!), fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _captionCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Caption…",
              filled: true,
              fillColor: const Color(0xFFFFF6ED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _tagsCtrl,
            decoration: InputDecoration(
              hintText: "Tags (comma separated)",
              filled: true,
              fillColor: const Color(0xFFFFF6ED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _visibility,
                  items: const [
                    DropdownMenuItem(value: "public", child: Text("Public")),
                    DropdownMenuItem(value: "private", child: Text("Private")),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() => _visibility = v ?? "public"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFF6ED),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _mediaType,
                  items: const [
                    DropdownMenuItem(value: "image", child: Text("Image")),
                    DropdownMenuItem(value: "video", child: Text("Video")),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() => _mediaType = v ?? "image"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFF6ED),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: busy ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pink,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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
                    "Submit",
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
