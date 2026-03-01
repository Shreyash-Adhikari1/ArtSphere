import 'dart:io';

import 'package:artsphere/features/post/presentation/pages/create_post_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  CameraController? _camera;
  List<CameraDescription> _cameras = [];

  XFile? _selected; // captured or picked
  bool _loadingCamera = true;
  bool _capturing = false;

  static const _pink = Color(0xFFC974A6);

  bool get _canNext => _selected != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _camera;
    if (cam == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cam.dispose();
      _camera = null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() => _loadingCamera = true);

    try {
      debugPrint("GETTING CAMERAS...");
      _cameras = await availableCameras();
      debugPrint("CAMERAS FOUND: ${_cameras.length}");

      if (_cameras.isEmpty) {
        debugPrint("NO CAMERAS FOUND");
        setState(() => _loadingCamera = false);
        return;
      }

      final back = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      debugPrint("INITIALIZING CAMERA...");
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      debugPrint("CAMERA INITIALIZED");

      await _camera?.dispose();
      _camera = controller;

      if (!mounted) return;
      setState(() => _loadingCamera = false);
    } catch (e) {
      debugPrint("CAMERA ERROR: $e");
      if (!mounted) return;
      setState(() => _loadingCamera = false);
    }
  }

  Future<void> _capture() async {
    final cam = _camera;
    if (cam == null) return;
    if (!cam.value.isInitialized) return;
    if (_capturing) return;

    setState(() => _capturing = true);
    try {
      final file = await cam.takePicture();
      if (!mounted) return;
      setState(() {
        _selected = file;
      });
    } catch (_) {
      // ignore
    } finally {
      if (!mounted) return;
      setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (file == null) return;

      if (!mounted) return;
      setState(() {
        _selected = file;
      });
    } catch (_) {
      // ignore
    }
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

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;

    final current = _camera?.description;
    if (current == null) return;

    final next = _cameras.firstWhere(
      (c) => c.lensDirection != current.lensDirection,
      orElse: () => _cameras.first,
    );

    setState(() => _loadingCamera = true);
    try {
      final controller = CameraController(
        next,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      await _camera?.dispose();
      _camera = controller;

      if (!mounted) return;
      setState(() => _loadingCamera = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCamera = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cam = _camera;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _canNext ? _goNext : null,
            child: Text(
              "Next",
              style: TextStyle(
                color: _canNext ? _pink : Colors.white38,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main preview area (camera or selected image)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    color: Colors.black,
                    child: _selected != null
                        ? Image.file(
                            File(_selected!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : _loadingCamera
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : (cam == null || !cam.value.isInitialized)
                        ? _CameraUnavailable(onPickGallery: _pickFromGallery)
                        : CameraPreview(cam),
                  ),
                ),
              ),
            ),

            // Bottom controls (Instagram vibe)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery button
                  _BottomIconButton(
                    label: "Gallery",
                    icon: Icons.photo_library_outlined,
                    onTap: _pickFromGallery,
                  ),

                  const Spacer(),

                  // Shutter
                  GestureDetector(
                    onTap: _selected != null ? null : _capture,
                    child: Opacity(
                      opacity: (_selected != null) ? 0.35 : 1,
                      child: _ShutterButton(busy: _capturing, accent: _pink),
                    ),
                  ),

                  const Spacer(),

                  // Flip camera (only if no selection)
                  _BottomIconButton(
                    label: "Flip",
                    icon: Icons.cameraswitch_outlined,
                    onTap: _selected != null ? null : _flipCamera,
                    disabled: _selected != null || _cameras.length < 2,
                  ),
                ],
              ),
            ),

            // Small hint row when selected
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _selected = null),
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      label: const Text(
                        "Retake / Choose another",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.onPickGallery});
  final VoidCallback onPickGallery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 42,
              color: Colors.white70,
            ),
            const SizedBox(height: 10),
            const Text(
              "Camera unavailable",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "You can still choose a photo from your gallery.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onPickGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text("Open Gallery"),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomIconButton extends StatelessWidget {
  const _BottomIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.busy, required this.accent});
  final bool busy;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: busy ? 26 : 58,
          height: busy ? 26 : 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: busy ? Colors.white : accent,
          ),
        ),
      ),
    );
  }
}
