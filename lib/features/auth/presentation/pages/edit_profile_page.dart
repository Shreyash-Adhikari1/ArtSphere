import 'dart:io';

import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/utils/snackbar_utils.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = ref.read(userViewModelProvider).userEntity;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _usernameController.text = user.username;
        _phoneController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // image haalney code yeta baata
  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  // permission dey bhanney function

  Future<bool> _askUserforPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

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
        title: Text("Permission Required"),
        content: Text(
          "To give permissions for this featuire, Please go to settings",
        ),
        actions: [
          TextButton(onPressed: () {}, child: Text("Cancel")),
          TextButton(onPressed: () {}, child: Text("Open Settings")),
        ],
      ),
    );
  }

  // code for camera
  Future<void> _clickFromCamera() async {
    final hasPermission = await _askUserforPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
    }

    // upload image to server
    if (photo == null) {
      return;
    }
    await ref
        .read(userViewModelProvider.notifier)
        .editProfile(avatar: photo.path);
  }

  // code for gallery
  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );

        if (images.isNotEmpty) {
          setState(() {
            _selectedMedia
              ..clear()
              ..addAll(images);
          });
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.add(image);
          });
        }

        // upload image to server
        if (image == null) {
          return;
        }
        await ref
            .read(userViewModelProvider.notifier)
            .editProfile(avatar: image.path);
      }
    } catch (e) {
      debugPrint('Gallery Error $e');

      if (mounted) {
        SnackbarUtils.showError(context, "gallery permission not granted");
      }
    }
  }

  // code for dialogue box: Kun source of media choose garney option dinu lai
  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color.fromARGB(255, 240, 227, 234),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_enhance_rounded),
                title: Text("Open Camera"),
                onTap: () {
                  _clickFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.browse_gallery),
                title: Text("Open Gallery"),
                onTap: () {
                  _pickFromGallery();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _avatarToUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final s = raw.trim();

    // If it's a local file scheme, it's NOT a network image
    if (s.startsWith('file://')) return null;

    // Already a full URL
    if (s.startsWith('http://') || s.startsWith('https://')) return s;

    // Filename or relative path -> make it full
    final fileName = s.split('/').last;
    return '${ApiEndpoints.profileImages}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);

    ref.listen(userViewModelProvider, (previous, next) {
      if (next.status == UserStatus.edited) {
        Navigator.pop(context);
      }

      if (next.status == UserStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? "Something went wrong")),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 20),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Builder(
                    builder: (_) {
                      ImageProvider provider;

                      // 1) Local picked image
                      if (_selectedMedia.isNotEmpty) {
                        provider = FileImage(File(_selectedMedia.first.path));
                      } else {
                        // 2) Backend avatar filename -> http url
                        final raw = state.userEntity?.avatar;
                        final url = _avatarToUrl(raw);

                        // Debug
                        debugPrint('raw avatar: $raw');
                        debugPrint('final url: $url');

                        provider = (url != null)
                            ? NetworkImage(url)
                            : const NetworkImage(
                                'https://via.placeholder.com/150',
                              );
                      }

                      return CircleAvatar(
                        radius: 55,
                        backgroundImage: provider,
                        onBackgroundImageError: (_, __) {
                          debugPrint('Avatar failed to load');
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD17BA6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _InputField(
                controller: _fullNameController,
                hint: "Full name",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              _InputField(
                controller: _usernameController,
                hint: "Username",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _InputField(
                controller: _phoneController,
                hint: "Phone number",
                icon: Icons.call,
              ),
              const SizedBox(height: 16),

              _InputField(
                controller: _addressController,
                hint: "Address",
                icon: Icons.location_on,
              ),

              const SizedBox(height: 50),

              state.status == UserStatus.loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: 160,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(userViewModelProvider.notifier)
                              .editProfile(
                                fullName: _fullNameController.text.trim(),
                                username: _usernameController.text.trim(),
                                phoneNumber: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD17BA6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _ProfileAvatar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         const CircleAvatar(
//           radius: 55,
//           backgroundImage: AssetImage("assets/images/avatar_placeholder.png"),
//         ),
//         Positioned(
//           bottom: 4,
//           right: 4,
//           child: GestureDetector(
//             onTap: () {
//               _clickFromCamera();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: const BoxDecoration(
//                 color: Color(0xFFD17BA6),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.camera_alt,
//                 size: 18,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
