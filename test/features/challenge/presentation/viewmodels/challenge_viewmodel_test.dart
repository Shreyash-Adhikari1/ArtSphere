import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/delete_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_all_challenges_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_challenge_by_id_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_my_challenges_usecase.dart';
import 'package:artsphere/features/challenge/presentation/states/challenge_state.dart';
import 'package:artsphere/features/challenge/presentation/viewmodels/challenge_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// =======================
// Mocks
// =======================
class MockCreateChallengeUsecase extends Mock
    implements CreateChallengeUsecase {}

class MockEditChallengeUsecase extends Mock implements EditChallengeUsecase {}

class MockDeleteChallengeUsecase extends Mock
    implements DeleteChallengeUsecase {}

class MockGetAllChallengesUsecase extends Mock
    implements GetAllChallengesUsecase {}

class MockGetMyChallengesUsecase extends Mock
    implements GetMyChallengesUsecase {}

class MockGetChallengeByIdUsecase extends Mock
    implements GetChallengeByIdUsecase {}

// =======================
// Fakes for any()
// =======================
class FakeCreateParams extends Fake implements CreateChallengeUsecaseParams {}

class FakeEditParams extends Fake implements EditChallengeUsecaseParams {}

class FakeDeleteParams extends Fake implements DeleteChallengeUsecaseParams {}

class FakeGetByIdParams extends Fake implements GetChallengeByIdUsecaseParams {}

