import '../../../../core/error/failures.dart';
import '../../../../core/network/either.dart';
import '../entities/user_entity.dart';

class UsersResult {
  final List<UserEntity> users;
  final int totalCount;

  const UsersResult({
    required this.users,
    required this.totalCount,
  });
}

abstract class UserRepository {
  Future<Either<Failure, UsersResult>> getUsers({
    required int page,
    required int limit,
    bool forceRefresh = false,
  });


}
