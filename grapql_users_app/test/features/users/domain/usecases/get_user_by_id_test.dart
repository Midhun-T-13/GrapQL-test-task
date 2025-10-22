import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/usecases/get_user_by_id.dart';

import 'get_users_test.mocks.dart';

void main() {
  late GetUserById useCase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    useCase = GetUserById(mockUserRepository);
  });

  const tUserId = '1';
  const tUser = UserEntity(
    id: tUserId,
    name: 'John Doe',
    username: 'johndoe',
    email: 'john@example.com',
    phone: '1234567890',
    website: 'johndoe.com',
    companyName: 'Doe Inc.',
    street: '123 Main St',
    suite: 'Apt 4',
    city: 'New York',
    zipcode: '10001',
  );

  group('GetUserById', () {
    test('should return UserEntity when repository call is successful', () async {
      // arrange
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Right(tUser));

      // act
      final result = await useCase(const GetUserByIdParams(id: tUserId));

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user.id, tUserId);
          expect(user.name, 'John Doe');
          expect(user.email, 'john@example.com');
        },
      );
      verify(mockUserRepository.getUserById(tUserId)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return ServerFailure when user is not found', () async {
      // arrange
      const tServerFailure = ServerFailure('User not found');
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Left(tServerFailure));

      // act
      final result = await useCase(const GetUserByIdParams(id: tUserId));

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'User not found');
        },
        (_) => fail('Should return Left'),
      );
      verify(mockUserRepository.getUserById(tUserId)).called(1);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tNetworkFailure = NetworkFailure('No internet connection');
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Left(tNetworkFailure));

      // act
      final result = await useCase(const GetUserByIdParams(id: tUserId));

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

    test('should pass correct user ID to repository', () async {
      // arrange
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Right(tUser));

      // act
      await useCase(const GetUserByIdParams(id: '123'));

      // assert
      verify(mockUserRepository.getUserById('123')).called(1);
    });

    test('should return user with complete information', () async {
      // arrange
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Right(tUser));

      // act
      final result = await useCase(const GetUserByIdParams(id: tUserId));

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user.id, tUserId);
          expect(user.name, 'John Doe');
          expect(user.username, 'johndoe');
          expect(user.email, 'john@example.com');
          expect(user.phone, '1234567890');
          expect(user.website, 'johndoe.com');
          expect(user.companyName, 'Doe Inc.');
          expect(user.street, '123 Main St');
          expect(user.suite, 'Apt 4');
          expect(user.city, 'New York');
          expect(user.zipcode, '10001');
        },
      );
    });

    test('should return user with only required fields', () async {
      // arrange
      const minimalUser = UserEntity(
        id: '2',
        name: 'Jane Smith',
        username: 'janesmith',
        email: 'jane@example.com',
      );
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Right(minimalUser));

      // act
      final result = await useCase(const GetUserByIdParams(id: '2'));

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user.id, '2');
          expect(user.name, 'Jane Smith');
          expect(user.username, 'janesmith');
          expect(user.email, 'jane@example.com');
          expect(user.phone, null);
          expect(user.website, null);
          expect(user.companyName, null);
        },
      );
    });

    test('should handle empty user ID', () async {
      // arrange
      const tServerFailure = ServerFailure('Invalid user ID');
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Left(tServerFailure));

      // act
      final result = await useCase(const GetUserByIdParams(id: ''));

      // assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Invalid user ID');
        },
        (_) => fail('Should return Left'),
      );
      verify(mockUserRepository.getUserById('')).called(1);
    });

    test('should handle multiple consecutive calls', () async {
      // arrange
      when(mockUserRepository.getUserById(any))
          .thenAnswer((_) async => const Right(tUser));

      // act
      await useCase(const GetUserByIdParams(id: '1'));
      await useCase(const GetUserByIdParams(id: '2'));
      await useCase(const GetUserByIdParams(id: '3'));

      // assert
      verify(mockUserRepository.getUserById('1')).called(1);
      verify(mockUserRepository.getUserById('2')).called(1);
      verify(mockUserRepository.getUserById('3')).called(1);
    });
  });

  group('GetUserByIdParams', () {
    test('should contain correct user ID', () {
      // arrange
      const params = GetUserByIdParams(id: tUserId);

      // assert
      expect(params.id, tUserId);
    });

    test('should handle different user IDs', () {
      // arrange
      const params1 = GetUserByIdParams(id: '1');
      const params2 = GetUserByIdParams(id: '999');
      const params3 = GetUserByIdParams(id: 'abc');

      // assert
      expect(params1.id, '1');
      expect(params2.id, '999');
      expect(params3.id, 'abc');
    });
  });
}
