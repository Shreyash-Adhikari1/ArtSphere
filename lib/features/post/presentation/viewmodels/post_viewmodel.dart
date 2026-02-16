import 'package:artsphere/features/post/domain/usecases/create_post_usecase.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// provider
final postViewModelProvider = NotifierProvider<PostViewmodel, PostState>(
  () => PostViewmodel(),
);

class PostViewmodel extends Notifier<PostState> {
  late final CreatePostUsecase _createPostUsecase;

  @override
  PostState build() {
    _createPostUsecase = ref.read(createPostUsecaseProvider);
    return const PostState();
  }

  Future<void> createPost({
    required String mediaPath,
    String mediaType = "image",
    String? caption,
    List<String>? tags,
    String visibility = "public",
  }) async {
    // start loading + clear old error
    state = state.copyWith(status: PostStatus.loading, errorMessage: null);

    final params = CreatePostUsecaseParams(
      mediaPath: mediaPath,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
      visibility: visibility,
    );

    final result = await _createPostUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
      },
      (createdPost) {
        state = state.copyWith(
          status: PostStatus.created,
          postEntity: createdPost,
        );
      },
    );
  }
}
