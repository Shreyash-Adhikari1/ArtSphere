import 'package:artsphere/features/challenge/data/models/challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/create/create_challenge_api_model.dart';

abstract interface class IChallengeRemoteDatasource {
  Future<ChallengeApiModel> createChallenge(
    CreateChallengeApiModel challenge,
    String challengeMediaPath,
  );

  Future<ChallengeApiModel> editChallenge(
    String challengeId,
    CreateChallengeApiModel challenge,
  );

  Future<List<ChallengeApiModel>> getAllChallenges();
  Future<List<ChallengeApiModel>> getMyChallenges();
  Future<ChallengeApiModel> getChallengeById(String challengeId);

  Future<bool> deleteChallenge(String challengeId);
  Future<bool> deleteAllMyChallenges();
}
