import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/network/either.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserById implements UseCase<UserEntity, GetUserByIdParams> {
  final UserRepository repository;

  GetUserById(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetUserByIdParams params) async {
    return await repository.getUserById(params.id);
  }
}

class GetUserByIdParams {
  final String id;

  GetUserByIdParams({required this.id});
}
