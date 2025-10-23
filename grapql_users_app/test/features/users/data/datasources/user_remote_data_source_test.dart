import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:grapql_users_app/core/error/exceptions.dart' as app_exceptions;
import 'package:grapql_users_app/features/users/data/datasources/user_remote_data_source.dart';
import 'package:grapql_users_app/features/users/data/models/user_model.dart';

import 'user_remote_data_source_test.mocks.dart';

@GenerateMocks([GraphQLClient])
void main() {
  late UserRemoteDataSourceImpl dataSource;
  late MockGraphQLClient mockGraphQLClient;

  setUp(() {
    mockGraphQLClient = MockGraphQLClient();
    dataSource = UserRemoteDataSourceImpl(client: mockGraphQLClient);
  });

  group('getUsers', () {
    const tPage = 1;
    const tLimit = 5;

    final tUsersData = [
      {
        'id': '1',
        'name': 'John Doe',
        'username': 'johndoe',
        'email': 'john@example.com',
        'phone': '1234567890',
        'website': 'johndoe.com',
        'company': {'name': 'Doe Inc.'},
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'username': 'janesmith',
        'email': 'jane@example.com',
        'phone': '0987654321',
        'website': 'janesmith.com',
        'company': {'name': 'Smith Corp.'},
      },
    ];

    final tSuccessResult = QueryResult(
      source: QueryResultSource.network,
      data: {
        'users': {
          'data': tUsersData,
          'meta': {'totalCount': 10},
        },
      },
      options: QueryOptions(document: gql('')),
    );

    test('should return UsersResponse when GraphQL query is successful', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      final result = await dataSource.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.users, isA<List<UserModel>>());
      expect(result.users.length, 2);
      expect(result.totalCount, 10);
      expect(result.users[0].id, '1');
      expect(result.users[0].name, 'John Doe');
      expect(result.users[0].email, 'john@example.com');
      verify(mockGraphQLClient.query(any)).called(1);
    });

    test('should use cacheAndNetwork policy when forceRefresh is false', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      await dataSource.getUsers(page: tPage, limit: tLimit, forceRefresh: false);

      // assert
      final captured = verify(mockGraphQLClient.query(captureAny)).captured;
      final options = captured[0] as QueryOptions;
      expect(options.fetchPolicy, FetchPolicy.cacheAndNetwork);
    });

    test('should use networkOnly policy when forceRefresh is true', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      await dataSource.getUsers(page: tPage, limit: tLimit, forceRefresh: true);

      // assert
      final captured = verify(mockGraphQLClient.query(captureAny)).captured;
      final options = captured[0] as QueryOptions;
      expect(options.fetchPolicy, FetchPolicy.networkOnly);
    });

    test('should throw ServerException when GraphQL query has error', () async {
      // arrange
      final errorResult = QueryResult(
        source: QueryResultSource.network,
        options: QueryOptions(document: gql('')),
        exception: OperationException(
          graphqlErrors: [
            GraphQLError(message: 'Failed to fetch users'),
          ],
        ),
      );
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => errorResult);

      // act & assert
      expect(
        () => dataSource.getUsers(page: tPage, limit: tLimit),
        throwsA(isA<app_exceptions.ServerException>().having(
          (e) => e.message,
          'message',
          'Failed to fetch users',
        )),
      );
    });

    test('should handle null data gracefully', () async {
      // arrange
      final nullDataResult = QueryResult(
        source: QueryResultSource.network,
        data: null,
        options: QueryOptions(document: gql('')),
      );
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => nullDataResult);

      // act
      final result = await dataSource.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.users, isEmpty);
      expect(result.totalCount, 0);
    });

    test('should handle empty users list', () async {
      // arrange
      final emptyResult = QueryResult(
        source: QueryResultSource.network,
        data: {
          'users': {
            'data': [],
            'meta': {'totalCount': 0},
          },
        },
        options: QueryOptions(document: gql('')),
      );
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => emptyResult);

      // act
      final result = await dataSource.getUsers(page: tPage, limit: tLimit);

      // assert
      expect(result.users, isEmpty);
      expect(result.totalCount, 0);
    });

    test('should pass correct variables to GraphQL query', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      await dataSource.getUsers(page: 3, limit: 10);

      // assert
      final captured = verify(mockGraphQLClient.query(captureAny)).captured;
      final options = captured[0] as QueryOptions;
      expect(options.variables['page'], 3);
      expect(options.variables['limit'], 10);
    });
  });

  group('getUserById', () {
    const tUserId = '1';

    final tUserData = {
      'id': '1',
      'name': 'John Doe',
      'username': 'johndoe',
      'email': 'john@example.com',
      'phone': '1234567890',
      'website': 'johndoe.com',
      'address': {
        'street': '123 Main St',
        'suite': 'Apt 4',
        'city': 'New York',
        'zipcode': '10001',
      },
      'company': {'name': 'Doe Inc.'},
    };

    final tSuccessResult = QueryResult(
      source: QueryResultSource.network,
      data: {'user': tUserData},
      options: QueryOptions(document: gql('')),
    );

    test('should return UserModel when GraphQL query is successful', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      final result = await dataSource.getUserById(tUserId);

      // assert
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      expect(result.name, 'John Doe');
      expect(result.email, 'john@example.com');
      expect(result.phone, '1234567890');
      expect(result.street, '123 Main St');
      expect(result.companyName, 'Doe Inc.');
      verify(mockGraphQLClient.query(any)).called(1);
    });

    test('should throw ServerException when GraphQL query has error', () async {
      // arrange
      final errorResult = QueryResult(
        source: QueryResultSource.network,
        options: QueryOptions(document: gql('')),
        exception: OperationException(
          graphqlErrors: [
            GraphQLError(message: 'User not found'),
          ],
        ),
      );
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => errorResult);

      // act & assert
      expect(
        () => dataSource.getUserById(tUserId),
        throwsA(isA<app_exceptions.ServerException>().having(
          (e) => e.message,
          'message',
          'User not found',
        )),
      );
    });

    test('should throw ServerException when user data is null', () async {
      // arrange
      final nullUserResult = QueryResult(
        source: QueryResultSource.network,
        data: {'user': null},
        options: QueryOptions(document: gql('')),
      );
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => nullUserResult);

      // act & assert
      expect(
        () => dataSource.getUserById(tUserId),
        throwsA(isA<app_exceptions.ServerException>().having(
          (e) => e.message,
          'message',
          'User not found',
        )),
      );
    });

    test('should pass correct user ID to GraphQL query', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      await dataSource.getUserById('123');

      // assert
      final captured = verify(mockGraphQLClient.query(captureAny)).captured;
      final options = captured[0] as QueryOptions;
      expect(options.variables['id'], '123');
    });

    test('should use cacheAndNetwork fetch policy', () async {
      // arrange
      when(mockGraphQLClient.query(any)).thenAnswer((_) async => tSuccessResult);

      // act
      await dataSource.getUserById(tUserId);

      // assert
      final captured = verify(mockGraphQLClient.query(captureAny)).captured;
      final options = captured[0] as QueryOptions;
      expect(options.fetchPolicy, FetchPolicy.cacheAndNetwork);
    });
  });

  group('createUser', () {
    const tName = 'John Doe';
    const tUsername = 'johndoe';
    const tEmail = 'john@example.com';
    const tPhone = '1234567890';


    final tUserData = {
      'id': '1',
      'name': tName,
      'username': tUsername,
      'email': tEmail,
    };

    final tSuccessResult = QueryResult(
      source: QueryResultSource.network,
      data: {'createUser': tUserData},
      options: QueryOptions(document: gql('')),
    );

    test('should return UserModel when GraphQL mutation is successful', () async {
      // arrange
      when(mockGraphQLClient.mutate(any)).thenAnswer((_) async => tSuccessResult);

      // act
      final result = await dataSource.createUser(
        name: tName,
        username: tUsername,
        email: tEmail,
        phone: tPhone
      );

      // assert
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      expect(result.name, tName);
      expect(result.username, tUsername);
      expect(result.email, tEmail);
      verify(mockGraphQLClient.mutate(any)).called(1);
    });

    test('should throw ServerException when GraphQL mutation has error', () async {
      // arrange
      final errorResult = QueryResult(
        source: QueryResultSource.network,
        options: QueryOptions(document: gql('')),
        exception: OperationException(
          graphqlErrors: [
            GraphQLError(message: 'Failed to create user'),
          ],
        ),
      );
      when(mockGraphQLClient.mutate(any)).thenAnswer((_) async => errorResult);

      // act & assert
      expect(
        () => dataSource.createUser(
          name: tName,
          username: tUsername,
          email: tEmail,
          phone: tPhone
        ),
        throwsA(isA<app_exceptions.ServerException>().having(
          (e) => e.message,
          'message',
          'Failed to create user',
        )),
      );
    });

    test('should throw ServerException when mutation returns no data', () async {
      // arrange
      final nullDataResult = QueryResult(
        source: QueryResultSource.network,
        data: {'createUser': null},
        options: QueryOptions(document: gql('')),
      );
      when(mockGraphQLClient.mutate(any)).thenAnswer((_) async => nullDataResult);

      // act & assert
      expect(
        () => dataSource.createUser(
          name: tName,
          username: tUsername,
          email: tEmail,
          phone: tPhone
        ),
        throwsA(isA<app_exceptions.ServerException>().having(
          (e) => e.message,
          'message',
          'No data returned from mutation',
        )),
      );
    });

    test('should pass correct parameters to GraphQL mutation', () async {
      // arrange
      when(mockGraphQLClient.mutate(any)).thenAnswer((_) async => tSuccessResult);

      // act
      await dataSource.createUser(
        name: 'Jane Smith',
        username: 'janesmith',
        email: 'jane@example.com',
        phone: '1234567890'
      );

      // assert
      final captured = verify(mockGraphQLClient.mutate(captureAny)).captured;
      final options = captured[0] as MutationOptions;
      expect(options.variables['name'], 'Jane Smith');
      expect(options.variables['username'], 'janesmith');
      expect(options.variables['email'], 'jane@example.com');
    });

    test('should handle generic exception', () async {
      // arrange
      when(mockGraphQLClient.mutate(any)).thenThrow(Exception('Network error'));

      // act & assert
      expect(
        () => dataSource.createUser(
          name: tName,
          username: tUsername,
          email: tEmail,
          phone: tPhone
        ),
        throwsA(isA<app_exceptions.ServerException>()),
      );
    });
  });
}
