import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/repositories/user_repository.dart';
import 'package:grapql_users_app/features/users/domain/usecases/get_users.dart';

import 'get_users_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late GetUsers useCase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    useCase = GetUsers(mockUserRepository);
  });

  const tUsers = [
    UserEntity(
      id: '1',
      name: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
    ),
    UserEntity(
      id: '2',
      name: 'Jane Smith',
      username: 'janesmith',
      email: 'jane@example.com',
    ),
  ];

  const tUsersResult = UsersResult(users: tUsers, totalCount: 10);
  const tPage = 1;
  const tLimit = 5;

  group('GetUsers', () {
    test('should return UsersResult when repository call is successful', () async {
      // arrange
      when(mockUserRepository.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Right(tUsersResult));

      // act
      final result = await useCase(const GetUsersParams(
        page: tPage,
        limit: tLimit,
      ));

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (usersResult) {
          expect(usersResult.users, tUsers);
          expect(usersResult.totalCount, 10);
        },
      );
      verify(mockUserRepository.getUsers(
        page: tPage,
        limit: tLimit,
        forceRefresh: false,
      )).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should pass forceRefresh parameter to repository', () async {
      // arrange
      when(mockUserRepository.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Right(tUsersResult));

      // act
      final result = await useCase(const GetUsersParams(
        page: tPage,
        limit: tLimit,
        forceRefresh: true,
      ));

      // assert
      expect(result.isRight, true);
      verify(mockUserRepository.getUsers(
        page: tPage,
        limit: tLimit,
        forceRefresh: true,
      )).called(1);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      const tServerFailure = ServerFailure('Server error');
      when(mockUserRepository.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Left(tServerFailure));

      // act
      final result = await useCase(const GetUsersParams(
        page: tPage,
        limit: tLimit,
      ));

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
        },
        (_) => fail('Should return Left'),
      );
      verify(mockUserRepository.getUsers(
        page: tPage,
        limit: tLimit,
        forceRefresh: false,
      )).called(1);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tNetworkFailure = NetworkFailure('No internet connection');
      when(mockUserRepository.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Left(tNetworkFailure));

      // act
      final result = await useCase(const GetUsersParams(
        page: tPage,
        limit: tLimit,
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

    test('should handle different page and limit values', () async {
      // arrange
      when(mockUserRepository.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Right(tUsersResult));

      // act
      final result = await useCase(const GetUsersParams(
        page: 3,
        limit: 10,
      ));

      // assert
      expect(result.isRight, true);
      verify(mockUserRepository.getUsers(
        page: 3,
        limit: 10,
        forceRefresh: false,
      )).called(1);
    });

    test('should handle empty users list', () async {
      // arrange
      const emptyResult = UsersResult(users: [], totalCount: 0);
      when(mockUserRepository.getUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Right(emptyResult));

      // act
      final result = await useCase(const GetUsersParams(
        page: tPage,
        limit: tLimit,
      ));

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

  group('GetUsersParams', () {
    test('should have correct props for equality comparison', () {
      // arrange
      const params1 = GetUsersParams(page: 1, limit: 5, forceRefresh: false);
      const params2 = GetUsersParams(page: 1, limit: 5, forceRefresh: false);
      const params3 = GetUsersParams(page: 2, limit: 5, forceRefresh: false);
      const params4 = GetUsersParams(page: 1, limit: 5, forceRefresh: true);

      // assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
      expect(params1, isNot(equals(params4)));
    });

    test('should have default forceRefresh value of false', () {
      // arrange
      const params = GetUsersParams(page: 1, limit: 5);

      // assert
      expect(params.forceRefresh, false);
    });
  });
}
