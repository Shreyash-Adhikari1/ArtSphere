import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:artsphere/features/submission/domain/usecases/create_new_post_and_submit_usecase.dart';
import 'package:artsphere/features/submission/domain/usecases/delete_submission_usecase.dart';
import 'package:artsphere/features/submission/domain/usecases/get_submissions_for_challenge_usecase.dart';
import 'package:artsphere/features/submission/domain/usecases/submit_existing_post_usecase.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:artsphere/features/submission/presentation/viewmodels/submission_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// =======================
// Mocks
// =======================
class MockGetForChallenge extends Mock
    implements GetSubmissionsForChallengeUsecase {}

class MockSubmitExisting extends Mock implements SubmitExistingPostUsecase {}

class MockCreateAndSubmit extends Mock
    implements CreateNewPostAndSubmitUsecase {}

class MockDeleteSubmission extends Mock implements DeleteSubmissionUsecase {}

// =======================
// Fakes for any()
// =======================
class FakeGetForChallengeParams extends Fake
    implements GetSubmissionsForChallengeUsecaseParams {}

class FakeSubmitExistingParams extends Fake
    implements SubmitExistingPostUsecaseParams {}

class FakeCreateAndSubmitParams extends Fake
    implements CreateNewPostAndSubmitUsecaseParams {}

class FakeDeleteSubmissionParams extends Fake
    implements DeleteSubmissionUsecaseParams {}