void main() {
  late MockCreateChallengeUsecase mockCreate;
  late MockEditChallengeUsecase mockEdit;
  late MockDeleteChallengeUsecase mockDelete;
  late MockGetAllChallengesUsecase mockGetAll;
  late MockGetMyChallengesUsecase mockGetMine;
  late MockGetChallengeByIdUsecase mockGetById;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        createChallengeUsecaseProvider.overrideWithValue(mockCreate),
        editChallengeUsecaseProvider.overrideWithValue(mockEdit),
        deleteChallengeUsecaseProvider.overrideWithValue(mockDelete),
        getAllChallengesUsecaseProvider.overrideWithValue(mockGetAll),
        getMyChallengesUsecaseProvider.overrideWithValue(mockGetMine),
        getChallengeByIdUsecaseProvider.overrideWithValue(mockGetById),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeCreateParams());
    registerFallbackValue(FakeEditParams());
    registerFallbackValue(FakeDeleteParams());
    registerFallbackValue(FakeGetByIdParams());
  });

  setUp(() {
    mockCreate = MockCreateChallengeUsecase();
    mockEdit = MockEditChallengeUsecase();
    mockDelete = MockDeleteChallengeUsecase();
    mockGetAll = MockGetAllChallengesUsecase();
    mockGetMine = MockGetMyChallengesUsecase();
    mockGetById = MockGetChallengeByIdUsecase();

    // safe defaults
    when(
      () => mockGetAll(),
    ).thenAnswer((_) async => const Right(<ChallengeEntity>[]));
    when(
      () => mockGetMine(),
    ).thenAnswer((_) async => const Right(<ChallengeEntity>[]));
    when(
      () => mockGetById(any()),
    ).thenAnswer((_) async => Right(const ChallengeEntity(challengeId: "c1")));
    when(
      () => mockCreate(any()),
    ).thenAnswer((_) async => Right(const ChallengeEntity(challengeId: "new")));
    when(
      () => mockEdit(any()),
    ).thenAnswer((_) async => Right(const ChallengeEntity(challengeId: "u1")));
    when(() => mockDelete(any())).thenAnswer((_) async => const Right(true));
  });

  // =========================================================
  // TEST 1: loadDiscoverChallenges success
  // =========================================================
  test(
    'loadDiscoverChallenges success -> sets discoverChallenges and turns off loading',
    () async {
      const items = [
        ChallengeEntity(challengeId: "c1"),
        ChallengeEntity(challengeId: "c2"),
      ];

      when(() => mockGetAll()).thenAnswer((_) async => const Right(items));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(challengeViewModelProvider.notifier);

      await vm.loadDiscoverChallenges();

      final state = container.read(challengeViewModelProvider);
      expect(state.discoverLoading, false);
      expect(state.discoverChallenges, items);
      expect(state.errorMessage, isNull);

      verify(() => mockGetAll()).called(1);
    },
  );

  // =========================================================
  // TEST 2: createChallenge success -> prepends to discover + my lists
  // =========================================================
  test(
    'createChallenge success -> prepends created into discoverChallenges and myChallenges',
    () async {
      const created = ChallengeEntity(
        challengeId: "c-new",
        challengeTitle: "New Challenge",
      );

      when(
        () => mockCreate(any()),
      ).thenAnswer((_) async => const Right(created));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(challengeViewModelProvider.notifier);

      // seed lists
      vm.state = const ChallengeState(
        discoverChallenges: [ChallengeEntity(challengeId: "old1")],
        myChallenges: [ChallengeEntity(challengeId: "old2")],
      );

      final params = CreateChallengeUsecaseParams(
        challengeTitle: "New Challenge",
        challengeDescription: "desc",
        challengeMedia: "/tmp/image.png",
        endsAt: DateTime(2030, 1, 1),
      );

      final result = await vm.createChallenge(params);

      expect(result, created);

      final state = container.read(challengeViewModelProvider);
      expect(state.actionLoading, false);
      expect(state.discoverChallenges.first.challengeId, "c-new");
      expect(state.myChallenges.first.challengeId, "c-new");

      verify(
        () => mockCreate(
          any(
            that: isA<CreateChallengeUsecaseParams>()
                .having(
                  (p) => p.challengeTitle,
                  'challengeTitle',
                  "New Challenge",
                )
                .having(
                  (p) => p.challengeMedia,
                  'challengeMedia',
                  "/tmp/image.png",
                ),
          ),
        ),
      ).called(1);
    },
  );

  // =========================================================
  // TEST 3: editChallenge empty id -> sets error and does NOT call usecase
  // =========================================================
  test(
    'editChallenge with empty challengeId -> sets errorMessage and returns null',
    () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(challengeViewModelProvider.notifier);

      final params = EditChallengeUsecaseParams(
        challengeId: "   ", // empty after trim
        challengeTitle: "Updated",
      );

      final result = await vm.editChallenge(params);

      expect(result, isNull);

      final state = container.read(challengeViewModelProvider);
      expect(state.errorMessage, "ChallengeId is required");

      verifyNever(() => mockEdit(any()));
    },
  );

  // =========================================================
  // TEST 4: loadChallengeDetails success -> activeChallenge set and loading false
  // =========================================================
  test(
    'loadChallengeDetails success -> sets activeChallenge and turns off detailsLoading',
    () async {
      const details = ChallengeEntity(
        challengeId: "c42",
        challengeTitle: "Art Battle",
      );

      when(
        () => mockGetById(any()),
      ).thenAnswer((_) async => const Right(details));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(challengeViewModelProvider.notifier);

      await vm.loadChallengeDetails("c42");

      final state = container.read(challengeViewModelProvider);
      expect(state.detailsLoading, false);
      expect(state.activeChallenge, details);
      expect(state.errorMessage, isNull);

      verify(
        () => mockGetById(
          any(
            that: isA<GetChallengeByIdUsecaseParams>().having(
              (p) => p.challengeId,
              'challengeId',
              "c42",
            ),
          ),
        ),
      ).called(1);
    },
  );

  // =========================================================
  // TEST 5: deleteChallenge failure -> optimistic remove then rollback + busy cleared
  // =========================================================
  test(
    'deleteChallenge failure -> rolls back lists, sets errorMessage, clears busy flag',
    () async {
      const failure = ApiFailure(message: "Delete failed", statusCode: 400);

      when(
        () => mockDelete(any()),
      ).thenAnswer((_) async => const Left(failure));

      const c1 = ChallengeEntity(challengeId: "c1");
      const c2 = ChallengeEntity(challengeId: "c2");

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(challengeViewModelProvider.notifier);

      vm.state = const ChallengeState(
        discoverChallenges: [c1, c2],
        myChallenges: [c1],
      );

      final ok = await vm.deleteChallenge("c1");
      expect(ok, false);

      final state = container.read(challengeViewModelProvider);

      // rollback restored lists
      expect(state.discoverChallenges, [c1, c2]);
      expect(state.myChallenges, [c1]);

      expect(state.errorMessage, failure.message);
      expect(state.busyById["c1"], false);

      verify(
        () => mockDelete(
          any(
            that: isA<DeleteChallengeUsecaseParams>().having(
              (p) => p.challengeId,
              'challengeId',
              "c1",
            ),
          ),
        ),
      ).called(1);
    },
  );
}
