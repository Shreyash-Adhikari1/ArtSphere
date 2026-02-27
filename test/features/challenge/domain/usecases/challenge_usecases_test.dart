import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/delete_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_all_challenges_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_challenge_by_id_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_my_challenges_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repository
class MockChallengeRepository extends Mock implements IChallengeRepository {}

// Fakes for any()
class FakeCreateChallengeParams extends Fake
    implements CreateChallengeUsecaseParams {}

class FakeEditChallengeParams extends Fake
    implements EditChallengeUsecaseParams {}

void main() {
  late MockChallengeRepository repo;

  late CreateChallengeUsecase createChallengeUsecase;
  late EditChallengeUsecase editChallengeUsecase;
  late DeleteChallengeUsecase deleteChallengeUsecase;
  late GetAllChallengesUsecase getAllChallengesUsecase;
  late GetMyChallengesUsecase getMyChallengesUsecase;
  late GetChallengeByIdUsecase getChallengeByIdUsecase;

  setUpAll(() {
    registerFallbackValue(FakeCreateChallengeParams());
    registerFallbackValue(FakeEditChallengeParams());
  });

  setUp(() {
    repo = MockChallengeRepository();

    createChallengeUsecase = CreateChallengeUsecase(challengeRepository: repo);
    editChallengeUsecase = EditChallengeUsecase(challengeRepository: repo);
    deleteChallengeUsecase = DeleteChallengeUsecase(challengeRepository: repo);
    getAllChallengesUsecase = GetAllChallengesUsecase(
      challengeRepository: repo,
    );
    getMyChallengesUsecase = GetMyChallengesUsecase(challengeRepository: repo);
    getChallengeByIdUsecase = GetChallengeByIdUsecase(
      challengeRepository: repo,
    );
  });

  group('Challenge Usecases', () {
    test(
      'CreateChallengeUsecase -> calls repo.createChallenge(params) and returns Right(ChallengeEntity)',
      () async {
        const created = ChallengeEntity(
          challengeId: "c1",
          challengeTitle: "Title",
        );

        when(
          () => repo.createChallenge(params: any(named: 'params')),
        ).thenAnswer((_) async => const Right(created));

        final params = CreateChallengeUsecaseParams(
          challengeTitle: "Title",
          challengeDescription: "Desc",
          challengeMedia: "media.png",
          endsAt: DateTime(2030, 1, 1),
        );

        final result = await createChallengeUsecase(params);

        expect(result, const Right(created));

        verify(
          () => repo.createChallenge(
            params: any(
              named: 'params',
              that: isA<CreateChallengeUsecaseParams>()
                  .having((p) => p.challengeTitle, 'challengeTitle', "Title")
                  .having(
                    (p) => p.challengeMedia,
                    'challengeMedia',
                    "media.png",
                  ),
            ),
          ),
        ).called(1);

        verifyNoMoreInteractions(repo);
      },
    );

    test(
      'EditChallengeUsecase -> calls repo.editChallenge(params) and returns Right(ChallengeEntity)',
      () async {
        const updated = ChallengeEntity(
          challengeId: "c1",
          challengeTitle: "Updated",
        );

        when(
          () => repo.editChallenge(any()),
        ).thenAnswer((_) async => const Right(updated));

        const params = EditChallengeUsecaseParams(
          challengeId: "c1",
          challengeTitle: "Updated",
          challengeDescription: "New Desc",
        );

        final result = await editChallengeUsecase(params);

        expect(result, const Right(updated));

        verify(
          () => repo.editChallenge(
            any(
              that: isA<EditChallengeUsecaseParams>()
                  .having((p) => p.challengeId, 'challengeId', "c1")
                  .having((p) => p.challengeTitle, 'challengeTitle', "Updated"),
            ),
          ),
        ).called(1);

        verifyNoMoreInteractions(repo);
      },
    );

    test(
      'DeleteChallengeUsecase -> calls repo.deleteChallenge(id) and returns Right(true)',
      () async {
        when(
          () => repo.deleteChallenge("c1"),
        ).thenAnswer((_) async => const Right(true));

        final result = await deleteChallengeUsecase(
          const DeleteChallengeUsecaseParams(challengeId: "c1"),
        );

        expect(result, const Right(true));
        verify(() => repo.deleteChallenge("c1")).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test(
      'GetAllChallengesUsecase -> calls repo.getAllChallenges() and returns Right(list)',
      () async {
        const list = [
          ChallengeEntity(challengeId: "c1"),
          ChallengeEntity(challengeId: "c2"),
        ];

        when(
          () => repo.getAllChallenges(),
        ).thenAnswer((_) async => const Right(list));

        final result = await getAllChallengesUsecase();

        expect(result, const Right(list));
        verify(() => repo.getAllChallenges()).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test(
      'GetMyChallengesUsecase -> calls repo.getMyChallenges() and returns Right(list)',
      () async {
        const list = [
          ChallengeEntity(challengeId: "m1"),
          ChallengeEntity(challengeId: "m2"),
        ];

        when(
          () => repo.getMyChallenges(),
        ).thenAnswer((_) async => const Right(list));

        final result = await getMyChallengesUsecase();

        expect(result, const Right(list));
        verify(() => repo.getMyChallenges()).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test(
      'GetChallengeByIdUsecase -> calls repo.getChallengeById(id) and returns Right(entity)',
      () async {
        const entity = ChallengeEntity(
          challengeId: "c99",
          challengeTitle: "Detail",
        );

        when(
          () => repo.getChallengeById("c99"),
        ).thenAnswer((_) async => const Right(entity));

        final result = await getChallengeByIdUsecase(
          const GetChallengeByIdUsecaseParams(challengeId: "c99"),
        );

        expect(result, const Right(entity));
        verify(() => repo.getChallengeById("c99")).called(1);
        verifyNoMoreInteractions(repo);
      },
    );
  });
}
