import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/usecases/create_user.dart';

import 'get_users_test.mocks.dart';

void main() {
  late CreateUser useCase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    useCase = CreateUser(mockUserRepository);
  });

  const tName = 'John Doe';
  const tUsername = 'johndoe';
  const tEmail = 'john@example.com';

  const tUser = UserEntity(
    id: '1',
    name: tName,
    username: tUsername,
    email: tEmail,
  );

  group('CreateUser', () {
    test('should return UserEntity when repository call is successful', () async {
      // arrange
      when(mockUserRepository.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const Right(tUser));

      // act
      final result = await useCase(const CreateUserParams(
        name: tName,
        username: tUsername,
        email: tEmail,
      ));

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user.id, '1');
          expect(user.name, tName);
          expect(user.username, tUsername);
          expect(user.email, tEmail);
        },
      );
      verify(mockUserRepository.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
      )).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      const tServerFailure = ServerFailure('Failed to create user');
      when(mockUserRepository.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const Left(tServerFailure));

      // act
      final result = await useCase(const CreateUserParams(
        name: tName,
        username: tUsername,
        email: tEmail,
      ));

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to create user');
        },
        (_) => fail('Should return Left'),
      );
      verify(mockUserRepository.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
      )).called(1);
    });

    test('should return ValidationFailure for invalid input', () async {
      // arrange
      const tValidationFailure = ValidationFailure('Invalid email format');
      when(mockUserRepository.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const Left(tValidationFailure));

      // act
      final result = await useCase(const CreateUserParams(
        name: tName,
        username: tUsername,
        email: 'invalid-email',
      ));

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Invalid email format');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tNetworkFailure = NetworkFailure('No internet connection');
      when(mockUserRepository.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const Left(tNetworkFailure));

      // act
      final result = await useCase(const CreateUserParams(
        name: tName,
        username: tUsername,
        email: tEmail,
      ));

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'No internet connection');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should pass correct parameters to repository', () async {
      // arrange
      when(mockUserRepository.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const Right(tUser));

      // act
      await useCase(const CreateUserParams(
        name: 'Jane Smith',
        username: 'janesmith',
        email: 'jane@example.com',
      ));

      // assert
      verify(mockUserRepository.createUser(
        name: 'Jane Smith',
        username: 'janesmith',
        email: 'jane@example.com',
      )).called(1);
    });

    test('should return created user with generated ID', () async {
      // arrange
      const createdUser = UserEntity(
        id: '123',
        name: tName,
        username: tUsername,
        email: tEmail,
      );
      when(mockUserRepository.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const Right(createdUser));

      // act
      final result = await useCase(const CreateUserParams(
        name: tName,
        username: tUsername,
        email: tEmail,
      ));

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user.id, '123');
          expect(user.name, tName);
          expect(user.username, tUsername);
          expect(user.email, tEmail);
        },
      );
    });
  });

  group('CreateUserParams', () {
    test('should have correct props for equality comparison', () {
      // arrange
      const params1 = CreateUserParams(
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
      );
      const params2 = CreateUserParams(
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
      );
      const params3 = CreateUserParams(
        name: 'Jane Smith',
        username: 'johndoe',
        email: 'john@example.com',
      );

      // assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should contain all required fields', () {
      // arrange
      const params = CreateUserParams(
        name: tName,
        username: tUsername,
        email: tEmail,
      );

      // assert
      expect(params.name, tName);
      expect(params.username, tUsername);
      expect(params.email, tEmail);
    });
  });
}
