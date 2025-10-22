import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/repositories/user_repository.dart';
import 'package:grapql_users_app/features/users/domain/usecases/get_users.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/user_list/user_list_cubit.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/user_list/user_list_state.dart';

import 'user_list_cubit_test.mocks.dart';

@GenerateMocks([GetUsers])
void main() {
  late UserListCubit cubit;
  late MockGetUsers mockGetUsers;

  setUp(() {
    mockGetUsers = MockGetUsers();
    cubit = UserListCubit(getUsersUseCase: mockGetUsers);
  });

  tearDown(() {
    cubit.close();
  });

  const tUsers = [
    UserEntity(
      id: '1',
      name: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
      phone: '1234567890',
    ),
    UserEntity(
      id: '2',
      name: 'Jane Smith',
      username: 'janesmith',
      email: 'jane@example.com',
      phone: '0987654321',
    ),
  ];

  const tUsersResult = UsersResult(users: tUsers, totalCount: 10);
  const tServerFailure = ServerFailure('Server error occurred');

  group('UserListCubit', () {
    test('initial state should be UserListInitial', () {
      expect(cubit.state, equals(UserListInitial()));
    });

    group('loadPage', () {
      blocTest<UserListCubit, UserListState>(
        'emits [UserListLoading, UserListLoaded] when data is fetched successfully',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadPage(1),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 1,
            totalPages: 2,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ],
        verify: (_) {
          verify(mockGetUsers(const GetUsersParams(
            page: 1,
            limit: 5,
            forceRefresh: false,
          ))).called(1);
        },
      );

      blocTest<UserListCubit, UserListState>(
        'emits [UserListLoading, UserListLoaded] with correct pagination for page 2',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadPage(2),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 2,
            totalPages: 2,
            hasNextPage: false,
            hasPreviousPage: true,
          ),
        ],
      );

      blocTest<UserListCubit, UserListState>(
        'emits [UserListLoading, UserListError] when fetching data fails',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Left(tServerFailure),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadPage(1),
        expect: () => [
          UserListLoading(),
          const UserListError(message: 'Server error occurred'),
        ],
      );

      blocTest<UserListCubit, UserListState>(
        'calls use case with forceRefresh=true when specified',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadPage(1, forceRefresh: true),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 1,
            totalPages: 2,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ],
        verify: (_) {
          verify(mockGetUsers(const GetUsersParams(
            page: 1,
            limit: 5,
            forceRefresh: true,
          ))).called(1);
        },
      );

      blocTest<UserListCubit, UserListState>(
        'calculates correct total pages when totalCount is not evenly divisible',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(UsersResult(users: tUsers, totalCount: 12)),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadPage(1),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 1,
            totalPages: 3,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ],
      );
    });

    group('nextPage', () {
      blocTest<UserListCubit, UserListState>(
        'loads next page when current state is UserListLoaded with hasNextPage=true',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        seed: () => const UserListLoaded(
          users: tUsers,
          currentPage: 1,
          totalPages: 2,
          hasNextPage: true,
          hasPreviousPage: false,
        ),
        act: (cubit) => cubit.nextPage(),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 2,
            totalPages: 2,
            hasNextPage: false,
            hasPreviousPage: true,
          ),
        ],
        verify: (_) {
          verify(mockGetUsers(const GetUsersParams(
            page: 2,
            limit: 5,
            forceRefresh: false,
          ))).called(1);
        },
      );

      blocTest<UserListCubit, UserListState>(
        'does not load next page when hasNextPage=false',
        build: () => cubit,
        seed: () => const UserListLoaded(
          users: tUsers,
          currentPage: 2,
          totalPages: 2,
          hasNextPage: false,
          hasPreviousPage: true,
        ),
        act: (cubit) => cubit.nextPage(),
        expect: () => [],
        verify: (_) {
          verifyNever(mockGetUsers(any));
        },
      );

      blocTest<UserListCubit, UserListState>(
        'does not load next page when state is not UserListLoaded',
        build: () => cubit,
        act: (cubit) => cubit.nextPage(),
        expect: () => [],
        verify: (_) {
          verifyNever(mockGetUsers(any));
        },
      );
    });

    group('previousPage', () {
      blocTest<UserListCubit, UserListState>(
        'loads previous page when current state is UserListLoaded with hasPreviousPage=true',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        seed: () => const UserListLoaded(
          users: tUsers,
          currentPage: 2,
          totalPages: 2,
          hasNextPage: false,
          hasPreviousPage: true,
        ),
        act: (cubit) => cubit.previousPage(),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 1,
            totalPages: 2,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ],
        verify: (_) {
          verify(mockGetUsers(const GetUsersParams(
            page: 1,
            limit: 5,
            forceRefresh: false,
          ))).called(1);
        },
      );

      blocTest<UserListCubit, UserListState>(
        'does not load previous page when hasPreviousPage=false',
        build: () => cubit,
        seed: () => const UserListLoaded(
          users: tUsers,
          currentPage: 1,
          totalPages: 2,
          hasNextPage: true,
          hasPreviousPage: false,
        ),
        act: (cubit) => cubit.previousPage(),
        expect: () => [],
        verify: (_) {
          verifyNever(mockGetUsers(any));
        },
      );
    });

    group('goToPage', () {
      blocTest<UserListCubit, UserListState>(
        'loads specified page when page number is valid',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        act: (cubit) => cubit.goToPage(3),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 3,
            totalPages: 2,
            hasNextPage: false,
            hasPreviousPage: true,
          ),
        ],
        verify: (_) {
          verify(mockGetUsers(const GetUsersParams(
            page: 3,
            limit: 5,
            forceRefresh: false,
          ))).called(1);
        },
      );

      blocTest<UserListCubit, UserListState>(
        'does not load page when page number is less than 1',
        build: () => cubit,
        act: (cubit) => cubit.goToPage(0),
        expect: () => [],
        verify: (_) {
          verifyNever(mockGetUsers(any));
        },
      );
    });

    group('refreshUsers', () {
      blocTest<UserListCubit, UserListState>(
        'loads page 1 with forceRefresh=true',
        build: () {
          when(mockGetUsers(any)).thenAnswer(
            (_) async => const Right(tUsersResult),
          );
          return cubit;
        },
        act: (cubit) => cubit.refreshUsers(),
        expect: () => [
          UserListLoading(),
          const UserListLoaded(
            users: tUsers,
            currentPage: 1,
            totalPages: 2,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ],
        verify: (_) {
          verify(mockGetUsers(const GetUsersParams(
            page: 1,
            limit: 5,
            forceRefresh: true,
          ))).called(1);
        },
      );
    });
  });
}
