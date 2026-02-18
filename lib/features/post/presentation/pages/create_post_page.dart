import 'dart:io';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  final String mediaPath;
  const CreatePostPage({super.key, required this.mediaPath});

  @override
  ConsumerState<CreatePostPage> createState() => _NewPostDetailsScreenState();
}

class _NewPostDetailsScreenState extends ConsumerState<CreatePostPage> {
  static const _pink = Color(0xFFC974A6);

  final _captionCtrl = TextEditingController();
  final List<String> _tags = [];

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = ref.read(postViewModelProvider.notifier);

    final created = await vm.createPost(
      mediaPath: widget.mediaPath,
      mediaType: "image",
      caption: _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
      tags: _tags.isEmpty ? null : _tags,
    );

    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Post created ✅")));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final err = ref.read(postViewModelProvider).errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postViewModelProvider);

    final loading = state.actionLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Image.file(
                      File(widget.mediaPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _captionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write anything you want to share :)",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _pink),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TagInput(
                tags: _tags,
                onChanged: (newTags) => setState(() {
                  _tags
                    ..clear()
                    ..addAll(newTags);
                }),
              ),
            ),

            const Spacer(),

            // Create button
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: 160,
                height: 44,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pink,
                    disabledBackgroundColor: _pink.withOpacity(.6),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Create Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagInput({super.key, required this.tags, required this.onChanged});

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  static const _pink = Color(0xFFC974A6);
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;

    // basic cleanup: remove leading '#'
    final cleaned = t.startsWith("#") ? t.substring(1) : t;
    if (cleaned.isEmpty) return;

    final next = [...widget.tags];
    if (!next.contains(cleaned)) next.add(cleaned);

    widget.onChanged(next);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tags",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.tags.map(
              (t) => Chip(
                label: Text("#$t"),
                deleteIconColor: _pink,
                onDeleted: () {
                  final next = [...widget.tags]..remove(t);
                  widget.onChanged(next);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          onSubmitted: _addTag,
          decoration: InputDecoration(
            hintText: "Add tag and press Enter (e.g. #art)",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: IconButton(
              onPressed: () => _addTag(_ctrl.text),
              icon: const Icon(Icons.add, color: _pink),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _pink),
            ),
          ),
        ),
      ],
    );
  }
}
