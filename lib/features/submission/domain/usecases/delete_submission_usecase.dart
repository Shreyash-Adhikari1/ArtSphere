import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/submission/data/repositories/submission_repository.dart';
import 'package:artsphere/features/submission/domain/repositories/submission_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteSubmissionUsecaseParams extends Equatable {
  final String submissionId;
  const DeleteSubmissionUsecaseParams({required this.submissionId});
  @override
  List<Object?> get props => [submissionId];
}

final deleteSubmissionUsecaseProvider = Provider<DeleteSubmissionUsecase>((
  ref,
) {
  return DeleteSubmissionUsecase(
    submissionRepository: ref.read(submissionRepositoryProvider),
  );
});

class DeleteSubmissionUsecase
    implements UsecaseWithParams<bool, DeleteSubmissionUsecaseParams> {
  final ISubmissionRepository _submissionRepository;
  DeleteSubmissionUsecase({required ISubmissionRepository submissionRepository})
    : _submissionRepository = submissionRepository;
  @override
  Future<Either<Failure, bool>> call(DeleteSubmissionUsecaseParams params) {
    return _submissionRepository.deleteSubmission(params.submissionId);
  }
}
