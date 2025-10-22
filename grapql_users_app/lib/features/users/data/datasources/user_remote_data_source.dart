import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../models/user_model.dart';

class UsersResponse {
  final List<UserModel> users;
  final int totalCount;

  const UsersResponse({
    required this.users,
    required this.totalCount,
  });
}

abstract class UserRemoteDataSource {
  Future<UsersResponse> getUsers({
    required int page,
    required int limit,
    bool forceRefresh = false,
  });

  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser({
    required String name,
    required String username,
    required String email,
  });



}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final GraphQLClient client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<UsersResponse> getUsers({
    required int page,
    required int limit,
    bool forceRefresh = false,
  }) async {
    const String getUsersQuery = r'''
      query GetUsers($page: Int!, $limit: Int!) {
        users(options: { paginate: { page: $page, limit: $limit } }) {
          data {
            id
            name
            username
            email
            phone
          }
          meta {
            totalCount
          }
        }
      }
    ''';

    try {
      final QueryOptions options = QueryOptions(
        document: gql(getUsersQuery),
        variables: {
          'page': page,
          'limit': limit,
        },
        fetchPolicy: forceRefresh? FetchPolicy.networkOnly : FetchPolicy.cacheAndNetwork,

      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        final exception = result.exception;

        // Check for network/link errors (offline, timeout, etc.)
        if (exception?.linkException != null) {
          throw const app_exceptions.NetworkException(
            'No internet connection. Please check your network and try again.',
          );
        }

        // Check for GraphQL errors
        if (exception?.graphqlErrors != null && exception!.graphqlErrors.isNotEmpty) {
          throw app_exceptions.ServerException(
            exception.graphqlErrors.first.message,
          );
        }

        // Default error
        throw const app_exceptions.ServerException(
          'Failed to fetch users. Please try again.',
        );
      }

      final List<dynamic> usersData = result.data?['users']['data'] ?? [];
      final int totalCount = result.data?['users']['meta']?['totalCount'] ?? 0;

      final users = usersData.map((user) => UserModel.fromJson(user)).toList();

      return UsersResponse(
        users: users,
        totalCount: totalCount,
      );
    } on app_exceptions.NetworkException {
      rethrow;
    } on app_exceptions.ServerException {
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network') ||
          e.toString().contains('connection')) {
        throw const app_exceptions.NetworkException(
          'No internet connection. Please check your network and try again.',
        );
      }
      throw app_exceptions.ServerException(
        'Something went wrong. Please try again later.',
      );
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    const String getUserQuery = r'''
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          name
          username
          email
          phone
          website
          address {
            street
            suite
            city
            zipcode
          }
          company {
            name
          }
        }
      }
    ''';

    try {
      final QueryOptions options = QueryOptions(
        document: gql(getUserQuery),
        variables: {
          'id': id,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        final exception = result.exception;

        // Check for network/link errors (offline, timeout, etc.)
        if (exception?.linkException != null) {
          throw const app_exceptions.NetworkException(
            'No internet connection. Please check your network and try again.',
          );
        }

        // Check for GraphQL errors
        if (exception?.graphqlErrors != null && exception!.graphqlErrors.isNotEmpty) {
          throw app_exceptions.ServerException(
            exception.graphqlErrors.first.message,
          );
        }

        // Default error
        throw const app_exceptions.ServerException(
          'Failed to fetch user details. Please try again.',
        );
      }

      final userData = result.data?['user'];
      if (userData == null) {
        throw const app_exceptions.ServerException('User not found');
      }

      return UserModel.fromJson(userData);
    } on app_exceptions.NetworkException {
      rethrow;
    } on app_exceptions.ServerException {
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network') ||
          e.toString().contains('connection')) {
        throw const app_exceptions.NetworkException(
          'No internet connection. Please check your network and try again.',
        );
      }
      throw app_exceptions.ServerException(
        'Something went wrong. Please try again later.',
      );
    }
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String username,
    required String email,
  }) async {
    const String createUserMutation = r'''
      mutation CreateUser($name: String!, $username: String!, $email: String!) {
        createUser(input: { name: $name, username: $username, email: $email }) {
          id
          name
          username
          email
        }
      }
    ''';

    try {
      final MutationOptions options = MutationOptions(
        document: gql(createUserMutation),
        variables: {
          'name': name,
          'username': username,
          'email': email,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        final exception = result.exception;

        // Check for network/link errors (offline, timeout, etc.)
        if (exception?.linkException != null) {
          throw const app_exceptions.NetworkException(
            'No internet connection. Please check your network and try again.',
          );
        }

        // Check for GraphQL errors
        if (exception?.graphqlErrors != null && exception!.graphqlErrors.isNotEmpty) {
          throw app_exceptions.ServerException(
            exception.graphqlErrors.first.message,
          );
        }

        // Default error
        throw const app_exceptions.ServerException(
          'Failed to create user. Please try again.',
        );
      }

      final userData = result.data?['createUser'];
      if (userData == null) {
        throw const app_exceptions.ServerException(
          'Unable to create user. Please try again.',
        );
      }

      return UserModel.fromJson(userData);
    } on app_exceptions.NetworkException {
      rethrow;
    } on app_exceptions.ServerException {
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network') ||
          e.toString().contains('connection')) {
        throw const app_exceptions.NetworkException(
          'No internet connection. Please check your network and try again.',
        );
      }
      throw app_exceptions.ServerException(
        'Something went wrong. Please try again later.',
      );
    }
  }

}
