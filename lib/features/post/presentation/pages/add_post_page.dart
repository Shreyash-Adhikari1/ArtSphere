import 'dart:io';
import 'package:artsphere/features/post/presentation/pages/create_post_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final ImagePicker _picker = ImagePicker();

  List<XFile> _recent = [];
  XFile? _selected;
  bool _loading = false;

  // A soft Artsphere pink (same vibe as your UI)
  static const _pink = Color(0xFFC974A6);

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    setState(() => _loading = true);
    try {
      // You can’t truly list the full gallery with image_picker,
      // but you can let users pick multiple as “recents”.
      // UX: “Choose from Gallery” opens multi-pick, we show the picks as grid.
      // This keeps code simple and works reliably.

      // Start empty; user can pick recents.
      _recent = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _chooseFromGallery() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 90);
      if (files.isEmpty) return;

      setState(() {
        _recent = files;
        _selected ??= files.first;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _chooseSingle() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file == null) return;

      setState(() {
        // put it at top like “recent”
        _recent = [file, ..._recent.where((x) => x.path != file.path)];
        _selected = file;
      });
    } catch (_) {}
  }

  void _goNext() {
    final selected = _selected;
    if (selected == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePostPage(mediaPath: selected.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canNext = _selected != null;

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
        actions: [
          TextButton(
            onPressed: canNext ? _goNext : null,
            child: Text(
              "Next",
              style: TextStyle(
                color: canNext ? _pink : Colors.grey.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 8),

                  // Big preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          color: Colors.grey.shade100,
                          child: _selected == null
                              ? _EmptyPreview(onPick: _chooseSingle)
                              : Image.file(
                                  File(_selected!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // "Choose from Gallery" row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          "Choose from Gallery",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _chooseFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _recent.isEmpty
                          ? _EmptyGrid(onPick: _chooseFromGallery)
                          : GridView.builder(
                              itemCount: _recent.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                              itemBuilder: (context, i) {
                                final x = _recent[i];
                                final isSelected = _selected?.path == x.path;

                                return GestureDetector(
                                  onTap: () => setState(() => _selected = x),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(x.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: _pink,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  final VoidCallback onPick;
  const _EmptyPreview({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text("Pick an image"),
      ),
    );
  }
}

class _EmptyGrid extends StatelessWidget {
  final VoidCallback onPick;
  const _EmptyGrid({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPick,
        child: const Text("Select images to show here"),
      ),
    );
  }
}
