import 'package:artsphere/core/services/hive/hive_service.dart';
import 'package:artsphere/features/challenge/data/datasources/challenge_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artsphere/features/challenge/data/models/hive/challenge_hive_model.dart';

final challengeLocalDatasourceProvider = Provider<IChallengeLocalDatasource>((
  ref,
) {
  return ChallengeLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class ChallengeLocalDatasource implements IChallengeLocalDatasource {
  final HiveService _hive;
  ChallengeLocalDatasource({required HiveService hiveService})
    : _hive = hiveService;

  @override
  Future<void> cacheDiscoverChallenges(List<ChallengeHiveModel> list) =>
      _hive.cacheDiscoverChallenges(list);

  @override
  List<ChallengeHiveModel> getCachedDiscoverChallenges() =>
      _hive.getCachedDiscoverChallenges();

  @override
  Future<void> cacheMyChallenges(List<ChallengeHiveModel> list) =>
      _hive.cacheMyChallenges(list);

  @override
  List<ChallengeHiveModel> getCachedMyChallenges() =>
      _hive.getCachedMyChallenges();

  @override
  ChallengeHiveModel? getCachedChallengeDetails(String challengeId) =>
      _hive.getCachedChallengeDetails(challengeId);
}
