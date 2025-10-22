import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/network/either.dart';
import '../repositories/user_repository.dart';

class GetUsers implements UseCase<UsersResult, GetUsersParams> {
  final UserRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, UsersResult>> call(GetUsersParams params) async {
    return await repository.getUsers(
      page: params.page,
      limit: params.limit,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetUsersParams extends Equatable {
  final int page;
  final int limit;
  final bool forceRefresh;

  const GetUsersParams({
    required this.page,
    required this.limit,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [page, limit, forceRefresh];
}
