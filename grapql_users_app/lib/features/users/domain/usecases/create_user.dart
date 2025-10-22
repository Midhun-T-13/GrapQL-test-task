import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/network/either.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class CreateUser implements UseCase<UserEntity, CreateUserParams> {
  final UserRepository repository;

  CreateUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(CreateUserParams params) async {
    return await repository.createUser(
      name: params.name,
      username: params.username,
      email: params.email,
    );
  }
}

class CreateUserParams extends Equatable {
  final String name;
  final String username;
  final String email;

  const CreateUserParams({
    required this.name,
    required this.username,
    required this.email,
  });

  @override
  List<Object> get props => [name, username, email];
}
