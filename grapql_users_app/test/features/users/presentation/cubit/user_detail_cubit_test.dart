import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/usecases/get_user_by_id.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/user_detail/user_detail_state.dart';

import 'user_detail_cubit_test.mocks.dart';

@GenerateMocks([GetUserById])
void main() {
  late UserDetailCubit cubit;
  late MockGetUserById mockGetUserById;

  setUp(() {
    mockGetUserById = MockGetUserById();
    cubit = UserDetailCubit(getUserById: mockGetUserById);
  });

  tearDown(() {
    cubit.close();
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

  const tServerFailure = ServerFailure('User not found');
  const tNetworkFailure = NetworkFailure('No internet connection');

  group('UserDetailCubit', () {
    test('initial state should be UserDetailInitial', () {
      expect(cubit.state, equals(const UserDetailInitial()));
    });

    group('loadUser', () {
      blocTest<UserDetailCubit, UserDetailState>(
        'emits [UserDetailLoading, UserDetailDisplay] when user is fetched successfully',
        build: () {
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Right(tUser),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadUser(tUserId),
        expect: () => [
          const UserDetailLoading(),
          const UserDetailDisplay(user: tUser),
        ],
        verify: (_) {
          verify(mockGetUserById(const GetUserByIdParams(id: tUserId))).called(1);
        },
      );

      blocTest<UserDetailCubit, UserDetailState>(
        'emits [UserDetailLoading, UserDetailError] when fetching user fails with server error',
        build: () {
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Left(tServerFailure),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadUser(tUserId),
        expect: () => [
          const UserDetailLoading(),
          const UserDetailError(message: 'User not found'),
        ],
      );

      blocTest<UserDetailCubit, UserDetailState>(
        'emits [UserDetailLoading, UserDetailError] when fetching user fails with network error',
        build: () {
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Left(tNetworkFailure),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadUser(tUserId),
        expect: () => [
          const UserDetailLoading(),
          const UserDetailError(message: 'No internet connection'),
        ],
      );

      blocTest<UserDetailCubit, UserDetailState>(
        'calls use case with correct user ID',
        build: () {
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Right(tUser),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadUser('123'),
        expect: () => [
          const UserDetailLoading(),
          const UserDetailDisplay(user: tUser),
        ],
        verify: (_) {
          verify(mockGetUserById(const GetUserByIdParams(id: '123'))).called(1);
        },
      );

      blocTest<UserDetailCubit, UserDetailState>(
        'can load different users sequentially',
        build: () {
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Right(tUser),
          );
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadUser('1');
          await cubit.loadUser('2');
        },
        expect: () => [
          const UserDetailLoading(),
          const UserDetailDisplay(user: tUser),
          const UserDetailLoading(),
          const UserDetailDisplay(user: tUser),
        ],
        verify: (_) {
          verify(mockGetUserById(const GetUserByIdParams(id: '1'))).called(1);
          verify(mockGetUserById(const GetUserByIdParams(id: '2'))).called(1);
        },
      );

      blocTest<UserDetailCubit, UserDetailState>(
        'handles user with minimal data (only required fields)',
        build: () {
          const minimalUser = UserEntity(
            id: '2',
            name: 'Jane Smith',
            username: 'janesmith',
            email: 'jane@example.com',
          );
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Right(minimalUser),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadUser('2'),
        expect: () => [
          const UserDetailLoading(),
          const UserDetailDisplay(
            user: UserEntity(
              id: '2',
              name: 'Jane Smith',
              username: 'janesmith',
              email: 'jane@example.com',
            ),
          ),
        ],
      );

      blocTest<UserDetailCubit, UserDetailState>(
        'handles empty user ID gracefully',
        build: () {
          when(mockGetUserById(any)).thenAnswer(
            (_) async => const Left(ServerFailure('Invalid user ID')),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadUser(''),
        expect: () => [
          const UserDetailLoading(),
          const UserDetailError(message: 'Invalid user ID'),
        ],
        verify: (_) {
          verify(mockGetUserById(const GetUserByIdParams(id: ''))).called(1);
        },
      );
    });
  });
}
