import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:grapql_users_app/core/error/failures.dart';
import 'package:grapql_users_app/core/network/either.dart';
import 'package:grapql_users_app/features/users/domain/entities/user_entity.dart';
import 'package:grapql_users_app/features/users/domain/usecases/create_user.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/add_user/add_user_cubit.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/add_user/add_user_state.dart';

import 'add_user_cubit_test.mocks.dart';

@GenerateMocks([CreateUser])
void main() {
  late AddUserCubit cubit;
  late MockCreateUser mockCreateUser;

  setUp(() {
    mockCreateUser = MockCreateUser();
    cubit = AddUserCubit(createUserUseCase: mockCreateUser);
  });

  tearDown(() {
    cubit.close();
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

  const tServerFailure = ServerFailure('Failed to create user');
  const tValidationFailure = ValidationFailure('Invalid email format');

  group('AddUserCubit', () {
    test('initial state should be AddUserInitial', () {
      expect(cubit.state, equals(AddUserInitial()));
    });

    group('createUser', () {
      blocTest<AddUserCubit, AddUserState>(
        'emits [AddUserLoading, AddUserSuccess] when user is created successfully',
        build: () {
          when(mockCreateUser(any)).thenAnswer(
            (_) async => const Right(tUser),
          );
          return cubit;
        },
        act: (cubit) => cubit.createUser(
          name: tName,
          username: tUsername,
          email: tEmail,
        ),
        expect: () => [
          AddUserLoading(),
          const AddUserSuccess(user: tUser),
        ],
        verify: (_) {
          verify(mockCreateUser(const CreateUserParams(
            name: tName,
            username: tUsername,
            email: tEmail,
          ))).called(1);
        },
      );

      blocTest<AddUserCubit, AddUserState>(
        'emits [AddUserLoading, AddUserError] when creation fails with server error',
        build: () {
          when(mockCreateUser(any)).thenAnswer(
            (_) async => const Left(tServerFailure),
          );
          return cubit;
        },
        act: (cubit) => cubit.createUser(
          name: tName,
          username: tUsername,
          email: tEmail,
        ),
        expect: () => [
          AddUserLoading(),
          const AddUserError(message: 'Failed to create user'),
        ],
      );

      blocTest<AddUserCubit, AddUserState>(
        'emits [AddUserLoading, AddUserError] when creation fails with validation error',
        build: () {
          when(mockCreateUser(any)).thenAnswer(
            (_) async => const Left(tValidationFailure),
          );
          return cubit;
        },
        act: (cubit) => cubit.createUser(
          name: tName,
          username: tUsername,
          email: 'invalid-email',
        ),
        expect: () => [
          AddUserLoading(),
          const AddUserError(message: 'Invalid email format'),
        ],
      );

      blocTest<AddUserCubit, AddUserState>(
        'calls use case with correct parameters',
        build: () {
          when(mockCreateUser(any)).thenAnswer(
            (_) async => const Right(tUser),
          );
          return cubit;
        },
        act: (cubit) => cubit.createUser(
          name: 'Jane Smith',
          username: 'janesmith',
          email: 'jane@example.com',
        ),
        expect: () => [
          AddUserLoading(),
          const AddUserSuccess(
            user: UserEntity(
              id: '1',
              name: tName,
              username: tUsername,
              email: tEmail,
            ),
          ),
        ],
        verify: (_) {
          verify(mockCreateUser(const CreateUserParams(
            name: 'Jane Smith',
            username: 'janesmith',
            email: 'jane@example.com',
          ))).called(1);
        },
      );

      blocTest<AddUserCubit, AddUserState>(
        'can create multiple users sequentially',
        build: () {
          when(mockCreateUser(any)).thenAnswer(
            (_) async => const Right(tUser),
          );
          return cubit;
        },
        act: (cubit) async {
          await cubit.createUser(
            name: tName,
            username: tUsername,
            email: tEmail,
          );
          await cubit.createUser(
            name: 'Jane Smith',
            username: 'janesmith',
            email: 'jane@example.com',
          );
        },
        expect: () => [
          AddUserLoading(),
          const AddUserSuccess(user: tUser),
          AddUserLoading(),
          const AddUserSuccess(user: tUser),
        ],
        verify: (_) {
          verify(mockCreateUser(any)).called(2);
        },
      );
    });
  });
}
