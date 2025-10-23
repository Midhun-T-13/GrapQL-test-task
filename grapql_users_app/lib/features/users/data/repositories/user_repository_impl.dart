import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/error/failures.dart';
import '../../../../core/network/either.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UsersResult>> getUsers({
    required int page,
    required int limit,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await remoteDataSource.getUsers(
        page: page,
        limit: limit,
        forceRefresh: forceRefresh,
      );
      return Right(
        UsersResult(
          users: response.users,
          totalCount: response.totalCount,
        ),
      );
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on app_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String id) async {
    try {
      final user = await remoteDataSource.getUserById(id);
      return Right(user);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on app_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser({
    required String name,
    required String username,
    required String email,
    required String phone
  }) async {
    try {
      final user = await remoteDataSource.createUser(
        name: name,
        username: username,
        email: email,
        phone: phone
      );
      return Right(user);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on app_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}
