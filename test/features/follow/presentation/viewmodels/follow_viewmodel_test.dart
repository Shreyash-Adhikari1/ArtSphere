import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/usecases/follow_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/get_is_following_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/unfollow_usecase.dart';
import 'package:artsphere/features/follow/presentation/viewmodels/follow_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// =======================
// Mocks
// =======================
class MockFollowUsecase extends Mock implements FollowUsecase {}

class MockUnfollowUsecase extends Mock implements UnfollowUsecase {}

class MockGetIsFollowingUsecase extends Mock implements GetIsFollowingUsecase {}

// =======================
// Fakes for any()
// =======================
class FakeFollowParams extends Fake implements FollowUsecaseParams {}

class FakeUnfollowParams extends Fake implements UnfollowUsecaseParams {}

class FakeGetIsFollowingParams extends Fake implements GetIsFollowingParams {}

void main() {
  late MockFollowUsecase mockFollow;
  late MockUnfollowUsecase mockUnfollow;
  late MockGetIsFollowingUsecase mockGetIsFollowing;

  // A valid FollowEntity (because your usecases return FollowEntity, not bool)
  late FollowEntity dummyFollow;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        followUsecaseProvider.overrideWithValue(mockFollow),
        unfollowUsecaseProvider.overrideWithValue(mockUnfollow),
        getIsFollowingUsecaseProvider.overrideWithValue(mockGetIsFollowing),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeFollowParams());
    registerFallbackValue(FakeUnfollowParams());
    registerFallbackValue(FakeGetIsFollowingParams());
  });

  setUp(() {
    mockFollow = MockFollowUsecase();
    mockUnfollow = MockUnfollowUsecase();
    mockGetIsFollowing = MockGetIsFollowingUsecase();

    // minimal valid user entities (your UserEntity has required fields)
    const me = UserEntity(
      userId: "me",
      fullName: "Me",
      username: "me",
      email: "me@gmail.com",
      password: "",
      confirmPassword: "",
    );

    const target = UserEntity(
      userId: "target1",
      fullName: "Target",
      username: "target",
      email: "target@gmail.com",
      password: "",
      confirmPassword: "",
    );

    dummyFollow = const FollowEntity(
      followId: "f1",
      follower: me,
      following: target,
      isFollowActive: true,
      isFollowedByMe: true,
    );

    // Default stubs
    when(() => mockFollow(any())).thenAnswer((_) async => Right(dummyFollow));
    when(() => mockUnfollow(any())).thenAnswer((_) async => Right(dummyFollow));
    when(
      () => mockGetIsFollowing(any()),
    ).thenAnswer((_) async => const Right(true));
  });

  // =========================================================
  // TEST 1: fetchIsFollowing caches result and avoids duplicate calls
  // =========================================================
  test('fetchIsFollowing caches result and avoids duplicate calls', () async {
    when(
      () => mockGetIsFollowing(any()),
    ).thenAnswer((_) async => const Right(true));

    final container = makeContainer();
    addTearDown(container.dispose);

    final vm = container.read(followViewModelProvider.notifier);

    await vm.fetchIsFollowing("user123");

    final state1 = container.read(followViewModelProvider);
    expect(state1.isFollowingCache["user123"], true);

    // Call again without force -> should NOT call usecase again
    await vm.fetchIsFollowing("user123");

    verify(() => mockGetIsFollowing(any())).called(1);
  });

  // =========================================================
  // TEST 2: toggleFollow success -> optimistic cache update + busy clears
  // =========================================================
  test('toggleFollow success -> updates cache and clears busy flag', () async {
    when(() => mockFollow(any())).thenAnswer((_) async => Right(dummyFollow));

    final container = makeContainer();
    addTearDown(container.dispose);

    final vm = container.read(followViewModelProvider.notifier);

    await vm.toggleFollow(targetUserId: "target1", currentlyFollowing: false);

    final state = container.read(followViewModelProvider);

    expect(state.isFollowingCache["target1"], true);
    expect(state.followBusy["target1"], false);

    verify(() => mockFollow(any())).called(1);
    verifyNever(() => mockUnfollow(any()));
  });

  // =========================================================
  // TEST 3: toggleFollow failure -> rollback cache + errorMessage + busy clears
  // =========================================================
  test(
    'toggleFollow failure -> rolls back cache and sets errorMessage',
    () async {
      const failure = ApiFailure(message: "Follow failed", statusCode: 400);

      when(
        () => mockFollow(any()),
      ).thenAnswer((_) async => const Left(failure));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(followViewModelProvider.notifier);

      await vm.toggleFollow(targetUserId: "target1", currentlyFollowing: false);

      final state = container.read(followViewModelProvider);

      // rollback: it should remove the cache entry if it didn't exist before
      expect(state.isFollowingCache.containsKey("target1"), false);
      expect(state.errorMessage, failure.message);
      expect(state.followBusy["target1"], false);

      verify(() => mockFollow(any())).called(1);
    },
  );
}