void main() {
  late MockGetForChallenge mockGetForChallenge;
  late MockSubmitExisting mockSubmitExisting;
  late MockCreateAndSubmit mockCreateAndSubmit;
  late MockDeleteSubmission mockDelete;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        getSubmissionsForChallengeUsecaseProvider.overrideWithValue(
          mockGetForChallenge,
        ),
        submitExistingPostUsecaseProvider.overrideWithValue(mockSubmitExisting),
        createNewPostAndSubmitUsecaseProvider.overrideWithValue(
          mockCreateAndSubmit,
        ),
        deleteSubmissionUsecaseProvider.overrideWithValue(mockDelete),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeGetForChallengeParams());
    registerFallbackValue(FakeSubmitExistingParams());
    registerFallbackValue(FakeCreateAndSubmitParams());
    registerFallbackValue(FakeDeleteSubmissionParams());
  });

  setUp(() {
    mockGetForChallenge = MockGetForChallenge();
    mockSubmitExisting = MockSubmitExisting();
    mockCreateAndSubmit = MockCreateAndSubmit();
    mockDelete = MockDeleteSubmission();

    // safe defaults
    when(
      () => mockGetForChallenge(any()),
    ).thenAnswer((_) async => const Right(<SubmissionEntity>[]));
    when(() => mockSubmitExisting(any())).thenAnswer((_) async {
      return Right(
        SubmissionEntity(
          submissionId: "s1",
          challengeId: "c1",
          submitterId: "me",
          submittedPost: const PostEntity(postId: "p1"),
        ),
      );
    });
    when(() => mockCreateAndSubmit(any())).thenAnswer((_) async {
      return Right(
        SubmissionEntity(
          submissionId: "s2",
          challengeId: "c1",
          submitterId: "me",
          submittedPost: const PostEntity(postId: "p-new"),
        ),
      );
    });
    when(() => mockDelete(any())).thenAnswer((_) async => const Right(true));
  });

  // =========================================================
  // TEST 1: loadSubmissions success -> status success + submissions set
  // =========================================================
  test(
    'loadSubmissions success -> sets status success and submissions',
    () async {
      final list = [
        SubmissionEntity(
          submissionId: "s1",
          challengeId: "c1",
          submitterId: "u1",
          submittedPost: const PostEntity(postId: "p1"),
        ),
        SubmissionEntity(
          submissionId: "s2",
          challengeId: "c1",
          submitterId: "u2",
          submittedPost: const PostEntity(postId: "p2"),
        ),
      ];

      when(
        () => mockGetForChallenge(any()),
      ).thenAnswer((_) async => Right(list));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(submissionViewModelProvider.notifier);

      await vm.loadSubmissions("c1");

      final state = container.read(submissionViewModelProvider);
      expect(state.status, SubmissionStatus.success);
      expect(state.submissions, list);
      expect(state.errorMessage, isNull);

      verify(() => mockGetForChallenge(any())).called(1);
    },
  );

  // =========================================================
  // TEST 2: refresh does nothing if no active challenge loaded yet
  // =========================================================
  test(
    'refresh without active challengeId -> does not call getForChallenge',
    () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(submissionViewModelProvider.notifier);

      await vm.refresh();

      verifyNever(() => mockGetForChallenge(any()));
    },
  );

  // =========================================================
  // TEST 3: submitExistingPost success -> sets action success, lastActionResult, calls refresh
  // =========================================================
  test(
    'submitExistingPost success -> action success + lastActionResult + refresh called',
    () async {
      final created = SubmissionEntity(
        submissionId: "s10",
        challengeId: "c1",
        submitterId: "me",
        submittedPost: const PostEntity(postId: "p10"),
      );

      // submit returns created
      when(
        () => mockSubmitExisting(any()),
      ).thenAnswer((_) async => Right(created));

      // refresh call should fetch updated list
      when(
        () => mockGetForChallenge(any()),
      ).thenAnswer((_) async => Right([created]));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(submissionViewModelProvider.notifier);

      final result = await vm.submitExistingPost(
        challengeId: "c1",
        postId: "p10",
      );

      expect(result, created);

      final state = container.read(submissionViewModelProvider);

      expect(state.action, SubmissionAction.submitExisting);
      expect(state.actionStatus, SubmissionStatus.success);
      expect(state.lastActionResult, created);

      // refresh happened
      verify(() => mockGetForChallenge(any())).called(1);
      verify(() => mockSubmitExisting(any())).called(1);
    },
  );

  // =========================================================
  // TEST 4: createNewPostAndSubmit success -> action success, lastActionResult, refresh called
  // =========================================================
  test(
    'createNewPostAndSubmit success -> action success + lastActionResult + refresh called',
    () async {
      final created = SubmissionEntity(
        submissionId: "s20",
        challengeId: "c1",
        submitterId: "me",
        submittedPost: const PostEntity(postId: "p20"),
      );

      when(
        () => mockCreateAndSubmit(any()),
      ).thenAnswer((_) async => Right(created));
      when(
        () => mockGetForChallenge(any()),
      ).thenAnswer((_) async => Right([created]));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(submissionViewModelProvider.notifier);

      final result = await vm.createNewPostAndSubmit(
        challengeId: "c1",
        post: const PostEntity(postId: "p20"),
        mediaPath: "/tmp/a.png",
      );

      expect(result, created);

      final state = container.read(submissionViewModelProvider);
      expect(state.action, SubmissionAction.createAndSubmit);
      expect(state.actionStatus, SubmissionStatus.success);
      expect(state.lastActionResult, created);

      verify(() => mockCreateAndSubmit(any())).called(1);
      verify(() => mockGetForChallenge(any())).called(1);
    },
  );

  // =========================================================
  // TEST 5: deleteSubmission failure -> rollback list + action failure + deletingSubmissionId cleared
  // =========================================================
  test(
    'deleteSubmission failure -> rolls back list and sets action failure',
    () async {
      const failure = ApiFailure(message: "Delete failed", statusCode: 400);
      when(
        () => mockDelete(any()),
      ).thenAnswer((_) async => const Left(failure));

      final s1 = SubmissionEntity(
        submissionId: "s1",
        challengeId: "c1",
        submitterId: "u1",
        submittedPost: const PostEntity(postId: "p1"),
      );
      final s2 = SubmissionEntity(
        submissionId: "s2",
        challengeId: "c1",
        submitterId: "u2",
        submittedPost: const PostEntity(postId: "p2"),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(submissionViewModelProvider.notifier);
      vm.state = SubmissionState(
        status: SubmissionStatus.success,
        submissions: [s1, s2],
        actionStatus: SubmissionStatus.initial,
        action: SubmissionAction.none,
      );

      final ok = await vm.deleteSubmission("s1");
      expect(ok, false);

      final state = container.read(submissionViewModelProvider);

      // rollback restored list
      expect(state.submissions, [s1, s2]);

      // failure state
      expect(state.action, SubmissionAction.delete);
      expect(state.actionStatus, SubmissionStatus.failure);
      expect(state.actionErrorMessage, failure.message);

      // cleared by copyWith(clearDeletingSubmissionId: true)
      expect(state.deletingSubmissionId, isNull);

      verify(() => mockDelete(any())).called(1);
    },
  );
}
