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
  build() {
    _createPostUsecase = ref.read(createPostUsecaseProvider);
    return PostState();
  }

  // create post method
  Future<void> createPost({
    String? media,
    String? mediaType,
    String? caption,
    List<String>? tags,
  }) async {
    state = state.copyWith(status: PostStatus.loading);
    final createPostParams = CreatePostUsecaseParams(
      media: media,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
    );
    final result = await _createPostUsecase.call(createPostParams);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
      },
      (isCreated) {
        if (isCreated) {
          state = state.copyWith(status: PostStatus.created);
        } else {
          state = state.copyWith(
            status: PostStatus.error,
            errorMessage: "Create Post Failed",
          );
        }
      },
    );
  }
}
