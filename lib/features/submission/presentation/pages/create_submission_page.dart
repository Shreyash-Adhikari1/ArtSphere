import 'dart:io';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:artsphere/features/submission/presentation/viewmodels/submission_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // --- Picker (same style as your EditProfilePage) ---
  final ImagePicker _imagePicker = ImagePicker();

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

  // Permission helper
  Future<bool> _askUserforPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "To give permissions for this feature, please go to settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _clickFromCamera() async {
    final hasPermission = await _askUserforPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _mediaPath = photo.path; // ✅ this is what makes the UI show the image
        _mediaType = "image"; // optional, keeps consistent
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _mediaPath = image.path; // ✅ this is what makes the UI show the image
          _mediaType = "image"; // optional, keeps consistent
        });
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gallery permission not granted")),
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 240, 227, 234),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_enhance_rounded),
                title: const Text("Open Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _clickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.browse_gallery),
                title: const Text("Open Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  // --- end picker ---

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
            onTap: busy ? null : _pickMedia, // ✅ hooked here
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
