import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:grapql_users_app/core/error/exceptions.dart' as app_exceptions;
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/data/datasources/user_remote_data_source.dart';
import 'package:grapql_users_app/features/users/data/models/user_model.dart';
import 'package:grapql_users_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/repositories/user_repository.dart';

import 'user_repository_impl_test.mocks.dart';

@GenerateMocks([UserRemoteDataSource])
void main() {
  late UserRepositoryImpl repository;
  late MockUserRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockUserRemoteDataSource();
    repository = UserRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tUserModel = UserModel(
    id: '1',
    name: 'John Doe',
    username: 'johndoe',
    email: 'john@example.com',
    phone: '1234567890',
  );

  const tUserEntity = UserEntity(
    id: '1',
    name: 'John Doe',
    username: 'johndoe',
    email: 'john@example.com',
    phone: '1234567890',
  );

  const tUsersModels = [
    UserModel(
      id: '1',
      name: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
    ),
    UserModel(
      id: '2',
      name: 'Jane Smith',
      username: 'janesmith',
      email: 'jane@example.com',
    ),
  ];

  const tUsersResponse = UsersResponse(
    users: tUsersModels,
    totalCount: 10,
  );

  group('getUsers', () {
    const tPage = 1;
    const tLimit = 5;

    test('should return UsersResult when remote data source call is successful', () async {
      // arrange
      when(mockRemoteDataSource.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => tUsersResponse);

      // act
      final result = await repository.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Should return Right'),
        (usersResult) {
          expect(usersResult.users.length, 2);
          expect(usersResult.totalCount, 10);
          expect(usersResult.users[0].id, '1');
          expect(usersResult.users[0].name, 'John Doe');
        },
      );
      verify(mockRemoteDataSource.getUsers(
        page: tPage,
        limit: tLimit,
        forceRefresh: false,
      )).called(1);
    });

    test('should pass forceRefresh parameter to remote data source', () async {
      // arrange
      when(mockRemoteDataSource.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => tUsersResponse);

      // act
      final result = await repository.getUsers(
        page: tPage,
        limit: tLimit,
        forceRefresh: true,
      );

      // assert
      expect(result.isRight, true);
      verify(mockRemoteDataSource.getUsers(
        page: tPage,
        limit: tLimit,
        forceRefresh: true,
      )).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(const app_exceptions.ServerException('Server error'));

      // act
      final result = await repository.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(const app_exceptions.NetworkException('No internet connection'));

      // act
      final result = await repository.getUsers(page: tPage, limit: tLimit);

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

    test('should return ServerFailure when generic exception is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message.contains('Exception'), true);
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should handle empty users list', () async {
      // arrange
      const emptyResponse = UsersResponse(users: [], totalCount: 0);
      when(mockRemoteDataSource.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => emptyResponse);

      // act
      final result = await repository.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (usersResult) {
          expect(usersResult.users, isEmpty);
          expect(usersResult.totalCount, 0);
        },
      );
    });
  });

  group('getUserById', () {
    const tUserId = '1';

    test('should return UserEntity when remote data source call is successful', () async {
      // arrange
      when(mockRemoteDataSource.getUserById(any))
          .thenAnswer((_) async => tUserModel);

      // act
      final result = await repository.getUserById(tUserId);

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user.id, '1');
          expect(user.name, 'John Doe');
          expect(user.email, 'john@example.com');
          expect(user.phone, '1234567890');
        },
      );
      verify(mockRemoteDataSource.getUserById(tUserId)).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getUserById(any))
          .thenThrow(const app_exceptions.ServerException('User not found'));

      // act
      final result = await repository.getUserById(tUserId);

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'User not found');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getUserById(any))
          .thenThrow(const app_exceptions.NetworkException('No internet connection'));

      // act
      final result = await repository.getUserById(tUserId);

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

    test('should pass correct user ID to remote data source', () async {
      // arrange
      when(mockRemoteDataSource.getUserById(any))
          .thenAnswer((_) async => tUserModel);

      // act
      await repository.getUserById('123');

      // assert
      verify(mockRemoteDataSource.getUserById('123')).called(1);
    });
  });

  group('createUser', () {
    const tName = 'John Doe';
    const tUsername = 'johndoe';
    const tEmail = 'john@example.com';

    test('should return UserEntity when remote data source call is successful', () async {
      // arrange
      when(mockRemoteDataSource.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => tUserModel);

      // act
      final result = await repository.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
      );

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
      verify(mockRemoteDataSource.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
      )).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenThrow(const app_exceptions.ServerException('Failed to create user'));

      // act
      final result = await repository.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
      );

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to create user');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return NetworkFailure when NetworkException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenThrow(const app_exceptions.NetworkException('No internet connection'));

      // act
      final result = await repository.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
      );

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

    test('should pass correct parameters to remote data source', () async {
      // arrange
      when(mockRemoteDataSource.createUser(
        name: anyNamed('name'),
        username: anyNamed('username'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => tUserModel);

      // act
      await repository.createUser(
        name: 'Jane Smith',
        username: 'janesmith',
        email: 'jane@example.com',
      );

      // assert
      verify(mockRemoteDataSource.createUser(
        name: 'Jane Smith',
        username: 'janesmith',
        email: 'jane@example.com',
      )).called(1);
    });
  });
}
